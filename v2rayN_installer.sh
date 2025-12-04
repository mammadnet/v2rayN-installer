#!/bin/bash


# Colors
RED="\e[31m"
GRN="\e[32m"
YLW="\e[33m"
MGN="\e[35m"
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
    echo -e "$YLW\0$1\0$RST"
}

success(){
    echo -e "$GRN\0$1\0$RST"
}

warining(){
    echo -e "$MGN\0$1\0$RST"
}

# Check if the user is the root user
if [ ! "$UID" -eq 0 ]; then
    error "permission denied"
    exit 1
else 
    user=$SUDO_USER
fi

# Check if unzip installed

if ! command -v "$unzip_package" > /dev/null 2>&1; then
    error "$unzip_package not installed"
    notice "install the $unzip_package package with this command:"
    notice "apt install $unzip_package"
    exit 1
fi

prompt='y'
if [ -e "$temp_directory/$package_name" ]; then
    warining "$package_name already exist in /tmp/"
    echo -n -e $YLW
    read -p "Do you want to download it again? [Y/n] " prompt
    echo -n -e $RST
    prompt=${prompt:-y}
fi
if [ $prompt == 'y' ]; then
    if [ -e "$temp_directory/$package_name" ]; then
        warining "Removing $temp_directory/$package_name"
        rm $temp_directory/$package_name
    fi

    notice "Downloading $download_url"
    notice "Save downloaded file to $temp_directory"

    wget -q --show-progress --progress=bar:force -O /tmp/$package_name $download_url 2>&1
    if [ ! $? -eq 0 ]; then
        error "download from $download_url failed " 
        exit 1
    fi

    success "Download completed"


fi

notice "Extracting: $temp_directory/$package_name"
notice "Save $expackage_name to $source_directory"

unzip -q -o -d $source_directory $temp_directory/$package_name
if [ ! $? -eq 0 ]; then
    error "Extracting $package_name to $downoad_url failed" 
    exit 1
fi

success "Extracting completed"

# Change owner of the extracted file to nurmal user
notice "Change ownership of extracted file, root -> $user"
chown -R $user:$user $source_directory
if [ ! $? -eq 0 ]; then
    error "Ownership change root to $user failed" 
    exit 1
fi

# Check if the v2rayN file already exists in /opt
# If it exists, remove it
if [ -e "$source_directory/$name" ]; then
    warining "Removing: $source_directory/$name"
    rm -rf "$source_directory/$name"
fi

notice "Rename $source_directory/$expackage_name to $source_directory/$name"
mv -f $source_directory/$expackage_name $source_directory/$name
if [ ! $? -eq 0 ]; then
    error "Rename $source_directory/$expackage_name to $source_directory/$name failed"
    exit 1
fi

notice "Create a symbolic link /bin/$name from $source_directory/$name/$name "
ln -f -s $source_directory/$name/$name /bin/ > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
    error "Create a symbolic link /bin/$name from $source_directory/$name/$name failed"
    exit 1
fi

desktop_items="/usr/share/applications"

desktop_Entry="[Desktop Entry]\nType=Application\nTerminal=false\nIcon=$source_directory/$name/$name.png\nName=v2rayN\nExec=/bin/$name\nCategories=Utility;\n"
notice "Create desktop item"
if [ ! -e $desktop_items ]; then
    error "$name was installed but Icon was not added to desktop items"
    error "$desktop_items not exist"
    notice "You can run the $name by v2rayN command"
    exit 1
fi

notice "Desktop item: $name.desktop to $desktop_items"
if [ -e "$desktop_items/$name.desktop" ]; then
    warining "Overwrite $desktop_items/$name.desktop"
fi

echo -e $desktop_Entry > $desktop_items/$name.desktop
if [ ! $? -eq 0 ]; then
    error "$name was installed but Icon was not added to desktop items"
    notice "You can run the $name by v2rayN command"
    exit 1
fi

success "v2rayN installation completed successfully"

exit 0




