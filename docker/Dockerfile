FROM nvcr.io/nvidia/isaac/ros:x86_64-ros2_humble_23aced29fb80f407b727eec37775e30e

###################################
# Environment_variable_preference #
###################################
ARG LOCAL_UID
ARG LOCAL_GID
ARG USER_NAME

ENV USER_NAME=${USER_NAME}
ENV USER_ID=${LOCAL_UID:-1000}
ENV GROUP_ID=${LOCAL_GID:-1000}

ENV HOMEPATH=/home/${USER_NAME}

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
RUN apt-get update -q && \
    apt-get install -yq \
        locales \
        locales-all && \
    sed -i '/ja_JP.UTF-8/s/^# //g' /etc/locale.gen
    
RUN locale-gen ja_JP.UTF-8

ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

# Install basic apps
RUN apt-get update -q && \
    apt-get install -yq \
        language-pack-ja \
        software-properties-common \
        bash-completion \
        lsb-release \
        alsa-utils \
        pulseaudio-utils \
        dpkg-dev \
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

#######################
# Add $USER_NAME user #
#######################
# Add sudo user
# Remove existing user with the same UID if it exists
RUN if id -u ${USER_ID} >/dev/null 2>&1; then \
        EXISTING_USER=$(id -nu ${USER_ID}); \
        userdel -r $EXISTING_USER 2>/dev/null || true; \
    fi && \
    useradd --create-home --home-dir ${HOMEPATH} --shell /bin/bash --user-group --groups adm,sudo,audio,video -u ${USER_ID} ${USER_NAME} && \
    groupmod -g ${GROUP_ID} -o ${USER_NAME} && \
    echo ${USER_NAME}:robotgroup | chpasswd && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set user
ENV USER=${USER_NAME}

# Set HOME position
WORKDIR ${HOMEPATH}
RUN /bin/bash -c ". ${HOMEPATH}/.bashrc"

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
USER ${USER_NAME}

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

# Switch back to user for workspace setup
USER ${USER_NAME}

# Configure ROS environment only if ROS is installed
RUN /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && source ~/.bashrc" && \
    rosdep update && \
    mkdir -p ~/colcon_ws/src && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo "export ROS_DOMAIN_ID=10" >> ~/.bashrc && \
    echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc && \
    echo "export _colcon_cd_root=/opt/ros/${ROS_DISTRO}/" >> ~/.bashrc && \
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc && \
    echo "source ~/colcon_ws/install/setup.bash" >> ~/.bashrc;
    
# Create bash aliases (only for ROS builds)
RUN echo "alias cb='CURRENT_DIR=\`pwd\` && cd /home/\${USER}/colcon_ws/ && colcon build --symlink-install && source ~/.bashrc && cd \${CURRENT_DIR}'" >> /home/${USER}/.bash_aliases && \
    echo "" >> /home/${USER}/.bash_aliases;
    
# User specific environment variables
RUN echo "export PYTHONDONTWRITEBYTECODE=1" >> /home/${USER}/.bash_aliases && \
    echo "export PS1='\[\e[1;33;40m\]\$CONTAINER_NAME\[\e[0m\] \${debian_chroot:+(\$debian_chroot)}\[\033[01;32m\]\u@\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /home/${USER}/.bash_aliases

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
USER ${USER_NAME}

# Set HOME position
WORKDIR ${HOMEPATH}

# Create entrypoint script
RUN echo '#!/bin/bash' > ${HOMEPATH}/entrypoint.sh && \
    echo 'set -e' >> ${HOMEPATH}/entrypoint.sh && \
    echo 'if [ -d "${HOMEPATH}/colcon_ws/src" ]; then' >> ${HOMEPATH}/entrypoint.sh; \
    echo '    find ${HOMEPATH}/colcon_ws/src \( -name "*.py" -o -name "*.sh" \) -exec chmod 755 {} +' >> ${HOMEPATH}/entrypoint.sh; \
    echo 'fi' >> ${HOMEPATH}/entrypoint.sh; \
    echo 'source /opt/ros/${ROS_DISTRO}/setup.bash 2>/dev/null || true' >> ${HOMEPATH}/entrypoint.sh; \
    echo 'exec "$@"' >> ${HOMEPATH}/entrypoint.sh && \
    chmod +x ${HOMEPATH}/entrypoint.sh

ENTRYPOINT ["bash", "-c", "${HOMEPATH}/entrypoint.sh bash"]
