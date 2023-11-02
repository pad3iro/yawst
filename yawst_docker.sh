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

TIME=$(date '+%y%m%d_%H%M%S');

. ./yawst.sh

# Script arguments
URL=$1;

if [[ "$URL" == "" ]]; then
    echo -e "$ORANGE""[*]"$RED" No target provided, switching to manual mode""$NC";
    echo -e "$ORANGE""[*]"$BLUE" Run $ docker exec -it \$(docker ps | grep yawst | head -1 | cut -d ' ' -f1) /bin/bash ""$NC";
    /bin/bash;
    exit 0;
fi

echo -e "$ORANGE""[*]"$BLUE" Starting scans against target: $WORKING_DIR""$NC";

create_working_dir;
run_nmap;
run_nikto;
run_wafw00f;
run_twa;
run_testssl;
run_whatweb;
run_ffuf;

echo -e "$ORANGE""[*]"$BLUE" Scans completed""$NC";

echo -e "$ORANGE""[*]"$BLUE" Preparing report""$NC";

create_report;

echo -e "$ORANGE""[*]"$BLUE" Report complete""$NC";

exit 0;
