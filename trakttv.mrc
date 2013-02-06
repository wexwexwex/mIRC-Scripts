;MPC interaction with http://trakt.tv/ i.e. announcing to trakt.tv what you're currently watching
;kinda outdated since I wrote this ages ago (and haven't been using trakt ever since) which uses the old MPC info page (controls.html)
;change the field <apikeyhere>, <usernamehere> and <md5hash of your password here>
;Requires curl.exe (http://curl.haxx.se/)
;I should probably switch to sockets whenever I get time to update this.
;needs an infinite timer for the command "mpcheck"

alias trak-settings {
  set %trak-apikey <apikeyhere>
  set %trak-dir C:\test\mpc\
}
alias mpcheck {
  sockClose mpc
  sockOpen mpc localhost 13579
}
on *:sockopen:mpc {
  sockwrite -nt mpc GET /controls.html HTTP/1.0

  sockwrite -nt mpc Host: localhost
  sockwrite -nt mpc $crlf
}
on *:sockread:mpc: {
  var %read
  sockread %read

  if (*var filepath* iswm %read) {
    var %hm1 $calc($count(%read, $+ $chr(92) $+ ) +1)
    set %hm2 $remove($gettok(%read, %hm1 ,92),";)
    if ($regex(%hm2,/(.*?)\.S\d\d?E\d\d/i) > 0) {
      echo -ae $replace($regml(1),., $chr(32) )
      set %trak-title $replace($regml(1),., $chr(32) )
      trakfilter
      tvpost1
    }
    else {
      echo -ae %hm2
      imdbpost
    }
  }
}

alias trakfilter {
  //ECHO -ae $regex(%hm2,^.*([sS][0-9][0-9]).*mkv) 
  if (S0 isin $regml(1)) {
    echo -ae $replace($regml(1),S0,"season": $+ $chr(32) $+ )
    set %trak-season $replace($regml(1),S0,"season": $+ $chr(32) $+ )
  }
  else {
    echo -ae $replace($regml(1),S,"season": $+ $chr(32) $+ )
    set %trak-season $replace($regml(1),S,"season": $+ $chr(32) $+ )
  }
  //ECHO -ae $regex(%hm2,^.*([eE][0-9][0-9]).*mkv)
  if (E0 isin $regml(1)) {
    echo -ae $replace($regml(1),E0,"episode": $+ $chr(32) $+ )
    set %trak-episode $replace($regml(1),E0,"episode": $+ $chr(32) $+ )
  }
  else {
    echo -ae $replace($regml(1),E,"episode": $+ $chr(32) $+ )
    set %trak-episode $replace($regml(1),E,"episode": $+ $chr(32) $+ )
  }
}

alias tvpost1 {
  write C:\test\mpc\episode.json $chr(123)
  write C:\test\mpc\episode.json "username": "<usernamehere>",
  write C:\test\mpc\episode.json "password": "<md5hash of your password here>",
  write C:\test\mpc\episode.json "title": " $+ %trak-title $+ ",
  write C:\test\mpc\episode.json "episodes": [
  write C:\test\mpc\episode.json $chr(123)
  write C:\test\mpc\episode.json %trak-season $+ ,
  write C:\test\mpc\episode.json %trak-episode
  write C:\test\mpc\episode.json $chr(125)
  write C:\test\mpc\episode.json ]
  write C:\test\mpc\episode.json $chr(125)
  tvpost2
}

alias tvpost2 {
  run %trak-dir $+ curl.exe -d @ $+ %trak-dir $+ episode.json  -H "Content-type: text/json" "http://api.trakt.tv/show/episode/seen/ $+ %trak-apikey $+ "
  unset %trak-episode
  unset %trak-title
  unset %trak-season
  remove %trak-dir $+ episode.json
}