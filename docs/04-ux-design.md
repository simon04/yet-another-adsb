# 04 — UX design

## Visual language

- **Map-first and full-bleed.** UI floats over the map as translucent panels
  (backdrop blur), with rounded corners and subtle borders. Styling is
  restrained, closer to Linear or Apple Maps than a "cockpit".
- **Dark by default**, with a muted custom basemap (land, water and roads in
  low-contrast greys) so aircraft colors pop. Offer a light theme and a
  satellite option, which needs a hosted imagery source that allows it.
- **Altitude color ramp** for aircraft and trails. Use a perceptually uniform
  palette that is colorblind-safe. Show the legend on hover.
- **Aircraft icons** are silhouettes by type category (narrowbody, widebody,
  regional, GA, heli, glider, balloon, drone, ground vehicle). Render them as
  SDF so they tint well at any size, and scale them by wake category.
- Use variable fonts (Inter or Geist) with tabular numerals for all live
  numbers so they don't jitter.
- Use motion only where it carries information: smooth aircraft movement, panel
  transitions under 200 ms, and honour `prefers-reduced-motion`.

## Layout

### Desktop
```
┌──────────────────────────────────────────────────────────────┐
│ [⌘K Search…]                    [filters] [layers] [⚙]       │
│                                                              │
│                         MAP                     ┌──────────┐ │
│                                                 │ DETAIL   │ │
│                                                 │ panel    │ │
│                                                 │          │ │
│ [stats chip: 1,234 ✈ · 812 msg/s]               └──────────┘ │
│ [▤ table drawer — collapsible, resizable]                    │
└──────────────────────────────────────────────────────────────┘
```

### Mobile
- The map takes the full screen, with a floating search pill at the top.
- The detail view is a **bottom sheet** with three snap points: peek (callsign,
  route, altitude), half, and full.
- Primary actions sit in the thumb zone. Use haptics in the PWA where it's
  supported.

## Key surfaces

### Aircraft detail
1. Header: callsign (large), derived flight number, airline, registration
   and type, photo (with planespotters attribution).
2. **Route bar:** `FRA ─────✈──── JFK` with a progress bar, distance flown and
   remaining, and an estimated ETA. Mark it "unverified" if it fails the
   plausibility check.
3. Live data grid: altitude (baro/geo), vertical rate, GS/IAS/TAS/Mach, track,
   squawk, signal (RSSI), source (ADS-B/MLAT/TIS-B), last seen.
4. Altitude and speed profile chart over the trail (uPlot).
5. Expandable "All fields" section with every readsb field, for power users.
6. Actions: follow, share (link plus OG image), add to watchlist, open in
   external sites (ADSBx, adsb.lol, FR24, planespotters).
7. Optional "Dispatch" card (only with an enrichment plugin key): scheduled vs
   estimated times, delay, gate, and status.

### Command palette (⌘K or `/`)
- Search by callsign, flight number, registration, hex, type, airport
  (ICAO/IATA) or airline.
- Commands: "go to my station", "toggle trails", "only military", "range plot".

### Table view
- A virtualized, sortable, column-configurable table. This is the tar1090
  parity feature that power users require.
- Hovering a row highlights the aircraft on the map, and the reverse.

### Filters and layers
- Filters: altitude range slider, type/category, airline, source (ADS-B, MLAT,
  other), military, interesting, emergency squawks, on ground.
- Layers: trails (selected, all, none), range outline, airports/runways, labels
  (callsign, altitude, none), day/night terminator, weather radar (optional,
  e.g. RainViewer, check terms).

### Feeder dashboard (differentiator)
- Range polar plot (max range per bearing, by altitude band), today vs
  all-time.
- Messages per second, aircraft count, and MLAT share.
- "Today's catch": rarest types seen, farthest aircraft, and military
  count.

## Interaction details

- Keyboard: tar1090-compatible keys where sensible. `T` toggles the table,
  arrow keys pan, `+`/`-` zoom, `Esc` deselects, `F` follows, `L` toggles labels,
  `?` shows a shortcuts overlay.
- The URL reflects state: `?icao=3c6444&lat=..&lon=..&zoom=..`. Accept the
  tar1090 parameter names too.
- Hover tooltip on desktop shows callsign, altitude and type.
- The globe projection is used automatically at low zoom (MapLibre v5).
- Stale data indicator: fade aircraft not seen in over 15 s, and show a banner
  if the source is unreachable.

## Accessibility and i18n

- WCAG AA contrast for UI chrome. Panels are keyboard navigable, with screen
  reader labels on controls.
- Unit system switch (aviation, metric, imperial) and 24h/12h time.
- i18n from day one (start with en and de).
