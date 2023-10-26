#!/bin/bash

#### CHANGE THIS
BASEDIR=/home/user/test;
####

# Colors
NC='\033[0m';
RED='\033[0;31m';
GREEN='\033[0;32m';
BLUE='\033[0;34m';
ORANGE='\033[0;33m';

# Script arguments
URL=$1;
TARGET=$2;

# Tools paths
TOOLSDIR=$BASEDIR/tools;

FFUF=$TOOLSDIR/ffuf/ffuf;
TWA=$TOOLSDIR/twa/twa;
TESTSSL=$TOOLSDIR/testssl.sh/testssl.sh;
WAFPASS=$TOOLSDIR/wafpass/wafpass;
PAGODO=$TOOLSDIS/pagodo/pagodo;
WAFW00F=$TOOLSDIR/wafw00f/wafw00f;
NMAP=$(command -v nmap);
NIKTO=$(command -v nikto);
WHATWEB=$(command -v whatweb);

TIME=$(date +%T);

function installer() {
    echo -e "$GREEN""[+] Installing nmap, nikto, whatweb and dependencies from APT""$NC";
    sleep 1;
    sudo apt install nmap nikto whatweb python3-pip python3-venv python3-setuptools golang curl dnsutils jq netcat-openbsd git -y;

    echo -e "$GREEN""[+] Creating $BASEDIR/tools directory for cloned tools. Will install a fresh and updated copy of each""$NC";
    if [[ ! -e "$TOOLSDIR" ]]; then
        mkdir -pv "$TOOLSDIR";
    fi

    echo -e "$GREEN""[+] Installing ffuf ""$NC";
    if [[ -e "$TOOLSDIR"/ffuf ]]; then
        rm -rf "$TOOLSDIR"/ffuf;
    fi
    mkdir "$TOOLSDIR"/ffuf;
    go install -v github.com/ffuf/ffuf@latest;
    cp $GOPATH/bin/ffuf "$TOOLSDIR"/ffuf/ffuf;

    echo -e "$GREEN""[+] Downloading twa ""$NC";
    if [[ -e "$TOOLSDIR"/twa ]]; then
        rm -rf "$TOOLSDIR"/twa;
    fi
    mkdir "$TOOLSDIR"/twa;
    wget https://raw.githubusercontent.com/trailofbits/twa/master/twa -qP "$TOOLSDIR"/twa/
    chmod +x "$TOOLSDIR"/twa/twa;

    echo -e "$GREEN""[+] Cloning testssl.sh ""$NC";
    if [[ -e "$TOOLSDIR"/testssl.sh ]]; then
        rm -rf "$TOOLSDIR"/testssl.sh;
    fi
    cd "$TOOLSDIR";
    git clone --depth 1 https://github.com/drwetter/testssl.sh;
    cd "$TOOLSDIR"/testssl.sh;
    ln -s testssl.sh testssl;
    rm -rf .????* [[:upper:]]*;

    echo -e "$GREEN""[+] Cloning wafpass ""$NC";
    if [[ -e "$TOOLSDIR"/wafpass ]]; then
        rm -rf "$TOOLSDIR"/wafpass;
    fi
    cd "$TOOLSDIR";
    git clone --depth 1 https://github.com/wafpassproject/wafpass.git
    cd "$TOOLSDIR"/wafpass;
    rm -rf .????* [[:upper:]]*;
    mv wafpass.py wafpass;
    chmod +x wafpass;

    cd "$TOOLSDIR";
    VIRTUAL_ENV="$TOOLSDIR"/.venv;
    python3 -m venv $VIRTUAL_ENV
    source $VIRTUAL_ENV/bin/activate

    echo -e "$GREEN""[+] Cloning and installing pagodo ""$NC";
    if [[ -e "$TOOLSDIR"/pagodo ]]; then
        rm -rf "$TOOLSDIR"/pagodo;
    fi

    git clone --depth 1 https://github.com/opsdisk/pagodo.git;
    pip install -r pagodo/requirements.txt;
    cd "$TOOLSDIR"/pagodo;
    mv pagodo.py pagodo;
    chmod +x pagodo.py;
    rm -rf .????* [[:upper:]]* requirements.txt;

    cd "$TOOLSDIR";
    echo -e "$GREEN""[+] Cloning and installing wafw00f ""$NC";
    if [[ -e "$TOOLSDIR"/wafw00f ]]; then
        rm -rf "$TOOLSDIR"/wafw00f;
    fi

    git clone --depth 1 https://github.com/EnableSecurity/wafw00f;
    cd wafw00f;
    mv wafw00f wafw00fb;
    mv wafw00fb/bin/wafw00f wafw00f;
    find . ! -name 'wafw00f' -type f -exec rm -f {} +
    rm -rf docs wafw00fb "$TOOLSDIR"/wafw00f.egg-info "$TOOLSDIR"/build;

    deactivate;
}

function print_errors(){
    echo -e "$RED""[!] No URL provided!\\n""$NC";
    echo -e "$GREEN""[*] Usage: $0 URL TARGET\\n""$NC";
    echo -e "$GREEN""[*] The URL is the URL to be scanned.""$NC";
    echo -e "$GREEN""[*] The TARGET is used to create a working directory for all output files.""$NC";
    echo -e "$GREEN""[*] If first time usage, run $0 install after setting the basedir in the top of this script""$NC";
    exit;
}

# Check for arguments
if [[ "$URL" == "" ]]; then
    print_errors;
fi

if [[ "$TARGET" == "" ]] && [[ "$URL" != "install" ]]; then
    print_errors;
fi

if [[ "$URL" == "install" ]]; then
    installer;
    exit;
fi

function run_cmd() {
    echo -e "$ORANGE""[*]$GREEN Running the following command:$1""$NC";
    sleep 1;
    eval "$1" >> "$WORKING_DIR"/all_output.txt 2>&1 ;
}

function run_nmap() {
    
    NMAP_TARGET=$(echo "$URL" | sed -e 's/^http\(\|s\):\/\///g' | sed -e 's/\/.*//');
    
    NMAP_CMD=""$NMAP" "$NMAP_TARGET" -v -Pn -p 80,8080,443 --script http-apache-negotiation,http-apache-server-status,http-aspnet-debug,http-auth,http-auth-finder,http-config-backup,http-cors,http-cross-domain-policy,http-default-accounts,http-enum,http-errors,http-generator,http-iis-short-name-brute,http-iis-webdav-vuln,http-internal-ip-disclosure,,http-mcmp,http-method-tamper,http-methods,http-ntlm-info,http-open-proxy,http-open-redirect,http-passwd,http-php-version,http-phpself-xss,http-trace,http-traceroute,http-vuln-cve2012-1823,http-vuln-cve2015-1635 -oA "$WORKING_DIR"/nmap-http --stats-every 10s";
    
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
    TWA_TARGET=$(echo "$URL" | sed -e 's/^http\(\|s\):\/\///g' | sed -e 's/\/.*//');
    TWA_CMD=""$TWA" -dw "$TWA_TARGET"";
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
    FFUF_CMD=""$FFUF" -w wordlists/directory-list-lowercase-2.3-small.txt -u "$URL"/FUZZ";
    run_cmd "$FFUF_CMD";
}

# Create working directory based on TARGET name
echo -e "$ORANGE""[*] Creating working directory for output: ./$TARGET-$TIME""$NC";
mkdir ./"$TARGET"-"$TIME";
WORKING_DIR="$TARGET"-"$TIME";
sleep 1;

run_nmap;
run_nikto;
run_wafw00f;
run_twa;
run_testssl;
run_whatweb;
run_ffuf;
exit


