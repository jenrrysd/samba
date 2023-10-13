#!/bin/bash

### INSTALACIÓN DE SAMBA EN ARCH LINUX

# Instala Samba
sudo pacman -S samba --noconfirm

# Habilita y arranca el servicio de Samba
sudo systemctl enable smb.service
sudo systemctl start smb.service

# Agrega reglas de firewall para permitir el tráfico de Samba
sudo iptables -A INPUT -p udp -m udp --dport 137 -j ACCEPT
sudo iptables -A INPUT -p udp -m udp --dport 138 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 139 -j ACCEPT
sudo iptables -A INPUT -p tcp -m tcp --dport 445 -j ACCEPT

# Guarda las reglas de firewall
sudo iptables-save > /etc/iptables/iptables.rules

# Crea el usuario sambauser con la contraseña 123abc
sudo useradd sambauser
echo -e "123abc\n123abc" | sudo smbpasswd -a sambauser

# Crea el directorio compartido y ajusta los permisos
sudo mkdir -p /home/sambauser/share
sudo chown -R sambauser:sambauser /home/sambauser/share

# Realiza una copia de seguridad del archivo smb.conf
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Crea un nuevo archivo smb.conf
cat > /etc/samba/smb.conf << EOF
[samba]
   comment = My Share
   path = /home/sambauser/share
   guest ok = no
   valid users = sambauser
   public = yes
   writable = yes
   browseable = yes
   create mask = 0644
   directory mask = 0755
   write list = sambauser
   workgroup = WORKGROUP
EOF

# Reinicia el servicio Samba
sudo systemctl restart smb.service

# Limpia la pantalla
clear

# Obtiene la dirección IP del servidor
ip=$(ip route | awk '/default/ {print $9}')
# Imprime la dirección para acceder a Samba
echo "Verifica Samba entrando en la siguiente dirección:"
echo "smb://$ip"

