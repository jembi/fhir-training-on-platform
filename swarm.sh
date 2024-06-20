#!/bin/bash

declare ACTION=""
declare COMPOSE_FILE_PATH=""
declare UTILS_PATH=""
declare STACK="fhir-training"

function init_vars() {
  ACTION=$1

  COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
  )

  UTILS_PATH="${COMPOSE_FILE_PATH}/../utils"

  readonly ACTION
  readonly COMPOSE_FILE_PATH
  readonly UTILS_PATH
  readonly STACK
}

# shellcheck disable=SC1091
function import_sources() {
  source "${UTILS_PATH}/docker-utils.sh"
  source "${UTILS_PATH}/config-utils.sh"
  source "${UTILS_PATH}/log.sh"
}

function restart_hapi_fhir() {
  local -r stackname="${FHIR_STACKNAME:-hapi-fhir}"
  if docker service ps -q ${stackname}_hapi-fhir &>/dev/null; then
    log info "Restarting HAPI FHIR.."
    try \
      "docker service scale ${stackname}_hapi-fhir=0" \
      throw \
      "Error scaling down hapi-fhir to update the IG"
    try \
      "docker service scale ${stackname}_hapi-fhir=$HAPI_FHIR_INSTANCES" \
      throw \
      "Error scaling up hapi-fhir to update the IG"
  else
    log warn "Service 'hapi-fhir' does not appear to be running... Skipping the restart of hapi-fhir"
  fi
}

function deploy_importers() {
  # Run through all the config importers
  for service_path in "${COMPOSE_FILE_PATH}/importer/"*/; do
    target_service_name=$(basename "$service_path")

    if [[ $IMPORT_ONLY != "" && "${target_service_name}" != $IMPORT_ONLY ]]; then
      log warn "IMPORT_ONLY ($IMPORT_ONLY) doesnt match $target_service_name. continue..."
      continue
    fi

    # Only run the importer for fhir datastore when validation is enabled
    if [[ $DISABLE_VALIDATION == "true" ]] && [[ "${target_service_name}" == "hapi-fhir" ]]; then
      log warn "Validation is disabled... Skipping the deploy of hapi fhir config importer"
      continue
    fi

    local swarmfile=${service_path}swarm.sh
    if [[ ! -f $swarmfile ]]; then
      log error "FATAL: $swarmfile is missing, please add it and try again"
      exit 1
    fi
    source $swarmfile

  done
}

function initialize_package() {
  (
    deploy_importers

    if [[ $DISABLE_VALIDATION == "false" ]]; then
      restart_hapi_fhir
    fi
    docker::join_network openhim_openhim-core hapi-fhir_public
  ) || {
    log error "Failed to deploy FHIR Training package"
    exit 1
  }

  (
    docker::deploy_service $STACK "${COMPOSE_FILE_PATH}" "docker-compose.yml"
  ) || {
    log error "Failed to deploy package"
    exit 1
  }
}

function destroy_package() {
  docker::stack_destroy $STACK

  docker::prune_configs "fhir-training"
}

main() {
  init_vars "$@"
  import_sources

  if [[ "${ACTION}" == "init" ]] || [[ "${ACTION}" == "up" ]]; then
    log info "Running package in single node mode"

    initialize_package
  elif [[ "${ACTION}" == "down" ]]; then
    log info "Scaling down package"

    docker::scale_services $STACK 0
  elif [[ "${ACTION}" == "destroy" ]]; then
    log info "Destroying package"

    destroy_package
  else
    log error "Valid options are: init, up, down, or destroy"
  fi
}

main "$@"
