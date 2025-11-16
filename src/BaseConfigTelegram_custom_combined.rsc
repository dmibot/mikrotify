
#!rsc by RouterOS
# BaseConfigTelegram - Skrip kustom dengan konfigurasi Telegram

# Variabel Global
:global TokenTelegram 'your-telegram-bot-token'
:global IDChatTelegram 'your-chat-id'  # Ganti dengan ID chat Telegram Anda
:global DigestTelegram
:global OffsetChatTelegram
:global FungsiNotifikasi
:global AntrianTelegram
:global KonfigurasiGlobalSiap false
:global TidakAdaNotifikasiBerita false
:global IdentitasEx ''  # Anda bisa menambahkan emoji atau teks tambahan di sini

# Fungsi untuk menambahkan pesan ke dalam digest
:global TambahDigestTelegram do={
    :local kunci $1
    :local pesan $2
    :if ([ :typeof $DigestTelegram->$kunci ] = 'nil') do={ :set $DigestTelegram->$kunci ''; }
    :set $DigestTelegram->$kunci ($DigestTelegram->$kunci . $pesan . '\n');
}

# Fungsi untuk merender template pesan
:global RenderTemplateTelegram do={
    :local namaTemplate $1
    :local variabel $2
    :local pesan '';
    :if ($namaTemplate = 'netwatch_event') do={
        :set pesan 'Host: $variabel->host Status: $variabel->status Waktu: $variabel->time';
    }
    :return $pesan;
}

# Fungsi untuk melakukan padding pada teks
:global TambahSpasiKanan do={
    :local teks $1
    :local panjang $2
    :local padding :math ceil ($panjang - [:len $teks])
    :return ($teks . [:repeat ' ' $padding])
}

# Fungsi untuk debounce event
:global DebounceTelegram do={
    :local kunci $1
    :local waktu $2
    :if ([ :typeof $kunci ] != 'string' || [ :typeof $waktu ] != 'string') do={ :return false; }
    :set hasil false;
    :if ([ :typeof $OffsetChatTelegram->$kunci ] = 'nil') do={ :set hasil true; :set $OffsetChatTelegram->$kunci $waktu; }
    :if ([ :typeof $OffsetChatTelegram->$kunci ] != 'nil' && $waktu > $OffsetChatTelegram->$kunci) do={ :set hasil true; :set $OffsetChatTelegram->$kunci $waktu; }
}

# Fungsi untuk mengirimkan pesan sebagai Markdown
:global KirimPesanMarkdown do={
    :local pesan $1
    /tool fetch url='https://api.telegram.org/bot$TokenTelegram/sendMessage?chat_id=$IDChatTelegram&text=$pesan&parse_mode=Markdown'
}

# Fungsi untuk mengirimkan tabel sebagai pesan
:global KirimTabelTelegram do={
    :local judul $1
    :local tubuh $2
    /tool fetch url='https://api.telegram.org/bot$TokenTelegram/sendMessage?chat_id=$IDChatTelegram&text=$judul%0A$tubuh&parse_mode=Markdown'
}

# Fungsi untuk mengirimkan digest
:global FlushDigestTelegram do={
    :local kunci $1
    :local judul $2
    :local tubuh $DigestTelegram->$kunci;
    $KirimTabelTelegram $judul $tubuh;
    :set $DigestTelegram->$kunci '';
}

# Fungsi untuk menguji koneksi Telegram
:global TesIntegrasiTelegram do={
    :local pesan 'Mengujicoba integrasi Telegram'
    $KirimPesanMarkdown $pesan $pesan;
}

# Fungsi untuk pengaturan notifikasi Telegram
:global NotifikasiTelegram do={
    :global FlushAntrianTelegram;
    :global AmbilIDChatTelegram;
    :global FungsiNotifikasi;
    :global HapusAntrianTelegram;
    :global KirimPesanTelegram;
    :global KirimPesanTelegram2;
}

# Fungsi untuk berkomunikasi dengan RouterOS melalui Telegram
:global ChatTelegram do={
    :local KeluarOK false;
    :onerror Kesalahan {
        :global KonfigurasiGlobalSiap; :global FungsiGlobalSiap;
        :retry { :if ($KonfigurasiGlobalSiap != true || $FungsiGlobalSiap != true) do={ :set KeluarOK false; } }
    }
}
