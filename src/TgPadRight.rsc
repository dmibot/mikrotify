# TgPadRight script
:global TgPadRight do={
    :local text $1
    :local length $2
    :local padding :math ceil ($length - [:len $text])
    :return ($text . [:repeat ' ' $padding])
}
