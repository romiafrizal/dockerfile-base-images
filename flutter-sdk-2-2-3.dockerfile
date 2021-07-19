FROM ubuntu:20.04

ENV UID=1000 \
    GID=1000 \
    USER="developer" \
    JAVA_VERSION="8" \
    FLUTTER_CHANNEL="stable" \
    FLUTTER_VERSION="2.2.3" \
    FLUTTER_GIT_URL="https://github.com/flutter/flutter.git" \
    FLUTTER_HOME="/home/$USER/flutter" \
    FLUTTER_WEB_PORT="8090" \
    FLUTTER_DEBUG_PORT="42000" 

ENV DEBIAN_FRONTEND="noninteractive"
RUN apt-get update \
  && apt-get install --yes --no-install-recommends openjdk-$JAVA_VERSION-jdk curl unzip sed git bash xz-utils libglvnd0 ssh xauth x11-xserver-utils libpulse0 libxcomposite1 libgl1-mesa-glx sudo \
  && rm -rf /var/lib/{apt,dpkg,cache,log}

RUN groupadd --gid $GID $USER \
  && useradd -s /bin/bash --uid $UID --gid $GID -m $USER \
  && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER \
  && chmod 0440 /etc/sudoers.d/$USER

USER $USER
WORKDIR /home/$USER

RUN git clone $FLUTTER_GIT_URL --depth 1 -b $FLUTTER_CHANNEL
RUN cd $FLUTTER_HOME && git checkout tags/$FLUTTER_VERSION 
ENV PATH "$PATH:$FLUTTER_HOME/bin"
RUN flutter config --no-analytics \ 
    && flutter precache  \
    && flutter update-packages\
    && flutter doctor

WORKDIR /home/$USER/app
EXPOSE 8090 42000