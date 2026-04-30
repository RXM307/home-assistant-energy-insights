# Tesla Full Stack Example

This is the intended first supported install shape.

## Helper packages

- `packages/helpers/battery.yaml`
- `packages/helpers/billing.yaml`
- `packages/helpers/ev.yaml`
- `packages/helpers/forecasting.yaml`
- `packages/helpers/vpp.yaml`

## Tesla-specific adapter packages

- `adapters/tesla/ev.yaml`
- `adapters/tesla/powerwall.yaml`

## Shared packages

- `packages/meters/*.yaml`
- `packages/core/*.yaml`

## Dashboards

- `dashboards/bundles/full-dashboard.yaml`

## Frontend cards

- `custom:mushroom-*`
- `custom:apexcharts-card`
- `custom:button-card`

## Notes

This example now includes the full public dashboard bundle. Users still need to copy the files into their own Home Assistant config and reload packages and Lovelace.
