#!/bin/bash

# Fungsi untuk mencetak teks di tengah layar
print_center() {
  local termwidth
  local padding
  local message="$1"
  local color="$2"
  termwidth=$(tput cols)
  padding=$(( (termwidth - ${#message}) / 2 ))
  printf "%s%${padding}s%s%s\n" "$color" "" "$message" "$(tput sgr0)"
}
# Banner Teks
print_center "    __               _                   __      "
print_center "   / /   ___  ____ _(_)_  ______ _____  / /_____ "
print_center "  / /   / _ \\/ __ \`/ / / / / __ \`/ __ \\/ __/ __ \\"
print_center " / /___/  __/ /_/ / / /_/ / /_/ / / / / /_/ /_/ /"
print_center "/_____/\___/\\__, /_/\\__, /\\__,_/_/ /_/\\__/\\____/ "
print_center "           /____/  /____/                         "
print_center ""
print_center ""
print_center ""
print_center "+-+-+-+-+ +-+-+-+-+ +-+ +-+-+-+-+-+-+-+"
print_center "|T|J|K|T| |S|M|K|N| |5| |B|A|N|D|U|N|G|"
print_center "+-+-+-+-+ +-+-+-+-+ +-+ +-+-+-+-+-+-+-+"
print_center ""
print_center ""
print_center ""


# Jeda waktu 2 detik
sleep 2


# Warna hijau untuk pesan sukses
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Ubah repository menjadi repository UGM
cat <<EOF > /etc/apt/sources.list
deb http://repo.ugm.ac.id/ubuntu focal main restricted universe multiverse
deb http://repo.ugm.ac.id/ubuntu focal-updates main restricted universe multiverse
deb http://repo.ugm.ac.id/ubuntu focal-security main restricted universe multiverse
deb http://repo.ugm.ac.id/ubuntu focal-backports main restricted universe multiverse
deb http://repo.ugm.ac.id/ubuntu focal-proposed main restricted universe multiverse
EOF
echo -e "${GREEN}Repository telah diubah menjadi repository UGM${NC}"

# Update sistem
apt update &> /dev/null
echo -e "${GREEN}Sistem berhasil diperbarui${NC}"
# Update sistem dan install ISC DHCP Server, iptables, dan iptables-persistent
apt install -y isc-dhcp-server iptables &> /dev/null
echo -e "${GREEN}Berhasil menginstall ISC DHCP Server dan iptables${NC}"

# Install iptables-persistent tanpa prompt interaktif
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean false | debconf-set-selections
apt install -y iptables-persistent &> /dev/null
echo -e "${GREEN}Berhasil menginstall iptables-persistent ${NC}"

#install python 3
sudo apt install python3 -y &> /dev/null
sleep 3
sudo apt install python3-pip -y &> /dev/null
sleep 3
sudo pip3 install netmiko &> /dev/null
sleep 1
sudo apt install expect -y &> /dev/null
echo -e "${GREEN}Berhasil menginstall python3 ${NC}"

# Konfigurasi Netplan
cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
  ethernets:
    eth1:
      dhcp4: no
  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.100.1/24
      routes:
        - to: 192.168.200.0/24
          via: 192.168.100.14
EOF

# Terapkan konfigurasi Netplan
netplan apply &> /dev/null
echo -e "${GREEN}Berhasil menerapkan konfigurasi Netplan${NC}"

# Konfigurasi DHCP Server
cat <<EOF > /etc/dhcp/dhcpd.conf
default-lease-time 600;
max-lease-time 7200;
option domain-name "local";
authoritative;

subnet 192.168.100.0 netmask 255.255.255.0 {
  range 192.168.100.2 192.168.100.200;
  option routers 192.168.100.1;
  option subnet-mask 255.255.255.0;
  option broadcast-address 192.168.100.255;
  option domain-name-servers 192.168.100.1,8.8.8.8;
  
  # Fixed IP assignment for specific clients based on MAC address
  host client1 {
    hardware ethernet 50:AF:B2:00:C7:00; # Ganti dengan MAC address asli
    fixed-address 192.168.100.14;
  }

  host client2 {
    hardware ethernet 66:77:88:99:AA:BB; # Ganti dengan MAC address asli
    fixed-address 192.168.100.20;
  }
}
EOF

# Tentukan interface DHCP
echo "INTERFACESv4=\"eth1.10\"" > /etc/default/isc-dhcp-server

# Restart DHCP server untuk menerapkan konfigurasi
systemctl restart isc-dhcp-server &> /dev/null
echo -e "${GREEN}Berhasil mengkonfigurasi dan me-restart DHCP server${NC}"

# Aktifkan IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p &> /dev/null
echo -e "${GREEN}Berhasil mengaktifkan IP forwarding${NC}"

# Konfigurasi NAT dengan iptables
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &> /dev/null

# Simpan aturan iptables agar tetap ada setelah reboot
iptables-save > /etc/iptables/rules.v4
echo -e "${GREEN}Berhasil mengkonfigurasi iptables dan menyimpan aturan${NC}"

# Jeda selama 3 detik sebelum menjalankan skrip cisco.py
sleep 7
echo -e "${YELLOW}Menjalankan konfigurasi Cisco...${NC}"
sudo python3 cisco.py &> /dev/null

# Pastikan file mikrotik.sh dapat dieksekusi
sleep 2
sudo chmod +x mikrotik.sh &> /dev/null
sleep 15
sudo ./mikrotik.sh
sleep 2
sudo systemctl restart isc-dhcp-server
sleep 25
sudo ./mikrotik.sh

# Restart DHCP server sekali lagi setelah konfigurasi selesai
echo -e "${GREEN}KONFIGURASI OTOMASI UBUNTU. CISCO dan MIKROTIK SELESAI${NC}"

