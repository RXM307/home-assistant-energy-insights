#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

ROOT = File.expand_path("..", __dir__)
views_dir = File.join(ROOT, "dashboards", "views")
templates_path = File.join(ROOT, "dashboards", "templates", "button-card-templates.yaml")
bundle_path = File.join(ROOT, "dashboards", "bundles", "full-dashboard.yaml")

view_order = %w[overview analytics solar-roi ev battery billing forecasting config]

bundle = {
  "title" => "Home Assistant Energy Insights"
}

if File.exist?(templates_path)
  templates = YAML.load_file(templates_path) || {}
  bundle.merge!(templates)
end

bundle["views"] = view_order.map do |name|
  YAML.load_file(File.join(views_dir, "#{name}.yaml"))
end

File.write(bundle_path, YAML.dump(bundle))
