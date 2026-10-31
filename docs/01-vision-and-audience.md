# 01 — Vision and audience

## One-liner

A fast, good-looking, mobile-friendly live map for ADS-B data that **drops in
next to an existing readsb/tar1090 install**, and optionally adds route and
flight info.

## Will enthusiasts actually use a new frontend?

Some will, under conditions. tar1090 is the de facto standard. It powers
ADSBexchange, adsb.lol, airplanes.live, adsb.fi and most home feeders (via
adsb.im, sdr-enthusiasts `ultrafeeder`, piaware + tar1090 installs). Its users
are loyal for good reasons:

- **Info density.** A sortable table, many columns, every field readsb decodes.
- **Speed.** It handles 10k+ aircraft on the global view and runs off a Pi.
- **Keyboard workflow.** Power users depend on its shortcuts and URL parameters.
- **Zero setup.** It is already installed and already reads local data.
- **History and replay** via globe_history traces.

"Prettier" alone will not get them to switch. Feeders already have a working
map, so a new one has to be *strictly better* at something they care about,
and no worse at the things above.

### Where tar1090 is weak (our opening)

| Gap | Why it matters |
| --- | --- |
| Raster/OpenLayers look, dated UI | Vector basemaps, dark styles and globe view look far better and are smaller |
| Poor mobile UX | Many people check "what's flying over me" on a phone |
| No route/flight info (beyond optional VRS routes) | The #1 reason casual users open FR24 instead |
| Search and discovery | No command palette, weak airport/airline browsing |
| Little feeder-centric insight | Range polar plots, message rate, "what did I catch today" live in separate tools (graphs1090) |
| Sharing | No nice share cards or embeds |

### Audience segments (in priority order)

1. **Home feeders** (Pi + SDR, run readsb/dump1090-fa). They are reachable through
   adsb.im, sdr-enthusiasts Discord, r/ADSB and r/RTLSDR. They want their own
   station's data, presented better. **Primary target.**
2. **Aggregator operators** (adsb.lol, airplanes.live, adsb.fi, community
   regional aggregators). They are open-source friendly and might offer an
   alternative UI if it is fast and self-hostable. This is a multiplier: one
   adoption reaches thousands of users.
3. **Casual plane-spotters / "what's overhead" users.** They are attracted by
   route info and mobile UX, but they won't run a receiver. They are reached
   only through segment 2 or a public hosted instance.

### Verdict

The niche is real but small. The way to win adoption:

- Ship it as a **companion to tar1090, not a replacement**. It installs into the
  same web server and reads the same `/data/aircraft.json` or binCraft files.
  Users can try it in 30 seconds and keep tar1090.
- **Match its density.** Include a power table view and keyboard shortcuts, and
  support tar1090-compatible URL params (`?icao=`, `?lat=&lon=&zoom=`) where
  cheap.
- **Beat it on mobile, visuals, search, and route info.**
- **Go open source** (GPL or MIT). The community distrusts closed and commercial
  trackers, after ADSBexchange's 2023 sale to JETNET.

## Non-goals (for now)

- Feeding or decoding (readsb does that).
- Running a global aggregator.
- Scraping FR24 or FlightAware (it violates their ToS, and the community
  frowns on it).
- Native apps (a PWA is good enough).

## Name

The working title is "yet-another-adsb". It's fine for the repo. Pick a short
brandable name before public launch.
