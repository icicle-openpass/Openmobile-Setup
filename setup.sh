####################################### Open Mobile App ###############################################

# 1) Setup stage environment
# 2) Create a config file
# 3) Make directory "/Desktop"
# 4) Curl command to download a file. (Edited Version)
# 5) Run the install.sh file (Edited Version)
# 6) Make the directoy named ea2openmobile
# 7) Download restartMicroservice.sh
# 8) Install NGINX
# 9) Edit default file
# 10) Test the NGINX File
# 11) Restart the NGINX service
# 12) Run the restartMicroservice file.

####################################### Open Mobile Code ##############################################

#!/bin/bash
set -x

# 1) Setup stage environment
curl -L -o ~/.ssh/icicleop https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/icicleop
chmod 600 ~/.ssh/icicleop

# 2) Create a config file
echo "IdentityFile ~/.ssh/icicleop" > ~/.ssh/config

# 3) Make directory "/Desktop"
mkdir Desktop


# 4) Curl command to download a file. (Edited Version)
curl -L -o install.sh https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/install.sh
chmod +x install.sh

# 5) Run the install.sh file (Edited Version)
bash /home/icicle/install.sh

# 6) Make the directoy named ea2openmobile
mkdir -p /home/icicle/icicleEdge/ea2openmobile

# 7) Download restartMicroservice.sh
curl -L -o /home/icicle/icicleEdge/ea2openmobile/restartMicroservice.sh https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/restartMicroservice.sh
chmod +x /home/icicle/icicleEdge/ea2openmobile/restartMicroservice.sh

# 8) Install NGINX
sudo apt install -y nginx

# 9) Edit default file
NGINX_CONF="/etc/nginx/sites-available/default"
sudo rm -rf $NGINX_CONF
sudo curl -L -o $NGINX_CONF https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/nginx

# 10) Test the NGINX File
sudo nginx -t

# 11) Restart the NGINX service
sudo systemctl restart nginx

# 12) Run the restartMicroservice file.
bash /home/icicle/icicleEdge/ea2openmobile/restartMicroservice.sh
