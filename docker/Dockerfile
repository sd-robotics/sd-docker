FROM nvcr.io/nvidia/isaac/ros:x86_64-ros2_humble_23aced29fb80f407b727eec37775e30e
LABEL maintainer="Valentin Keith"

###################################
# Environment variable preference #
###################################
ARG LOCAL_UNAME
ARG LOCAL_UID
ARG LOCAL_GID

# ENV HOMEPATH=/home/${LOCAL_UNAME}
ENV DEBCONF_NOWARNINGS=yes


######################
# Install basic apps #
######################
# Time-zone setting
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        tzdata

ENV TZ="Asia/Tokyo"

# Set Language
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        locales \
        locales-all && \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen
    
RUN locale-gen ja_JP.UTF-8

ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

# Install basic apps
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
        language-pack-ja \
        software-properties-common \
        bash-completion \
        lsb-release \
        dpkg-dev \
        pkg-config \
        net-tools \
        usbutils \
        libusb-1.0-0-dev \
        libudev-dev \
        iputils-ping \
        pipewire-audio-client-libraries \
        libspa-0.2-bluetooth \
        libspa-0.2-jack \
        alsa-utils \
        apulse \
        uuid-dev \
        fonts-takao-* \
        sudo \
        git-all \
        wget \
        curl \
        nano \
        gedit


###################
# Add user (TODO) #
###################
# Add sudo user
# RUN groupadd -g 1005 ${LOCAL_UNAME} && \
#     useradd --create-home --home-dir ${HOMEPATH} --shell /bin/bash --user-group --groups adm,sudo,audio,video -u ${LOCAL_UID} ${LOCAL_UNAME} && \
#     echo ${LOCAL_UNAME}:spacedata | chpasswd && \
#     echo "${LOCAL_UNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set HOME position
# WORKDIR $HOMEPATH
# RUN . $HOMEPATH/.bashrc

###############
# Install pip #
###############
# Run as root user
USER root

RUN apt-get update -q && \
    apt-get install -yq \
        python3 \
        python3-dev \
        python3-pip

# Run as user
# USER ${LOCAL_UNAME}

# install pip
RUN python3 -m pip install -U \
        pip \
        wheel \
        numpy

################
# ROS settings #
################
# Run as root user
USER root

# Set Cyclone DDS
RUN apt-get update -q && \
    apt-get install -yq \
        ros-${ROS_DISTRO}-cyclonedds \
        ros-${ROS_DISTRO}-rmw-cyclonedds-cpp

##################
# Other settings #
##################
# Run as root user
USER root

# Clean cache
RUN apt-get clean &&\
	apt-get autoremove && \	
    rm -rf /var/lib/apt/lists/ && \
    rm /etc/apt/apt.conf.d/docker-clean

# Set user
# USER ${LOCAL_UNAME}

# Set entrypoint script
COPY ./ros2_entrypoint.sh /
RUN chmod +x /ros2_entrypoint.sh
ENTRYPOINT ["/ros2_entrypoint.sh"]
