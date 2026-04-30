#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-dev}"
POD="${POD:-}"
POD_PREFIX="${POD_PREFIX:-home-assistant-dev}"
CONTAINER="${CONTAINER:-}"
REMOTE_CONFIG_DIR="${REMOTE_CONFIG_DIR:-/config}"
PACKAGES_DIR="${PACKAGES_DIR:-${REMOTE_CONFIG_DIR}/packages}"
DASHBOARDS_DIR="${DASHBOARDS_DIR:-${REMOTE_CONFIG_DIR}/dashboards}"
DASHBOARD_FILENAME="${DASHBOARD_FILENAME:-home-assistant-energy-insights-full.yaml}"
PACKAGE_PREFIX="${PACKAGE_PREFIX:-hei}"
ADAPTER_DIR="${ADAPTER_DIR:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required" >&2
  exit 1
fi

KUBE_BASE=(-n "${NAMESPACE}")
if [[ -n "${CONTAINER}" ]]; then
  KUBE_BASE+=( -c "${CONTAINER}" )
fi

PACKAGES_BEGIN_MARKER="# BEGIN Home Assistant Energy Insights packages"
PACKAGES_END_MARKER="# END Home Assistant Energy Insights packages"
DASHBOARD_BEGIN_MARKER="# BEGIN Home Assistant Energy Insights dashboard"
DASHBOARD_END_MARKER="# END Home Assistant Energy Insights dashboard"

resolve_pod() {
  if [[ -n "${POD}" ]]; then
    echo "${POD}"
    return
  fi

  local match
  match="$(
    kubectl -n "${NAMESPACE}" get pods --field-selector=status.phase=Running \
      -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' \
      | grep "^${POD_PREFIX}-" \
      | head -n1 || true
  )"

  if [[ -z "${match}" ]]; then
    echo "No running pod found in namespace '${NAMESPACE}' matching prefix '${POD_PREFIX}-'" >&2
    exit 1
  fi

  echo "${match}"
}

flatten_name() {
  local path="$1"
  local name
  name="$(echo "${path}" | sed 's#^\./##; s#/#_#g; s#[^a-zA-Z0-9._-]#_#g; s#-#_#g')"
  echo "${PACKAGE_PREFIX}_${name}"
}

TARGET_POD="$(resolve_pod)"

mkdir -p "${TMP_DIR}/packages" "${TMP_DIR}/dashboards"

while IFS= read -r file; do
  base="$(flatten_name "${file}")"
  cp "${REPO_ROOT}/${file#./}" "${TMP_DIR}/packages/${base}"
done < <(
  cd "${REPO_ROOT}" && find ./packages -type f -name '*.yaml' | sort
)

if [[ -z "${ADAPTER_DIR}" ]]; then
  if [[ -d "${REPO_ROOT}/adapters/tesla-local" ]]; then
    ADAPTER_DIR="adapters/tesla-local"
  else
    ADAPTER_DIR="adapters/tesla"
  fi
fi

if [[ ! -d "${REPO_ROOT}/${ADAPTER_DIR}" ]]; then
  echo "Adapter directory not found: ${ADAPTER_DIR}" >&2
  exit 1
fi

while IFS= read -r file; do
  base="$(basename "${file}")"
  cp "${REPO_ROOT}/${file#./}" "${TMP_DIR}/packages/${PACKAGE_PREFIX}_adapters_tesla_${base}"
done < <(
  cd "${REPO_ROOT}" && find "./${ADAPTER_DIR}" -maxdepth 1 -type f -name '*.yaml' | sort
)

cp "${REPO_ROOT}/dashboards/bundles/full-dashboard.yaml" \
  "${TMP_DIR}/dashboards/${DASHBOARD_FILENAME}"

echo "Deploying Home Assistant Energy Insights"
echo "Namespace: ${NAMESPACE}"
echo "Pod:       ${TARGET_POD}"
if [[ -n "${CONTAINER}" ]]; then
  echo "Container: ${CONTAINER}"
fi
echo "Adapter:   ${ADAPTER_DIR}"
echo "Packages:  ${PACKAGES_DIR}"
echo "Dashboard: ${DASHBOARDS_DIR}/${DASHBOARD_FILENAME}"
echo

kubectl "${KUBE_BASE[@]}" exec "${TARGET_POD}" -- sh -lc \
  "mkdir -p '${PACKAGES_DIR}' '${DASHBOARDS_DIR}' && rm -f '${PACKAGES_DIR}/${PACKAGE_PREFIX}_'*.yaml '${PACKAGES_DIR}/${PACKAGE_PREFIX}__'*.yaml"

tar -cf - -C "${TMP_DIR}" packages dashboards \
| kubectl "${KUBE_BASE[@]}" exec -i "${TARGET_POD}" -- sh -lc \
    "tar -xf - -C '${REMOTE_CONFIG_DIR}'"

CONFIG_CHECK="$(
  kubectl "${KUBE_BASE[@]}" exec "${TARGET_POD}" -- sh -lc "
    if [ -f '${REMOTE_CONFIG_DIR}/configuration.yaml' ]; then
      if grep -Fq '${PACKAGES_BEGIN_MARKER}' '${REMOTE_CONFIG_DIR}/configuration.yaml' \
        || grep -Eq '^[[:space:]]*packages:[[:space:]]*!include_dir_named[[:space:]]+packages([[:space:]]*|#.*)$' '${REMOTE_CONFIG_DIR}/configuration.yaml'; then
        echo PACKAGES_INCLUDE=present
      else
        echo PACKAGES_INCLUDE=missing
      fi
      if grep -Fq '${DASHBOARD_BEGIN_MARKER}' '${REMOTE_CONFIG_DIR}/configuration.yaml' \
        || grep -Fq 'filename: dashboards/${DASHBOARD_FILENAME}' '${REMOTE_CONFIG_DIR}/configuration.yaml'; then
        echo DASHBOARD_INCLUDE=present
      else
        echo DASHBOARD_INCLUDE=missing
      fi
    else
      echo CONFIG_FILE=missing
    fi
  " 2>/dev/null || true
)"

maybe_append_config() {
  local label="$1"
  local content="$2"
  local answer

  printf "%s is missing from /config/configuration.yaml. Add it now? [y/N] " "${label}" >&2
  read -r answer
  if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
    return
  fi

  kubectl "${KUBE_BASE[@]}" exec -i "${TARGET_POD}" -- sh -lc "cat >> '${REMOTE_CONFIG_DIR}/configuration.yaml'" <<EOF

${content}
EOF
}

if grep -q '^CONFIG_FILE=missing$' <<<"${CONFIG_CHECK}"; then
  printf "/config/configuration.yaml not found in pod. Create it with required Energy Insights config? [y/N] " >&2
  read -r create_answer
  if [[ "${create_answer}" =~ ^[Yy]$ ]]; then
    kubectl "${KUBE_BASE[@]}" exec -i "${TARGET_POD}" -- sh -lc "cat > '${REMOTE_CONFIG_DIR}/configuration.yaml'" <<EOF
${PACKAGES_BEGIN_MARKER}
homeassistant:
  packages: !include_dir_named packages
${PACKAGES_END_MARKER}

${DASHBOARD_BEGIN_MARKER}
lovelace:
  dashboards:
    energy-insights:
      mode: yaml
      title: Energy Insights
      icon: mdi:view-dashboard
      show_in_sidebar: true
      filename: dashboards/${DASHBOARD_FILENAME}
${DASHBOARD_END_MARKER}
EOF
    CONFIG_CHECK=$'PACKAGES_INCLUDE=present\nDASHBOARD_INCLUDE=present'
  fi
else
  if grep -q '^PACKAGES_INCLUDE=missing$' <<<"${CONFIG_CHECK}"; then
    maybe_append_config \
      "packages include" \
      "${PACKAGES_BEGIN_MARKER}
homeassistant:
  packages: !include_dir_named packages
${PACKAGES_END_MARKER}"
  fi

  if grep -q '^DASHBOARD_INCLUDE=missing$' <<<"${CONFIG_CHECK}"; then
    maybe_append_config \
      "dashboard registration" \
      "${DASHBOARD_BEGIN_MARKER}
lovelace:
  dashboards:
    energy-insights:
      mode: yaml
      title: Energy Insights
      icon: mdi:view-dashboard
      show_in_sidebar: true
      filename: dashboards/${DASHBOARD_FILENAME}
${DASHBOARD_END_MARKER}"
  fi
fi

CONFIG_CHECK="$(
  kubectl "${KUBE_BASE[@]}" exec "${TARGET_POD}" -- sh -lc "
    if [ -f '${REMOTE_CONFIG_DIR}/configuration.yaml' ]; then
      if grep -Fq '${PACKAGES_BEGIN_MARKER}' '${REMOTE_CONFIG_DIR}/configuration.yaml' \
        || grep -Eq '^[[:space:]]*packages:[[:space:]]*!include_dir_named[[:space:]]+packages([[:space:]]*|#.*)$' '${REMOTE_CONFIG_DIR}/configuration.yaml'; then
        echo PACKAGES_INCLUDE=present
      else
        echo PACKAGES_INCLUDE=missing
      fi
      if grep -Fq '${DASHBOARD_BEGIN_MARKER}' '${REMOTE_CONFIG_DIR}/configuration.yaml' \
        || grep -Fq 'filename: dashboards/${DASHBOARD_FILENAME}' '${REMOTE_CONFIG_DIR}/configuration.yaml'; then
        echo DASHBOARD_INCLUDE=present
      else
        echo DASHBOARD_INCLUDE=missing
      fi
    else
      echo CONFIG_FILE=missing
    fi
  " 2>/dev/null || true
)"

cat <<EOF
Done.

Files deployed:
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_helpers_battery.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_helpers_billing.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_helpers_ev.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_helpers_forecasting.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_helpers_roi.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_helpers_vpp.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_meters_annual_trueup.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_meters_battery.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_meters_ev.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_meters_grid.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_meters_home.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_meters_solar.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_core_battery_runtime.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_core_credits.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_core_energy_mix.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_core_ev.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_core_forecasting.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_core_records.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_packages_core_vpp.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_adapters_tesla_ev.yaml
  ${PACKAGES_DIR}/${PACKAGE_PREFIX}_adapters_tesla_powerwall.yaml
  ${DASHBOARDS_DIR}/${DASHBOARD_FILENAME}

configuration.yaml check:
$(if grep -q '^CONFIG_FILE=missing$' <<<"${CONFIG_CHECK}"; then
    printf '%s\n' "  /config/configuration.yaml not found in pod."
  else
    if grep -q '^PACKAGES_INCLUDE=present$' <<<"${CONFIG_CHECK}"; then
      printf '%s\n' "  packages include: present"
    else
      printf '%s\n' "  packages include: missing"
    fi
    if grep -q '^DASHBOARD_INCLUDE=present$' <<<"${CONFIG_CHECK}"; then
      printf '%s\n' "  dashboard registration: present"
    else
      printf '%s\n' "  dashboard registration: missing"
    fi
  fi)

If this fresh dev instance does not already include packages, add this to configuration.yaml:

homeassistant:
  packages: !include_dir_named packages

If this fresh dev instance does not already register a YAML dashboard, add this to configuration.yaml:

lovelace:
  dashboards:
    energy-insights:
      mode: yaml
      title: Energy Insights
      icon: mdi:view-dashboard
      show_in_sidebar: true
      filename: dashboards/${DASHBOARD_FILENAME}

Adapter edits:
  Usually none if your dev Tessie instance exposes the same entity ids as production.
  If entity ids differ, edit only these files:
  - ${PACKAGES_DIR}/${PACKAGE_PREFIX}_adapters_tesla_ev.yaml
  - ${PACKAGES_DIR}/${PACKAGE_PREFIX}_adapters_tesla_powerwall.yaml

Typical next steps in Home Assistant:
  1. Add the configuration.yaml snippets if needed.
  2. Restart Home Assistant.
  3. Open the Energy Insights dashboard.
  4. If some canonical entities stay unavailable, adjust only the deployed Tesla adapter files.

Override defaults if needed:
  NAMESPACE=${NAMESPACE} POD_PREFIX=${POD_PREFIX} ./scripts/kubectl_copy_to_dev.sh
  NAMESPACE=${NAMESPACE} POD=${TARGET_POD} ./scripts/kubectl_copy_to_dev.sh
  CONTAINER=<name> ./scripts/kubectl_copy_to_dev.sh
  ADAPTER_DIR=adapters/tesla ./scripts/kubectl_copy_to_dev.sh
EOF
