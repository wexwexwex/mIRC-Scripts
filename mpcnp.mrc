;MPC IRC announce script for mIRC
;You have to enable Web Interface. Default port is 13579
;Use /mpc to announce

alias mpc {
  sockclose mpcx
  sockopen mpcx localhost 13579
}

on *:sockopen:mpcx: {
  if $sockerr > 0 { echo -a error | sockclose mpcx }
  sockwrite -n $sockname GET /info.html HTTP/1.1
  sockwrite -n $sockname Host: localhost
  sockwrite -n $sockname $crlf
}
on *:sockread:mpcx: {
  if $sockerr > 0 { echo -a error | sockclose mpcx }
  sockread %read
  ;echo -a %read
  if (*mpchc_np">*</p>* iswm %read) {
    if ($regex(%read,id="mpchc_np">(.*)</p>) > 0) {
      var %mpctotal $regml(1)
      msg $active watching :: $replace($remove(%mpctotal,MPC-HC v1.6.5.6366,&laquo;,&raquo;),&bull;,•) ::
    }      
  }
}
