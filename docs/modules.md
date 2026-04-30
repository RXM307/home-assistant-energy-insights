# Modules

This repository is intended to be installable in slices. Modules are grouped so users can install only the parts they need.

## Helper Modules

- `packages/helpers/battery.yaml`
  Battery-related inputs such as usable capacity and reserve.
- `packages/helpers/billing.yaml`
  Utility billing rates and fixed-charge inputs.
- `packages/helpers/ev.yaml`
  EV efficiency and gas-comparison inputs.
- `packages/helpers/forecasting.yaml`
  Billing-cycle start and forecast timing inputs.
- `packages/helpers/vpp.yaml`
  VPP rebate, rate, event, and battery-cost inputs.

## Meter Modules

- `packages/meters/solar.yaml`
  Solar energy windows for daily, monthly, billing, and yearly reporting.
- `packages/meters/home.yaml`
  Home load and home-without-EV energy windows.
- `packages/meters/grid.yaml`
  Grid import, export, and net usage windows.
- `packages/meters/ev.yaml`
  EV charging windows and source-split windows.
- `packages/meters/battery.yaml`
  Battery charged, discharged, and source-split windows.
- `packages/meters/annual_trueup.yaml`
  Annual net-credit meters with a configurable reset automation.

## Core Modules

- `packages/core/credits.yaml`
  Credit-bank, import/export value, and billing-credit math.
- `packages/core/energy_mix.yaml`
  Solar, battery, and grid mix calculations for daily consumption views.
- `packages/core/battery_runtime.yaml`
  Runtime and ETA sensors for discharge, reserve, and full-charge estimates.
- `packages/core/ev.yaml`
  EV source percentages and estimated miles metrics.
- `packages/core/forecasting.yaml`
  Billing-cycle progress and forecast-readiness sensors.
- `packages/core/vpp.yaml`
  VPP earnings, payback progress, and event-apply script.
- `packages/core/records.yaml`
  Daily, monthly, yearly, and lifetime peak/record tracking.

## Adapter Modules

- `adapters/tesla/ev.yaml`
  Canonical EV entities mapped from the Tesla vehicle and wall connector entities.
- `adapters/tesla/powerwall.yaml`
  Canonical home battery, solar, grid, and storm-watch entities mapped from the Tesla/Powerwall entities.

## Planned Next Modules

- `dashboards/views/*.yaml`
- `dashboards/bundles/*.yaml`

## Dependency Direction

Keep dependencies one-way:

1. helpers
2. meters
3. core logic
4. adapters
5. dashboards

Dashboards should not define logic. Adapters should not carry shared billing or forecasting math that belongs in core packages.
