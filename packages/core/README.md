# Core Packages

Core packages contain source-agnostic calculations built on canonical entities, helpers, and utility meters.

## Files

- `billing.yaml` calculates billing-cycle charges, projected cost, and rate summaries.
- `credits.yaml` calculates grid import/export value, net usage, and annual credit-bank values.
- `energy_mix.yaml` calculates daily source mix for solar, grid, battery, home load, and EV usage.
- `battery_runtime.yaml` estimates battery time to empty, reserve, and full charge.
- `ev.yaml` calculates EV source split, charging percentages, miles, and gas-equivalent comparisons.
- `forecasting.yaml` calculates billing-cycle progress, forecast confidence, and month-end projections.
- `records.yaml` tracks peak power records and best/lowest energy days.
- `roi.yaml` calculates solar savings, payback progress, and breakeven estimates.
- `vpp.yaml` tracks VPP value, event earnings, and battery payback.

Core packages should not reference private integration entity ids. If a calculation needs source data, expose it through an adapter first.
