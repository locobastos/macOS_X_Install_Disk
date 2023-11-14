#!/bin/sh
set -e
set -x

SCRIPT_DIR=$(dirname "$(realpath "$0")")

SETUP_DISK_URL="http://updates-http.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg"
SETUP_DISK_NAME="macOS_X_10.11.6-15G31_El_Capitan_Downloaded_Disk.dmg"
SETUP_DISK_SUM="bca6d2b699fc03e7876be9c9185d45bf4574517033548a47cb0d0938c5732d59"

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
DEV_DISK=$(hdiutil info | grep "Install OS X" | awk '{ print $1 }')

#----- Extract InstallMacOSX.pkg content.
rm -rf "${SCRIPT_DIR}/InstallMacOSX"
pkgutil --expand "/Volumes/Install OS X/InstallMacOSX.pkg" "${SCRIPT_DIR}/InstallMacOSX"

#----- Unmount the DMG file.
hdiutil detach ${DEV_DISK}

#----- Mount the installer on the host machine.
rm -rf "${SCRIPT_DIR}/InstallESD"
hdiutil attach "${SCRIPT_DIR}/InstallMacOSX/InstallMacOSX.pkg/InstallESD.dmg" -nobrowse -mountpoint "${SCRIPT_DIR}/InstallESD"

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
rm -rf "${SCRIPT_DIR}/InstallMacOSX/"

#----- Reduce the image size.
hdiutil resize -size $(hdiutil resize -limits "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage" | tail -n 1 | awk '{ print $1 }')b "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"

#----- Convert the sparseimage to a DMG file.
hdiutil convert -format UDZO -o "${SCRIPT_DIR}/macOS_X_10.11.6-15G31_El_Capitan_Install_Disk" "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"

#----- Convert the sparseimage to an ISO file.
hdiutil convert -format UDTO -o "${SCRIPT_DIR}/macOS_X_10.11.6-15G31_El_Capitan_Install_Disk" "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
mv "${SCRIPT_DIR}/macOS_X_10.11.6-15G31_El_Capitan_Install_Disk.cdr" "${SCRIPT_DIR}/macOS_X_10.11.6-15G31_El_Capitan_Install_Disk.iso"
rm -f "${SCRIPT_DIR}/BaseSystem_UDSP.sparseimage"
