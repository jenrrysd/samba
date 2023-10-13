#!/bin/bash

###INSTALACION DE SAMBA EN FEDORA SERVER

sudo dnf install samba -y
sudo systemctl enable smb --now

server=`(firewall-cmd --get-active-zones | head -n1)`
sudo firewall-cmd --permanent --zone=$server --add-service=samba
sudo firewall-cmd --reload

##creamos el usuario; sambauser
sudo useradd sambauser

##el password es; 123abc
sudo yes '123abc' | smbpasswd -a sambauser

sudo mkdir -p /home/sambauser/share
sudo semanage fcontext --add --type "samba_share_t" "/home/sambauser/share(/.*)?"
sudo restorecon -R /home/sambauser/share

##respaldar copia del fichero
mv /etc/samba/smb.conf /etc/samba/smb.conf-copia
rm -rf /etc/samba/smb.conf
cd /etc/samba/

cat > smb.conf << EOF
[samba]
comment = My Share
path = /home/sambauser/share
writable = yes
browseable = yes
public = yes
create mask = 0644
directory mask = 0755
write list = sambauser
workgroup = WORKGROUP
EOF

##camabiamos al nuevo usuario y grupo
sudo chown -R sambauser:sambauser /home/sambauser/share

##reiniciamos el servicio samba
sudo systemctl restart smb

clear
ip=`hostname -I | cut -f1 -d' '`

echo "Verifica Samba entrando en la siguiente direccion"
echo "smb://$ip"
