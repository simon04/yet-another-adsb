#!/usr/bin/env bash
# Polls adsb.lol for one fixed region and writes it in readsb aircraft.json
# shape, so the app uses the same code path as on a home feeder.
# Upstream load is 1 request per interval, independent of the number of viewers.
set -euo pipefail

: "${YAA_LAT:?}" "${YAA_LON:?}"
radius=${YAA_RADIUS_NM:-250}
interval=${YAA_INTERVAL:-2}
out=${RUNTIME_DIRECTORY:-/run/yaa}/aircraft.json
url="https://api.adsb.lol/v2/point/$YAA_LAT/$YAA_LON/$radius"

while :; do
  # v2 "now" is in ms, readsb's in s; "ac" is readsb's "aircraft".
  if curl -fsS --max-time 10 -A "yet-another-adsb demo (${YAA_CONTACT:-})" "$url" |
    jq -c '{now: (.now / 1000), messages: 0, aircraft: .ac}' >"$out.tmp"; then
    mv -f "$out.tmp" "$out"
    sleep "$interval"
  else
    echo "fetch failed, backing off" >&2
    sleep 30
  fi
done
