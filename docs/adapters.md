# Adapters

Adapters are the install boundary between a user's real Home Assistant entities and this repo's canonical entity model.

## Rule

Users should adapt source entities in one place:

- `adapters/<source>/`

They should not edit:

- `packages/core/`
- `packages/meters/`
- dashboard views
- dashboard bundles

## Install Shapes

### Tesla Install

Current first-class adapter:

- `adapters/tesla/ev.yaml`
- `adapters/tesla/powerwall.yaml`

The public Tesla adapter intentionally uses placeholder vehicle entity ids such
as `sensor.your_vehicle_battery_level`. Replace those ids with the entity ids
from your Home Assistant instance.

For local development, you can create `adapters/tesla-local/ev.yaml` and
`adapters/tesla-local/powerwall.yaml`. That directory is gitignored, and the dev
deploy script prefers it automatically when present while still deploying the
files under the normal Tesla adapter package names.

### Generic Install

If a user does not have Tesla or Powerwall entities, they should copy the generic adapter templates and replace the placeholder entity ids with their own:

- `adapters/generic/ev.yaml`
- `adapters/generic/home_power.yaml`

## Mapping Strategy

Keep mapping shallow.

Good adapter logic:

- direct renames
- light normalization
- unit cleanup when needed
- one small amount of fallback logic if the source is inconsistent

Bad adapter logic:

- billing math
- forecast math
- record tracking
- ROI logic
- long chains of installation-specific conditionals

## Example

If a user has:

- `sensor.mycar_soc`
- `sensor.mycar_range_miles`
- `sensor.mycharger_power_kw`
- `binary_sensor.mycar_connected`

their EV adapter should map those to:

- `sensor.ev_battery_percent`
- `sensor.ev_range`
- `sensor.ev_charging_power`
- `binary_sensor.ev_plugged_in`

The rest of the system should not know the original names.

## Fallback Policy

Fallbacks are acceptable only when they reflect a real source ambiguity. Do not stack broad speculative fallback lists into public adapters unless the supported source is known to emit those variants.

## Future Direction

The repo should eventually support multiple adapters cleanly:

- Tesla + Powerwall
- generic EV + generic charger
- generic solar + battery systems
- utility-provider-specific billing helpers only where truly needed
