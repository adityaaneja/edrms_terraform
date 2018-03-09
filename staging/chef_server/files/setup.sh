#!/bin/bash
sudo apt-get update
sudo apt-get -y install curl

# create staging directories
if [ ! -d /drop ]; then
sudo  mkdir /drop
fi
if [ ! -d /downloads ]; then
sudo  mkdir /downloads
fi

# download the Chef server package
if [ ! -f /downloads/chef-server-core_12.17.15-1_amd64.deb ]; then
  echo "Downloading the Chef server package..."
sudo  wget -nv -P /downloads https://packages.chef.io/files/stable/chef-server/12.17.15/ubuntu/14.04/chef-server-core_12.17.15-1_amd64.deb
fi

#Edit the hostname of the EC2 instance
sudo chmod 666 /etc/hostname
sudo echo "`curl http://169.254.169.254/latest/meta-data/public-hostname`" > /etc/hostname
sudo chmod 644 /etc/hostname
sudo service hostname restart
# install Chef server
if [ ! $(which chef-server-ctl) ]; then
  echo "Installing Chef server..."
sudo  dpkg -i /downloads/chef-server-core_12.17.15-1_amd64.deb


sudo chef-server-ctl reconfigure
sudo chmod 666 /etc/opscode/chef-server.rb
sudo cat  > /etc/opscode/chef-server.rb << EOF
server_name = "`curl http://169.254.169.254/latest/meta-data/public-hostname`"
api_fqdn "`curl http://169.254.169.254/latest/meta-data/public-hostname`"
bookshelf['vip'] = "`curl http://169.254.169.254/latest/meta-data/public-hostname`"
nginx['url'] = "https://#{server_name}"
nginx['server_name'] = "`curl http://169.254.169.254/latest/meta-data/public-hostname`"
nginx['ssl_certificate'] = "/var/opt/opscode/nginx/ca/#{server_name}.crt"
nginx['ssl_certificate_key'] = "/var/opt/opscode/nginx/ca/#{server_name}.key"
EOF

sudo chmod 640 /etc/opscode/chef-server.rb
sudo  chef-server-ctl reconfigure



  echo "Waiting for services..."
  until (curl -D - http://localhost:8000/_status) | grep "200 OK"; do sleep 15s; done
  while (curl http://localhost:8000/_status) | grep "fail"; do sleep 15s; done

  echo "Installing and Configuring Chef Management Console!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  sudo chef-server-ctl install chef-manage
  sudo chef-server-ctl reconfigure
  sudo chef-manage-ctl reconfigure --accept-license

  echo "Installing Configuring Chef Reporting!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  sudo chef-server-ctl install opscode-reporting 
  sudo chef-server-ctl reconfigure 
  sudo opscode-reporting-ctl reconfigure --accept-license
  

  echo "Creating initial user and organization..."
#sudo  chef-server-ctl user-create chefadmin Chef Admin admin@4thcoffee.com insecurepassword --filename /drop/chefadmin.pem
#sudo   chef-server-ctl org-create 4thcoffee "Fourth Coffee, Inc." --association_user chefadmin --filename 4thcoffee-validator.pem
 
sudo  chef-server-ctl user-create chefadmin Aditya Aneja aneja@ualberta.ca 2bontbit? --filename /drop/chefadmin.pem
sudo   chef-server-ctl org-create adityauoa "Sample UoA" --association_user chefadmin --filename /drop/aditya-ualberta-validator.pem
sudo chown -R ubuntu.ubuntu /drop
fi


  echo "Installing and Configuring Opscode Console!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  sudo chef-server-ctl install opscode-manage
  sudo opscode-manage-ctl reconfigure  --accept-license
  sudo chef-server-ctl reconfigure

echo "Your Chef server is ready!"

