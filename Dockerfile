FROM suchja/x11client:latest
MAINTAINER Jan Suchotzki <jan@suchotzki.de>

# Inspired by monokrome/wine
ENV WINE_MONO_VERSION 0.0.8
USER root

# Install some tools required for creating the image
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		curl \
		unzip \
		ca-certificates \
		apt-transport-https

RUN dpkg --add-architecture i386
RUN curl 'https://dl.winehq.org/wine-builds/Release.key' -o Release.key
RUN apt-key add Release.key
RUN echo "deb https://dl.winehq.org/wine-builds/debian/ jessie main" >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y winehq-devel

# Install wine and related packages
#RUN dpkg --add-architecture i386 \
#		&& apt-get update \
#		&& apt-get install -y --no-install-recommends \
#				wine \
#				wine32 \
#		&& rm -rf /var/lib/apt/lists/*

# Use the latest version of winetricks
RUN curl -SL 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' -o /usr/local/bin/winetricks \
		&& chmod +x /usr/local/bin/winetricks

# Get latest version of mono for wine
RUN mkdir -p /usr/share/wine/mono \
	&& curl -SL 'http://sourceforge.net/projects/wine/files/Wine%20Mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi/download' -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi \
	&& chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi

# Wine really doesn't like to be run as root, so let's use a non-root user
USER xclient
ENV HOME /home/xclient
ENV WINEPREFIX /home/xclient/.wine
ENV WINEARCH win32

# Use xclient's home dir as working dir
WORKDIR /home/xclient

RUN echo "alias winegui='wine explorer /desktop=DockerDesktop,1024x768'" > ~/.bash_aliases 
