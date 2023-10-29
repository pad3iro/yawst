FROM golang:latest AS go-build
RUN go install github.com/ffuf/ffuf@latest

FROM ubuntu:latest AS python-build
RUN apt update && apt install git python3 python3-setuptools python3-pip -y

WORKDIR /python-tools

RUN git clone https://github.com/opsdisk/pagodo.git
RUN pip install -r pagodo/requirements.txt
RUN python3 -m pip install pyinstaller
RUN pyinstaller --onefile pagodo/pagodo.py

RUN git clone https://github.com/wafpassproject/wafpass
RUN pyinstaller --onefile wafpass/wafpass.py

FROM ubuntu:latest
RUN apt update && apt install bash nikto jq curl wget nmap net-tools dnsutils netcat-openbsd python3 perl-base whatweb git bsdmainutils wafw00f -y

WORKDIR /yawst/resources
ADD wordlists wordlists
COPY --from=python-build /python-tools/wafpass/payloads payloads

WORKDIR /yawst/tools

COPY --from=go-build /go/bin/ffuf .
COPY --from=python-build /python-tools/dist/pagodo .
COPY --from=python-build /python-tools/dist/wafpass .

RUN wget https://raw.githubusercontent.com/trailofbits/twa/master/twa
RUN chmod +x twa

RUN git clone https://github.com/drwetter/testssl.sh.git
RUN ln -s testssl.sh/testssl.sh testssl

WORKDIR /yawst

ENTRYPOINT ["tail", "-f", "/dev/null"]
