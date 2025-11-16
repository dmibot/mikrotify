# TgSendMarkdown script
:global TgSendMarkdown do={
    :local message $1
    /tool fetch url='https://api.telegram.org/bot$TelegramTokenId/sendMessage?chat_id=$TelegramChatId&text=$message&parse_mode=Markdown'
}
