# Generic Adapters

Generic adapters are starting points for systems that do not match the Tesla / Powerwall example.

Use these when your Home Assistant instance already has useful solar, battery, grid, charger, or EV entities, but their entity ids do not match the canonical names used by Energy Insights.

## How To Use

1. Copy the adapter file that matches your source data.
2. Replace each placeholder entity id with the real entity from your Home Assistant instance.
3. Include the edited adapter package with the rest of the Energy Insights packages.
4. Leave dashboards and core packages unchanged.

## Files

- `ev.yaml` maps EV battery, charging, range, and plug state entities.
- `home_power.yaml` maps solar, home load, grid, and battery entities.

All installation-specific entity mapping belongs in adapters. Shared calculations belong in `packages/core/`, and dashboards should only read canonical entities.
