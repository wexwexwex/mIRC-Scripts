;simple vlc script
alias vlc {
  sockclose vlc
  sockopen vlc localhost 8080
}
on *:sockopen:vlc: {
  if $sockerr > 0 { echo -at vlc not running | sockclose vlc }
  sockwrite -n $sockname GET /requests/status.xml HTTP/1.1
  sockwrite -n $sockname Host: localhost
  sockwrite -n $sockname Connection: Keep-Alive
  sockwrite -n $sockname $crlf
}
on *:sockread:vlc: {
  if $sockerr > 0 { echo -a error | sockclose vlc }
  sockread %vlcx
  ;echo -a %vlcx

  if (*name='filename'>* iswm %vlcx) {

    if ($regex(%vlcx,<info name='filename'>\s*\K(.+?)(?=\s*<\/info>)) == 1) {
      set %vlcann1 $regml(1)
    }
  }

  if (*name='Frame rate'>* iswm %vlcx) {
    if ($regex(%vlcx,<info name='Frame rate'>\s*\K(.+?)(?=\s*<\/info>)) == 1) {
      var %vlcann2 $regml(1)
    }
  }

  if (*name='Codec'>* iswm %vlcx) {
    if ($regex(%vlcx,<info name='Codec'>\s*\K(.+?)(?=\s*<\/info>)) == 1) {
      var %vlcann3 $regml(1)
      msg $active 7VLC %vlcann1 7:: %vlcann3 $+ @ $+ %vlcann2 fps
      unset %vlcann1
    }
  }


}
