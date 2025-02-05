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

sudo tee $NGINX_CONF > /dev/null <<EOF
server {
    listen 80;
    listen 30080;

    server_name _;  # Accept requests from any IP

    location /cgi-bin/callms.py {
        set $state_value $arg_state;
        set $user_value $arg_user;
        set $ms $arg_ms;
        set $port $arg_port;
        set $path $arg_path;
        set $file $arg_page;

        if ($ms = "") {
            return 400 "Missing microservice name";
        }
        if ($port = "") {
            return 400 "Missing port number";
        }
        if ($path = "") {
            return 400 "Missing microservice path";
        }
        if ($file = "") {
            return 400 "Missing file name";
        }

        proxy_pass http://10.43.195.204:30080$request_uri;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# 10) Test the NGINX File
sudo nginx -t

# 11) Restart the NGINX service
sudo systemctl restart nginx

# 12) Run the restartMicroservice file.
bash /home/icicle/icicleEdge/ea2openmobile/restartMicroservice.sh
