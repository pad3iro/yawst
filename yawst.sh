#!/bin/bash

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';

function print_errors(){
    echo -e "$RED""[!] No URL provided!\\n""$NC";
    echo -e "$GREEN""[*] Usage: $0 URL\\n""$NC";
    echo -e "$GREEN""[*] The URL is the URL to be scanned.""$NC";
    echo -e "$GREEN""[*] If not running on docker and it is first time usage, run $0 install after setting the basedir in the top of this script""$NC";
    exit 1;
}

function run_cmd() {
    echo -e "$ORANGE""[*]$GREEN Running the following command:$1""$NC";
    sleep 1;
    eval "$1" >> "$WORKING_DIR"/all_output.txt 2>&1 ;
}

function run_nmap() {
    NMAP_CMD=""$NMAP" "$HOSTNAME" -v -Pn -p 80,8080,443 --script http-apache-negotiation,http-apache-server-status,http-aspnet-debug,http-auth,http-auth-finder,http-config-backup,http-cors,http-cross-domain-policy,http-default-accounts,http-enum,http-errors,http-generator,http-iis-short-name-brute,http-iis-webdav-vuln,http-internal-ip-disclosure,,http-mcmp,http-method-tamper,http-methods,http-ntlm-info,http-open-proxy,http-open-redirect,http-passwd,http-php-version,http-phpself-xss,http-trace,http-traceroute,http-vuln-cve2012-1823,http-vuln-cve2015-1635 -oX "$WORKING_DIR"/nmap.xml";
    #Fast test mode
    #NMAP_CMD=""$NMAP" "$HOSTNAME" -v -Pn -p 443 --script http-apache-negotiation -oX "$WORKING_DIR"/nmap.xml";
    run_cmd "$NMAP_CMD";
}

function run_nikto() {
    NIKTO_CMD=""$NIKTO" -h "$URL" -timeout 3 -maxtime 7m -output "$WORKING_DIR"/nikto.html -Format htm";
    #Fast test mode
    #NIKTO_CMD=""$NIKTO" -h "$URL" -timeout 3 -maxtime 2m -output "$WORKING_DIR"/nikto.html -Format htm";
    run_cmd "$NIKTO_CMD";
}

function run_wafw00f() {
    WAFW00F_CMD=""$WAFW00F" "$URL" -o "$WORKING_DIR"/wafw00f.json";
    run_cmd "$WAFW00F_CMD";
}

function run_twa() {
    TWA_CMD=""$TWA" -dwc "$HOSTNAME" > "$WORKING_DIR"/twa.csv";
    run_cmd "$TWA_CMD";
}

function run_testssl(){
    TESTSSL_CMD=""$TESTSSL" --quiet -oH "$WORKING_DIR"/testssl.html --warnings off "$URL"";
    run_cmd "$TESTSSL_CMD";
}

function run_whatweb(){
    WHATWEB_CMD=""$WHATWEB" "$URL" -U 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36' --log-json="$WORKING_DIR"/whatweb.json";
    run_cmd "$WHATWEB_CMD";
}

function run_ffuf(){
    FFUF_CMD=""$FFUF" -w "$RESOURCES_DIR"/wordlists/common_small.txt -u "$URL"/FUZZ -of html -o "$WORKING_DIR"/ffuf.html";
    #Fast Test mode
    #FFUF_CMD=""$FFUF" -w "$RESOURCES_DIR"/wordlists/log_files_only.txt -u "$URL"/FUZZ -of html -o "$WORKING_DIR"/ffuf.html";
    run_cmd "$FFUF_CMD";
}

function create_working_dir(){
    HOSTNAME=$(echo "$URL" | sed -e 's/^http\(\|s\):\/\///g' | sed -e 's/\/.*//');
    WORKING_DIR="$RESULTS_DIR"/"$HOSTNAME"-"$TIME";
    echo -e "$ORANGE""[*] Creating working directory for output: $WORKING_DIR""$NC";
    mkdir "$WORKING_DIR";
}

function create_report(){
    UTILS_PATH="./resources/utils";
    cp "$UTILS_PATH"/report.html $WORKING_DIR/report.html;
    sed -i "s|%TARGET%|""$URL""|g" $WORKING_DIR/report.html;
    xsltproc $WORKING_DIR/nmap.xml -o $WORKING_DIR/nmap.html
    "$UTILS_PATH"/converter.py $WORKING_DIR/twa.csv;
    "$UTILS_PATH"/converter.py $WORKING_DIR/twa.json $WORKING_DIR/wafw00f.json;
    "$UTILS_PATH"/whatweb_to_html.py $WORKING_DIR/whatweb.json;
    perl -0777 -i -pe 's/<nav>.*<\/nav>//igs' $WORKING_DIR/ffuf.html;
    perl -0777 -i -pe "s/<th>$HOSTNAME<\/th>//igs" $WORKING_DIR/twa.html;
    perl -0777 -i -pe "s/<tr><td>PASS/<tr bgcolor=\"darkseagreen\"><td>PASS/igs" $WORKING_DIR/twa.html;
    perl -0777 -i -pe "s/<tr><td>FAIL/<tr bgcolor=\"indianred\"><td>FAIL/igs" $WORKING_DIR/twa.html;
    perl -0777 -i -pe "s/<tr><td>MEH/<tr bgcolor=\"lightsalmon\"><td>MEH/igs" $WORKING_DIR/twa.html;
    perl -0777 -i -pe "s/<tr><td>SKIP/<tr bgcolor=\"lightsteelblue\"><td>SKIP/igs" $WORKING_DIR/twa.html;
}

