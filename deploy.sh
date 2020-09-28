#!/bin/bash
P_URL="https://github.com/ferion11/f11_wine64_builder/releases/download/v5.18/wine-staging-5.18.tar.gz"

P_NAME="wine"
P_MVERSION="staging-linux-amd64"
P_FILENAME="$(echo $P_URL | cut -d/ -f9)"
P_CSOURCE="f11"
TEMP="$(echo $P_FILENAME | cut -d- -f3)"
P_VERSION="${TEMP%???????}"

WORKDIR="workdir"

#echo "P_NAME: ${P_NAME}"
#echo "P_MVERSION: ${P_MVERSION}"
#echo "P_FILENAME: ${P_FILENAME}"
#echo "P_CSOURCE: ${P_CSOURCE}"
#echo "P_VERSION: ${P_VERSION}"

#echo "RESULT: ${P_NAME}-${P_MVERSION}-nodeps-v${P_VERSION}-${P_CSOURCE}-x86_64.AppImage"
#exit 0
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
