domain=${1?param missing - domain.} 

# INSTALL MONGODB
# https://onecompiler.com/posts/3vchuyxuh/enabling-replica-set-in-mongodb-with-just-one-node
# https://www.mongodb.com/docs/manual/tutorial/configure-scram-client-authentication/
echo "-------- INSTALL MONGODB --------"
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
ps --no-headers -o comm 1
sudo systemctl start mongod
sudo systemctl daemon-reload
sudo systemctl status mongod
sudo systemctl enable mongod

# REDIS
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install redis

sudo apt update
sudo apt install gh

# INSTALL NODEJS
echo "-------- INSTALL NODEJS --------"
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
apt install npm

# INSTALL PM2
echo "-------- INSTALL PM2 --------"
sudo npm install -g pm2

# INSTALL NGINX
echo "-------- INSTALL NGINX --------"
sudo apt-get update
sudo apt-get install nginx

echo "-------- RUN NGINX --------"
sudo systemctl enable nginx
sudo systemctl start nginx

# INSTALL LETSENCRYPT
echo "-------- INSTALL LETSENCRYPT --------"
sudo apt-get update
sudo apt-get install letsencrypt

echo "-------- SETUP SSL --------"
cp nginx-before-ssl.conf /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo "-------- CREATE SSL CERTIFICATE --------"
sudo letsencrypt certonly -a webroot --webroot-path=/var/www/html -d $domain
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
cp ssl-params.conf /etc/nginx/snippets/ssl-params.conf
cp nginx.conf /etc/nginx/sites-enabled/default
sed -i "s/__DOMAIN__/$domain/" /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo "-------- SETUP PROJECT ---------"
gh auth login