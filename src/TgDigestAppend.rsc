# TgDigestAppend script
:global TgDigestAppend do={
    :local key $1
    :local message $2
    :if ([ :typeof $TelegramDigest->$key ] = 'nil') do={ :set $TelegramDigest->$key ''; }
    :set $TelegramDigest->$key ($TelegramDigest->$key . $message . '\n');
}
