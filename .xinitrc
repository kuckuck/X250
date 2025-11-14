#!/bin/sh
# ~/.xinitrc

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

#/usr/bin/xscreensaver -no-splash &
feh --bg-scale ~/sg.jpg &
#conky | while read -r; do xsetroot -name "$REPLY"; done &
/home/nick/conkyrcs/statusbar.sh | while read -r; do xsetroot -name "$REPLY"; done &
#wmname LG3D &
xbindkeys

mpd &
pidof mpdscribble >& /dev/null
if [ $? -ne 0 ]; then
 mpdscribble &
fi

#./statusbar.sh &

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK


exec dwm
