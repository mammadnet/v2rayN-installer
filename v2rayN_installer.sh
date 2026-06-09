#!/bin/bash


# Colors
RED="\e[31m"
GRN="\e[32m"
YLW="\e[33m"
MGN="\e[35m"
RST="\e[0m"

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

# Show help message
show_help(){
    echo
    notice "**************v2rayN Installer****************"
    success "Download and install latest version of v2rayN" 
    notice "_____________________________________________"
    echo "Run $0 to install latest version of v2rayN"
    notice "_____________________________________________"
    echo "To use proxy to download and install v2rayN: $0 -s [HOST] -p [PORT]"
    echo "Ex: $0 -s 192.168.1.20 -p 10808"
    echo "For Print this message use: -h"
    echo
    echo
}

# Pars options
proxy_set=0
proxy_host=""
proxy_port=""

while getopts "s:p:h" opt; do
    case $opt in 
        s) 
            proxy_host="$OPTARG"
            proxy_set=1
            ;;
        p) 
            proxy_port="$OPTARG"
            ;;
        h)
            show_help
            exit 0
            ;;
        *)
            error "Bad options"
            show_help
            exit 1
            ;;
    esac
done

if [ $proxy_set -eq 1 ]; then
    if [ -z "$proxy_port" ]; then
        error "Missing proxy port"
        show_help
        exit 1
    fi
fi

#----------------
unzip_package='unzip'
app_name="v2rayN-linux-64"
compressed_app="$app_name.zip"
name="v2rayN"
latest_version_url="https://github.com/2dust/v2rayN/releases/latest/download"
download_url=$latest_version_url/$compressed_app
temp_directory="/tmp"
source_directory="/opt"
bin_dir="/bin"
user=$USER
desktop_items="/usr/share/applications"


# Check if the user is the root user
if [ ! "$UID" -eq 0 ]; then
    notice "Running in user mode"
    notice "Installing app in user invironment"
    source_directory="$HOME/.local/share"
    bin_dir="$HOME/.local/bin"
    desktop_items="$HOME/.local/share/applications"

else 
    user=$SUDO_USER
fi

# Download main package with wget based on set proxy
download(){
    output_path="$2"
    url="$1"
    proxy_opt=""
    if [ $proxy_set -eq 1 ]; then
        proxy_opt="-e use_proxy=yes -e https_proxy=$proxy_host:$proxy_port"
    fi

    wget $proxy_opt --show-progress --progress=bar:force --timeout=30 -O $output_path $url 2>&1
}

# Check if unzip installed

if ! command -v "$unzip_package" > /dev/null 2>&1; then
    error "$unzip_package not installed"
    notice "install the $unzip_package package with this command:"
    notice "apt install $unzip_package"
    exit 1
fi

prompt='y'
if [ -e "$temp_directory/$compressed_app" ]; then
    warining "$compressed_app already exist in $temp_directory "
    echo -n -e $YLW
    read -p "Do you want to download it again? [Y/n] " prompt
    echo -n -e $RST
    prompt=${prompt:-y}
fi
if [ $prompt == 'y' ]; then
    if [ -e "$temp_directory/$compressed_app" ]; then
        warining "Removing $temp_directory/$compressed_app"
        rm $temp_directory/$compressed_app
    fi

    notice "Downloading $download_url"
    notice "Save downloaded file to $temp_directory"

    download $download_url $temp_directory/$compressed_app
    if [ ! $? -eq 0 ]; then
        error "download from $download_url failed " 
        exit 1
    fi

    success "Download completed"


fi

notice "Extracting archive: $temp_directory/$compressed_app"
notice "Saving $app_name to $source_directory"

unzip -q -o -d $source_directory $temp_directory/$compressed_app
if [ ! $? -eq 0 ]; then
    error "Extracting $compressed_app to $source_directory failed" 
    exit 1
fi

success "Extraction completed."
if [ "$UID" -eq 0 ]; then
    # Change owner of the extracted file to nurmal user
    notice "Changing ownership of extracted files (root -> $user)"
    chown -R $user:$user $source_directory/$app_name
    if [ ! $? -eq 0 ]; then
        error "Ownership change root to $user failed" 
        exit 1
    fi
fi

# Check if the v2rayN file already exists in /opt
# If it exists, remove it
if [ -e "$source_directory/$name" ]; then
    warining "Removing old installation at: $source_directory/$name"
    rm -rf "$source_directory/$name"
fi

notice "Renaming $source_directory/$app_name -> $source_directory/$name"
mv -f $source_directory/$app_name $source_directory/$name
if [ ! $? -eq 0 ]; then
    error "Renaming $source_directory/$app_name to $source_directory/$name failed"
    exit 1
fi

if [ ! -e $bin_dir ]; then
    notice "Create $bin_dir directory..."
    mkdir -p $bin_dir
fi

notice "Add executable permission for $source_directory/$name/$name"
chmod 754 $source_directory/$name/$name 2>&1
if [ ! $? -eq 0 ]; then
    error "Add executable permission for $source_directory/$name/$name failed"
    exit 1
fi

notice "Creating symbolic link: $bin_dir/$name -> $source_directory/$name/$name"
ln -f -s $source_directory/$name/$name $bin_dir/ > /dev/null 2>&1
if [ ! $? -eq 0 ]; then
    error "Create a symbolic link $bin_dir/$name from $source_directory/$name/$name failed"
    exit 1
fi

desktop_Entry="[Desktop Entry]\nType=Application\nTerminal=false\nIcon=$source_directory/$name/$name.png\nName=v2rayN\nExec=$bin_dir/$name\nCategories=Utility;\n"
notice "Creating desktop entry..."
if [ ! -e $desktop_items ]; then
    error "$name was installed but Icon was not added to desktop items"
    error "$desktop_items not exist"
    notice "You can run the $name by v2rayN command"
    exit 1
fi

notice "Copying $name.desktop to $desktop_items"
if [ -e "$desktop_items/$name.desktop" ]; then
    warining "Overwriting existing: $desktop_items/$name.desktop"
fi

echo -e $desktop_Entry > $desktop_items/$name.desktop
if [ ! $? -eq 0 ]; then
    error "$name was installed but Icon was not added to desktop items"
    notice "You can run the $name by v2rayN command"
    exit 1
fi

notice "Update desktop item file"
update-desktop-database $desktop_items

success "v2rayN installation completed successfully"

exit 0




