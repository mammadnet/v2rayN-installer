#!/bin/bash


# Colors
RED="\e[31m"
GRN="\e[32m"
BLU="\e[34m"
RST="\e[0m"
#----------------
unzip_package='unzip'
expackage_name="v2rayN-linux-64"
package_name="$expackage_name.zip"
name="v2rayN"
latest_version_url="https://github.com/2dust/v2rayN/releases/latest/download"
download_url=$latest_version_url/$package_name
temp_directory="/tmp"
source_directory="/opt"

error(){
    echo -e "$RED\0ERR: $1\0$RST" >&2
}

notice(){
    echo -e "$BLU\0$1\0$RST"
}

success(){
    echo -e "$GRN\0$1\0$RST"
}

# Check if the user is the root user
if [ ! "$UID" -eq 0 ]; then
    error "permission denied"
    exit 1
fi

# Check if unzip installed

if ! command -v "$unzip_package" > /dev/null 2>&1; then
    error "$unzip_package not installed"
    notice "install the $unzip_package package with this command:"
    notice "apt install $unzip_package"
    exit 1
fi


notice "download $download_url"
wget -q --show-progress --progress=bar:force -O /tmp/$package_name $download_url 2>&1
if [ ! $? -eq 0 ]; then
    error "download from $downoad_url failed " 
    exit 1
fi

if [ ! -e "$temp_directory/$package_name" ]; then
    error "$package_name not exist"
    exit 1
fi

unzip -o -d $source_directory $temp_directory/$package_name
if [ ! $? -eq 0 ]; then
    error "Extracting $package_name to $downoad_url failed" 
    exit 1
fi

# Check if the v2rayN file already exists in /opt
# If it exists, remove it
if [ -e "$source_directory/$name" ]; then
    rm -rf "$source_directory/$name"
fi

mv -f $source_directory/$expackage_name $source_directory/$name
if [ ! $? -eq 0 ]; then
    error "something went wrong!!!"
    exit 1
fi


ln -f -s $source_directory/$name/$name /bin/
if [ ! $? -eq 0 ]; then
    error "something went wrong!!!"
    exit 1
fi

desktop_items="/usr/share/applications"

desktop_Entry="[Desktop Entry]\nType=Application\nTerminal=false\nIcon=$source_directory/$name/$name.png\nName=v2rayN\nExec=/bin/$name\nCategories=Utility;\n"

if [ ! -e $desktop_items ]; then
    error "$name was installed but Icon was not added to desktop items"
    error "$desktop_items not exist"
    echo "You can run the $name by v2rayN command"
    exit 1
fi

echo -e $desktop_Entry > $desktop_items/$name.desktop
if [ ! $? -eq 0 ]; then
    error "something went wrong!!!"
    exit 1
fi

exit 0




