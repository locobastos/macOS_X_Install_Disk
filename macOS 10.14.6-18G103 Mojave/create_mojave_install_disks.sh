#!/bin/sh
set -e
set -x

SCRIPT_DIR=$(dirname "$(realpath "$0")")

SETUP_FILE1_URL="https://swcdn.apple.com/content/downloads/17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el/BaseSystem.chunklist"
SETUP_FILE1_NAME="macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.chunklist"
SETUP_FILE1_SUM="15257b761187499cfb5a8ca978e686d1304f94ccfa85fee47aa41cb0481fd94c"

SETUP_FILE2_URL="https://swcdn.apple.com/content/downloads/17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el/BaseSystem.dmg"
SETUP_FILE2_NAME="macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.dmg"
SETUP_FILE2_SUM="c1bb8a816a9ecd916e824c975368a3921f4bcbc9469aa63e9c9fe10a783931ad"

SETUP_FILE3_URL="https://swcdn.apple.com/content/downloads/17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el/InstallESDDmg.pkg"
SETUP_FILE3_NAME="macOS_X_10.14.6-18G103_Mojave_Downloaded_Disk.pkg"
SETUP_FILE3_SUM="defd3e8fdaaed4b816ebdd7fdd92ebc44f12410a0deeb93e34486c3d7390ffb7"

#----- Check if the files already exist AND if the checksums are good.
while [ ! -f "${SCRIPT_DIR}/${SETUP_FILE1_NAME}" -a "$(shasum -a 256 "${SCRIPT_DIR}/${SETUP_FILE1_NAME}")" != "${SETUP_FILE1_SUM}" ]
do
    # Download the chunklist file.
    rm -f "${SCRIPT_DIR}/${SETUP_FILE1_NAME}"
    curl -L ${SETUP_FILE1_URL} -o "${SCRIPT_DIR}/${SETUP_FILE1_NAME}"
done

while [ ! -f "${SCRIPT_DIR}/${SETUP_FILE2_NAME}" -a "$(shasum -a 256 "${SCRIPT_DIR}/${SETUP_FILE2_NAME}")" != "${SETUP_FILE2_SUM}" ]
do
    # Download the BaseSystem image.
    rm -f "${SCRIPT_DIR}/${SETUP_FILE2_NAME}"
    curl -L ${SETUP_FILE2_URL} -o "${SCRIPT_DIR}/${SETUP_FILE2_NAME}"
done

while [ ! -f "${SCRIPT_DIR}/${SETUP_FILE3_NAME}" -a "$(shasum -a 256 "${SCRIPT_DIR}/${SETUP_FILE3_NAME}")" != "${SETUP_FILE3_SUM}" ]
do
    # Download the PKG file.
    rm -f "${SCRIPT_DIR}/${SETUP_FILE3_NAME}"
    curl -L ${SETUP_FILE3_URL} -o "${SCRIPT_DIR}/${SETUP_FILE3_NAME}"
done

#----- Extract InstallOS.pkg content.
rm -rf "${SCRIPT_DIR}/InstallOS"
pkgutil --expand "${SCRIPT_DIR}/${SETUP_FILE3_NAME}" "${SCRIPT_DIR}/InstallOS"

#----- Mount the installer on the host machine.
rm -rf "${SCRIPT_DIR}/InstallESD"
hdiutil attach "${SCRIPT_DIR}/InstallOS/InstallESD.dmg" -nobrowse -mountpoint "${SCRIPT_DIR}/InstallESD"

#----- Convert the boot image to sparse image.
rm -f "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
hdiutil convert -format UDSP -o "${SCRIPT_DIR}/BaseSystem_UDSP" "${SCRIPT_DIR}/${SETUP_FILE2_NAME}"

#----- Resize the sparse image to add remaining packages.
hdiutil resize -size 8g "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"

#----- Mount the sparse image to a directory.
rm -rf "${SCRIPT_DIR}/BaseSystem_UDSP"
hdiutil attach "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage" -nobrowse -mountpoint "${SCRIPT_DIR}/BaseSystem_UDSP"

#----- Delete the symbolic link to the Packages folder.
rm -f "${SCRIPT_DIR}/BaseSystem_UDSP/System/Installation/Packages"

#----- Copy the real Packages folder (the missing slash '/', at the end of "Packages" folder name, is very important).
cp -Rp "${SCRIPT_DIR}/InstallESD/Packages" "${SCRIPT_DIR}/BaseSystem_UDSP/System/Installation/"

#----- Copy the installer necessary files.
cp -p "${SCRIPT_DIR}/${SETUP_FILE1_NAME}" "${SCRIPT_DIR}/${SETUP_FILE2_NAME}" "${SCRIPT_DIR}/BaseSystem_UDSP/"

#----- Dismount both image (InstallESD=source, BaseSystem_UDSP=destination).
hdiutil detach "${SCRIPT_DIR}/InstallESD/"
hdiutil detach "${SCRIPT_DIR}/BaseSystem_UDSP/"
rm -rf "${SCRIPT_DIR}/InstallOS/"

#----- Reduce the image size.
hdiutil resize -size $(hdiutil resize -limits "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage" | tail -n 1 | awk '{ print $1 }')b "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"

#----- Convert the sparseimage to a DMG file.
hdiutil convert -format UDZO -o "${SCRIPT_DIR}/macOS_X_10.14.6-18G103_Mojave_Install_Disk" "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"

#----- Convert the sparseimage to an ISO file.
hdiutil convert -format UDTO -o "${SCRIPT_DIR}/macOS_X_10.14.6-18G103_Mojave_Install_Disk" "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
mv "${SCRIPT_DIR}/macOS_X_10.14.6-18G103_Mojave_Install_Disk.cdr" "${SCRIPT_DIR}/macOS_X_10.14.6-18G103_Mojave_Install_Disk.iso"
rm -f "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
