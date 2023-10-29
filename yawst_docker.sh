#!/bin/bash

BASEDIR=/yawst;
####

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';

# Script arguments
URL=$1;

# Tools paths
TOOLSDIR=$BASEDIR/tools;
RESOURCESDIR=$BASEDIR/resources;

FFUF=$TOOLSDIR/ffuf;
TWA=$TOOLSDIR/twa;
TESTSSL=$TOOLSDIR/testssl;
WAFPASS=$TOOLSDIR/wafpass;
PAGODO=$TOOLSDIS/pagodo;
NMAP=$(command -v nmap);
NIKTO=$(command -v nikto);
WHATWEB=$(command -v whatweb);
WAFW00F=$(command -v wafw00f);

TIME=$(date +%T);

function print_errors(){
    echo -e "$RED""[!] No URL provided!\\n""$NC";
    echo -e "$GREEN""[*] Usage: $0 URL\\n""$NC";
    echo -e "$GREEN""[*] The URL is the URL to be scanned.""$NC";
    exit;
}

# Check for arguments
if [[ "$URL" == "" ]]; then
    print_errors;
fi

function run_cmd() {
    echo -e "$ORANGE""[*]$GREEN Running the following command:$1""$NC";
    sleep 1;
    eval "$1" >> "$WORKING_DIR"/all_output.txt 2>&1 ;
}

function run_nmap() {
    NMAP_CMD=""$NMAP" "$HOSTNAME" -v -Pn -p 80,8080,443 --script http-apache-negotiation,http-apache-server-status,http-aspnet-debug,http-auth,http-auth-finder,http-config-backup,http-cors,http-cross-domain-policy,http-default-accounts,http-enum,http-errors,http-generator,http-iis-short-name-brute,http-iis-webdav-vuln,http-internal-ip-disclosure,,http-mcmp,http-method-tamper,http-methods,http-ntlm-info,http-open-proxy,http-open-redirect,http-passwd,http-php-version,http-phpself-xss,http-trace,http-traceroute,http-vuln-cve2012-1823,http-vuln-cve2015-1635 -oA "$WORKING_DIR"/nmap-http --stats-every 10s";
    run_cmd "$NMAP_CMD";
}

function run_nikto() {
    NIKTO_CMD=""$NIKTO" -h "$URL" -timeout 3 -maxtime 7m -output "$WORKING_DIR"/nikto.txt";
    run_cmd "$NIKTO_CMD";
}

function run_wafw00f() {
    WAFW00F_CMD=""$WAFW00F" "$URL"";
    run_cmd "$WAFW00F_CMD";
}

function run_twa() {
    TWA_CMD=""$TWA" -dw "$HOSTNAME"";
    run_cmd "$TWA_CMD";
}

function run_testssl(){
    TESTSSL_CMD=""$TESTSSL" --quiet  -oH "$WORKING_DIR"/testssl.html --warnings off "$URL"";
    run_cmd "$TESTSSL_CMD";
}

function run_whatweb(){
    WHATWEB_CMD=""$WHATWEB" "$URL"";
    run_cmd "$WHATWEB_CMD";
}

function run_ffuf(){
    FFUF_CMD=""$FFUF" -w "$RESOURCESDIR"/wordlists/directory-list-lowercase-2.3-small.txt -u "$URL"/FUZZ";
    run_cmd "$FFUF_CMD";
}

# Create working directory based on TARGET name
HOSTNAME=$(echo "$URL" | sed -e 's/^http\(\|s\):\/\///g' | sed -e 's/\/.*//');
WORKING_DIR="$HOSTNAME"-"$TIME";
echo -e "$ORANGE""[*] Creating working directory for output: ./$WORKING_DIR""$NC";
mkdir ./"$WORKING_DIR";


sleep 1;

run_nmap;
run_nikto;
run_wafw00f;
run_twa;
run_testssl;
run_whatweb;
run_ffuf;
exit
