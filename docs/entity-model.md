# Entity Model

This project is built around canonical entities. Core packages and dashboards should consume those canonical names. Adapter packages are responsible for mapping integration-specific entities into this model.

## Why

Without a canonical layer, every dashboard becomes tied to one vendor, one naming scheme, and one specific Home Assistant installation.

## Layers

There are three layers:

1. source entities
2. canonical entities
3. dashboards

### Source Entities

These come from integrations or local sensors.

Examples:

- `sensor.vendor_ev_time_to_full`
- `sensor.home_charger_power`
- `sensor.home_battery_soc`

### Canonical Entities

These are the stable public-facing entities the repo is allowed to rely on.

#### EV Canonical Entities

- `sensor.ev_battery_percent`
- `sensor.ev_range`
- `sensor.ev_odometer`
- `sensor.ev_charge_limit`
- `sensor.ev_stored_energy`
- `sensor.ev_energy_to_target`
- `sensor.ev_charging_state`
- `sensor.ev_charging_power`
- `sensor.ev_charge_current`
- `sensor.ev_time_to_full`
- `sensor.ev_location`
- `binary_sensor.ev_plugged_in`

#### Home Power Canonical Entities

- `sensor.home_battery_percent`
- `sensor.home_battery_power`
- `sensor.home_solar_power`
- `sensor.home_load_power`
- `sensor.home_load_no_ev_power`
- `sensor.grid_net_power`
- `sensor.grid_status`
- `binary_sensor.storm_watch_active`

#### Meter and Billing Entities

These mostly come from `packages/meters` and `packages/core`, but adapter authors should understand the upstream sources those packages expect to exist.

- `sensor.solar_generated_daily`
- `sensor.home_load_daily`
- `sensor.home_load_no_ev_daily`
- `sensor.grid_import_daily`
- `sensor.grid_export_total_daily`
- `sensor.ev_charging_daily`
- `sensor.battery_charged_daily`
- `sensor.battery_discharged_daily`
- `sensor.billing_marginal_electricity_rate`
- `sensor.billing_effective_total_rate`

### Dashboards

Dashboards should only reference canonical entities and package-provided derived sensors. They should not know whether the source is Tesla, Enphase, Home Assistant Energy, or a user-defined template.

## Adapter Responsibilities

An adapter package should:

- map source entities into canonical entities
- define only source-specific logic
- avoid embedding dashboard assumptions
- avoid duplicating shared billing, forecasting, record, or ROI math

Examples:

- `adapters/tesla/`
- `adapters/generic/`

## How Users Map Their Entities

People should map their entities by editing or creating adapter packages, not by editing core packages or dashboards.

The intended workflow is:

1. identify which source entities actually exist in the user's install
2. create or edit an adapter file under `adapters/<source>/`
3. map those source entities into the canonical names above
4. leave `packages/core`, `packages/meters`, and dashboards unchanged

If a user has:

- `sensor.my_car_soc`
- `sensor.my_car_range`
- `sensor.my_wallbox_power`

their adapter should expose:

- `sensor.ev_battery_percent`
- `sensor.ev_range`
- `sensor.ev_charging_power`

The dashboards should never need to know the original entity names.

## Required vs Optional Mapping

Modules can be installed independently, so adapters only need to provide the canonical entities required by the installed modules.

### EV Module

Minimum useful EV adapter:

- `sensor.ev_battery_percent`
- `sensor.ev_range`
- `sensor.ev_charging_power`
- `sensor.ev_charging_state`
- `sensor.ev_time_to_full`
- `binary_sensor.ev_plugged_in`

### Battery / Home Power Module

Minimum useful battery adapter:

- `sensor.home_battery_percent`
- `sensor.home_battery_power`
- `sensor.home_solar_power`
- `sensor.home_load_power`
- `sensor.grid_net_power`

### Full Install

For the full dashboard bundle, all EV and home power canonical entities should exist, plus the helper, meter, and core packages included by that bundle.

## Migration Rule

When moving current dashboards into this repo:

- first identify every required source entity
- then map it into a canonical name
- only then update the dashboard to use the canonical name

This keeps migration incremental and avoids mixing direct source references with the public model.
