# Dashboard Views

Views are the editable source files for the public dashboard bundle.

## Files

- `overview.yaml` - live status, daily totals, billing snapshot, weather, and forecast tiles.
- `analytics.yaml` - energy trends, source mix, records, and best/lowest days.
- `solar-roi.yaml` - billing impact, solar payback, ROI, and lifetime value.
- `ev.yaml` - EV battery, charging, source split, miles, and cost.
- `battery.yaml` - home battery status, runtime estimates, source split, and VPP value.
- `billing.yaml` - billing-cycle usage, costs, credits, and rate inputs.
- `forecasting.yaml` - month-end, billing-cycle, and long-range forecast charts.
- `config.yaml` - dashboard-facing helper controls and reset actions.

Views should consume canonical entities from the packages and adapters. Put reusable styling in `dashboards/templates/`, installation-specific mapping in `adapters/`, and shared calculations in `packages/core/`.
