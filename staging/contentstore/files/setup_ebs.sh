#!/bin/bash
while [ `lsblk -n | grep -c 'xvdh'` -ne 1 ]
do
  echo "Waiting for /dev/xvdh to become available" >>/tmp/test.log
  sleep 10
done

blkid /dev/xvdh |grep 'TYPE="ext4"'
IS_EXT4_VOLUME="$?"
echo $IS_EXT4_VOLUME
if [ $IS_EXT4_VOLUME != 0 ]; then
 		echo "creating filesystem"
		mkfs.ext4 /dev/xvdh
fi
echo "Mounting..."
mount /dev/xvdh /media
echo '/dev/xvdh /media ext4 defaults 0 0' | tee -a /etc/fstab

###############
Setup NFS server
###############

yum install nfs-utils -y
chmod -R 755 /media
chown nfsnobody:nfsnobody /media
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

cat <<EOF > /etc/exports
/media    172.31.0.0/16(rw,sync,no_root_squash,no_all_squash)
EOF

systemctl restart nfs-server
