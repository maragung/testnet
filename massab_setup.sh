#!/bin/bash


echo -e "\033[32m"
cat << "EOF"
   dP                              oo         
      88                                         
.d888b88 .d8888b. dP  dP  dP 88d888b. dP 88d888b.
88'  `88 88ooood8 88  88  88 88'  `88 88 88'  `88
88.  .88 88.  ... 88.88b.88' 88       88 88    88
`88888P8 `88888P' 8888P Y8P  dP       dP dP    dP
                                                 
                                                 
EOF
echo -e "\033[0m"


apt-get install cron curl

# Warna ANSI
GREEN='\033[0;32m'
BLUE='\033[1;36m'
YELLOW='\033[0;33m'
NC='\033[0m' # Mengembalikan warna ke default

echo -e "${BLUE}Masukkan path default (default: /root/massa), Tekan ENTER jika tidak ingin merubahnya:"
read -r path_default

if [ -z "$path_default" ]; then
    path_default="/root/massa"
fi

#!/bin/bash

# Menanyakan konfirmasi kepada pengguna
read -p "Apakah Anda yakin ingin mengosongkan isi file massa.cfg? (Y/N): " choice

# Memeriksa pilihan pengguna
if [[ $choice == "Y" || $choice == "y" ]]; then
    # Mengosongkan file massa.cfg
    echo "" > massa.cfg
    echo "Isi file massa.cfg telah berhasil dikosongkan."
elif [[ $choice == "N" || $choice == "n" ]]; then
    echo "Pengosongan isi file massa.cfg dibatalkan."
else
    echo "Pilihan tidak valid. Pengosongan isi file massa.cfg dibatalkan."
    exit 1
fi


# Memeriksa keberadaan file massa-client/massa-client
if [ ! -f "$path_default/massa-client/massa-client" ]; then
    echo "File massa-client/massa-client tidak ditemukan di $path_default/massa-client."
    echo "Silakan install Massa terlebih dahulu."
    exit 1
fi

# Memeriksa keberadaan file massa-node/massa-node
if [ ! -f "$path_default/massa-node/massa-node" ]; then
    echo "File massa-node/massa-node tidak ditemukan di $path_default/massa-node."
    echo "Silakan install Massa terlebih dahulu."
    exit 1
fi

cd "$path_default/massa-client"
echo -e "${YELLOW}Anda berada di direktori $path_default/massa-client.${NC}"
echo $(pwd)
echo "path_default=\"$path_default\"" > massa.cfg
echo "path_default telah disimpan dalam massa.cfg."

# Menggunakan warna biru untuk pesan "Masukkan Alamat public Massa (tekan Enter untuk menyimpan, kosongkan untuk melanjutkan ke input password):"
echo -e "${BLUE}Masukkan Alamat public Massa (tekan ENTER untuk menyimpan.):${NC}"

addresses=()
while true; do
    IFS= read -r address
    if [ -z "$address" ]; then
        break
    fi
    addresses+=("$address")
    echo "Alamat $address telah ditambahkan."
    echo -e "${BLUE}Tambahkan alamat yang lain atau tekan ENTER untuk menyimpan."
done

# Simpan alamat-alamat ke dalam file massa.cfg
echo "addresses=(" >> massa.cfg
for address in "${addresses[@]}"; do
    echo "\"$address\"" >> massa.cfg
done
echo ")" >> massa.cfg

# Menggunakan warna hijau untuk pesan "Alamat public Massa telah disimpan ke dalam file config."
echo -e "${GREEN}Alamat public Massa telah disimpan ke dalam file config.${NC}"

echo -e "${BLUE}Masukkan password yang ingin disimpan (tekan ENTER untuk menyimpan):"

# Membaca input password dari pengguna dan menyimpannya dalam file massa.cfg
IFS= read -r -s password
echo "password=\"$password\"" >> massa.cfg
echo -e "${GREEN}Password telah disimpan dalam massa.cfg."


# Validasi input jumlah_roll
valid_input=false
while [ "$valid_input" = false ]; do
    echo -e "${BLUE}Masukkan jumlah roll yang akan dibeli (1-100):"
    read -r jumlah_roll

    if ! [[ "$jumlah_roll" =~ ^[1-9][0-9]?$|^100$ ]]; then
        echo "Jumlah roll yang dimasukkan tidak valid. Harap masukkan angka integer antara 1 dan 100."
    else
        valid_input=true
    fi
done

echo "jumlah_roll=\"$jumlah_roll\"" >> massa.cfg
echo -e "${GREEN}Jumlah roll yang akan dibeli telah disimpan dalam massa.cfg."



# Get the current directory
current_directory=$(pwd)

# Append the filename to the current directory
file_path="$current_directory/massab.sh"


curl -o $file_path https://gist.githubusercontent.com/dewrin/8ee41e59a6d0ba7dbc096f99e19072d6/raw/1f724ca65635de9bb0ef701f3e81b3ae5addb6a8/buy_rolls.sh

chmod +x $file_path

sed -i "s#path_client=\"\"#path_client=\"$path_default/massa-client\"#" "$file_path"


# Store the cron job command in a variable
cron_job="*/10 * * * * $file_path >/dev/null 2>&1"

# Check if the cron job already exists
if crontab -l | grep -q "$file_path"; then
    echo "Cron job already exists."
else
    # Add the cron job
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    echo "Cron job added."
fi

# Confirm the cron job
echo "Current cron jobs:"
crontab -l


echo -e "${GREEN}Massa buy rolls v3 installed successfully."
echo -e "${YELLOW}Jalankan perintah sudo chmod +x $file_path"




