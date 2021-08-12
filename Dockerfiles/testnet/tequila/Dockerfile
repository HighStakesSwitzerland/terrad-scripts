FROM ubuntu:20.04 AS shell

###VARIABLES
ARG DEBIAN_FRONTEND=noninteractive
ARG GO=go1.16.6.linux-amd64.tar.gz
ARG USER=tequila

###INSTALL ALL NECESSARY PACKAGES
RUN apt update && apt upgrade -y
RUN apt install -y build-essential git wget liblz4-tool nodejs npm jq curl lz4 vim net-tools
RUN apt autoremove -y

###CREATE NEW USER $USER
RUN mkdir /home/$USER && useradd -d /home/$USER $USER && usermod -aG sudo $USER &&\
    echo $USER ALL=NOPASSWD: ALL >> /etc/sudoers &&\ 
    sed -i "s#$USER:/bin/sh#/$USER:/bin/bash#" /etc/passwd

###EXPORT THE GO PATHS
RUN echo "USER=$USER" >> /etc/profile
RUN echo 'export GOROOT=/usr/local/go' >> /etc/profile
RUN echo "export GOPATH=/home/$USER/go" >> /etc/profile
RUN echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> /etc/profile
RUN cat /etc/profile >> /home/$USER/.bashrc

###DOWNLOAD AND INSTALL GO AND GO LINTER 
RUN wget https://golang.org/dl/${GO} && tar xf $GO && mv go /usr/local

RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(/usr/local/go/bin/go env GOPATH)/bin v1.41.1

###INCREASE MAXIMUM NUMBER OF OPEN FILES
RUN echo "*                soft    nofile          65535" >> /etc/security/limits.conf
RUN echo "*                hard    nofile          65535" >> /etc/security/limits.conf


FROM shell AS tequila-01

###INSTALL AND BUILD TERRAD
ARG MONIKER='TS_Tequila'
ARG USER=tequila

WORKDIR /home/$USER
RUN git clone https://github.com/terra-project/core/
WORKDIR ./core
RUN git checkout v0.4.6
RUN . /etc/profile && LEDGER_ENABLED=false make install

FROM tequila-01 AS tequila-02
ARG MONIKER='TS_Tequila'
ARG USER=tequila

WORKDIR /home/$USER
RUN mkdir /home/$USER/.terrad
RUN chown $USER:$USER -R /home/$USER/.terrad

RUN su $USER -c ". /etc/profile && terrad init --chain-id=tequila-004 \"$MONIKER\""

RUN echo $USER
#update app.toml and config.toml
RUN sed -i 's#seeds = ""#seeds = "341f51bf381566dfef0fc345c2aa882cbeebd320@public-seed2.terra.dev:36656"#' /home/$USER/.terrad/config/config.toml
RUN sed -i 's#persistent_peers = ""#persistent_peers = "3e4ef3cae6a40862a777e878003d473679f2643b@5.9.224.235:36656,001122a6fca861fcb0abef55ccc8202c2abb8114@37.120.245.175:26656,dc02367d1c959d0cf263ee9e4d2090faf4467837@188.40.78.235:26656,0ebc58b17bb00fcf3ef79e73ae777dfbc2f5c896@193.176.85.155:26656,9b0de4e76f874191ae3b08010b0a7542a73c1098@161.97.75.60:26656"#' /home/$USER/.terrad/config/config.toml
#enable prometheus for monitoring from the host
RUN sed -i 's#prometheus = false#prometheus = true#' /home/$USER/.terrad/config/config.toml
#set minimum gas price (recommended) in order to enable anti-spam by rejecting incoming transactions with implied gas price less than a specified minimum
RUN sed -i 's#minimum-gas-prices = ""#minimum-gas-prices = "0.01133uluna,0.15uusd,0.104938usdr,169.77ukrw,428.571umnt,0.125ueur,0.98ucny,16.37ujpy,0.11ugbp,10.88uinr,0.19ucad,0.14uchf,0.19uaud,0.2usgd,4.62uthb,1.25usek,1.25unok,1.25udkk,2180.0uidr,7.6uphp"#' /home/$USER/.terrad/config/app.toml
#enable access from outside the container
RUN sed -i 's#laddr = "tcp://127.0.0.1:26657"#laddr = "tcp://0.0.0.0:26657"#' /home/$USER/.terrad/config/config.toml
#RUN sed -i 's#proxy_app = "tcp://127.0.0.1:26658"#proxy_app = "tcp://0.0.0.0:26658"#' /home/$USER/.terrad/config/config.toml

FROM tequila-02
ARG USER=tequila

ARG ADDRESS_BOOK_URL=https://raw.githubusercontent.com/TerranStakers/terrad-scripts/main/Dockerfiles/testnet/tequila/addrbook.json
ARG GENESIS=https://raw.githubusercontent.com/terra-money/testnet/master/tequila-0004/genesis.json

RUN curl $GENESIS -o /home/$USER/.terrad/config/genesis.json
RUN curl $ADDRESS_BOOK_URL -o /home/$USER/.terrad/config/addrbook.json
RUN chown $USER:$USER -R /home/$USER/.terrad
RUN chown $USER:$USER /home/$USER/

###LOGIN BY DEFAULT AS $USER
USER $USER

###START TERRAD

CMD . /etc/profile && bash
