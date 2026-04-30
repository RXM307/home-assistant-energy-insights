# Migration Plan

This repository is being built from an existing working Home Assistant setup. Migration should happen in layers.

## Order

1. helper inputs
2. utility meters
3. core derived sensors
4. source adapters
5. dashboards

## Why

If dashboards move first, every later entity rename or package split creates repeated churn. Moving the entity layer first makes the dashboard migration mostly mechanical.

## Current Progress

- helper inputs split into domain files
- initial Tesla-specific helper file created
- install and module docs scaffolded

## Next Migration Slice

- split utility meters by domain
- identify which current utility meters are source-agnostic versus Tesla-specific
- begin extracting core runtime logic from large monolithic packages
