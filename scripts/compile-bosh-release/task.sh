#!/bin/bash -exu

export ROOT="${PWD}"
export STEMCELL_VERSION=$(cat "${ROOT}"/stemcell/version)
export RELEASE_VERSION=$(cat "${ROOT}"/bosh-release/version)
export BOSH_DEPLOYMENT="compilation_${RELEASE_NAME}"

function main() {
  upload_stemcell
  upload_release
  force_compilation
  check_existing_release_in_bucket
}

function force_compilation() {
  pushd /tmp > /dev/null
    sed \
      -e "s/REPLACE_ME_RELEASE_VERSION/${RELEASE_VERSION}/g" \
      -e "s/REPLACE_ME_RELEASE_NAME/${RELEASE_NAME}/g" \
      "${ROOT}/ci/scripts/compile-bosh-release/fixtures/compilation.yml" > "compilation.yml"
    bosh -n deploy "/tmp/compilation.yml"
  popd > /dev/null

  pushd "${ROOT}/compiled-bosh-release" > /dev/null
    bosh export-release "${RELEASE_NAME}/${RELEASE_VERSION}" "ubuntu-trusty/${STEMCELL_VERSION}"
  popd > /dev/null

  bosh -n delete-deployment
}

function check_existing_release_in_bucket() {
  pushd "${ROOT}/compiled-bosh-release" > /dev/null
    local filename
    filename=$(ls | grep tgz)

    set +e
    curl -f "https://s3.amazonaws.com/bbl-precompiled-bosh-releases/${filename}" > /dev/null
    if [ $? -eq 0 ]; then
      echo "${filename} already exists on s3. Quitting."
      exit 1
    fi
    set -e
  popd > /dev/null
}

function upload_stemcell() {
  pushd "${ROOT}/stemcell" > /dev/null
    bosh upload-stemcell stemcell.tgz
  popd > /dev/null
}

function upload_release() {
  pushd "${ROOT}/bosh-release" > /dev/null
    bosh upload-release release.tgz
  popd > /dev/null
}

function cleanup_releases() {
  bosh -n clean-up
}

function rollup() {
  set +x
  local input
  input="${1}"

  local output

  IFS=$'\n'
  for line in ${input}; do
    output="${output:-""}\n${line}"
  done

  printf "%s" "${output#'\n'}"
  set -x
}

trap cleanup_releases EXIT
main
