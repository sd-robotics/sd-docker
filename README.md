# SD Docker for Development

[![README in English](https://img.shields.io/badge/English-d9d9d9)](./README.md)
[![日本語版 README](https://img.shields.io/badge/日本語-d9d9d9)](./README_JA.md)

<p style="display: inline">
  <img src="https://img.shields.io/badge/-Ubuntu_22.04_LTS-555555.svg?style=flat&logo=ubuntu">
  <img src="https://img.shields.io/badge/-Docker-2496ED.svg?style=flat&logo=docker&logoColor=white">
  <img src="https://img.shields.io/badge/-NVIDIA_Isaac_ROS-76B900.svg?style=flat&logo=nvidia&logoColor=white">
  <img src="https://img.shields.io/badge/-ROS2 Humble-%2322314E?style=flat&logo=ROS&logoColor=white">
</p>

## Table of Contents
1. [**Overview**](#overview)
2. [**Requirements**](#requirements)
    1. [Check Nvidia Drivers](#check-nvidia-drivers)
    2. [Install Docker Engine](#install-docker-engine)
    3. [Install NVIDIA Container Toolkit](#install-nvidia-container-toolkit)
    4. [Download Nvidia Isaac ROS Image](#download-nvidia-isaac-ros-image)
3. [**Usage**](#usage)
    1. [Setup Workspace](#setup-workspace)
    2. [Build Image](#build-image)
    3. [Run Container](#run-container)
    4. [Toggle Container](#toggle-container)
4. [**References**](#references)

---

## Overview
This repository provides the tools and scripts necessary to create Docker Containers for the development of the **Bot-Q TMS** platform. It streamlines the setup of the development environment using NVIDIA Isaac ROS.

## Requirements

You need a Linux environment with an NVIDIA GPU.

| Component | Requirement |
| :--- | :--- |
| **OS** | Ubuntu >= 22.04 LTS |
| **GPU** | NVIDIA GPU with valid drivers |
| **Software** | Docker Engine, NVIDIA Container Toolkit |

### Check Nvidia Drivers
First, ensure that Nvidia drivers are installed and recognized by your machine.
```bash
nvidia-smi
```
You should see output similar to the following:
```text
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.133.07             Driver Version: 570.133.07     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4080 ...    Off |   00000000:01:00.0  On |                  N/A |
+-----------------------------------------+------------------------+----------------------+
```

If the command is not found or no GPU is detected, please refer to [this guide](https://phoenixnap.com/kb/install-nvidia-drivers-ubuntu) to install the drivers (GUI method recommended).

### Install Docker Engine
Install Docker Engine on Ubuntu using the official repository.

1. **Set up Docker's `apt` repository:**
    ```bash
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    ```

2. **Install the Docker packages:**
    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

3. **Configure Docker to run without root privileges:**
    ```bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```

4. **Apply changes:**
    Reboot or logout/login to activate the group changes.
    ```bash
    reboot
    ```

### Install NVIDIA Container Toolkit
This toolkit allows the Docker container to utilize the host's GPU.

1. **Configure the production repository:**
    ```bash
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt-get update
    ```

2. **Install the toolkit:**
    ```bash
    export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
    sudo apt-get install -y \
        nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
    ```

3. **Apply changes:**
    ```bash
    reboot
    ```

### Download Nvidia Isaac ROS image
Download the base image required for development.

```bash
docker pull nvcr.io/nvidia/isaac/ros:x86_64-ros2_humble_23aced29fb80f407b727eec37775e30e
```

> [!NOTE]
> This image is approximately 20GB. Ensure you have sufficient disk space and a stable internet connection (wired recommended).

## Usage

### Setup Workspace
Clone this repository and set up your workspace directory.

```bash
git clone https://github.com/sd-robotics/sd-docker
```

Copy the configuration to a new directory for your specific container instance.

```bash
cp -r sd-docker/ ~/docker_workspaces/
mv ~/docker_workspaces/ ~/{your_new_container_name}/
```

> [!WARNING]
> Container names must be unique. Please ensure specific folder names are used for different environments.

### Build Image
Before building, configure the architecture settings.

> [!NOTE]
> Edit the `env.sh` file inside the `docker` folder. Set the `ARCHITECTURE` variable to match your hardware:
> ```bash
> ARCHITECTURE=jetson   # Use 'amd64' for PC, 'jetson' for Nvidia Jetson
> ```

Navigate to the directory and build the Docker image.

```bash
cd ~/{your_new_container_name}/docker
bash build.sh
```

### Run Container
Once the build is complete, launch the container.

```bash
bash run.sh
```

> [!TIP]
> A shared folder is created at `~/colcon_ws/src/` inside the container, mapping to your local machine for easy data exchange.

### Toggle Container
Commands to manage the container lifecycle.

**Start an existing container:**
```bash
docker start {your_new_container_name}
```

**Enter the container terminal:**
```bash
docker exec -it {your_new_container_name} /bin/bash
```

**Stop the container:**
```bash
docker stop {your_new_container_name}
```

## References
- **Docker Engine Installation:** [Official Documentation](https://docs.docker.com/engine/install/ubuntu/)
- **Isaac ROS Base Image:** [NVIDIA NGC Catalog](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/isaac/containers/ros)
