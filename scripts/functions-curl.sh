#!/bin/bash

CURL=$(/usr/bin/which curl)
GREP=$(/usr/bin/which grep)

ACTION_STOP="action=stop"
ACTION_STARTE="action=stop"

function doPost() {
    local LOGIN=${1?Need login}
    local ADDRESS=${2?Need address}
    local SERVICE=${3?Need service}
    local FIELDS=${4?Need fields}

    local RESULT=$($CURL -L -u "$LOGIN" --header Referer:${ADDRESS} -H User-Agent:curl -X POST --connect-timeout 1 --max-time 1 --silent -N "${FIELDS}" "${ADDRESS}${SERVICE}" | $GREP -q "OK" && echo true || echo false)
    echo " -> URL:    ${ADDRESS}${SERVICE}"
    echo "    POST:   ${FIELDS}"
    echo "    RESULT: ${RESULT}"
}

function doSlingPost() {
    local LOGIN=${1?Need login}
    local ADDRESS=${2?Need address}
    local SERVICE=${3?Need service}
    local FIELDS=${4?Need fields}

    local RESULT=$($CURL -L -u "$LOGIN" --header Referer:${ADDRESS} -H User-Agent:curl -X POST --connect-timeout 1 --max-time 1 -w "%{http_code}" -o /dev/null --silent -N "${FIELDS}" "${ADDRESS}${SERVICE}" | $GREP -q "200" && echo true || echo false)
    echo " -> URL:    ${ADDRESS}${SERVICE}"
    echo "    POST:   ${FIELDS}"
    echo "    RESULT: ${RESULT}"
}

function doDelete() {
    local LOGIN=${1?Need login}
    local ADDRESS=${2?Need address}
    local PATH=${3?Need path}

    local RESULT=$($CURL -L -u "$LOGIN" --header Referer:${ADDRESS} -H User-Agent:curl -X DELETE --connect-timeout 1 --max-time 1 -w "%{http_code}" -o /dev/null --silent -N "${ADDRESS}${PATH}" | $GREP -q "204" && echo true || echo false)
    echo " -> URL:    ${ADDRESS}${PATH}"
    echo "    RESULT: ${RESULT}"
}

function doDeletePath() {
    local PATH=${1?Need path}

    doDelete "${AEM_USER}:${AEM_PASS}" "${AEM_SCHEMA}://${AEM_HOST}:${AEM_PORT}" "${PATH}"

}

function doPostFields() {
    local SERVICE=${1?Need service}
    local FIELDS=${2?Need fields}

    doPost "${AEM_USER:-admin}:${AEM_PASS:-admin}" "${AEM_SCHEMA:-http}://${AEM_HOST:-localhost}:${AEM_PORT:-4502}" "${SERVICE}" "${FIELDS}"

}


function doSlingPostFields() {
    local SERVICE=${1?Need service}
    local FIELDS=${2?Need fields}

    doSlingPost "${AEM_USER:-admin}:${AEM_PASS:-admin}" "${AEM_SCHEMA:-http}://${AEM_HOST:-localhost}:${AEM_PORT:-4502}" "${SERVICE}" "${FIELDS}"

}


function compileCurlHeader() {
    echo "-u $1 --header Referer:$2 --connect-timeout 5 --max-time 5 --noproxy '*' --write-out %{http_code} --silent --output /dev/null"
}

function doWorkflowsTurnOff() {
    doSlingPostFields "/system/console/bundles/com.day.cq.cq-mailer" "-F action=stop"
    doSlingPostFields "/system/console/bundles/com.adobe.granite.workflow.core" "-F action=stop"
}

function doWorkflowsTurnOn() {
    doSlingPostFields "/system/console/bundles/com.day.cq.cq-mailer" "-F action=start"
    doSlingPostFields "/system/console/bundles/com.adobe.granite.workflow.core" "-F action=start"
}