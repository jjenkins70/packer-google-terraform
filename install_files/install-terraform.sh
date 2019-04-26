#!/bin/bash


# operating systems tested on:
#
# 1. Ubuntu 18.04
# Put the link here
# 1. Centos 7
# put the link here

readonly DEFAULT_INSTALL_PATH="/usr/local/bin/terraform"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TMP_DIR="/tmp/install"
readonly SCRIPT_NAME="$(basename "$0")"

function print_usage {
  echo
  echo "Usage: install-terraform [OPTIONS]"
  echo "Options:"
  echo
  echo -e "  --install-bucket\t\tThe GCS location of a folder that contains all the install artifacts. Required"
  echo
  echo -e " one of the following 2 options:"
  echo -e "or..."
  echo -e "  --version\t\t The Terraform version required to be downloaded from Hashicorp Releases. Required."
  echo
  echo "This script can be used to install Terraform and its dependencies. This script has been tested with Ubuntu 18.04 and Centos 7."
  echo
}

function log {
  local -r level="$1"
  local -r func="$2"
  local -r message="$3"
  local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [${SCRIPT_NAME}:${func}] ${message}"
}

function assert_not_empty {
  local func="assert_not_empty"
  local -r arg_name="$1"
  local -r arg_value="$2"

  if [[ -z "${arg_value}" ]]; then
    log "ERROR" ${func} "The value for '${arg_name}' cannot be empty"
    print_usage
    exit 1
  fi
}

function has_yum {
  [ -n "$(command -v yum)" ]
}

function has_apt_get {
  [ -n "$(command -v apt-get)" ]
}

function install_dependencies {
  local func="install_dependencies"
  log "INFO" ${func} "Installing dependencies"

  if $(has_apt_get); then
    sudo apt-get update -y
    sudo apt-get install -y curl unzip jq
    sudo apt-get upgrade -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    export PATH=$PATH:/snap/bin  #gsutil isn't found without the path being updated
  elif $(has_yum); then
    sudo yum update -y
    sudo yum install -y unzip jq curl
    sudo yum install -y epel-release
  else
    log "ERROR" ${func} "Could not find apt-get or yum. Cannot install dependencies on this OS."
    exit 1
  fi
}

function get_terraform_binary {
  local func="get_terraform_binary"
  local -r bin="$1"
  local -r type="$2"
  local -r zip="${TMP_ZIP}"

  if [[ ${type} != 1 ]]; then # get from download
    ver="${bin}"
    assert_not_empty "--version" "${ver}"
    log "INFO" ${func} "Copying Terraform version ${ver} binary to local"
    cd ${TMP_DIR}
    curl -O https://releases.hashicorp.com/terraform/${ver}/terraform_${ver}_linux_amd64.zip
    curl -Os https://releases.hashicorp.com/terraform/${ver}/terraform_${ver}_SHA256SUMS
    curl -Os https://releases.hashicorp.com/terraform/${ver}/terraform_${ver}_SHA256SUMS.sig
    ret=`sha256sum -c terraform_${ver}_SHA256SUMS 2> /dev/null |grep terraform_${ver}_linux_amd64.zip| grep OK | cut -d' ' -f2`
    if [ "${ret}" != "OK" ]; then
      log "ERROR" ${func} "The copy of the Terraform binary failed"
      exit
    else
      log "INFO" ${func} "Copy of Terraform  binary successful"
    fi
    unzip -tqq ${TMP_DIR}/${zip}
    if [ $? -ne 0 ]
    then
      log "ERROR" ${func} "Supplied Terraform binary is not a zip file"
      exit
    fi
  else
    assert_not_empty "--terraform-bin" "${bin}"
    log "INFO" ${func} "Copying Terraform binary from ${ib} to local"
    log "INFO" ${func} "gs://${ib}/install_files/${bin}  ${TMP_DIR}/${zip}"
    gsutil cp "gs://${ib}/install_files/${bin}" "${TMP_DIR}/${zip}"
    ex_c=$?
    if [ ${ex_c} -ne 0 ]; then
      log "ERROR" ${func} "The copy of the Terraform binary from ${ib}/${bin} failed"
      exit
    else
      log "INFO" ${func} "Copy of Terraform binary successful"
    fi
    unzip -tqq ${TMP_DIR}/${zip}
    if [ $? -ne 0 ]; then
      log "ERROR" ${func} "Supplied Terraform binary is not a zip file"
      exit
    fi
  fi
}

function install_terraform {
  local func="install_terraform"
  local -r loc="$1"
  local -r tmp="$2"
  local -r zip="$3"

  log "INFO" ${func} "Installing Terraform"
  cd "${tmp}" && unzip -q "${zip}"
  sudo chown root:root terraform
  sudo mv terraform "${loc}"
  sudo setcap cap_ipc_lock=+ep "${loc}"
}

function main {
  local func="main"
  if [ -e ${TMP_DIR} ]; then
    rm -rf "${TMP_DIR}"
  fi
  mkdir "${TMP_DIR}"
  while [[ $# > 0 ]]; do
    local key="$1"

    case "${key}" in
      --help)
        print_usage
        exit
        ;;
      --install-bucket)
        ib="$2"
        shift
        ;;
      --terraform-bin)
        tb="$2"
        TMP_ZIP="terraformd.zip"
        shift
        ;;
      --version)
        version="$2"
        TMP_ZIP="terraform_${version}_linux_amd64.zip"
        shift
        ;;
      *)
        log "ERROR" "${func}" "Unrecognized argument: ${key}"
        print_usage
        exit 1
        ;;
    esac

    shift
  done

  assert_not_empty "--install-bucket" "${ib}"

  log "INFO" "${func}" "Starting Terraform install"
  install_dependencies
  # if there is no version then we are going to get binary from GCS
  # else we download from Terraform site
  if [[ -z ${version} ]]; then
    get_terraform_binary "${tb}" 1
  else
    get_terraform_binary "${version}" 0
  fi
  install_terraform "${DEFAULT_INSTALL_PATH}" "${TMP_DIR}" "${TMP_ZIP}"
  log "INFO" "${func}" "Terraform install complete!"
  sudo rm -rf "${TMP_DIR}"
}

main "$@"
