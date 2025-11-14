#!/bin/bash
# Author: nnoell <nnoell3@gmail.com>
# Depends: dzen2-xft-xpm-xinerama-svn && conky
# Desc: dzen2 bar for XMonad, ran within xmonad.hs via spawnPipe

sleep 2

#Layout
BAR_H=12
BIGBAR_W=70
WIDTH_L=1366
WIDTH_R=1500 #WIDTH_L + WIDTH_R = 1280
HEIGHT=16
X_POS_L=0
X_POS_R=420
Y_POS_L=700
Y_POS_R=0
#Colors and font
CRIT="#99cc66"
BAR_FG="#3475aa"
BAR_BG="#363636"
DZEN_FG="#9d9d9d"
DZEN_FG2="#444444"
DZEN_BG="#020202"
#DZEN_BG="#0d111b"
RED="#F92672"
GREEN="#A6E22E"
BLUE="#1B5080"
YELLOW="#FD971F"
COLOR_SEP=$DZEN_FG2
#FONT="montecarlo-medium-r-normal-*-11-*-*-*-*-*-*-*"
#FONT="-*-envy code r-medium-r-*-*-14-*-*-*-*-*-iso8859-*"
#Conky
CONKYFILE="${HOME}/.config/conky/conkyrc"
IFS='|'
INTERVAL=1
CPUTemp=0
GPUTemp=0
CPULoad0=0
CPULoad1=0
MpdInfo=0
MpdRandom="Off"
MpdRepeat="Off"

DiskIO=0
Rx=0
Tx=0

BAT0=0
BAT1=0


#clickable areas
VOL_MUTE_CMD="sh /home/hoang/Scripts/volosd.sh mute"
VOL_UP_CMD="sh /home/hoang/Scripts/volosd.sh up"
VOL_DOWN_CMD="sh /home/hoang/Scripts/volosd.sh down"
DROP_START_CMD="dropbox start"
DROP_STOP_CMD="dropbox stop"
MPD_REP_CMD="mpc -h 127.0.0.1 repeat"
MPD_RAND_CMD="mpc -h 127.0.0.1 random"
MPD_TOGGLE_CMD="ncmpcpp toggle"
MPD_NEXT_CMD="ncmpcpp next"
MPD_PREV_CMD="ncmpcpp prev"
CAL_CMD="sh ${HOME}/Scripts/dzencal.sh"


printBattery0() {
	echo -n "^fg($YELLOW)B0 "
	echo -n "$(echo $BAT0 | gdbar -fg $YELLOW -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl)"
	return
}


printBattery1() {
        echo -n "^fg($GREEN)B1 "
	echo -n "$(echo $BAT1 | gdbar -fg $GREEN -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl)"
	return
}



printVolInfo() {
	Perc=$(amixer get Master | grep "Mono:" | awk '{print $4}' | tr -d '[]%')
	Mute=$(amixer get Master | grep "Mono:" | awk '{print $6}')
	echo -n "^fg($DZEN_FG2)^ca(1,$VOL_MUTE_CMD)^ca(4,$VOL_UP_CMD)^ca(5,$VOL_DOWN_CMD)VOL^ca()^ca()^ca() "
	if [[ $Mute == "[off]" ]]; then
		echo -n "$(echo $Perc | gdbar -fg $BAR_FG -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl) "
		echo -n "^fg()off"
	else
		echo -n "$(echo $Perc | gdbar -fg $CRIT -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl) "
		echo -n "^fg()${Perc}%"
	fi
	return
}

printCPUInfo() {
	[[ $CPULoad0 -gt 70 ]] #&& CPULoad0="^fg($CRIT)$CPULoad0^fg()"
	#echo -n " ^fg($GREEN)CPU ^fg($GREEN)${CPULoad0}%^fg($DZEN_FG2)/^fg($GREEN)${CPULoad1}%"
  echo -n "^fg($BLUE)CPU ^fg($BLUE)${FREQ}GHz $(echo $CPULoad0 | gdbar -fg $BLUE -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl)"
#echo -n "^fg($GREEN) CPU1 ^fg($GREEN)${CPULoad1}% $(echo $CPULoad1 | gdbar -fg $GREEN -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -sw o -ss 1 -sw 2 -nonl)"
	return
}

printTempInfo() {
  CPUTemp=$(sensors  coretemp-isa-0000 | grep 'Core 0' | awk -F'+' '{print$2}' | awk -F'.' '{print $1}')
 # GPUTemp=$(nvidia-settings -q gpucoretemp | grep 'Attribute' | awk '{print $4}' | tr -d '.')
	[[ $CPUTemp -gt 70 ]] && CPUTemp="^fg($CRIT)$CPUTemp^fg()"
#	[[ $GPUTemp -gt 70 ]] && GPUTemp="^fg($CRIT)$GPUTemp^fg()"
	echo -n "^fg($RED)TEMP ^fg($RED)${CPUTemp}°^fg($DZEN_FG2)"
	return
}

printMemInfo() {
#	[[ $MemPerc -gt 70 ]] && CPUTemp="^fg($CRIT)$MemPerc^fg()"
	#echo -n "^fg($YELLOW)MEM ^fg($YELLOW)${MemPerc}%"
  echo -n "^fg($BLUE)MEM ^fg($BLUE)${MemPerc}% $(echo $MemPerc | gdbar -fg $BLUE -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl)"
  return
}

printDropBoxInfo() {
	DropboxON=$(ps -A | grep -c dropbox)
	if [[ $DropboxON == "0" ]]; then
		echo -n "^fg($DZEN_FG2)^ca(1,$DROP_START_CMD)DROPBOX^ca() ^fg()Off"
	else
		echo -n "^fg($DZEN_FG2)^ca(1,$DROP_STOP_CMD)DROPBOX^ca() ^fg($CRIT)On"
	fi
	return
}

printMpdInfo() {
	MPDON=$(ps -A | grep -c mpd)
	if [[ $MPDON == "0" ]]; then
		echo -n "^fg($DZEN_FG2)^ca(1,mpd)MPD^ca() ^fg()Off"
	else
		[[ $MpdRepeat == "On" ]] && MpdRepeat="^fg($CRIT)$MpdRepeat^fg()"
		[[ $MpdRandom == "On" ]] && MpdRandom="^fg($CRIT)$MpdRandom^fg()"
		echo -n "^fg($DZEN_FG2)^ca(1,$MPD_REP_CMD)REPEAT^ca() ^fg()$MpdRepeat "
		echo -n "^fg($DZEN_FG2)| ^ca(1,$MPD_RAND_CMD)RANDOM^ca() ^fg()$MpdRandom "
		echo -n "^fg($DZEN_FG2)| ^ca(1,$MPD_TOGGLE_CMD)^ca(4,$MPD_NEXT_CMD)^ca(5,$MPD_PREV_CMD)MPD^ca()^ca()^ca() $MpdInfo"
	fi
	return
}

printDateInfo() {
	echo -n "^ca(1,$CAL_CMD)^fg()$(date '+%Y^fg(#444).^fg()%m^fg(#444).^fg()%d^fg(#3475aa)/^fg(#444444)%a^fg(#363636)')^ca()"
	return
}


printTimeInfo() {
  echo -n "^fg($RED)$(date '+%I^fg(#3475aa):^fg(#3475aa)%M^fg(#444):^fg(#3475aa)%S %p')"
  return
}



printStorage (){
    echo -n "SSD $SSD HDD $HDD"
    return
}

printNetspeed (){
    echo -n "RX $RX TX $TX"
    return
}

printWiFi () {
    echo -n "^fg($YELLOW)WiFi $(echo $WiFi | gdbar -fg $YELLOW -bg $BAR_BG -h $BAR_H -w $BIGBAR_W -s o -ss 1 -sw 2 -nonl)"
    return
}


printSpace() {
	echo -n "^fg($COLOR_SEP)|^fg()"
	return
}


printRight() {
	while true; do
		read CPULoad0 BAT0 BAT1 MemPerc SSD HDD RX TX WiFi FREQ
                printBattery0
                printSpace
                printBattery1
                printSpace
		printCPUInfo
                printSpace
                printMemInfo
                printSpace
                printStorage
                printSpace
                printNetspeed
                printSpace
                printDateInfo
                printSpace
                printTimeInfo
                printSpace
                printVolInfo
                printSpace
                printWiFi
		echo
	done
	return
}

#Print all and pipe into dzen
conky -c $CONKYFILE -u $INTERVAL | printRight | dzen2 -x $X_POS_R -y $Y_POS_R -w $WIDTH_R -h $HEIGHT -ta 'r' -bg $DZEN_BG -fg $DZEN_FG -p -e '' &
