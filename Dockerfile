FROM wbh16/debian_min10:latest

#ENV DEBIAN_FRONTEND noninteractive

LABEL maintainer="wbh16 <wbhenriques@gmail.com>"

#VOLUME /var/log/asterisk

#EXPOSE 5060/udp 5060/tcp 4569/udp

#RUN apt-get install openssl libxml2-dev libncurses5-dev uuid-dev sqlite3 libsqlite3-dev pkg-config libjansson-dev -y

RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y && apt-get autoclean \
&& apt-get install libpri1.4 -y && apt-get install dahdi -y && apt-get install asterisk asterisk-mp3 -y && apt-get install asterisk-dahdi -y \
&& echo "America/Sao_Paulo" > /etc/timezone && rm /etc/localtime && ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

COPY configs/conf_padrao/ /etc/asterisk/ 
COPY configs/audio/pt_BR /usr/share/asterisk/sounds/pt_BR
#COPY configs/custom/ /var/lib/asterisk/sounds/custom/

RUN mkdir -p /usr/src/codecs/opus \
&& cd /usr/src/codecs/opus \
&& apt-get update && apt-get install curl \
&& curl -vsL http://downloads.digium.com/pub/telephony/codec_opus/asterisk-16.0/x86-64/codec_opus-16.0_current-x86_64.tar.gz | tar --strip-components 1 -xz \
&& chmod -R 644 /usr/src/codecs/opus && chmod -R 750 /var/spool/asterisk \
&& cp -af *.so /usr/lib/asterisk/modules/ \
&& cp -af codec_opus_config-en_US.xml /usr/share/asterisk/documentation/ && cd / \
&& rm -rf /usr/src/codecs/opus \
&& apt-get purge curl -y \
&& chmod -R 640 /etc/asterisk/sip.conf /etc/asterisk/iax.conf /etc/asterisk/extensions.conf \
&& find /usr/share/asterisk/sounds/pt_BR/ -type d | xargs chmod 755 && find /usr/share/asterisk/sounds/pt_BR/ -type f | xargs chmod 644 \
&& chown -R root.root /usr/share/asterisk/sounds/pt_BR/ \
&& chown -R asterisk:asterisk /var/lib/asterisk /var/log/asterisk /var/spool/asterisk /etc/asterisk \
&& rm -rf /var/lib/apt/lists/*

#/var/run/asterisk 

ENTRYPOINT ["/usr/sbin/asterisk", "-vvvdddf", "-T", "-W", "-U", "asterisk", "-p"]

#CMD ["/usr/sbin/asterisk", "-vvvdddf", "-T", "-W", "-U", "asterisk", "-p"]

