#!/usr/bin/expect -f

# Variabel MikroTik
set mikrotik_ip "192.168.100.14"
set mikrotik_user "admin"
set mikrotik_password "" 
set timeout 10  

# Koneksi Telnet ke MikroTik
spawn telnet $mikrotik_ip

# Menunggu prompt login
expect "Login:"
send "$mikrotik_user\r"

# Menunggu prompt password
expect "Password:"
send "$mikrotik_password\r"

# Menunggu prompt MikroTik
expect ">"
sleep 1
# Set IP pada ether2 dengan alamat 192.168.200.1/24
send "/ip address add address=192.168.200.1/24 interface=ether2\r"
sleep 2  

# Menjalankan DHCP server setup pada interface ether2
send "/ip dhcp-server setup\r"
expect "Select interface:"
send "ether2\r"
sleep 1

# Pilih alamat jaringan (IP pool)
expect "Select network:"
send "\r"
sleep 1

# Pilih IP Address untuk DHCP server
expect "Select gateway for dhcp network:"
send "\r"
sleep 1

# Pilih rentang IP untuk client (dari 192.168.200.2 hingga 192.168.200.254)
expect "Select addresses to give out:"
send "\r"
sleep 1

# Tambahkan dua DNS baru
expect "Select DNS servers:"
send "\r"  
sleep 1

# Pilih lease time untuk IP (10 menit)
expect "Select lease time:"
send "\r"
sleep 1

# Menyelesaikan setup
expect "Do you want to enable DHCP server now? (y/n):"
send "y\r"
sleep 2

# Aktifkan NAT Masquerade untuk keluar ke internet
send "/ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade\r"
sleep 2

# Routing MikroTik ke Ubuntu server
send "/ip route add dst-address=192.168.100.0/24 gateway=192.168.100.1\r"
sleep 2

# Menutup Telnet
send "quit\r"

# Menunggu proses selesai dan keluar
expect eof
