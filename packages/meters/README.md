# Meter Packages

Meter packages define utility meters for the reporting windows used by the dashboards.

## Files

- `solar.yaml` tracks solar generation and savings windows.
- `home.yaml` tracks home load and home-without-EV windows.
- `grid.yaml` tracks grid import, export, and net usage windows.
- `battery.yaml` tracks battery charge, discharge, and source-split windows.
- `ev.yaml` tracks EV charging and solar/grid charging-source windows.
- `annual_trueup.yaml` tracks annual net-credit import/export meters and reset actions.

## Conventions

- Daily, monthly, yearly, and billing-cycle meters stay in these domain files.
- Billing-cycle meters use the `*_billing` suffix.
- Annual true-up meters are reset manually or by the configurable annual true-up automation.
- Derived values belong in `packages/core/`, not in meter packages.
