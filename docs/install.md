# Install Guide

This repo now has a first coherent install path. It is still mid-migration, but users can install the shared package layers, choose an adapter, and load the full dashboard bundle without editing dashboard entity ids.

## Requirements

Home Assistant requirements:

- packages enabled
- template integration support
- utility meter integration support
- a weather entity, defaulting to `weather.forecast_home` in the public dashboard
- Forecast.Solar sensors if you want the solar forecast and peak-time cards populated

Frontend card requirements:

- [`custom:mushroom-*`](https://github.com/piitaya/lovelace-mushroom)
- [`custom:apexcharts-card`](https://github.com/RomRider/apexcharts-card)
- [`custom:button-card`](https://github.com/custom-cards/button-card)

Optional:

- `card-mod` is not currently required by the public bundle

## Install HACS And Frontend Dependencies

If this Home Assistant instance does not already have HACS:

1. Follow the HACS download guide: [Downloading HACS](https://www.hacs.xyz/docs/use/download/download/)
2. Then complete HACS setup: [Initial configuration](https://www.hacs.xyz/docs/use/configuration/basic/)

After HACS is installed, add these dashboard dependencies through HACS:

1. [`Mushroom`](https://github.com/piitaya/lovelace-mushroom)
2. [`ApexCharts Card`](https://github.com/RomRider/apexcharts-card)
3. [`Button Card`](https://github.com/custom-cards/button-card)

HACS dashboard docs:

- [Using the HACS dashboard](https://hacs.xyz/docs/use/repositories/dashboard/)

## Recommended Install Layout

Example Home Assistant config structure:

```yaml
homeassistant:
  packages: !include_dir_named packages
```

Example file layout:

```text
config/
  packages/
    helpers/
    meters/
    core/
    adapters/
  dashboards/
```

## First Supported Bundle

The first public bundle is:

- [`full-dashboard.yaml`](dashboards/bundles/full-dashboard.yaml)

It is built from:

- [`dashboards/templates/button-card-templates.yaml`](dashboards/templates/button-card-templates.yaml)
- the view files under [`dashboards/views`](dashboards/views)
- [`scripts/build_dashboard_bundle.rb`](scripts/build_dashboard_bundle.rb)

It includes these views:

- `overview`
- `analytics`
- `solar-roi`
- `ev`
- `battery`
- `billing`
- `forecasting`
- `config`

## Shared Packages To Copy

### Helper packages

- [`packages/helpers/battery.yaml`](packages/helpers/battery.yaml)
- [`packages/helpers/billing.yaml`](packages/helpers/billing.yaml)
- [`packages/helpers/ev.yaml`](packages/helpers/ev.yaml)
- [`packages/helpers/forecasting.yaml`](packages/helpers/forecasting.yaml)
- [`packages/helpers/roi.yaml`](packages/helpers/roi.yaml)
- [`packages/helpers/vpp.yaml`](packages/helpers/vpp.yaml)

### Meter packages

- [`packages/meters/solar.yaml`](packages/meters/solar.yaml)
- [`packages/meters/home.yaml`](packages/meters/home.yaml)
- [`packages/meters/grid.yaml`](packages/meters/grid.yaml)
- [`packages/meters/ev.yaml`](packages/meters/ev.yaml)
- [`packages/meters/battery.yaml`](packages/meters/battery.yaml)
- [`packages/meters/annual_trueup.yaml`](packages/meters/annual_trueup.yaml)

### Core packages

- [`packages/core/credits.yaml`](packages/core/credits.yaml)
- [`packages/core/energy_mix.yaml`](packages/core/energy_mix.yaml)
- [`packages/core/battery_runtime.yaml`](packages/core/battery_runtime.yaml)
- [`packages/core/ev.yaml`](packages/core/ev.yaml)
- [`packages/core/forecasting.yaml`](packages/core/forecasting.yaml)
- [`packages/core/roi.yaml`](packages/core/roi.yaml)
- [`packages/core/vpp.yaml`](packages/core/vpp.yaml)
- [`packages/core/records.yaml`](packages/core/records.yaml)

## Choose One Adapter Path

### Tesla / Powerwall path

Copy:

- [`adapters/tesla/ev.yaml`](adapters/tesla/ev.yaml)
- [`adapters/tesla/powerwall.yaml`](adapters/tesla/powerwall.yaml)

Expected raw entities for the current Tesla adapter:

- EV:
  - `sensor.your_vehicle_battery_level`
  - `sensor.your_vehicle_battery_range`
  - `sensor.your_vehicle_odometer`
  - `sensor.your_vehicle_charging`
  - `sensor.your_vehicle_charger_power`
  - `sensor.your_vehicle_time_to_full_charge`
  - `number.your_vehicle_charge_limit`
  - `number.your_vehicle_charge_current`
  - `binary_sensor.tesla_wall_connector_vehicle_connected`
  - `binary_sensor.your_vehicle_charge_cable`
- Power / solar / home:
  - `sensor.energy_percentage_charged`
  - `sensor.energy_battery_power`
  - `sensor.energy_solar_power`
  - `sensor.energy_load_power`
  - `sensor.energy_grid_power`
  - `sensor.energy_island_status`
  - `binary_sensor.energy_storm_watch_active`
  - `sensor.energy_grid_imported`
  - `sensor.energy_total_solar_generated`
  - `sensor.energy_grid_exported_from_solar`
  - `sensor.energy_grid_exported_from_battery`
  - `sensor.energy_total_home_usage`
  - `sensor.ev_charging_energy`
  - `sensor.energy_total_battery_discharged`

If your instance uses different raw ids, edit only the adapter files.

For local development against a private Home Assistant instance, keep private
entity ids out of git by copying the Tesla adapter files to
`adapters/tesla-local/`. The deploy script uses that gitignored directory
automatically when it exists.

### Generic path

Copy:

- [`adapters/generic/ev.yaml`](adapters/generic/ev.yaml)
- [`adapters/generic/home_power.yaml`](adapters/generic/home_power.yaml)

Then replace the placeholder entity ids with real entities from the user's install.

## Mapping Rule

Users should map their source entities only in adapter files.

They should not edit:

- `packages/core/*`
- `packages/meters/*`
- dashboard views
- dashboard bundles

Example:

- user has `sensor.my_car_soc`
- user has `sensor.my_wallbox_power`
- user maps those to:
  - `sensor.ev_battery_percent`
  - `sensor.ev_charging_power`

The dashboard bundle stays unchanged.

## Dashboard Install

Copy:

- [`dashboards/bundles/full-dashboard.yaml`](dashboards/bundles/full-dashboard.yaml)

Load it as a YAML dashboard or merge it into an existing Lovelace dashboard flow, depending on how the user's Home Assistant instance manages dashboards.

## Recommended Order

1. install the custom cards
2. copy helper packages
3. copy meter packages
4. copy core packages
5. copy one adapter path
6. adjust adapter mappings if using the generic path
7. copy the dashboard bundle
8. restart Home Assistant
9. reload Lovelace dashboards

A full restart is recommended here because the package set defines template sensors, utility meters, scripts, and automations.

## Annual True-Up

Annual net-credit tracking is utility-specific. The included true-up meters do
not assume a WA/PSE April 1 reset by default.

To enable an automatic annual credit-bank reset, open the Config view and set:

- `Annual True-Up Auto Reset Enabled`
- `Annual True-Up Reset Month`
- `Annual True-Up Reset Day`

For a PSE-style April 1 reset, use month `4` and day `1`. If your utility has
no annual true-up, leave auto-reset disabled and the annual credit bank will
continue accumulating until you manually reset it.

## Maintaining The Bundle

For repo maintainers, rebuild the bundle after editing dashboard templates or view files:

```bash
ruby scripts/build_dashboard_bundle.rb
```

## Public Release Notes

The current public bundle is the full dashboard stack. Partial dashboard bundles
can be added later, but the shared packages and adapter boundary are already
structured so users can install only the modules they need.
