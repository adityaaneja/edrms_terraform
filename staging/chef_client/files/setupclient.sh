#!/bin/bash
sudo yum install wget -y
sudo yum install curl -y
sudo mkdir /downloads

echo "Downloading Chef Client "
sudo  wget -nv -P /downloads https://packages.chef.io/files/stable/chef/12.4.0/el/7/chef-12.4.0-1.el7.x86_64.rpm

sudo  yum install /downloads/chef-12.4.0-1.el7.x86_64.rpm -y

sudo mkdir /etc/chef

sudo cat >> /etc/chef/aditya-ualberta-validator.pem <<EOF
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAupSsB46KurWQOGhmsSuE381pgVZTE8ZWXQG9foRrqmgYjiqE
bkDr5CRIOx6sqRqDqx5RPNLNGQyyF9pug90oLEzYEL3A3Qa3PNk3SXU5TVKC1El1
jzAFYIWETwnjVaA301wkuRhIl1eIvOpYHP8fBTuh5/wfZNfSobFt9a95zNedy6PR
FvdqlXxmEMIzQGbTcmGSwwvYs25ooPfdxnzTzzYHckpjGVX+biPfzRzwJnfwEXpm
A4tc+30VNTIXT/5iTqox6NzADBYwCnoECOQc7DmW3OEtieT1jKxQKmQy+KFSFu8Q
EoCoOaEW7tmhGyDT/Rc2+phe0V4rcdotoNACVwIDAQABAoIBAQCHL0klgIXLmdmQ
xTQCkkGH1lDnQSCYZ1ATuzsM++z2Xs3L08p4B9niRtd+3k7Dh053IVRC+YlY6PXw
incgW5DL6DF0j8e5XTBOiiOguap2952LKl5fDLAYqySeD9ADLj7EiTKiWZHe9bFB
D5ogCEj1hatdZjNo4WbfeKrvI+DgJOoOh6sNeOr1MCThMQzbGvtL6+/H6/HJIACx
REsXEeWGXhhvFGQE4pz4SMweOJYA9Zqt1N6mv9Orhf0UiNxzuRludjHQbSFZWdMO
c4Y9ofYqNnpbT3q79W7mIwpRYXN3IlTMFmT89LliBZ7WjKqZ/Gx2qxXw38x8yrC2
UFhGcLfhAoGBAPg2ZBSEx2vv22sxcIxjEpvEgSTeonhmrB2mKshFfi7G+PjYy/Jc
YlHfbJbL9nfAAOfRuIjvHk+l4J0vi64c7Mcu6a7ZZpZenSlhSzcT5RTy52ozKDYe
UnGJKsV+kQ+gRYzMo7WdPlOu27fUZw0p4dHfGfo21Iep91pDVEamYbjVAoGBAMBv
Q2/xopFt/t0P5RTuqxGqbi28lQ7XrAymSC0OdPKqUwROgeVKeESpmSKJnF2msCkH
+HxMIxIPiXz9cd91rNjpG5+OLyOgQf1SWPp0CRTj99A5ne8vcqCA6yTREawmv7m9
ZFdxQqQf0CvG/jpIHafDlyqK2Fz2aPcsk5UJhWR7AoGBANifP4DY0OJWlvxaTYt3
+4mOWdc/pjPGB3hoyPW4EIPqiudC7ds63WPuxeplX1jrbN7knVSEu8NvVTRZhmIS
RGMhgjhi67FYKXkvvGD5L/i0dVquAu4YUINd3sI1z4v/qDNVdZrO/NIzzPYGnVlT
sA1l1FoW+CzeHU3dbPOryaVxAoGABzzoG3DKPZAWkvgDFMt5UbvIUx4RuTIxfXRP
qKovieUQJExTpG0tot+CLANjBz66x4BOP1aZxxcgg7wAqXgCnVH/QPwXF87yTHXp
dNoicU+1xXY1U4bEV/chYQwgDwqSEYlnGcbfy86KhOsCKu0FeIbpy6bXRn/aKNnb
XzKxersCgYEAx4SCga3voD22baWozxNSlk9FHW18cP0RGIAN46TFBF5aWk4qkz/D
M09k9PxOOueSE39KDNKQA+/RCQG4twStIJxJvu9HvQC3uedQBeDq+awFWu83HWFO
t1kntaqEjBliBoP+zk8b79nRrusvHoysnaHUAbYwjpdlV5RWn9gPMZQ=
-----END RSA PRIVATE KEY-----
EOF

sudo cat >> /etc/chef/client.rb <<EOF
log_level        :info
log_location     STDOUT
chef_server_url  'https://ec2-54-175-17-199.compute-1.amazonaws.com/organizations/adityauoa'
validation_key         "/etc/chef/.aditya-ualberta-validator.pem"
validation_client_name 'chef-validator'
EOF

/usr/bin/chef-client

sudo cat >> /etc/chef/startup.json <<EOF
{"run_list": ["cookbook[edrms]"]}
EOF


/usr/bin/chef-client -j /etc/chef/startup.json

echo "Your Chef client is ready!"

