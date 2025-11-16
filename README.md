
# Mikrotify

Mikrotify adalah kumpulan skrip yang dirancang untuk RouterOS guna mengotomatisasi konfigurasi dan interaksi dengan router Mikrotik melalui Telegram. Mikrotify mendukung pengiriman notifikasi, pengelolaan event, dan penerimaan perintah melalui Telegram, sehingga memudahkan pengelolaan infrastruktur jaringan secara jarak jauh.

## Fitur
- **Telegram Notifications**: Kirim pemberitahuan melalui Telegram mengenai status dan peringatan dari RouterOS.
- **Interaksi via Telegram**: Berkomunikasi langsung dengan router Mikrotik melalui Telegram untuk menjalankan perintah atau mendapatkan status.
- **Konfigurasi yang Dapat Disesuaikan**: Konfigurasi skrip dapat disesuaikan melalui file overlay untuk memenuhi kebutuhan spesifik pengguna.

## Instalasi

1. **Clone Repository**
   Pertama, clone repositori ini ke dalam sistem Anda:
   ```
   git clone https://github.com/dmibot/mikrotify.git
   ```

2. **Upload Skrip ke RouterOS**
   Salin skrip yang ada di folder `src` ke dalam RouterOS Anda. Anda dapat meng-upload file `.rsc` melalui Winbox atau menggunakan terminal.

3. **Konfigurasi Telegram Bot**
   Pastikan Anda sudah memiliki bot Telegram. Anda bisa membuatnya melalui [BotFather](https://core.telegram.org/bots#botfather). Setelah itu, perbarui `TokenTelegram` dan `IDChatTelegram` di dalam file skrip dengan token bot dan ID chat Telegram Anda.

4. **Modifikasi Konfigurasi**
   Anda dapat mengkustomisasi pengaturan di dalam file `BaseConfigTelegram_custom_overlay.rsc`. Sesuaikan pengaturan seperti token, ID chat, dan pengaturan lainnya sesuai kebutuhan Anda.

## Penggunaan

- **Pengujian Koneksi**:
   Untuk menguji apakah konfigurasi Telegram Anda berfungsi, jalankan skrip `TgSelfTest`.

- **Mengirim Notifikasi**:
   Anda dapat menggunakan fungsi `TgSendMarkdown` atau `TgSendTable` untuk mengirimkan pesan atau tabel ke Telegram.

- **Menambahkan Pesan ke Digest**:
   Gunakan `TgDigestAppend` untuk menambahkan pesan ke dalam digest yang nantinya dapat dikirimkan menggunakan `TgDigestFlush`.

## Contributing

Jika Anda ingin berkontribusi pada proyek ini, silakan lakukan fork, buat perubahan, dan kirimkan pull request. Semua kontribusi diterima dengan baik.

## Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).
