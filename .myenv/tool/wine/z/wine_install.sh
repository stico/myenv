#!env bash
echo "Installing wine need 1) Network access. 2) Manual accept agreement. Continue (N) [Y/N]?"
read -e continue                                                                                           
[ "$continue" != "Y" -a "$continue" != "y" ] && echo "Give up, pls install those soft manually later!" && return 1

# TODO: auto accept the agreement? (see debconf-utils)

# Install wine
wine_ver=wine1.5-amd64
echo "INFO: installing $wine_ver, which need downloads and takes long time"
sudo add-apt-repository -y ppa:ubuntu-wine/ppa		&> /dev/null
sudo apt-get update
sudo apt-get install -y $wine_ver 
(! command -v wine &> /dev/null) && echo "Install $wine_ver failed, pls check!" && exit 1

