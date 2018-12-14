#!/bin/bash
#
# rotate_desktop.sh
#
# Rotates modern Linux desktop screen and input devices to match. Handy for
# convertible notebooks. Call this script from panel launchers, keyboard
# shortcuts, or touch gesture bindings (xSwipe, touchegg, etc.).
#
# Using transformation matrix bits taken from:
#   https://wiki.ubuntu.com/X/InputCoordinateTransformation
#

Icon=$HOME/keyonc.png
Icoff=$HOME/keyoff.png
fconfig=".keyboard" 
id=12

if [ ! -f $fconfig ];
    then
        echo "Creating config file"
        echo "normal" > $fconfig
        var="normal"
    else
        read -r var< $fconfig
        echo "Mode is : $var"
fi

#Check For Override
if [ -z "$1" ];
then
    echo ""
else
    var=$1
fi

function do_rotate
{
    xrandr --output $1 --rotate $var

    #Notify and set icon
            case "$var" in
            normal)
	        notify-send -i $Icon "Laptop Mode..." \ "ON - Keyboard enabled!";
		echo "Laptop Mode..."
		xinput enable $id
		echo "left" > $fconfig
		;;
            inverted)
	        notify-send -i $Icoff "Tent Mode..." \ "OFF - Keyboard disabled!";
		echo "Tent Mode..."
		xinput disable $id
		echo "right" > $fconfig
		;;
            left)
	        notify-send -i $Icon "Tablet Mode..." \ "OFF - Keyboard disabled!";
		echo "Tablet Mode..."
		xinput disable $id
		echo "inverted" > $fconfig
		;;
            right)
	        notify-send -i $Icon "Tablet Mode..." \ "OFF - Keyboard disabled!";
		echo "Tablet Mode..."
		xinput disable $id
		echo "normal" > $fconfig
		;;
        esac

  
  TRANSFORM='Coordinate Transformation Matrix'

  POINTERS=`xinput | grep 'slave  pointer'`
  POINTERS=`echo $POINTERS | sed s/↳\ /\$/g`
  POINTERS=`echo $POINTERS | sed s/\ id=/\@/g`
  POINTERS=`echo $POINTERS | sed s/\ \\\[slave\ pointer/\#/g`
  iIndex=2
  POINTER=`echo $POINTERS | cut -d "@" -f $iIndex | cut -d "#" -f 1`
  while [ "$POINTER" != "" ] ; do
    POINTER=`echo $POINTERS | cut -d "@" -f $iIndex | cut -d "#" -f 1`
    POINTERNAME=`echo $POINTERS | cut -d "$" -f $iIndex | cut -d "@" -f 1`
    #if [ "$POINTER" != "" ] && [[ $POINTERNAME = *"TouchPad"* ]]; then    # ==> uncomment to transform only touchpads
    #if [ "$POINTER" != "" ] && [[ $POINTERNAME = *"Touchscreen"* ]]; then  # ==> uncomment to transform only trackpoints
    #if [ "$POINTER" != "" ] && [[ $POINTERNAME = *"ACPI"* ]]; then   # ==> uncomment to transform only digitizers (touch)
    #if [ "$POINTER" != "" ] && [[ $POINTERNAME = *"MOUSE"* ]]; then       # ==> uncomment to transform only optical mice
    if [ "$POINTER" != "" ] ; then                                         # ==> uncomment to transform all pointer devices
        case "$var" in
            normal)
		[ ! -z "$POINTER" ]    && xinput set-prop "$POINTER" "$TRANSFORM" 1 0 0 0 1 0 0 0 1
		;;
            inverted)
		[ ! -z "$POINTER" ]    && xinput set-prop "$POINTER" "$TRANSFORM" -1 0 1 0 -1 1 0 0 1
		;;
            left)
		[ ! -z "$POINTER" ]    && xinput set-prop "$POINTER" "$TRANSFORM" 0 -1 1 1 0 0 0 0 1
		;;
            right)
		[ ! -z "$POINTER" ]    && xinput set-prop "$POINTER" "$TRANSFORM" 0 1 0 -1 0 1 0 0 1
		;;
        esac      
    fi
    iIndex=$[$iIndex+1]
  done
}

XDISPLAY=`xrandr --current | grep primary | sed -e 's/ .*//g'`
if [ "$XDISPLAY" == "" ] || [ "$XDISPLAY" == " " ] ; then
  XDISPLAY=`xrandr --current | grep connected | sed -e 's/ .*//g' | head -1`
fi

do_rotate $XDISPLAY $var
