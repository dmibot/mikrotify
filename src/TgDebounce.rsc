# TgDebounce script
:global TgDebounce do={
    :local key $1
    :local time $2
    :if ([ :typeof $key ] != 'string' || [ :typeof $time ] != 'string') do={ :return false; }
    :set result false;
    :if ([ :typeof $TelegramChatOffset->$key ] = 'nil') do={ :set result true; :set $TelegramChatOffset->$key $time; }
    :if ([ :typeof $TelegramChatOffset->$key ] != 'nil' && $time > $TelegramChatOffset->$key) do={ :set result true; :set $TelegramChatOffset->$key $time; }
}