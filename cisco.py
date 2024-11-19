from netmiko import ConnectHandler

# Konfigurasi perangkat
cisco_switch = {
    'device_type': 'cisco_ios_telnet',  # Gunakan 'cisco_ios_ssh' jika menggunakan SSH
    'host': '192.168.6.179',               # Ganti dengan IP EVE-NG server Anda
    'port': 30232,                     # Port konsol Cisco switch di EVE-NG/PNetLab
    'username': '',                    # Kosong jika tidak menggunakan username
    'password': '',                    # Kosong jika tidak ada password
    'secret': '',                      # Kosong jika tidak menggunakan enable password
}

try:
    # Koneksi ke perangkat
    connection = ConnectHandler(**cisco_switch)
    connection.enable()  # Masuk ke mode enable jika diperlukan

    # Kirim perintah konfigurasi
    commands = [
        'show ip interface brief',                    # Menampilkan ringkasan interface
        'configure terminal',                         # Masuk ke mode konfigurasi
        'interface Ethernet 0/0',                    # Pilih interface e0/0
        'switchport trunk encapsulation dot1q',       # Set trunk encapsulation dot1q
        'switchport mode trunk',                     # Ubah mode menjadi trunk
        'no shutdown',                               # Aktifkan interface
        'exit',                                      # Keluar dari konfigurasi interface
        'vlan database',                             # Masuk ke VLAN database
        'vlan 10 name SMKN_5_BANDUNG',               # Buat VLAN 10 dengan nama SMKN_5_BANDUNG
        'exit',                                      # Keluar dari VLAN database
        'show ip interface brief',                   # Tampilkan kembali ringkasan interface
        'configure terminal',                        # Masuk ke mode konfigurasi
        'interface Ethernet 0/1',                    # Pilih interface e0/1
        'switchport mode access',                    # Ubah mode menjadi access
        'switchport access vlan 10',                 # Tetapkan VLAN 10
        'no shutdown',                               # Aktifkan interface
        'exit',                                      # Keluar dari konfigurasi interface
        'end',
        'write memory'                               # Simpan konfigurasi
    ]
    
    # Eksekusi semua perintah
    output = connection.send_config_set(commands)
    print(output)

    # Putuskan koneksi
    connection.disconnect()

except Exception as e:
    print(f"Error: {e}")
