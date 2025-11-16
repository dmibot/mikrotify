# TgDigestFlush script
:global TgDigestFlush do={
    :local key $1
    :local title $2
    :local body $TelegramDigest->$key;
    $TgSendTable $title $body;
    :set $TelegramDigest->$key '';
}
