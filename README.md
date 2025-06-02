# HackScripts?

## What is HackScripts?

HackScripts is a collection of scripts that I use to automate the setup of my servers and development environments. The scripts are written in bash and are tested on Ubuntu 22.04 LTS.

## How to use HackScripts?

To use HackScripts, you can clone the repository and run the scripts that you need. The scripts are organized into folders based on their purpose. The `setup` folder contains scripts that set up the development environment, the `server` folder contains scripts that set up the server environment, and the `security` folder contains scripts that set up security features.


## Scripts List

| Script | Description | Status | Published By | Published On |
| --- | --- | --- | --- | --- |
 [install_miniconda.sh](setup/install_miniconda.sh) | Script to set up Miniconda on a Linux system | Not tested | Unknown | Unknown |
 [cythonize_project.sh](other/cythonize_project.sh) | 🚀 Python Build System with Cython | tested | Deepak Raj | 2025-06-02 |
 [setup_docker_centos.sh](setup/setup_docker_centos.sh) | Script to install Docker and Docker Compose on centos system | tested | Deepak Raj | 2024-09-25 |
 [notification.sh](other/notification.sh) | Function to send notifications | tested | Deepak Raj | 2024-08-30 |
 [setup_gh_ssh.sh](setup/setup_gh_ssh.sh) | Script to setup SSH keys for multiple GitHub accounts | tested | Deepak Raj | 2024-08-29 |
 [setup_vscode.sh](setup/setup_vscode.sh) | Script to install Visual Studio Code on a Linux system | tested | Deepak Raj | 2024-08-28 |
 [setup_time_sync.sh](server/setup_time_sync.sh) | This script sets up NTP or systemd-timesyncd on Ubuntu | tested | Deepak Raj | 2024-08-28 |
 [setup_ssh.sh](setup/setup_ssh.sh) | setup open ssh server on ubuntu | tested | Deepak Raj | 2024-08-28 |
 [setup_redis_server.sh](database/setup_redis_server.sh) | Script to setup Redis server on a Linux system | tested | Deepak Raj | 2024-08-28 |
 [setup_postgres.sh](database/setup_postgres.sh) | Script to setup PostgreSQL and pgAdmin on a Linux system | not tested | Deepak Raj | 2024-08-28 |
 [setup_docker.sh](setup/setup_docker.sh) | Script to install Docker and Docker Compose on a Linux system | tested | Deepak Raj | 2024-08-28 |
 [install_fail2ban.sh](security/install_fail2ban.sh) | Script to install and configure fail2ban on Ubuntu | tested | Deepak Raj | 2024-08-28 |
 [create_conda_env.sh](setup/create_conda_env.sh) | Script to create a new Conda environment with the latest Python version | tested | Deepak Raj | 2024-08-28 |
 [basic_setup.sh](setup/basic_setup.sh) | Script for basic server setup on a Linux system | tested | Deepak Raj | 2024-08-28 |



## Contributing

If you have a script that you would like to add to HackScripts, feel free to open a pull request. Please make sure that the script is well-documented and tested before submitting it.
