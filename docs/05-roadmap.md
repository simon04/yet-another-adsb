# 05 — Roadmap

## Phase 0 — Spikes (de-risk, ~1–2 weeks)

- [ ] MapLibre v5 with a custom dark style on OpenFreeMap, and a PMTiles variant.
- [ ] Render 10k synthetic aircraft: compare a symbol layer, deck.gl IconLayer
      and a custom WebGL layer. Measure fps on a laptop and a phone.
- [ ] Read a real local `aircraft.json` (from a readsb box or a recorded
      sample) and interpolate.
- [ ] Port the binCraft decoder from tar1090 and verify it against the JSON
      output.
- [ ] `POST api.adsb.lol/api/0/routeset` from the browser (CORS) and measure
      the hit rate and plausibility for local traffic.

**Exit criterion:** pick a rendering approach and confirm the perf budget is
achievable.

## Phase 1 — MVP for home feeders

- [ ] Local readsb JSON source with interpolation and trails.
- [ ] Aircraft detail panel (live data, tar1090-db metadata, photo).
- [ ] Command palette search and filters (altitude, military, emergency).
- [ ] Table view (virtualized, sortable).
- [ ] URL state, keyboard shortcuts, dark and light themes, responsive layout
      with a mobile bottom sheet.
- [ ] Install script (lighttpd alias) and Docker image.

**tar1090 parity checklist** (minimum before announcing): table, labels,
trails, filters, select via URL, MLAT indication, receiver range rings, and
behaviour that matches tar1090 on stale data.

## Phase 2 — Enrichment

- [ ] Routes via adsb.lol routeset or bundled VRS standing data, with
      plausibility checks.
- [ ] Derived flight number, route bar and ETA.
- [ ] Derived origin from takeoff detection.
- [ ] Phase-of-flight detection.
- [ ] Feeder dashboard (range polar plot, stats).
- [ ] PWA install and share links with an OG image.

## Phase 3 — Aggregator and history

- [ ] v2 API source (adsb.lol, airplanes.live, adsb.fi) with viewport queries
      and rate-limit handling.
- [ ] binCraft globe tiles for global view (for aggregator operators who
      self-host).
- [ ] Trace and history replay with a timeline scrubber.
- [ ] Optional companion backend: WebSocket push, history DB, key proxy.

## Phase 4 — Nice to have

- [ ] Dispatch plugins (FR24 API, AeroAPI, AeroDataBox) using the user's own
      key.
- [ ] Watchlists and push alerts (registration, type, squawk 7700, military
      near me).
- [ ] 3D view (altitude-extruded trails, terrain).
- [ ] Airport view (arrivals and departures inferred from local traffic).
- [ ] Embeddable widget.

## Validation (do early)

- Before Phase 1 ends, post screenshots and a demo to r/ADSB, the
  sdr-enthusiasts Discord and the adsb.lol community. Ask "would you install
  this next to tar1090? What is missing?"
- Track installs (opt-in ping or GitHub release downloads) and issues. Act on
  the first 20 users' feedback before adding features.
- Talk to one aggregator operator (adsb.lol is the most open) about hosting it
  as an alternative UI.

## Open questions

1. **License:** GPL-3.0, to match tar1090 and readsb and to signal community
   alignment, or MIT for wider reuse?
2. **Framework:** React plus shadcn (recommended) or Svelte 5?
3. **Hosted public instance:** yes, against adsb.lol? This needs rate-limit
   friendliness and attribution (ODbL).
4. **Scope of the backend:** stay strictly static for v1 (recommended)?
5. **Paid dispatch data:** is BYO-key personal use acceptable under the FR24
   and FlightAware ToS? Read the ToS before Phase 4.
