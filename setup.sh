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
curl -L -o icicleop https://raw.githubusercontent.com/icicle-openpass/Openmobile-Setup/refs/heads/main/icicleop
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
mkdir -p ./icicleEdge/ea2openmobile

# 7) Download restartMicroservice.sh
RSTMCS="/home/icicle/icicleEdge/ea2openmobile/restartMicroservice.sh"

sudo touch $RSTMCS
chmod +x $RSTMCS

sudo tee $NGINX_CONF > /dev/null <<EOF
#!/bin/bash

echo "Shutting down local instances to get up-to-date IP address"
echo "Killall and Uninstall k3s"
sudo bash /usr/local/bin/k3s-killall.sh
sudo bash /usr/local/bin/k3s-uninstall.sh
sudo rm /var/lib/rancher/k3s/server/token
sudo rm -rf /etc/ceph \
       /etc/cni \
       /etc/kubernetes \
       /etc/rancher \
       /opt/cni \
       /opt/rke \
       /run/secrets/kubernetes.io \
       /run/calico \
       /run/flannel \
       /var/lib/calico \
       /var/lib/etcd \
       /var/lib/cni \
       /var/lib/kubelet \
       /var/lib/rancher\
       /var/log/containers \
       /var/log/kube-audit \
       /var/log/pods \
       /var/run/calico



sleep 3
bash /home/icicle/icicleEdge/adminTools/edgeTools/setupOfflineMode.sh reset
bash /home/icicle/icicleEdge/adminTools/edgeTools/setupOfflineMode.sh init

# Do a fresh install
echo "Installing K3s -- sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"server --flannel-iface=icl43\" sh -"
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --flannel-iface=icl43" /bin/sh -
sleep 5


NODE_NAME=`sudo k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml get nodes| tail -n 1 | awk '{print $1}' `
EDGE_ID=$NODE_NAME
EDGE_ID+="-edgedevel"
sudo k3s kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml label node $NODE_NAME icicletype=edgedevel
echo $EDGE_ID > ~/.ssh/icicletype


cd /home/icicle/icicleEdge
./bin/deployMicroservice.py -home `pwd` -devel -edge edgedevel 30080website
echo Deployed Website!
./bin/deployMicroservice.py -home `pwd` -devel -edge edgedevel 4242phonehub
echo Deployed Phone Hub!  
./bin/deployMicroservice.py -home `pwd` -devel -edge edgedevel 1212aimissions 
echo Deployed AI Mission in the background!
EOF

# 8) Install NGINX
sudo apt install -y nginx

# 9) Edit default file
NGINX_CONF="/etc/nginx/sites-available/default"

sudo cp $NGINX_CONF "$NGINX_CONF.bak"

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
if [ $? -eq 0 ]; then
    echo "Nginx configuration is valid. Restarting Nginx..."
    sudo systemctl restart nginx
    echo "Nginx restarted successfully!"
else
    echo "Nginx configuration failed. Restoring backup..."
    sudo cp "$NGINX_CONF.bak" $NGINX_CONF
    sudo nginx -t
    exit 1
fi

# 12) Run the restartMicroservice file.
bash /home/icicle/icicleEdge/ea2openmobile/restartMicroservice.sh
