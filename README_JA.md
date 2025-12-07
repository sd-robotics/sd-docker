# SD Docker(開発用)

[![README in English](https://img.shields.io/badge/English-d9d9d9)](./README.md)
[![日本語版 README](https://img.shields.io/badge/日本語-d9d9d9)](./README_JA.md)

<p style="display: inline">
  <img src="https://img.shields.io/badge/-Ubuntu_22.04_LTS-555555.svg?style=flat&logo=ubuntu">
  <img src="https://img.shields.io/badge/-Docker-2496ED.svg?style=flat&logo=docker&logoColor=white">
  <img src="https://img.shields.io/badge/-NVIDIA_Isaac_ROS-76B900.svg?style=flat&logo=nvidia&logoColor=white">
  <img src="https://img.shields.io/badge/-ROS2 Humble-%2322314E?style=flat&logo=ROS&logoColor=white">
</p>

## 目次
1. [**概要**](#概要)
2. [**前提条件**](#前提条件)
    1. [NVIDIAドライバの確認](#nvidiaドライバの確認)
    2. [Docker Engineのインストール](#docker-engineのインストール)
    3. [NVIDIA Container Toolkitのインストール](#nvidia-container-toolkitのインストール)
    4. [Isaac ROSイメージのダウンロード](#isaac-rosイメージのダウンロード)
3. [**使い方**](#使い方)
    1. [ワークスペースのセットアップ](#ワークスペースのセットアップ)
    2. [イメージのビルド](#イメージのビルド)
    3. [コンテナの起動](#コンテナの起動)
    4. [コンテナの操作 (Start/Stop)](#コンテナの操作-startstop)
4. [**参考文献**](#参考文献)

---

## 概要
このリポジトリは、**Bot-Q TMS** プラットフォーム開発用のDockerコンテナを作成するためのツール一式を提供します。NVIDIA Isaac ROSベースの開発環境構築を効率化します。

## 前提条件

NVIDIA GPUを搭載したLinux環境が必要です。

| 項目 | 要件 |
| :--- | :--- |
| **OS** | Ubuntu >=22.04 LTS |
| **GPU** | NVIDIA GPU (適切なドライバがインストールされていること) |
| **ソフトウェア** | Docker Engine, NVIDIA Container Toolkit |

### NVIDIAドライバの確認
まず、マシンにNVIDIAドライバがインストールされ、認識されていることを確認してください。
```bash
nvidia-smi
```
以下のような出力がターミナルに表示されるはずです。
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

もし表示されない場合は、ドライバがインストールされていない可能性があります。[こちらのサイト](https://phoenixnap.com/kb/install-nvidia-drivers-ubuntu) などを参考に、ドライバをインストールしてください（GUIでのインストールを推奨します）。

### Docker Engineのインストール
Ubuntu用のDocker Engineを公式リポジトリからインストールします。

1. **Dockerのaptリポジトリを設定:**
    ```bash
    # Dockerの公式GPGキーを追加:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # リポジトリをAptソースに追加:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    ```

2. **Dockerパッケージのインストール:**
    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

3. **root権限なしでDockerを実行できるように設定:**
    ```bash
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```

4. **変更の適用:**
    再起動またはログアウトを行って、グループの変更を適用します。
    ```bash
    reboot
    ```

### NVIDIA Container Toolkitのインストール
Dockerコンテナ上からマシンのGPUを認識・使用するために必要です。

1. **パッケージリポジトリの設定:**
    ```bash
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    sudo apt-get update
    ```

2. **Toolkitのインストール:**
    ```bash
    export NVIDIA_CONTAINER_TOOLKIT_VERSION=1.17.8-1
    sudo apt-get install -y \
        nvidia-container-toolkit=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        nvidia-container-toolkit-base=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        libnvidia-container-tools=${NVIDIA_CONTAINER_TOOLKIT_VERSION} \
        libnvidia-container1=${NVIDIA_CONTAINER_TOOLKIT_VERSION}
    ```

3. **変更の適用:**
    ```bash
    reboot
    ```

### Isaac ROSイメージのダウンロード
開発に使用するベースイメージをダウンロードします。

```bash
docker pull nvcr.io/nvidia/isaac/ros:x86_64-ros2_humble_23aced29fb80f407b727eec37775e30e
```

> [!NOTE]
> イメージのサイズは約20GBあります。十分なディスク容量を確認し、ダウンロード速度を確保するために有線LAN接続の使用を推奨します。

## 使い方

### ワークスペースのセットアップ
このリポジトリをクローンします。

```bash
git clone https://github.com/sd-robotics/sd-docker
```

フォルダをワークスペースにコピーし、新しいコンテナ用にリネームします。

```bash
cp -r sd-docker/ ~/docker_workspaces/
mv ~/docker_workspaces/ ~/{your_new_container_name}/
```

> [!WARNING]
> 同じ名前のコンテナを複数作成することはできません。環境ごとに異なるフォルダ名を付けてください。

### イメージのビルド
ビルドを実行する前に、アーキテクチャ設定を確認してください。

> [!NOTE]
> `docker`フォルダ内の `env.sh` ファイルを編集し、使用するハードウェアに合わせて `ARCHITECTURE` 変数を設定してください：
> ```bash
> ARCHITECTURE=jetson   # PCの場合は 'amd64'、Jetsonの場合は 'jetson'
> ```

ディレクトリに移動し、Dockerイメージをビルドします。
```bash
cd ~/{your_new_container_name}/docker
bash build.sh
```

### コンテナの起動
ビルドが完了したら、コンテナを起動します。

```bash
bash run.sh
```

> [!TIP]
> コンテナ内の `~/colcon_ws/src/` に共有フォルダが作成されます。これを使用して、ホストマシンとコンテナ間でデータをやり取りできます。

### コンテナの操作 (Start/Stop)
作成済みコンテナのライフサイクル管理コマンドです。

**既存のコンテナを開始:**
```bash
docker start {your_new_container_name}
```

**コンテナのターミナルに接続:**
```bash
docker exec -it {your_new_container_name} /bin/bash
```

**コンテナを停止:**
```bash
docker stop {your_new_container_name}
```

## 参考文献
- **Docker Engine インストール:** [公式ドキュメント](https://docs.docker.com/engine/install/ubuntu/)
- **Isaac ROS 開発用ベースイメージ:** [NVIDIA NGC カタログ](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/isaac/containers/ros)
