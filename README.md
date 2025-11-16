# mikrotify

Framework notifikasi **Telegram** untuk **MikroTik RouterOS**.  
Fokus ke: **MarkdownV2**, queue, retry, debounce, digest, logging, dan health check.

Repo ini berisi kumpulan script RouterOS yang bisa kamu import sebagai **BaseConfig**, lalu dipanggil dari script lain (PPPoE monitor, Netwatch, DHCP, dsb) tanpa perlu nulis ulang fungsi-fungsi dasar.

---

![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![RouterOS 7+](https://img.shields.io/badge/RouterOS-7.0%2B-FF6C00?logo=mikrotik&logoColor=white)
![Telegram Bot](https://img.shields.io/badge/Telegram-Bot-26A5E4?logo=telegram&logoColor=white)
![Language: RouterOS Script](https://img.shields.io/badge/Language-RouterOS%20Script-lightgrey)
![Status: Experimental](https://img.shields.io/badge/Status-Experimental-orange)


---


## ✨ Fitur Utama

- ✅ **MarkdownV2 ready**  
  - Escape karakter spesial otomatis (`_ * [ ] ( ) ~ \` > # + - = | { } . !`)  
  - Support judul **bold**, code block, dan **tabel rapi** via monospace.

- ✅ **BaseConfig terpusat**  
  - Satu script berisi: token, chat ID, helper string, URL encode, queue, dll.  
  - Script lain cukup panggil:
    
        :global BaseConfigTelegram; $BaseConfigTelegram;

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
  - `TgTemplates` + `TgRenderTemplate` → bikin teks notifikasi konsisten dan gampang dirapikan.  
  - Misal template `pppoe_down`, `netwatch_event`, dsb.

- ✅ **Logging wrapper**  
  - `TgLog level msg [toTelegram]` → tulis ke `/log` dan opsional kirim ke Telegram.  
  - Bisa dipakai sebagai standar logging di semua script.

- ✅ **Health check + debug mode**  
  - `TgSelfTest` untuk kirim test message dari router.  
  - Flag `TgDebug` untuk log isi request sebelum dikirim ke Telegram.

---

## 🧱 Requirements

- **RouterOS**: minimal v7.x  
  (dikembangkan & dites di **RouterOS v7.20.x / hAP ax²**)
- **Router**: perangkat MikroTik yang bisa akses `https://api.telegram.org`
- **Bot Telegram**:
  - Buat bot via `@BotFather`
  - Simpan `BOT_TOKEN`
  - Dapatkan `CHAT_ID` (user / group / channel)

---

## 📦 Instalasi

1. **Buat bot & ambil token**

   - Chat `@BotFather`, buat bot baru, simpan `BOT_TOKEN`.
   - Tambahkan bot ke grup kalau mau dipakai di group, lalu ambil `chat_id`.

2. **Import BaseConfig ke RouterOS**

   - Ambil isi script `BaseConfig-Telegram.rsc` dari folder `base/` repo ini.
   - Di WinBox / WebFig → **System → Scripts** → Add → paste script → `Run Script`.

3. **Edit konfigurasi di BaseConfig**

   Di dalam `BaseConfigTelegram`, ubah:

       :global TgToken  "ISI_TOKEN_BOT_DISINI";
       :global TgChatId "ISI_CHAT_ID_DISINI";

4. (Opsional) Atur **scheduler** untuk:
   - `tg_flush_queue` (otomatis dibuat BaseConfig kalau ada error kirim)
   - digest PPPoE / laporan berkala lain  
   - health check harian

---

## 🧠 Fungsi Global yang Disediakan

Setelah `BaseConfig-Telegram.rsc` dijalankan, kamu akan punya beberapa global function, di antaranya:

**Format & Template:**

- `TgEscapeMarkdown` – escape teks untuk MarkdownV2  
- `TgPadRight` – padding kanan untuk bikin tabel rapi  
- `TgSendMarkdown` – kirim pesan biasa (subject + body + optional link)  
- `TgSendTable` – kirim teks sebagai tabel (code block)  
- `TgRenderTemplate` – render teks dari template + context

**Reliability:**

- `TgQueue` + `TgFlushQueue` – queue & retry  
- `TgDebounce` – batasi frekuensi event per key  
- `TgDigestAppend` / `TgDigestFlush` – buffer & kirim digest

**Convenience:**

- `TgLog` – wrapper logging + optional Telegram  
- `TgSelfTest` – kirim pesan test  
- `TgDebug` – flag untuk debug

Detail implementasi ada di file `base/BaseConfig-Telegram.rsc`.

---

## 🚀 Cara Pakai (Contoh)

> Penting: sebelum pakai contoh di bawah, pastikan BaseConfig sudah jalan:
>
>     :global BaseConfigTelegram; $BaseConfigTelegram;

### 1. Kirim pesan sederhana

    :global BaseConfigTelegram; $BaseConfigTelegram;
    :global TgSendMarkdown;

    $TgSendMarkdown "Halo dari mikrotify" "Ini pesan test dari RouterOS.";

---

### 2. Kirim tabel status interface (tabel rapi)

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

---

### 3. Netwatch dengan debounce (anti spam)

Di **Netwatch → host → tab `Down`**, isi script berikut:

    :global BaseConfigTelegram; $BaseConfigTelegram;
    :global TgDebounce;
    :global TgRenderTemplate;
    :global TgSendMarkdown;

    # maksimal 1 notif per 5 menit per host
    :if ([$TgDebounce ("NETWATCH_" . $host) 5m] = false) do={
      :return;
    }

    :local msg [$TgRenderTemplate "netwatch_event" {
      host=$host;
      status=$status;
      time=([/system/clock get date] . " " . [/system/clock get time]);
    }];

    $TgSendMarkdown "Netwatch DOWN" $msg;

---

### 4. Digest PPPoE (rekap tiap 10 menit)

Saat event PPPoE terjadi, kumpulkan baris ke buffer:

    :global BaseConfigTelegram; $BaseConfigTelegram;
    :global TgDigestAppend;

    $TgDigestAppend "pppoe" ("[" . [/system/clock get time] . "] ISP1 down di pppoe-out1");

Lalu buat **scheduler tiap 10 menit** (misalnya di `/system scheduler`):

    :global BaseConfigTelegram; $BaseConfigTelegram;
    :global TgDigestFlush;

    $TgDigestFlush "pppoe" "Digest PPPoE";

---

### 5. 🧪 Health Check (Self Test)

Untuk memastikan integrasi Telegram OK:

    :global BaseConfigTelegram; $BaseConfigTelegram;
    :global TgSelfTest;

    $TgSelfTest;

Kalau pesan ini masuk ke Telegram, berarti koneksi + konfigurasi **mikrotify** sudah benar.

---

## 📁 Struktur Repo 

Berikut adalah struktur repositori **Mikrotify**
```` ``` ````
```` ``` ````mikrotify/
```` ``` ````├── src/
```` ``` ````│ ├── BaseConfigTelegram.rsc # Skrip utama untuk konfigurasi dan pengaturan bot Telegram
```` ``` ````│ ├── TgSendMarkdown.rsc # Skrip untuk mengirim pesan sederhana menggunakan format Markdown
```` ``` ````│ ├── TgSendTable.rsc # Skrip untuk mengirim pesan berupa tabel
```` ``` ````│ ├── TgPadRight.rsc # Skrip untuk penyesuaian padding di tabel
```` ``` ````│ ├── TgDebounce.rsc # Skrip untuk mengatur debounce (anti spam) pada notifikasi
```` ``` ````│ ├── TgRenderTemplate.rsc # Skrip untuk merender template pesan
```` ``` ````│ ├── TgDigestAppend.rsc # Skrip untuk menambah data ke dalam digest
```` ``` ````│ ├── TgDigestFlush.rsc # Skrip untuk mengirimkan digest (ringkasan) secara berkala
```` ``` ````│ ├── TgSelfTest.rsc # Skrip untuk pengecekan integrasi Telegram
```` ``` ````│ └── notification-telegram.rsc # Skrip untuk pengaturan dan pengiriman notifikasi Telegram
```` ``` ````│
```` ``` ````├── examples/
```` ``` ````│ └── example_script.rsc # Contoh skrip penggunaan Mikrotify dalam berbagai skenario
```` ``` ````│
```` ``` ````├── LICENSE.md # Lisensi GNU 3.0
```` ``` ````├── .gitignore # File untuk mengabaikan file yang tidak perlu dalam repo
```` ``` ````└── Makefile # File untuk otomatisasi build dan pengaturan repo


---

## 📜 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.  
You may copy, distribute and modify the software as long as you track changes/dates in source files and keep the same license.

See the `LICENSE` file for the full text.

---

## 📝 Catatan

- Script ini **bukan fork & bukan copy-paste** dari repo lain; konsep diadaptasi ulang dengan struktur fungsi sendiri.
- Fokus repo ini adalah jadi **toolkit notifikasi** yang bisa ditempel di berbagai skenario:
  - Netwatch
  - PPPoE
  - DHCP
  - monitoring custom
  - dan lain-lain sesuai kreativitas kamu.
