# 02 — Data sources

Short answer to "can we get FR24-style flight numbers, origin/destination and
dispatch info for free?":

- **Callsign → flight number:** yes, derivable for free. Map the ICAO airline
  prefix to the IATA code (`DLH4AB` is not always `LH4AB`; see caveats).
- **Origin / destination:** *mostly* yes, from community route databases
  (CC0). They are often stale or wrong, so they need plausibility checks.
- **Schedule, actual times, delay, gate, terminal, status:** **not freely
  available.** This needs a paid API (FR24, FlightAware AeroAPI) or freemium
  APIs with tiny quotas. Design it as an optional, bring-your-own-key plugin.

Verify all terms and prices below before relying on them. They change often.

## 1. Live positions

| Source | Access | License / terms | Notes |
| --- | --- | --- | --- |
| **Local readsb / dump1090-fa** `/data/aircraft.json` | Same origin, ~1 Hz poll | Your own data | Primary mode. Every feeder has it. |
| **readsb binCraft** (`/data/aircraft.binCraft.zst`, globe tiles `globe_XXXX.binCraft`) | Same origin | Your own data | Compact binary format used by tar1090 for globe view. Much smaller than JSON, so it's needed at aggregator scale. Format is defined by readsb/tar1090 source (no formal spec). |
| **readsb traces** (`/data/traces/xx/trace_full_<hex>.json`) | Same origin | Your own data | Track history per aircraft. |
| **adsb.lol API** (`api.adsb.lol/v2/...`) | No key | **ODbL** (data), BSD-3 (code) | Unfiltered. Point/radius, callsign, hex, mil, etc. Compatible with ADSBx RapidAPI v2 format. |
| **airplanes.live API** | No key | **Non-commercial**, no SLA, 1 req/s | Same v2 format. |
| **adsb.fi open data API** | No key | Personal/non-commercial, attribution, ~1 req/s | Same v2 format. |
| **ADSBexchange** | Paid (RapidAPI / enterprise) | Commercial | Owned by JETNET since 2023. |
| **OpenSky Network** | Free account, credit quota | Research/non-commercial | Coarser, also has historical flights. |

Implication: the public aggregator APIs are fine for "area around me" queries
from a single browser at 1 req/s. They are **not** a backend for a public
global map with many users. For that you need your own feed, or a partnership
with an aggregator (e.g. adsb.lol, which is open and sympathetic).

## 2. Aircraft metadata (registration, type, operator)

- **tar1090-db** (wiedehopf; derived from Mictronics' DB, among others):
  ICAO hex → registration, type designator, flags (military, interesting, PIA,
  LADD). Already shipped with tar1090 installs as `db/*.js` / CSV, so it can be
  reused locally.
- **ICAO type designators → description / wake category:** available inside
  tar1090-db and Mictronics.
- **Photos:** the planespotters.net public photo API (by hex or registration).
  It requires attribution and linking back. Thumbnails only, no caching beyond
  their terms.
- **Operator logos:** licensing is messy. Avoid them in v1, or use text
  badges.

## 3. Routes (origin/destination)

| Source | License | Notes |
| --- | --- | --- |
| **vradarserver/standing-data** | **CC0-1.0** | Routes by callsign plus airports, airlines, built from Virtual Radar Server user submissions. Can be bundled or mirrored. |
| **adsb.lol `POST /api/0/routeset`** | ODbL | Body: `{planes:[{callsign, lat, lng}]}`, 1–100 per request, CORS `*`. Returns `airport_codes`, `_airports[]` and a `plausible` flag (checks the aircraft's position is near the route). Backed by the VRS standing data. |
| **adsbdb.com** | Free API, but route data may **not** be copied or redistributed without permission | Live lookups only, no bulk mirror. |
| **OpenSky `/flights`** | Non-commercial | Departure/arrival airports estimated from ADS-B, after the fact (often next day). Useful for history, not live. |

Caveats:

- Callsign ≠ flight number. Airlines use alphanumeric ATC callsigns
  (`EZY12KP` for U2 1234), and codeshares break naive mapping. Show the
  **callsign as primary** and the derived flight number as secondary.
- Routes change seasonally. Always show plausibility, e.g. by greying out the
  route when the aircraft is far off the great-circle line.
- We can also **derive** origin ourselves: when the first trace point is on the
  ground or low near an airport, we know where it took off. That gives us a
  self-made, correct origin for flights departing within our coverage.

## 4. "Dispatch" info (schedule, ETD/ETA, delay, gate, status)

This is not available from open sources. Options:

| Provider | Model | Fit |
| --- | --- | --- |
| **Flightradar24 API** | Paid, credit-based (Explorer / Essential / Advanced). Free sandbox key for testing only. Not included in consumer Silver/Gold. Entry level reportedly ~$9/month (unverified). | Good data. **Check ToS** on displaying data in a public competing tracker; likely only OK for personal use with the user's own key. |
| **FlightAware AeroAPI** | Pay per query, with a personal tier | Good schedules/gates. Same ToS caveat. |
| **AeroDataBox, AirLabs, Aviationstack** | Freemium (very small free quotas) | OK for "on click of one aircraft" lookups. |
| **Airline/airport open data** | Varies | Not worth it. |

Design decision: **enrichment plugins with bring-your-own API key.**

- Query only on demand (when a user selects an aircraft), and cache per
  callsign plus date.
- Run keys either client-side (personal installs) or through the optional
  companion backend (so keys stay hidden on shared installs).
- Never require a paid key. The core experience must work with free data only.

## 5. Things we can compute ourselves (free, and a differentiator)

- ETA to destination, from the great-circle distance remaining and current
  groundspeed.
- Phase of flight (taxi / climb / cruise / descent / approach) from altitude,
  vertical rate and position near airports.
- Probable runway, from heading near the threshold.
- Emergency squawks (7500/7600/7700), military, "interesting", and LADD/PIA
  flags.
- Feeder stats: range polar plot, max range per sector, messages/s, aircraft
  seen today. Feeders love this.

## 6. Basemap data

- **OpenFreeMap** (free hosted vector tiles, no key) for quick start.
- **Protomaps PMTiles** (single file, self-hostable, offline on a Pi, works from
  a static server via HTTP range requests). This is the best fit for local
  installs.
- Aviation overlays (airports, runways): **OurAirports** (public domain).
  Airspaces: openAIP (CC BY-NC-SA, check terms).
