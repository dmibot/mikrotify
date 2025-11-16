# TgSelfTest script
:global TgSelfTest do={
    :local message 'Testing Telegram integration'
    $TgSendMarkdown $message $message;
}
