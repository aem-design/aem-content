#!/bin/bash

VLT="$(pwd)/bin/vlt"
REPO="$(pwd)/lib"
VLT_HOME="$(pwd)/bin"

function vltCheckout() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}
    local CRX_JCR_ROOT=${3?Please specify JCR ROOT PATH}
    local CRX_FILTER=${4?Please specify FLTER PATH}

    $VLT --credentials $CRX_CREDENTIALS checkout --force --filter $CRX_FILTER $CRX_HOST $CRX_JCR_ROOT
}

function vltExport() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}
    local CRX_JCR_ROOT=${3?Please specify JCR ROOT PATH}
    local ROOT_PATH=${4?Please specify ROOT PATH}
    local VLT_FLAGS=${5:-}

    debug "$VLT $VLT_FLAGS --credentials $CRX_CREDENTIALS export -v $CRX_HOST $ROOT_PATH $CRX_JCR_ROOT" "info" 
    $VLT $VLT_FLAGS --credentials $CRX_CREDENTIALS export -v $CRX_HOST $ROOT_PATH $CRX_JCR_ROOT
}


function vltImport() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}
    local CRX_JCR_ROOT=${3?Please specify JCR ROOT PATH}
    local ROOT_PATH=${4?Please specify ROOT PATH}
    local VLT_FLAGS=${5:-}

    debug "$VLT $VLT_FLAGS --credentials $CRX_CREDENTIALS import -v $CRX_HOST $CRX_JCR_ROOT $ROOT_PATH" "info" 
    $VLT $VLT_FLAGS --credentials $CRX_CREDENTIALS import -v $CRX_HOST $CRX_JCR_ROOT $ROOT_PATH
}


function vltUpdate() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}
    local CRX_JCR_ROOT=${3?Please specify JCR ROOT PATH}
    local CRX_FILTER=${4?Please specify FLTER PATH}

    $VLT --credentials $CRX_CREDENTIALS update --force --filter $CRX_FILTER $CRX_HOST $CRX_JCR_ROOT
}

function vltCheckin() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}
    local CRX_JCR_ROOT=${3?Please specify JCR ROOT PATH}

    $VLT --credentials "$CRX_CREDENTIALS" commit --force ${@:4}
}

function vltSyncRegister() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}
    local CRX_JCR_ROOT=${3?Please specify JCR ROOT PATH}

    #This will sync your CRX to Disk and Vice Versa
    #Install Syc Service
    $VLT --credentials $CRX_CREDENTIALS sync install --uri $CRX_HOST
    #Register Dir for Sync
    $VLT --credentials $CRX_CREDENTIALS sync register --uri $CRX_HOST $CRX_JCR_ROOT
}

function vltSyncUnRegister() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}
    local CRX_JCR_ROOT=${3?Please specify JCR ROOT PATH}

    #UnRegister Dir for Sync
    $VLT --credentials $CRX_CREDENTIALS sync unregister --uri $CRX_HOST $CRX_JCR_ROOT
}


function vltSyncStatus() {
    local CRX_CREDENTIALS=${1?Please specify CREDENTIALS}
    local CRX_HOST=${2?Please specify HOST}

    #UnRegister Dir for Sync
    echo $($VLT --credentials $CRX_CREDENTIALS sync status --uri $CRX_HOST)
}