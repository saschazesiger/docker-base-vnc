FROM debian:bullseye-slim

ENV TURBOVNC_V=3.0.3

LABEL org.opencontainers.image.authors="janis@js0.ch"
LABEL org.opencontainers.image.source="https://github.com/saschazesiger/"

RUN  echo "deb http://deb.debian.org/debian bullseye contrib non-free" >> /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y install --no-install-recommends wget locales procps xvfb wmctrl x11vnc fluxbox fbsetbg screen libxcomposite-dev libxcursor1 xauth python3 supervisor dbus-x11 x11-xserver-utils curl unzip gettext pulseaudio pavucontrol trickle ffmpeg fonts-takao fonts-arphic-uming libgtk-3-0 && \
	touch /etc/locale.gen && \
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen && \
	apt-get -y install --reinstall ca-certificates && \
	rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
	wget -O /tmp/turbovnc.deb https://sourceforge.net/projects/turbovnc/files/${TURBOVNC_V}/turbovnc_${TURBOVNC_V}_amd64.deb/download && \
	dpkg -i /tmp/turbovnc.deb && \
	rm -rf /opt/TurboVNC/java /opt/TurboVNC/README.txt && \
	cp -R /opt/TurboVNC/bin/* /bin/ && \
	rm -rf /opt/TurboVNC /tmp/turbovnc.deb && \
	sed -i '/# $enableHTTP = 1;/c\$enableHTTP = 0;' /etc/turbovncserver.conf

COPY /x11vnc /usr/bin/x11vnc
RUN chmod 751 /usr/bin/x11vnc


RUN mkdir /browser && \
	mkdir /opt/scripts && \
	useradd -d /browser -s /bin/bash "browser" && \
	chown -R "browser" /browser && \
	ulimit -n 2048

ADD /server /opt/scripts/
COPY /start-audio.sh /opt/scripts/
COPY /conf/ /etc/.fluxbox/
RUN chmod -R 770 /opt/scripts/

RUN echo 'session.screen0.rootCommand: fbsetbg -f /etc/.fluxbox/background.jpg' >> /root/.fluxbox/init



COPY default.pa /etc/pulse/default.pa
RUN adduser root pulse-access
RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu

