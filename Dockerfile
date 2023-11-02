FROM golang:latest AS go-build
RUN go install github.com/ffuf/ffuf@latest

FROM ubuntu:latest AS python-build
RUN apt update && apt install git python3 python3-setuptools python3-pip -y

WORKDIR /python-tools

RUN git clone --depth 1 https://github.com/opsdisk/pagodo.git
RUN pip install -r pagodo/requirements.txt
RUN python3 -m pip install pyinstaller
RUN pyinstaller --onefile pagodo/pagodo.py

RUN git clone --depth 1 https://github.com/wafpassproject/wafpass
RUN pyinstaller --onefile wafpass/wafpass.py

RUN python3 -m pip install xmltodict json2html
ADD resources/utils/converter.py converter.py
RUN pyinstaller --onefile converter.py

ADD resources/utils/whatweb_to_html.py whatweb_to_html.py
RUN pyinstaller --onefile whatweb_to_html.py

FROM ubuntu:latest
RUN apt update && apt install nikto whatweb wafw00f bash jq nmap net-tools dnsutils netcat-openbsd python3 wget git bsdmainutils xsltproc curl -y

WORKDIR /yawst

COPY --from=go-build /go/bin/ffuf ./tools/
COPY --from=python-build /python-tools/dist/pagodo ./tools/
COPY --from=python-build /python-tools/dist/wafpass ./tools/

ADD resources resources
COPY --from=python-build /python-tools/wafpass/payloads resources/payloads
COPY --from=python-build /python-tools/dist/converter resources/utils/converter.py
COPY --from=python-build /python-tools/dist/whatweb_to_html resources/utils/whatweb_to_html.py

ADD yawst_docker.sh .
ADD yawst.sh .

RUN mkdir results

RUN groupadd -r yawst && useradd -r -g yawst yawst && chown -R yawst:yawst .
USER yawst:yawst

RUN wget https://raw.githubusercontent.com/trailofbits/twa/master/twa -P ./tools/
RUN chmod +x ./tools/twa

RUN git clone --depth 1 https://github.com/drwetter/testssl.sh.git ./tools/testssl.sh
RUN ln -s /yawst/tools/testssl.sh/testssl.sh /yawst/tools/testssl

RUN chmod +x yawst_docker.sh

ENTRYPOINT ["./yawst_docker.sh"]