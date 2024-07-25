#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

qvm_actions_sh="/usr/lib/qubes/qvm-actions.sh"
uca_qubes_xml="/usr/lib/qubes/uca_qubes.xml"
xdg_thunar_xml="/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"

rm "$qvm_actions_sh"
echo "Removed $qvm_actions_sh"

rm "$uca_qubes_xml"
echo "Removed $uca_qubes_xml"

rm "$xdg_thunar_xml"
echo "Removed $xdg_thunar_xml"

# Rename file to .uninstalled file
if [[ -e "/etc/xdg/Thunar/uca.xml" ]]; then
    mv -f /etc/xdg/Thunar/uca.xml /etc/xdg/Thunar/uca.xml.uninstalled
fi

# Revert to backup file
if [[ -e "$default_uca_xml" ]]; then
    mv -f /etc/xdg/Thunar/uca.xml.bak /etc/xdg/Thunar/uca.xml
fi

emerge -vqC xfce-base/thunar
