FROM ubuntu:20.04

# install dependencies
RUN  apt-get update \
  && apt-get install -y wget unzip xvfb libxtst6 libxrender1 xterm socat procps


# set ARG variables, secrets inyected
ARG TWSUSERID=xxxxxx
ARG TWSPASSWORD=yyyyy

# set environment variables
ENV APP=GATEWAY \
    IBC_INI=/root/ibc/config.ini \
    IBC_PATH=/opt/ibc \
    JAVA_PATH_ROOT=/opt/i4j_jres \
    LOG_PATH=/opt/ibc/logs \
    TWS_INSTALL_LOG=/root/Jts/tws_install.log \
    TWS_PATH=/root/Jts \
    TWS_SETTINGS_PATH=/root/Jts \
    TWS_INSTALLATION_DIR=/root/Jts/ibgateway/1019



# make dirs
RUN mkdir -p /tmp && mkdir -p ${IBC_PATH} && mkdir -p ${TWS_PATH} 
# && mkdir -p ${TWS_INSTALLATION_DIR}
# download IB TWS
RUN wget -q -O /tmp/ibgw.sh https://download2.interactivebrokers.com/installers/ibgateway/stable-standalone/ibgateway-stable-standalone-linux-x64.sh
RUN chmod +x /tmp/ibgw.sh

# download IBC
RUN wget -q -O /tmp/IBC.zip https://github.com/IbcAlpha/IBC/releases/download/3.8.1/IBCLinux-3.8.1.zip
RUN unzip /tmp/IBC.zip -d ${IBC_PATH}
RUN chmod +x ${IBC_PATH}/*.sh ${IBC_PATH}/*/*.sh

# install TWS, write output to file so that we can parse the TWS version number later
# skipping warning messages 
# printf "/root/Jts/ibgateway/1019\nn" |  /tmp/ibgw.sh
# installing on the default path  (y)
# run after installation no
# more info https://www.baeldung.com/linux/bash-interactive-prompts
RUN printf "${TWS_INSTALLATION_DIR}\\nn"  | /tmp/ibgw.sh >> ${TWS_INSTALL_LOG} 
# "/root/Jts/ibgateway/1019\nn"

RUN echo  ${TWSUSERID} 
RUN echo  ${TWSPASSWORD}

# RUN echo  ${TWSUSERID} >> ${TWS_INSTALL_LOG} 
# RUN echo  ${TWSPASSWORD}  >> /${TWS_INSTALL_LOG} 


# remove downloaded files
RUN rm /tmp/ibgw.sh /tmp/IBC.zip

# copy IBC/Jts configs
COPY config/config.ini ${IBC_INI}

RUN echo "IbLoginId=" >> config/test_sed.delete
RUN echo "IbPassword=" >> config/test_sed.delete

RUN cat  config/test_sed.delete | grep IbLoginId 
RUN cat  config/test_sed.delete | grep IbPassword 



COPY config/jts.ini ${TWS_PATH}/jts.iniUSE

# copy cmd script 
WORKDIR /home
COPY cmd.sh cmd.sh
RUN chmod +x cmd.sh

# set display environment variable (must be set after TWS installation)
ENV DISPLAY=:0


# CHANGE INITIAL USER DATA PER CONNECTION 
RUN sed -i -E "s/IbLoginId\=.+/IbLoginId=${TWSUSERID}/"  ${IBC_INI}
RUN sed -i -E "s/IbPassword\=.+/IbPassword=${TWSPASSWORD}/"  ${IBC_INI}

RUN cat   ${IBC_INI} | grep IbLoginId 
RUN cat   ${IBC_INI} | grep IbPassword 


# execute cmd script
CMD ./cmd.sh
