# TgRenderTemplate script
:global TgRenderTemplate do={
    :local templateName $1
    :local variables $2
    :local message '';
    :if ($templateName = 'netwatch_event') do={
        :set message 'Host: $variables->host Status: $variables->status Time: $variables->time';
    }
    :return $message;
}
