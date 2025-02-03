#!/bin/bash

unzip_package='unzip'
expackage_name="v2rayN-linux-64"
package_name="$expackage_name.zip"
name="v2rayN"
latest_version_url="https://github.com/2dust/v2rayN/releases/latest/download"
download_url=$latest_version_url/$package_name
temp_directory="/tmp"
source_directory="/opt"

# Check if the user is the root user
if [ ! "$UID" -eq 0 ]; then
    echo "permission denied" >&2
    exit 1
fi

# Check if unzip installed

if ! command -v "$unzip_package" > /dev/null 2>&1; then
    echo "$unzip_package not installed"
    echo "install the $unzip_package package with this command:"
    echo "apt install $unzip_package"
    exit 1
fi


echo "download $download_url"
# wget -O /tmp/$name.zip $download_url
if [ ! $? -eq 0 ]; then
    echo "download from $downoad_url failed " 
    exit 1
fi

if [ ! -e "$temp_directory/$package_name" ]; then
    echo "$package_name not exist"
    exit 1
fi

unzip -o -d $source_directory $temp_directory/$package_name
if [ ! $? -eq 0 ]; then
    echo "Extracting $package_name to $downoad_url failed" 
    exit 1
fi

# Check if the v2rayN file already exists in /opt
# If it exists, remove it
if [ -e "$source_directory/$name" ]; then
    rm -rf "$source_directory/$name"
fi

mv -f $source_directory/$expackage_name $source_directory/$name
if [ ! $? -eq 0 ]; then
    echo "something went wrong!!!"
    exit 1
fi








