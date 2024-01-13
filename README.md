# SimpleScan Installation Guide

Welcome to the SimpleScan project! This README provides detailed instructions for installing and running SimpleScan either using Docker or directly on your host system.

## Docker Installation (Most Users)

SimpleScan can be easily installed and run in a Docker container. This method is recommended as it encapsulates all the necessary dependencies and doesn't require modifications to your host system.

### Installation Steps
**Raspbian OS / ARM64 systems

1. **Download and run the Auto-Install Script**

   Run the following in your `/opt/` directory, or any other directory where you have appropriate permissions and want to install.

   ```sh
curl -O https://raw.githubusercontent.com/criani/simplescan/main/autoinstall_pi.sh
chmod +x autoinstall.sh
sudo ./autoinstall.sh
   ```
   This script will automatically pull and run the autoinstall script on your Pi / arm64 type system and install docker (if needed) and the required images, and will set up and start SimpleScan in a Docker container listening on port 5000 of the host system.
   To access simplescan simply open a browser and go to Http://<host-IP>:5000 where <host-IP> is the IP address of the docker host. 

### Installation Steps
**Ubuntu/Debian

1. **Download and run the Auto-Install Script**

   Run the following in your `/opt/` directory, or any other directory where you have appropriate permissions and want to install.

   ```sh
   curl -s https://raw.githubusercontent.com/criani/simplescan/main/autoinstall.sh | sudo bash
   ```
   This script will automatically pull and run the autoinstall script on your debian based system and install docker (if needed) and the required images, and will set up and start SimpleScan in a Docker container listening on port 5000 of the host system.
   To access simplescan simply open a browser and go to Http://<host-IP>:5000 where <host-IP> is the IP address of the docker host. 

### Installation Steps
**CentOS/Redhat

1. **Download and run the Auto-Install Script**

   Run the following in your `/opt/` directory, or any other directory where you have appropriate permissions and want to install.

   ```sh
curl -O https://raw.githubusercontent.com/criani/simplescan/main/autoinstall_yum.sh
chmod +x autoinstall.sh
sudo ./autoinstall.sh
   ```
   This script will automatically pull and run the autoinstall script on your debian based system and install docker (if needed) and the required images, and will set up and start SimpleScan in a Docker container listening on port 5000 of the host system.
   To access simplescan simply open a browser and go to Http://<host-IP>:5000 9where <host-IP> is the IP address of the docker host. 


   

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

   By default, SimpleScan will run on the host IP `127.0.0.1`, when installed this way. To access from another host, open main.py and change the flask listening address from 127.0.0.1 to 0.0.0.0

## Note

- Running SimpleScan directly on your host requires you to manage the dependencies and environment configurations yourself.
- For any issues or contributions, feel free to open an issue or a pull request in this repository.

Thank you for using SimpleScan!
