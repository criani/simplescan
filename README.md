# SimpleScan Installation Guide

Welcome to the SimpleScan project! This README provides detailed instructions for installing and running SimpleScan either using Docker or directly on your host system.

## Docker Installation (Most Users)

SimpleScan can be easily installed and run in a Docker container. This method is recommended as it encapsulates all the necessary dependencies and doesn't require modifications to your host system.

### Installation Steps
#### Raspbian OS / ARM64 Systems

1. **Download and run the Auto-Install Script**

   Run the following in your `/opt/` directory, or any other directory where you have appropriate permissions and want to install.

   ```sh
   curl -O https://raw.githubusercontent.com/criani/simplescan/main/autoinstall_pi.sh
   chmod +x autoinstall_pi.sh
   sudo ./autoinstall_pi.sh
   ```
   This script will automatically pull and run the autoinstall script on your Pi / ARM64 type system and install Docker (if needed) and the required images, and will set up and start SimpleScan in a Docker container listening on port 5000 of the host system.
   To access SimpleScan simply open a browser and go to `http://<host-IP>:5000` where `<host-IP>` is the IP address of the Docker host.

   NOTE: if you ever need to recreate the container for whatever reason, you can just run the script again. Scans will persist on the host in /opt/simplescan/scans and reports will be in /opt/simplescan/reports. 


#### Ubuntu/Debian

1. **Download and run the Auto-Install Script**

   Run the following in your `/opt/` directory, or any other directory where you have appropriate permissions and want to install.

   ```sh
   curl -s https://raw.githubusercontent.com/criani/simplescan/main/autoinstall.sh | sudo bash
   ```
   This script will automatically pull and run the autoinstall script on your Debian based system and install Docker and docker-compose (if needed) and the required images, and will set up and start SimpleScan in a Docker container listening on port 5000 of the host system.
   To access SimpleScan simply open a browser and go to `http://<host-IP>:5000` where `<host-IP>` is the IP address of the Docker host. Scans will persist on the host in /opt/simplescan/scans and reports will be in /opt/simplescan/reports. 

#### CentOS/Redhat

1. **Download and run the Auto-Install Script**

   Run the following in your `/opt/` directory, or any other directory where you have appropriate permissions and want to install.

   ```sh
   curl -O https://raw.githubusercontent.com/criani/simplescan/main/autoinstall_yum.sh
   chmod +x autoinstall_yum.sh
   sudo ./autoinstall_yum.sh
   ```
   This script will automatically pull and run the autoinstall script on your YUM based system and install Docker (if needed) and the required images, and will set up and start SimpleScan in a Docker container listening on port 5000 of the host system.
   To access SimpleScan simply open a browser and go to `http://<host-IP>:5000` where `<host-IP>` is the IP address of the Docker host. Scans will persist on the host in /opt/simplescan/scans and reports will be in /opt/simplescan/reports. 


## Running Directly on Host (Advanced Users or Contributors)

If you prefer to run SimpleScan directly on your host system, follow these instructions.

### Prerequisites

- Git installed on your system.
- Python environment set up.
- Ensure you have all the required dependencies and Python packages installed.

### Installation Steps

1. **Clone the Repository**

   Use Git to clone the SimpleScan repository to your local machine:

   ```sh
   git clone https://github.com/criani/simplescan.git
   ```

2. **Navigate to the Repository Directory**

   Change into the cloned directory:

   ```sh
   cd simplescan
   ```

3. **Run SimpleScan**

   Execute the main script:

   ```sh
   python3 main.py
   ```

   By default, SimpleScan will run on the host IP `127.0.0.1` when installed this way. To access from another host, open `main.py` and change the Flask listening address from `127.0.0.1` to `0.0.0.0`.

## Note

- Running SimpleScan directly on your host requires you to manage the dependencies and environment configurations yourself.
- For any issues or contributions, feel free to open an issue or a pull request in this repository.

**LICENSE**
SimpleScan is a simple, web based frontend that allows for running Nmap based vulnerability scans and reviewing the results in a user friendly way. 
Copyright (C) 2023  Chris Riani

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
