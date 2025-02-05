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
sudo chown -R icicle:icicle .ssh
sleep 10
chmod 700 /home/icicle/.ssh
sleep 10
curl -L -o /home/icicle/.ssh/icicleop https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/icicleop
sleep 10
chmod 600 /home/icicle/.ssh/icicleop
sleep 10

# 2) Create a config file
echo "IdentityFile /home/icicle/.ssh/icicleop" > /home/icicle/.ssh/config
sleep 10

# 3) Make directory "/Desktop"
mkdir Desktop
sudo chown -R icicle:icicle Desktop

# 4) Curl command to download a file. (Edited Version)
sudo curl -L -o install.sh https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/install.sh
sleep 10
sudo chmod +x install.sh
sleep 10

# 5) Run the install.sh file (Edited Version)
sudo chown -R icicle:icicle install.sh
bash /home/icicle/install.sh -y

# 6) Make the directoy named ea2openmobile
mkdir -p /home/icicle/icicleEdge/ea2openmobile
sudo chown -R icicle:icicle /home/icicle/icicleEdge/ea2openmobile

# 7) Download restartMicroservice.sh
curl -L -o /home/icicle/icicleEdge/ea2openmobile/k3s_setup.sh https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/k3s_setup.sh
sleep 10
curl -L -o /home/icicle/icicleEdge/ea2openmobile/deployMicroService.sh https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/deployMicroService.sh
sleep 10
chmod +x /home/icicle/icicleEdge/ea2openmobile/k3s_setup.sh
chmod +x /home/icicle/icicleEdge/ea2openmobile/deployMicroService.sh
sudo chown -R icicle:icicle /home/icicle/icicleEdge/ea2openmobile/k3s_setup.sh
sudo chown -R icicle:icicle /home/icicle/icicleEdge/ea2openmobile/deployMicroService.sh

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
bash /home/icicle/icicleEdge/ea2openmobile/k3s_setup.sh -y
sleep 10
bash /home/icicle/icicleEdge/ea2openmobile/deployMicroService.sh -y

true
