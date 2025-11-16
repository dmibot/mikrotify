<p align="center">
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-GPLv3-blue.svg" alt="License: GPL v3">
  </a>
  <a href="https://github.com/DmiBot/mikrotify/stargazers">
    <img src="https://img.shields.io/github/stars/DmiBot/mikrotify?style=social" alt="GitHub stars">
  </a>
  <a href="https://github.com/DmiBot/mikrotify/issues">
    <img src="https://img.shields.io/github/issues/DmiBot/mikrotify" alt="GitHub issues">
  </a>
  <img src="https://img.shields.io/badge/RouterOS-7.0%2B-FF6C00?logo=mikrotik&logoColor=white" alt="RouterOS 7+">
  <img src="https://img.shields.io/badge/Telegram-Bot-26A5E4?logo=telegram&logoColor=white" alt="Telegram Bot">
  <img src="https://img.shields.io/badge/Language-RouterOS%20Script-lightgrey" alt="RouterOS Script">
  <img src="https://img.shields.io/badge/Status-Experimental-orange" alt="Status: Experimental">
</p>






Framework notifikasi **Telegram** untuk **MikroTik RouterOS**  
Fokus ke: **MarkdownV2**, queue, retry, debounce, digest, logging, dan health check.

Repo ini berisi kumpulan script RouterOS yang bisa kamu import sebagai **BaseConfig**, lalu dipanggil dari script lain (PPPoE monitor, Netwatch, DHCP, dsb) tanpa perlu nulis ulang fungsi-fungsi dasar.

---

## ✨ Fitur Utama

- ✅ **MarkdownV2 ready**  
  - Escape karakter spesial otomatis (`_ * [ ] ( ) ~ \` > # + - = | { } . !`)  
  - Support **judul bold**, `code block`, dan **tabel rapi** via monospace.

- ✅ **BaseConfig terpusat**  
  - Satu script berisi: token, chat ID, helper string, URL encode, dsb.  
  - Script lain cukup panggil: `:global BaseConfigTelegram; $BaseConfigTelegram;`

- ✅ **Queue & Retry (reliable send)**  
  - Kalau `/tool fetch` ke Telegram gagal → pesan dimasukkan ke queue.  
  - Scheduler `tg_flush_queue` kirim ulang sampai berhasil.

- ✅ **Debounce (anti spam event)**  
  - Fungsi `TgDebounce("KEY", 5m)` buat nahan event yang sama dalam interval tertentu.  
  - Cocok buat Netwatch / PPPoE yang flapping.

- ✅ **Digest / Rekap (batch notifikasi)**  
  - Kumpulin banyak event ke buffer dengan `TgDigestAppend`.  
  - Kirim jadi satu laporan periodik dengan `TgDigestFlush`.  
  - Contoh: rekap PPPoE, DHCP, atau error tertentu tiap 10 menit.

- ✅ **Template event**  
  - `TgTemplates` + `TgRenderTemplate` → bikin teks notifikasi konsisten, gampang dirapikan.  
  - Misal template `pppoe_down`, `netwatch_event`, dll.

- ✅ **Logging wrapper**  
  - `TgLog level msg [toTelegram]` → tulis ke `/log` dan opsional kirim ke Telegram.  
  - Bisa dipakai sebagai standar logging di semua script.

- ✅ **Health check + debug mode**  
  - `TgSelfTest` untuk kirim test message dari router.  
  - Flag `TgDebug` untuk log isi request sebelum dikirim ke Telegram.

---

## 🧱 Requirements

- **RouterOS**: minimal v7.x (di-develop & dites di 7.20.x)  
- **Router**: perangkat Mikrotik yang bisa akses `https://api.telegram.org`  
- **Bot Telegram**:
  - Buat bot via `@BotFather`
  - Dapatkan `BOT_TOKEN`
  - Dapatkan `CHAT_ID` (user / group / channel)

---

## 📦 Instalasi

1. **Buat bot & ambil token**

   - Chat `@BotFather`, buat bot baru, simpan `BOT_TOKEN`.
   - Tambahkan bot ke grup kalau mau dipakai di group, lalu ambil `chat_id`.

2. **Import BaseConfig ke RouterOS**

   - Copy isi script `BaseConfig-Telegram.rsc` dari repo ini.
   - Di WinBox / WebFig → **System → Scripts** → Add → paste script → `Run Script`.

3. **Edit konfigurasi di BaseConfig**

   Di dalam `BaseConfigTelegram`, ubah:

   ```rsc
   :global TgToken  "ISI_TOKEN_BOT_DISINI";
   :global TgChatId "ISI_CHAT_ID_DISINI";


🚀 Cara Pakai (Contoh)
1. Kirim pesan sederhana
:global BaseConfigTelegram; $BaseConfigTelegram;
:global TgSendMarkdown;

$TgSendMarkdown "Halo dari mikrotify" "Ini pesan test dari RouterOS.";

2. Kirim tabel status interface (tabel rapi)
:global BaseConfigTelegram; $BaseConfigTelegram;
:global TgSendTable;
:global TgPadRight;

:local body "";

:set body ([$TgPadRight "NAME" 16] . \
           [$TgPadRight "STATUS" 8] . \
           [$TgPadRight "RX-BYTE" 14] . \
           "TX-BYTE\n");
:set body ($body . "----------------  -------  ------------  ------------\n");

:foreach i in=[/interface print as-value] do={
  :local name    ($i->"name");
  :local running ($i->"running");
  :local rx      ($i->"rx-byte");
  :local tx      ($i->"tx-byte");

  :local st;
  :if ($running = true) do={ :set st "up"; } else={ :set st "down"; }

  :set body ($body . \
    [$TgPadRight $name 16] . \
    [$TgPadRight $st 8] . \
    [$TgPadRight $rx 14] . \
    $tx . "\n");
}

$TgSendTable "Status Interface" $body;

3. Netwatch dengan debounce (anti spam)

Di Netwatch → host → tab Down:

:global BaseConfigTelegram; $BaseConfigTelegram;
:global TgDebounce;
:global TgRenderTemplate;
:global TgSendMarkdown;

# maksimal 1 notif per 5 menit per host
:if ([$TgDebounce ("NETWATCH_" . $host) 5m] = false) do={ :return; }

:local msg [$TgRenderTemplate "netwatch_event" {
  host=$host;
  status=$status;
  time=([/system/clock get date] . " " . [/system/clock get time]);
}];

$TgSendMarkdown "Netwatch DOWN" $msg;

4. Digest PPPoE (rekap tiap 10 menit)

Saat event terjadi, kumpulkan:

:global BaseConfigTelegram; $BaseConfigTelegram;
:global TgDigestAppend;

$TgDigestAppend "pppoe" ("[" . [/system/clock get time] . "] ISP1 down di pppoe-out1");


Scheduler tiap 10 menit:

:global BaseConfigTelegram; $BaseConfigTelegram;
:global TgDigestFlush;

$TgDigestFlush "pppoe" "Digest PPPoE";

🧪 Health Check

Untuk memastikan integrasi Telegram OK:

:global BaseConfigTelegram; $BaseConfigTelegram;
:global TgSelfTest;

$TgSelfTest;


Kalau pesan masuk ke Telegram, berarti koneksi + config sudah benar.

📜 License
GNU 3.0

📝 Catatan

Script ini bukan fork & bukan copy-paste dari repo lain; konsep diadaptasi ulang dengan struktur fungsi sendiri.

Fokus repo ini adalah jadi “toolkit notifikasi” yang bisa ditempel di berbagai skenario (Netwatch, PPPoE, DHCP, monitoring custom, dsb).


