#!/bin/bash

host=$1
max_test=30

TLS_BASE_URL_DEFAULT="https://tls-observatory.services.mozilla.com"
HTTP_BASE_URL_DEFAULT="https://http-observatory.security.mozilla.org"



################################################################################
# C B R   LIB
_B="\e[34m"
_R="\e[31m"
_G="\e[32m"
_N="\e[0m"
function pb()
{
    echo -e "${_B}$1${_N}"
}
function pr()
{
    echo -e "${_R}$1${_N}"
}
function pg()
{
    echo -e "${_G}$1${_N}"
}
function pbr()
{
    echo -e "${_B}$1 : ${_R}✘${_N}"
}
function pbg()
{
    echo -e "${_B}$1 : ${_G}✔${_N}"
}
function tab()
{
    if [[ $1 -eq 0 ]]; then
        cat -
    fi
    t="$(printf %${1}s)"
    sed "s|^|${t}|"
}
################################################################################

function http()
{
    host=$1
    pb "test http"
    pb "  ask analyze (max 10s to get a result)"
    state="PENDING"
    i=1
    while (( $i < $max_test )); do
        let i++
        state=$(curl --data "hidden=true" ${HTTP_BASE_URL}/api/v1/analyze?host=${host} 2>/dev/null | jq .state)
        if [[ $state = '"FINISHED"' ]]; then
            break
        fi
        sleep 0.5
    done
    if [[ $state != '"FINISHED"' ]]; then
        pr "    unable to get a FINISHED state"
        pb "    Exit, the test http"
        return
    fi
    scan_id=$(curl --data "hidden=true" ${HTTP_BASE_URL}/api/v1/analyze?host=${host} 2>/dev/null | jq .scan_id)
    pg "    success: scan_id is ${scan_id}"
    #
    pb "  get scan result (head 10) with the cmd:"
    pb "    curl ${HTTP_BASE_URL}/api/v1/getScanResults?scan=${scan_id}"
    curl ${HTTP_BASE_URL}/api/v1/getScanResults?scan=${scan_id} 2>/dev/null | tab 4 | head -10
}

function tls()
{
    host=$1
    pb "test tls"
    pb "  ask scan"
    scan_id=$(curl --data "target=${host}&rescan=False" ${TLS_BASE_URL}/api/v1/scan 2>/dev/null | jq .scan_id)
    pb "    scan_id is ${scan_id}"
    #
    pb "  get the result (max 10s to get a result) with the cmd:"
    i=1
    completion_perc=0
    while (( $i < $max_test )); do
        let i++
        completion_perc=$(curl ${TLS_BASE_URL}/api/v1/results?id=${scan_id} 2>/dev/null | jq .completion_perc)
        if [[ $completion_perc -eq 100 ]]; then
            break
        fi
        sleep 0.5
    done
    if [[ $completion_perc -ne 100 ]]; then
        pr "    unable to get a cempletion_perc = 100"
        pb "    Exit, the test http"
        return
    fi
    pb "    curl ${TLS_BASE_URL}/api/v1/results?id=${scan_id}"
    curl ${TLS_BASE_URL}/api/v1/results?id=${scan_id} 2>/dev/null | jq . | tab 4 | head -10
}

if [ -z "$TLS_BASE_URL" -o -z "$HTTP_BASE_URL" ] ; then
    pb "Info:"
fi
if [[ -z $TLS_BASE_URL ]]; then
    pr "  TLS_BASE_URL not defined, let's use the DEFAULT: ${TLS_BASE_URL_DEFAULT}"
fi
if [[ -z $HTTP_BASE_URL ]]; then
    pr "  HTTP_BASE_URL not defined, let's use the DEFAULT: ${HTTP_BASE_URL_DEFAULT}"
fi
if [ -z "$TLS_BASE_URL" -o -z "$HTTP_BASE_URL" ] ; then
    pb "   Normally when api are not proxied, the mozzila_observatory_test.bash should be executed with:"
    pb "   TLS_BASE_URL=http://127.0.0.1:8083 HTTP_BASE_URL=http://127.0.0.1:57001 ./mozilla_observatory_test.bash <host_to_test>"
fi

TLS_BASE_URL=${TLS_BASE_URL:-${TLS_BASE_URL_DEFAULT}}
HTTP_BASE_URL=${HTTP_BASE_URL:-${HTTP_BASE_URL_DEFAULT}}

pb "API used"
pb " - HTTP : ${HTTP_BASE_URL}"
pb " - TLS : ${TLS_BASE_URL}"
http $host
tls $host
