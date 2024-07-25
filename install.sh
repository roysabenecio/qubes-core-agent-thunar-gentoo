#!/bin/bash
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root"
	exit 1
fi

# Copy qubes files that are not related to emerge itself
cp -r usr /
cp -r etc /

default_uca_xml="/etc/xdg/Thunar/uca.xml"

# Create a backup of uca.xml if it exists
if [[ -e "$default_uca_xml" ]]; then
    cp "$default_uca_xml" /etc/xdg/Thunar/uca.xml.bak
fi

package="xfce-base/thunar"
emerge_check=$(emerge -pq "$package")
existing_pattern="^\[ebuild\s+R\s+\] $package|^\[binary\s+R\s+\] $package"
		
# File paths
uca_qubes_xml="usr/lib/qubes/uca_qubes.xml"
temp_file="temp_uca.xml"

# Search pattern and insertion point
search_pattern="</actions>"
insert_content=$(cat "$uca_qubes_xml")

update_uca_file() {
    # Use awk to insert content before search pattern
    awk -v pattern="$search_pattern" -v insert="$insert_content" '
        /<\/actions>/ {
            print insert
        }
        { print }
    ' "$default_uca_xml" > "$temp_file"

    # Replace original uca.xml with the updated content
    mv "$temp_file" "$default_uca_xml"
}

if echo "$emerge_check" | grep -Eq "${existing_pattern}"; then
    echo "Package is already installed"
    echo "Will update files now"
    update_uca_file
else
    echo "Package needs to be installed first"

	emerge -vq "$package"
    echo "Done installing"
    echo "Will update files now"
    update_uca_file
fi

echo "Installing custom-qubes-core-agent-thunar done"
