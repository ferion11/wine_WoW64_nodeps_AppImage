#!/bin/bash
#P_URL="https://www.playonlinux.com/wine/binaries/phoenicis/staging-linux-amd64/PlayOnLinux-wine-5.11-staging-linux-amd64.tar.gz"
P_URL="https://www.playonlinux.com/wine/binaries/phoenicis/staging-linux-amd64/PlayOnLinux-wine-4.21-staging-linux-amd64.tar.gz"

P_NAME="$(echo $P_URL | cut -d/ -f4)"
P_MVERSION="$(echo $P_URL | cut -d/ -f7)"
P_FILENAME="$(echo $P_URL | cut -d/ -f8)"
P_CSOURCE="$(echo $P_FILENAME | cut -d- -f1)"
P_VERSION="$(echo $P_FILENAME | cut -d- -f3)"

WORKDIR="workdir"

#=========================
die() { echo >&2 "$*"; exit 1; };
#=========================

#-----------------------------
#dpkg --add-architecture i386
#apt update
#apt install -y aptitude wget file bzip2 gcc-multilib
#apt install -y aptitude wget file bzip2
#===========================================================================================
# Get inex
# using the package
mkdir "${WORKDIR}" || die "Cant create the dir ${WORKDIR}"

wget -nv "${P_URL}" || die "Cant download the main file"
tar xf "${P_FILENAME}" -C "$WORKDIR/" || die "Cant extract the file ${P_FILENAME}"

cd "${WORKDIR}" || die "ERROR: Directory don't exist: ${WORKDIR}"

#some clean (keeping it like it is because don't have deps anyway):
#rm -rf $pkgcachedir ; rm -rf share/man ; rm -rf usr/share/doc ; rm -rf usr/share/lintian ; rm -rf var ; rm -rf sbin ; rm -rf usr/share/man
#rm -rf usr/share/mime ; rm -rf usr/share/pkgconfig; rm -rf lib; rm -rf etc;
#---------------------------------
#===========================================================================================

# Disable winemenubuilder
sed -i 's/winemenubuilder.exe -a -r/winemenubuilder.exe -r/g' share/wine/wine.inf

# Disable FileOpenAssociations
sed -i 's|    LicenseInformation|    LicenseInformation,\\\n    FileOpenAssociations|g;$a \\n[FileOpenAssociations]\nHKCU,Software\\Wine\\FileOpenAssociations,"Enable",,"N"' share/wine/wine.inf

#===========================================================================================
# appimage
cd ..

#wget -nv -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -O  appimagetool.AppImage
chmod +x appimagetool.AppImage

chmod +x AppRun

cp AppRun "${WORKDIR}"
cp resource/* "${WORKDIR}"

./appimagetool.AppImage --appimage-extract

export ARCH=x86_64; squashfs-root/AppRun -v ${WORKDIR} -u 'gh-releases-zsync|ferion11|Wine_Appimage|continuous|${P_NAME}-${P_MVERSION}-nodeps-v${P_VERSION}-${P_CSOURCE}-*arch*.AppImage.zsync' ${P_NAME}-${P_MVERSION}-nodeps-v${P_VERSION}-${P_CSOURCE}-${ARCH}.AppImage

echo "All files at the end of script: $(ls)"
