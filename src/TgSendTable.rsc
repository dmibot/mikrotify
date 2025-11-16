# TgSendTable script
:global TgSendTable do={
    :local title $1
    :local body $2
    /tool fetch url='https://api.telegram.org/bot$TelegramTokenId/sendMessage?chat_id=$TelegramChatId&text=$title%0A$body&parse_mode=Markdown'
}
