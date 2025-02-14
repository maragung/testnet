**Tutorial Lengkap Setup VPS Akash Cloud dengan Persistent Storage**

---

### **1. Buat Deployment Baru di Akash Cloud**
1. **Buka Dashboard Akash** di [Akash Network](https://akash.network/)
2. Pilih **"Create Deployment"**
3. Pilih **Ubuntu 24.04** sebagai OS
4. **Atur Konfigurasi Resource:**
   - **CPU**: 1 Core
   - **Memory**: 2GB
   - **Ephemeral Storage**: 1GB (default)
   - **Persistent Storage**:
     - **Size**: 50GB
     - **Type**: NVMe
     - **Mount Path**: `/mnt/data`

5. **Masukkan SSH Key** untuk mengakses VPS
   - Bisa menggunakan **Generate New Key** atau masukkan **Public Key** sendiri

6. **Klik "Create Deployment"** dan pilih **provider yang sesuai**

---

### **2. Konfigurasi `deploy.yaml` (Jika Deploy via CLI)**
Jika ingin menggunakan CLI, buat file `deploy.yaml` dengan konfigurasi berikut:

```yaml
version: "2.0"
services:
  ubuntu-1:
    image: ghcr.io/akash-network/ubuntu-2404-ssh:2
    expose:
      - port: 80
        as: 80
        to:
          - global: true
      - port: 22
        as: 22
        to:
          - global: true
    env:
      - SSH_PUBKEY=<ISI_SSH_PUBLIC_KEY_ANDA>
    params:
      storage:
        data:
          mount: /mnt/data
          readOnly: false
profiles:
  compute:
    ubuntu-1:
      resources:
        cpu:
          units: 1
        memory:
          size: 2gb
        storage:
          - name: data
            size: 50Gi
            attributes:
              persistent: true
              class: beta3
  placement:
    dcloud:
      pricing:
        ubuntu-1:
          denom: uakt
          amount: 10000
deployment:
  ubuntu-1:
    dcloud:
      profile: ubuntu-1
      count: 1
```

**Langkah Deploy via CLI:**
```sh
akash tx deployment create deploy.yaml --from <your_wallet>
```

---

### **3. Login ke VPS via SSH**
Setelah deployment berhasil, login ke VPS dengan perintah berikut:
```sh
ssh root@<IP_VPS>
```

Cek apakah storage sudah ter-mount dengan benar:
```sh
df -h
```
Pastikan ada `/mnt/data` dengan ukuran sesuai konfigurasi.

---

### **4. Install Aplikasi dan Simpan di `/mnt/data`**
Karena filesystem root bersifat ephemeral (hilang setelah reboot), pastikan aplikasi penting disimpan di `/mnt/data`.

1. **Update Repository**
   ```sh
   apt update && apt upgrade -y
   ```
2. **Install Aplikasi (contoh: `htop`, `nano`)**
   ```sh
   apt install -y htop nano
   ```
3. **Pindahkan Instalasi Aplikasi ke `/mnt/data` (Opsional)**
   Jika ingin aplikasi tetap ada setelah reboot, simpan di `/mnt/data` dan buat symlink:
   ```sh
   mkdir -p /mnt/data/bin
   cp /usr/bin/htop /mnt/data/bin/
   ln -s /mnt/data/bin/htop /usr/local/bin/htop
   ```
   Lakukan ini untuk aplikasi lain juga.

---

### **5. Restart VPS (Workaround untuk Reboot)**
Karena tidak bisa `reboot`, gunakan cara berikut:

1. **Hentikan Deployment**
   ```sh
   akash tx deployment close --from <your_wallet>
   ```
2. **Deploy Ulang**
   ```sh
   akash tx deployment create deploy.yaml --from <your_wallet>
   ```
3. **Atau Logout dan Login Ulang**
   ```sh
   exit
   ssh root@<IP_VPS>
   ```

---

### **6. Pastikan Data Tetap Ada Setelah Logout**
Cek apakah aplikasi tetap ada setelah keluar dan masuk kembali:
```sh
htop
```
Jika masih ada, berarti persistent storage bekerja dengan baik! 🚀


### **7. Kesimpulan**
✅ Dengan konfigurasi ini, semua data di `/mnt/data` **tetap ada** setelah logout/restart.
✅ **Gunakan `/mnt/data` sebagai penyimpanan utama** untuk aplikasi dan file penting.
✅ Jika VPS mati, cukup **deploy ulang** dengan file `deploy.yaml` untuk mendapatkan konfigurasi yang sama.

Selamat menggunakan Akash Cloud! 🎉

