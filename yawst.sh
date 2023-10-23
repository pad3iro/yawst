#!/bin/bash

#### CHANGE THIS
BASEDIR=/home/user/testi;
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

BFAC=$TOOLSDIR/bfac/bfac;
FFUF=$TOOLSDIR/ffuf/ffuf;
TWA=$TOOLSDIR/twa.sh;
NMAP=$(command -v nmap);

TIME=$(date +%T);

function installer() {
		echo -e "$GREEN""[+] Installing nmap, nikto and dependencies""$NC";
		sleep 1;
    sudo apt install nmap nikto python3-pip python3-venv python3-setuptools golang curl dnsutils jq netcat-openbsd git -y;

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

    echo -e "$GREEN""[+] Installing webanalyze ""$NC";
		if [[ -e "$TOOLSDIR"/webanalyze ]]; then
      rm -rf "$TOOLSDIR"/webanalyze;
    fi
    mkdir "$TOOLSDIR"/webanalyze;
		go install -v github.com/rverton/webanalyze/cmd/webanalyze@latest;
    cp $GOPATH/bin/webanalyze "$TOOLSDIR"/webanalyze/webanalyze;
    #"$TOOLSDIR"/webanalyze/webanalyze -update; Not working after Wappalyzer was removed from github
    wget https://github.com/rverton/webanalyze/blob/master/technologies.json -qP "$TOOLSDIR"/webanalyze/

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
    git clone https://github.com/drwetter/testssl.sh;
    cd "$TOOLSDIR"/testssl.sh;
    rm -rf .????* [[:upper:]]*;

    echo -e "$GREEN""[+] Cloning wafpass ""$NC";
		if [[ -e "$TOOLSDIR"/wafpass ]]; then
      rm -rf "$TOOLSDIR"/wafpass;
    fi
    cd "$TOOLSDIR";
    git clone https://github.com/wafpassproject/wafpass.git
    cd "$TOOLSDIR"/wafpass;
    rm -rf .????* [[:upper:]]*;

    cd "$TOOLSDIR";
    VIRTUAL_ENV="$TOOLSDIR"/.venv;
    python3 -m venv $VIRTUAL_ENV
    source $VIRTUAL_ENV/bin/activate

    echo -e "$GREEN""[+] Cloning and installing pagodo ""$NC";
		if [[ -e "$TOOLSDIR"/pagodo ]]; then
      rm -rf "$TOOLSDIR"/pagodo;
    fi

    git clone https://github.com/opsdisk/pagodo.git;
    pip install -r pagodo/requirements.txt;
    cd "$TOOLSDIR"/pagodo;
    chmod +x pagodo.py;
    rm -rf .????* [[:upper:]]* requirements.txt;

    cd "$TOOLSDIR";
    echo -e "$GREEN""[+] Cloning and installing wafw00f ""$NC";
		if [[ -e "$TOOLSDIR"/wafw00f ]]; then
      rm -rf "$TOOLSDIR"/wafw00f;
    fi

    git clone https://github.com/EnableSecurity/wafw00f;
    python wafw00f/setup.py install 2> /dev/null;
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

# Create working directory based on TARGET name
echo -e "$ORANGE""[*] Creating working directory for output: ./$TARGET-$TIME""$NC";
mkdir ./"$TARGET"-"$TIME";
WORKING_DIR="$TARGET"-"$TIME";
sleep 1;
