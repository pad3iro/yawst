# Yet Another Web Scanning Toolchain

#### Build and run

mkdir -p results; chmod 777 results; #to be writable by the container

docker build -t yawst .

docker run -v $(pwd)/results:/yawst/results -it yawst https://www.hackthissite.org/

#### Tools list
* https://github.com/ffuf/ffuf ( https://github.com/ffuf/ffuf/wiki )

* https://github.com/sullo/nikto

* https://github.com/nmap/nmap

* https://github.com/opsdisk/pagodo (TODO)

* https://github.com/drwetter/testssl.sh

* https://github.com/trailofbits/twa

* https://github.com/wafpassproject/wafpass (TODO)

* https://github.com/EnableSecurity/wafw00f

* https://github.com/urbanadventurer/WhatWeb
  