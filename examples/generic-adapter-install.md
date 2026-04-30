# Generic Adapter Install

This is the intended install path for users who do not share the Tesla entity model.

## Files to copy

Helpers:

- `packages/helpers/battery.yaml`
- `packages/helpers/billing.yaml`
- `packages/helpers/ev.yaml`
- `packages/helpers/forecasting.yaml`
- `packages/helpers/vpp.yaml`
- `packages/helpers/roi.yaml`

Meters:

- `packages/meters/*.yaml` for the modules you want

Core:

- `packages/core/*.yaml` for the modules you want

Adapters:

- `adapters/generic/ev.yaml`
- `adapters/generic/home_power.yaml`

Dashboards:

- `dashboards/bundles/full-dashboard.yaml`

Frontend cards:

- `custom:mushroom-*`
- `custom:apexcharts-card`
- `custom:button-card`

## What the user edits

Only the adapter files.

Replace placeholder entities like:

- `sensor.replace_with_ev_battery_percent`
- `sensor.replace_with_ev_charging_power`
- `sensor.replace_with_home_battery_percent`
- `sensor.replace_with_grid_net_power`

with real entities from the user's install.

## What the user should not edit

- `packages/core/*`
- `packages/meters/*`
- dashboards

## Why

This keeps installation-specific mapping in one place and lets updates to shared logic or dashboards stay portable.
