ARG ARCHITECTURE

# Multi-stage build approach to select base image based on ARCHITECTURE
FROM nvcr.io/nvidia/isaac/ros:x86_64-ros2_humble_23aced29fb80f407b727eec37775e30e AS base-amd64
FROM nvcr.io/nvidia/isaac/ros:aarch64-ros2_humble_77e6a678c2058abf96bedcb8f7dd4330 AS base-jetson

# Select the appropriate base image
FROM base-${ARCHITECTURE} AS base

###################################
# Environment_variable_preference #
###################################
ARG USER_ID=${LOCAL_UID:-1000}
ARG GROUP_ID=${LOCAL_GID:-1000}
ARG USERNAME
ARG HOME=/home/${USERNAME}

ENV DEBCONF_NOWARNINGS=yes
ENV DEBIAN_FRONTEND=noninteractive

######################
# Install basic apps #
######################
# Time-zone setting
RUN apt-get update -q && \
    apt-get install -yq \
        tzdata

ENV TZ="Asia/Tokyo"

# Set Language
RUN apt-get install -yq \
        locales && \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen ja_JP.UTF-8

ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja

# Install basic apps
RUN apt-get install -yq \
        language-pack-ja \
        software-properties-common \
        bash-completion \
        lsb-release \
        dpkg-dev \
        alsa-utils \
        pulseaudio \
        pulseaudio-utils \
        portaudio19-dev \
        pkg-config \
        net-tools \
        usbutils \
        libusb-1.0-0-dev \
        libudev-dev \
        iputils-ping \
        uuid-dev \
        sudo \
        git-all \
        wget \
        curl \
        nano \
        gedit

###############
# Install pip #
###############
RUN apt-get update -q && \
    apt-get install -yq \
        python3 \
        python3-dev \
        python3-pip

#######################
# Add ${USERNAME} user #
#######################
# Add sudo user
# Remove existing user with the same UID if it exists
RUN if id -u ${USER_ID} >/dev/null 2>&1; then \
        EXISTING_USER=$(id -nu ${USER_ID}); \
        userdel -r ${EXISTING_USER} 2>/dev/null || true; \
    fi && \
    useradd --create-home --home-dir ${HOME} --shell /bin/bash --user-group --groups adm,sudo,audio,video -u ${USER_ID} ${USERNAME} && \
    groupmod -g ${GROUP_ID} -o ${USERNAME} && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set user
ENV USER=${USERNAME}

# Run as user
USER ${USERNAME}

# install pip packages
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

# Switch back to user for workspace setup
USER ${USERNAME}

# Configure ROS environment only if ROS is installed
RUN rosdep update && \
    mkdir -p ~/colcon_ws/src && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo "export ROS_DOMAIN_ID=10" >> ~/.bashrc && \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc && \
    # Create bash aliases (only for ROS builds)
    echo "alias cb='CURRENT_DIR=\`pwd\` && cd /home/\${USER}/colcon_ws/ && colcon build --symlink-install && source ~/.bashrc && cd \${CURRENT_DIR}'" >> /home/${USER}/.bash_aliases && \
    echo "" >> /home/${USER}/.bash_aliases;

# User specific environment variables
RUN echo "export PYTHONDONTWRITEBYTECODE=1" >> /home/${USER}/.bash_aliases && \
    echo "export PS1='\[\e[1;33;40m\]\${CONTAINER_NAME}\[\e[0m\] \${debian_chroot:+(\${debian_chroot})}\[\033[01;32m\]\u@\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/${USER}/.bash_aliases

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
USER ${USERNAME}

# Set HOME position
WORKDIR ${HOME}
