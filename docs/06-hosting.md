# 06 — Hosting the demo

The public demo runs on a dev machine: **Cloudflare Tunnel → Caddy → static
files plus a systemd poller**. No ports are opened on the machine, and
Cloudflare handles TLS.

```
browser ──https──▶ Cloudflare ──tunnel──▶ cloudflared ──http──▶ Caddy :80
                                                                 ├─ /        /srv/http/yaa/   (vite build)
                                                                 └─ /data/*  /run/yaa/        (yaa-poller.service)
yaa-poller.service ──every 2 s──▶ api.adsb.lol/v2/point/<lat>/<lon>/250
```

## Why a poller instead of proxying adsb.lol

- `api.adsb.lol/v2/*` sends no CORS header (checked 2026-11-01), so the
  browser can't call it from another origin.
- A plain reverse proxy would send one upstream request per viewer per
  second, all from our IP. The poller sends **one request every 2 s no matter
  how many viewers there are**, which keeps us within fair use.
- The poller rewrites the v2 response into readsb `aircraft.json` shape
  (`now` in seconds, `ac` → `aircraft`). The app reads `/data/aircraft.json`
  with the same code as on a home feeder, and the demo needs no special source.
- The output goes to tmpfs (`/run/yaa`), so there are no disk writes.

Routes (`POST api.adsb.lol/api/0/routeset`) send `CORS *` and are called from
the browser directly.

The cost of this design is a fixed region (250 nm max per query). That's
acceptable for a demo, and `04-ux-design` already plans to limit it.

## Files

| File | Installed to |
| --- | --- |
| [`deploy/yaa.caddyfile`](../deploy/yaa.caddyfile) | `/etc/caddy/Caddyfile.d/yaa.legner.me.caddyfile` |
| [`deploy/yaa-poller.service`](../deploy/yaa-poller.service) | `/etc/systemd/system/yaa-poller.service` |
| [`deploy/yaa-poller.sh`](../deploy/yaa-poller.sh) | `/usr/local/lib/yaa/yaa-poller.sh` |
| [`deploy/poller.env.example`](../deploy/poller.env.example) | `/etc/yaa/poller.env` |
| `dist/` (from `pnpm build`) | `/srv/http/yaa/` |

The hostname `yaa.legner.me` is a placeholder; pick the real one.

## Setup (one-time)

```sh
sudo install -Dm755 deploy/yaa-poller.sh /usr/local/lib/yaa/yaa-poller.sh
sudo install -Dm644 deploy/yaa-poller.service /etc/systemd/system/yaa-poller.service
sudo install -Dm644 deploy/poller.env.example /etc/yaa/poller.env   # then edit
sudo install -Dm644 deploy/yaa.caddyfile /etc/caddy/Caddyfile.d/yaa.legner.me.caddyfile
sudo install -d /srv/http/yaa
sudo systemctl daemon-reload
sudo systemctl enable --now yaa-poller.service
sudo caddy validate --config /etc/caddy/Caddyfile && sudo systemctl enable --now caddy
```

The poller needs `curl` and `jq` on the host.

**Cloudflare** (Zero Trust → Networks → Tunnels → existing tunnel → Public
hostnames): add `yaa.<domain>` → `HTTP` → `localhost:80`. Caddy picks the
site block by Host header.

While the demo is not public yet, put a **Cloudflare Access** policy (email
OTP) on the hostname. That's better than `basicauth` in Caddy because the
traffic never reaches the machine.

## Deploy

```sh
pnpm build && rsync -a --delete dist/ /srv/http/yaa/
```

Vite emits hashed files under `assets/`, so they are cached as immutable.
`index.html` and `/data/*` are not cached. Cloudflare doesn't cache JSON by
default, so no cache rule is needed.

## Caveats on this machine (checked 2026-11-01)

- `caddy.service` is currently **disabled**. Enabling it also activates every
  existing file in `/etc/caddy/Caddyfile.d/`, and sites without `http://`
  (e.g. `bitwarden.legner.me`, `cloud.legner.me`) will try ACME on :443.
  Review or move those files first.
- `cloudflared.service` is token-based (dashboard-managed), so ingress rules
  are edited in the dashboard, not in a local config file.
- Load: one poll is about 110 kB of JSON at 250 nm (about 15–20 kB after zstd),
  so each viewer uses about 10 kB/s. That's negligible for a demo.

## Later

- **Home feeder mode on the same box:** swap the `/data/*` handler for the
  commented `reverse_proxy` to the feeder. Don't expose a home station's exact
  location publicly without thinking about it.
- **Wider coverage:** several pollers, or adsb.lol globe tiles, if the
  companion backend from `03-architecture` is ever built.
