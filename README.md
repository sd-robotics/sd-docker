# SD Docker for development

This repository allows to create new Docker Containers for the development of Q bot.

## Requirements

You need an environment with Docker Engine in a Nvidia driver-installed machine.

### Check Nvidia Drivers
First, make sure that you have already installed Nvidia drivers in your machine.
```bash
$ nvidia-smi
```
You should be able to see a similar output in your terminal.
```bash
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.133.07             Driver Version: 570.133.07     CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 4080 ...    Off |   00000000:01:00.0  On |                  N/A |
|  0%   36C    P8              8W /  320W |     528MiB /  16376MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A            2499      G   /usr/lib/xorg/Xorg                      236MiB |
|    0   N/A  N/A            2749      G   /usr/bin/gnome-shell                     27MiB |
|    0   N/A  N/A           58057      G   /proc/self/exe                           81MiB |
|    0   N/A  N/A           76752      G   /opt/google/chrome/chrome                 3MiB |
|    0   N/A  N/A           76799      G   ...ersion=20250707-050044.361000         67MiB |
+-----------------------------------------------------------------------------------------+
```

If not, you may not have previously installed Nvidia drivers in your machine.
Please, have a look at this [site](https://phoenixnap.com/kb/install-nvidia-drivers-ubuntu) where it explains how to install the drivers using GUI (recommended method).


### Install Docker Engine
Now, let's install Docker Engine based on Ubuntu
1. Let Ubuntu be able to find Docker Engine
```bash
# Add Docker's official GPG key:
$ sudo apt-get update
$ sudo apt-get install ca-certificates curl
$ sudo install -m 0755 -d /etc/apt/keyrings
$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
$ sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt-get update
```
2. Install Docker Engine
```bash
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

3. Allow to run Docker without root privileges
```bash
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
```

4. Reboot or logout to activate the changes to groups
```bash
$ reboot
```

### Install NVIDIA Container Toolkit

You need this in order to you machine to recognize the installed GPUs over Docker.

1. Let Ubuntu find the package.
```bash
$ curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

$ sudo apt-get update
```

2. Install NVIDIA Container Toolkit.
```bash
$ export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
  sudo apt-get install -y \
      nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
      libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
```

3. Reboot or logout to activate the changes to groups
```bash
$ reboot
```

### Download Nvidia Isaac ROS image
You have now installed Docker in your machine. Now, we need to download the base image that we are going to use for development.

```bash
$ docker pull nvcr.io/nvidia/isaac/ros:x86_64-ros2_humble_23aced29fb80f407b727eec37775e30e
```

> [!NOTE]
> Downloading this image will take around 20GB of your space. Please, make sure that you have enough space, and ensure a wired connection to internet for faster download speeds.

## Usage
If you have not clonned yet this repository, please do it now.
```bash
git clone https://github.com/sd-robotics/sd-docker
```

Now, copy this folder into your workingspace and change its name.

```bash
$ cp sd-docker/ ~/docker_workspaces/
$ mv ~/docker_workspaces/ ~/{your_new_container_name}/
```

> [!WARNING]
> You cannot have multiple containers with the same name, so please keep different names for each folder you create.

After creating your new folder, go inside the `docker` folder and execute the `build.sh` to create a new image.
```bash
$ cd ~/{your_new_container_name}/docker
$ bash build.sh
```

It will take a while if the base image was not downloaded previously.

Once, finished to building the image, you can now create your container.
```bash
$ bash run.sh
```

> [!NOTE]
> You will have a sharing folder in `~/colcon_ws/src/` where you can exchange data between the container and your local machine.


### Toogle a Docker Container

To start an already created container, you need to first start the container.
```bash
$ docker start {your_new_container_name}
```
Once started, let's log into the container terminal.
```bash
$ docker exec -it {your_new_container_name} /bin/bash
```
If you already finished your work in the container, terminate it.
```bash
$ docker stop {your_new_container_name}
```

## References

- Docker Engine: [link](https://docs.docker.com/engine/install/ubuntu/)
- Isaac ROS Dev Base: [link](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/isaac/containers/ros)
