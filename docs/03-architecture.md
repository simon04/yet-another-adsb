# 03 — Architecture

## Principles

1. **Static-first.** The core app is a static bundle that runs from any web
   server next to readsb, with no backend required.
2. **The data source is a plugin.** Local readsb JSON, readsb binCraft, aggregator
   v2 APIs and replay all sit behind one interface.
3. **Aircraft never touch the framework's reactivity.** Thousands of moving
   objects live in typed arrays in a worker and are drawn by the GPU. UI
   components only subscribe to the *selected* aircraft and aggregates.
4. **Performance budget.** 10k aircraft at 60 fps on a mid-range laptop, and 2k
   at 60 fps on a mid-range phone. The initial JS payload is under 300 kB gzip,
   excluding map tiles.

## Stack (recommendation)

| Concern | Choice | Why |
| --- | --- | --- |
| Language/build | TypeScript, Vite | Standard |
| Map | **MapLibre GL JS v5** | Vector tiles, globe projection, open source, custom layers |
| Aircraft rendering | MapLibre symbol layer (SDF icons) for v1, then a **custom WebGL layer** (`CustomLayerInterface`) or deck.gl `IconLayer` via `MapboxOverlay` (interleaved) if needed | Symbol layers are easy but repaint the GeoJSON source each update. A custom layer with instanced quads plus GPU interpolation scales best. |
| UI framework | **React 19 + Tailwind v4 + shadcn/ui (Radix)** | Best component ecosystem for a "very modern" look, with accessible primitives. Alternative: Svelte 5 (smaller, but fewer components). |
| State | Zustand (UI state) plus worker-owned aircraft store | Keeps React re-renders out of the hot path |
| Data worker | Web Worker + Comlink, `fzstd` for binCraft `.zst` | Decoding off the main thread |
| Charts | uPlot (altitude/speed profiles, feeder stats) | Tiny and fast |
| Search | MiniSearch / FlexSearch over the in-memory aircraft list plus airports | Command palette |
| PWA | vite-plugin-pwa | Installable, offline shell |
| Tests | Vitest, Playwright (visual and perf smoke) | |

## Module layout (planned)

```
src/
  sources/        DataSource adapters
    readsb-json.ts      /data/aircraft.json polling
    readsb-bincraft.ts  binCraft + globe tiles (port of tar1090 decoder)
    v2-api.ts           adsb.lol / airplanes.live / adsb.fi (ADSBx v2 format)
    replay.ts           traces / globe_history
  worker/
    store.ts         SoA typed arrays: hex, lat, lon, alt, gs, track, ts, flags
    interpolate.ts   dead reckoning between updates
    trails.ts        per-aircraft ring buffers → line geometry
  enrich/         plugins: aircraftDb, routes, photos, dispatch (BYO key)
  map/
    style/           custom dark/light MapLibre styles
    layers/          aircraft, trails, range-ring, airports, selection
  ui/             panels, command palette, table, detail sheet
  app/            routing (URL state), settings, i18n
```

### DataSource interface (sketch)

```ts
interface DataSource {
  id: string;
  capabilities: { global: boolean; history: boolean; mlat: boolean };
  start(view: Viewport, emit: (batch: AircraftBatch) => void): void;
  setViewport(view: Viewport): void; // aggregator: bbox queries / globe tiles
  stop(): void;
}
```

## Data flow

```
readsb files / API ──fetch──▶ Worker: decode → merge into store → interpolate
                                         │ (transferable Float32Arrays, ~10–30 Hz)
                                         ▼
                              Main: custom WebGL layer draws instances
                                         │
                              selected hex ──▶ React detail panel (1 Hz)
                                         └──▶ enrich plugins (on demand, cached)
```

- Poll at 1 Hz locally (readsb default). Render at 60 fps with interpolated
  positions, so aircraft glide instead of jumping (tar1090 jumps).
- Trails color each segment by altitude, using a perceptually uniform palette
  that matches the tar1090 convention so users recognise it.
- Picking: use GPU color-picking or a spatial index (flatbush) in the worker
  for hover and click.

## Optional companion backend (phase 3+)

This is not needed for the MVP. It covers things a static site can't do:

- Hide API keys for paid enrichment and cache responses (SQLite).
- Serve a WebSocket push stream instead of polling, plus delta encoding for
  aggregator scale.
- Keep a long-term history DB ("what flew over yesterday at 14:00"), feeder
  stats and alerts (push notifications for watchlist hex/registration/type).

Suggested stack: a Go or Rust single binary (it's easy to ship in Docker and on
Pis). It reads readsb's JSON or Beast/`--net-api-port` output directly.

## Deployment targets

1. **Drop-in folder.** Copy `dist/` to `/usr/local/share/yaa`, then add a lighttpd
   alias `/yaa/` (same pattern as tar1090). It reads `/tar1090/data/` or
   `/data/` on the same origin. Provide an install script.
2. **Docker image** that works next to sdr-enthusiasts `ultrafeeder`, with the
   readsb data dir mounted read-only.
3. **adsb.im integration.** Approach the maintainer once the app is stable.
4. **Hosted demo** on a public aggregator API (adsb.lol), limited to a
   viewport/radius to stay within rate limits.

## Risks

| Risk | Mitigation |
| --- | --- |
| binCraft format changes (undocumented) | Port from tar1090 source, pin a version, keep the JSON fallback |
| WebGL perf on low-end phones | Level-of-detail (dots when zoomed out), cap the interpolation rate |
| Route data wrong | Plausibility flag and derived-origin logic |
| Paid API ToS | BYO key, personal use, no redistribution |
| Feature creep vs tar1090 parity | Parity checklist in roadmap; ship the core first |
