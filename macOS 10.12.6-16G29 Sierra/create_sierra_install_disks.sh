#!/bin/sh
set -e
set -x

SCRIPT_DIR=$(dirname "$(realpath "$0")")

SETUP_DISK_URL="http://updates-http.cdn-apple.com/2019/cert/061-39476-20191023-48f365f4-0015-4c41-9f44-39d3d2aca067/InstallOS.dmg"
SETUP_DISK_NAME="macOS_X_10.12.6-16G29_Sierra_Downloaded_Disk.dmg"
SETUP_DISK_SUM="c793c9aae9b59302b4b01a52aad387d7e4873cf00c48352afc1ffcc826cb0208"

#----- Check if the file already exists AND if the checksum is good.
while [ ! -f "${SCRIPT_DIR}/${SETUP_DISK_NAME}" -a "$(shasum -a 256 "${SCRIPT_DIR}/${SETUP_DISK_NAME}")" != "${SETUP_DISK_SUM}" ]
do
    # Download the disk image.
    rm -f "${SCRIPT_DIR}/${SETUP_DISK_NAME}"
    curl -L ${SETUP_DISK_URL} -o "${SCRIPT_DIR}/${SETUP_DISK_NAME}"
done

#----- Mount the DMG file.
hdiutil attach "${SCRIPT_DIR}/${SETUP_DISK_NAME}"
diskutil list
DEV_DISK=$(hdiutil info | grep "Install macOS" | awk '{ print $1 }')

#----- Extract InstallOS.pkg content.
rm -rf "${SCRIPT_DIR}/InstallOS"
pkgutil --expand "/Volumes/Install macOS/InstallOS.pkg" "${SCRIPT_DIR}/InstallOS"

#----- Unmount the DMG file.
hdiutil detach ${DEV_DISK}

#----- Mount the installer on the host machine.
rm -rf "${SCRIPT_DIR}/InstallESD"
hdiutil attach "${SCRIPT_DIR}/InstallOS/InstallOS.pkg/InstallESD.dmg" -nobrowse -mountpoint "${SCRIPT_DIR}/InstallESD"

#----- Convert the boot image to sparse image.
rm -f "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
hdiutil convert -format UDSP -o "${SCRIPT_DIR}/BaseSystem_UDSP" "${SCRIPT_DIR}/InstallESD/BaseSystem.dmg"

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
cp -p "${SCRIPT_DIR}"/InstallESD/BaseSystem.* "${SCRIPT_DIR}/BaseSystem_UDSP/"

#----- Dismount both image (InstallESD=source, BaseSystem_UDSP=destination).
hdiutil detach "${SCRIPT_DIR}/InstallESD/"
hdiutil detach "${SCRIPT_DIR}/BaseSystem_UDSP/"
rm -rf "${SCRIPT_DIR}/InstallOS/"

#----- Reduce the image size.
hdiutil resize -size $(hdiutil resize -limits "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage" | tail -n 1 | awk '{ print $1 }')b "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"

#----- Convert the sparseimage to a DMG file.
hdiutil convert -format UDZO -o "${SCRIPT_DIR}/macOS_X_10.12.6-16G29_Sierra_Install_Disk" "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"

#----- Convert the sparseimage to an ISO file.
hdiutil convert -format UDTO -o "${SCRIPT_DIR}/macOS_X_10.12.6-16G29_Sierra_Install_Disk" "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
mv "${SCRIPT_DIR}/macOS_X_10.12.6-16G29_Sierra_Install_Disk.cdr" "${SCRIPT_DIR}/macOS_X_10.12.6-16G29_Sierra_Install_Disk.iso"
rm -f "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
