#!/bin/bash
echo "From:`hostname -i`" >> index.html
cat >> index.html << EOF
<h1> ${server_text} </h1>
<p> DB Address: ${db_address}</p>
<p> DB port: ${db_port} </p>
EOF
yum httpd install -y
systemctl start httpd
