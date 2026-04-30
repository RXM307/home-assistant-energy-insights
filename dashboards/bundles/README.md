# Dashboard Bundles

Dashboard bundles are install-ready Lovelace YAML files.

## Files

- `full-dashboard.yaml` includes the complete Energy Insights dashboard:
  `Overview`, `Analytics`, `Solar ROI`, `EV`, `Battery`, `Billing`, `Forecasting`, and `Config`.

The bundle is generated from shared templates and individual view files. Edit those source files first, then rebuild the bundle.

```bash
ruby scripts/build_dashboard_bundle.rb
```

Install the bundle by copying it into your Home Assistant dashboard directory and registering it as a YAML dashboard.
