#!/bin/bash

BASE_DIR=/yawst;

TOOLS_DIR=$BASE_DIR/tools;
RESOURCES_DIR=$BASE_DIR/resources;
RESULTS_DIR=$BASE_DIR/results;

FFUF=$TOOLS_DIR/ffuf;
TWA=$TOOLS_DIR/twa;
TESTSSL=$TOOLS_DIR/testssl;
WAFPASS=$TOOLS_DIR/wafpass;
PAGODO=$TOOLS_DIR/pagodo;
NMAP=$(command -v nmap);
NIKTO=$(command -v nikto);
WHATWEB=$(command -v whatweb);
WAFW00F=$(command -v wafw00f);

TIME=$(date +%T);

# Script arguments
URL=$1;

if [[ "$URL" == "" ]]; then
    print_errors;
fi

. ./yawst.sh

create_working_dir;
run_nmap;
run_nikto;
run_wafw00f;
run_twa;
run_testssl;
run_whatweb;
run_ffuf;

exit;
