#!/bin/bash

# NOTE
#	Just directly run to install
#
#	Truble Shooting
#		FoxitReader614.0217_enu_Setup.exe
#			Unable to register the DLL/OCX: RegSvr32 failed with exit code
#			(and some others alike)
#			-> select "Ignore"

wine_base=${MY_ENV}/tool/wine

echo "INFO: install foxit binary"
echo "NOTE: it is also possible to copy the installed/portable binary to ~/.wine/drive_c/Program Files/ to install"
if [ ! -e ${HOME}'/.wine/drive_c/Program Files (x86)/Foxit Software/' ] ; then
	wine $MY_DOC/DCB/Software/installer/FoxitReader614.0217_enu_Setup.exe
fi

echo "INFO: install foxit icon"
foxit_icon=~/.wine/foxit_icon.png
[ ! -e "${foxit_icon}" ] && cp ${wine_base}/conf/foxit_icon.png ${foxit_icon}

echo "INFO: install foxit shell"
foxit_shell=~/.wine/foxit
if [ ! -e "${foxit_shell}" ] ; then
	cat <<-'FOXIT_SHELL' > "${foxit_shell}"
		#!/bin/sh
		QUICKPARLOCATION="C:\\Program Files (x86)\\Foxit Software\\Foxit Reader\\Foxit Reader.exe"
		PARAM=`winepath -w "$*"`
		wine "$QUICKPARLOCATION" "$PARAM"
		exit 0
	FOXIT_SHELL
	chmod u+x "${foxit_shell}"
fi

echo "INFO: install foxit desktop settings"
foxit_desktop_name=foxit.desktop
foxit_desktop_fullpath=/usr/share/applications/${foxit_desktop_name}
if [ ! -e "${foxit_desktop_fullpath}" ] ; then
	cat <<-FOXIT_DESKTOP > ${wine_base}/conf/
		[Desktop Entry]
		Name=Foxit Reader
		Comment=PDF reader
		Icon=${foxit_icon}
		Exec=${foxit_shell} %f
		Terminal=false
		Type=Application
		MimeType=application/pdf;application/x-pdf;
		Categories=Office;
		X-GNOME-Bugzilla-Bugzilla=Foxit
		X-GNOME-Bugzilla-Product=foxit reader
		X-GNOME-Bugzilla-Component=Zwischenlager
		X-GNOME-Bugzilla-Version=3.2.1
		StartupNotify=true
		X-HildonDesk-ShowInToolbar=true
		X-Osso-Service=org.gnome.Games.AisleRiot
		X-Osso-Type=application/x-executable
		X-Ubuntu-Gettext-Domain=aisleriot
	FOXIT_DESKTOP
	sudo cp ${wine_base}/conf/${foxit_desktop_name} "${foxit_desktop_fullpath}"
	sudo chmod 644 "${foxit_desktop_fullpath}"
fi

echo "INFO: set foxit as default"
echo "!!! NOTE !!! In Ubuntu 13.10, you might need to: (right click pdf file) > properties > open with > (select foxit as default)"
app_defaults=/usr/share/applications/defaults.list
if grep -q "pdf=evince.desktop" "${app_defaults}" ; then
	sudo cp "${app_defaults}"{,.bak.$(date "+%Y-%m-%d_%H-%M-%S")}
	sudo sed -i -e "s/pdf=evince.desktop/pdf=${foxit_desktop_name}/" "${app_defaults}"
fi
