# Apple macOS X 10.10.5-14F27 Yosemite

In this guide, you will

-   Download the Yosemite disk from Apple's server,
-   Create an installation disk from the downloaded one,
-   Create a virtual machine using Oracle VirtualBox,
-   Install Yosemite from the installation disk.

## Create the macOS X 10.10.5 Yosemite Install Disk from official sources

As the `hdiutil` tool is proprietary, we do not have the choice to use a macOS to create the ISO file. I have used macOS 10.10 to create this ISO.

1.  Download the InstallMacOSX.dmg from Apple's servers.

        http://updates-http.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg

    Source: https://support.apple.com/en-us/HT211683
    I have renamed it "macOS_X_10.10.5-14F27_Yosemite_Downloaded_Disk.dmg".

2.  Check the checksum of the downloaded DMG to be sure it is safe.

        CRC    = 8948187C
        MD5    = 453536DDF8406CFC40EC776DABF3491E
        SHA1   = C542681961CC7FAFB9C15BFD4AF152A3A57F07FA
        SHA256 = DE869907CE4289FE948CBD2DEA7479FF9C369BBF47B06D5CB5290D78FB2932C6

3.  Insert the disk "macOS_X_10.10.5-14F27_Yosemite_Downloaded_Disk.dmg".

4.  Open "InstallMacOSX.pkg".

5.  Follow the steps to install the package.

6.  When the installation is over, click on the Close button and eject the disk "Install OS X".

7.  Open a terminal, then: 

        # Mount the installer on the host machine.
        hdiutil attach /Applications/Install\ OS\ X\ Yosemite.app/Contents/SharedSupport/InstallESD.dmg -nobrowse -mountpoint ~/Downloads/install_esd
        
        # Convert the boot image to sparse image.
        hdiutil convert -format UDSP -o ~/Downloads/BaseSystem_UDSP ~/Downloads/install_esd/BaseSystem.dmg
        
        # Resize the sparse image to add remaining packages.
        hdiutil resize -size 8g ~/Downloads/BaseSystem_UDSP.sparseimage
        
        # Mount the sparse image to a directory.
        hdiutil attach ~/Downloads/BaseSystem_UDSP.sparseimage -nobrowse -mountpoint ~/Downloads/build_install_disk
        
        # Delete the symbolic link to the Packages folder.
        rm ~/Downloads/build_install_disk/System/Installation/Packages
        
        # Copy the real Packages folder (the missing slash '/', at the end of "Packages" folder name, is very important).
        cp -Rp ~/Downloads/install_esd/Packages ~/Downloads/build_install_disk/System/Installation/
        
        # Copy the installer necessary files.
        cp -p ~/Downloads/install_esd/BaseSystem.* ~/Downloads/build_install_disk/
        
        # Dismount both image (install_esd=source, build_install_disk=destination).
        hdiutil detach ~/Downloads/install_esd/
        hdiutil detach ~/Downloads/build_install_disk/
        
        # Reduce the image size.
        hdiutil resize -size $(hdiutil resize -limits ~/Downloads/BaseSystem_UDSP.sparseimage | tail -n 1 | awk '{ print $1 }')b ~/Downloads/BaseSystem_UDSP.sparseimage
        
        # Convert the sparseimage to a DMG file.
        hdiutil convert -format UDZO -o ~/Downloads/macOS_X_10.10.5-14F27_Yosemite_Install_Disk ~/Downloads/BaseSystem_UDSP.sparseimage
## Create a new Virtual Machine from this install disk

1.  Create a new virtual machine, give the name you want, I called mine "macOS_X_10.10.5_Yosemite".
   You will need its name during the step 8.

2.  Give it enough RAM, at least 4096 MB.

3.  Create a new fixed-size VirtualBox Disk Image (VDI) with at least 25 GB.

4.  In the VM's system settings, add CPU if you can (2 CPU is good).

5.  In the VM's display settings, use 128 MB of video memory.

6. In the VM's storage settings, attach the macOS_X_10.10.5-14F27_Yosemite_Install_Disk.dmg to the empty CD/DVD drive.

7.  Click OK then close VirtualBox

8.  Open a command prompt (cmd.exe) as administrator, then:

        cd "C:\Program Files\Oracle\VirtualBox"
        SET VM_NAME="macOS_X_10.10.5_Yosemite"
        VBoxManage.exe modifyvm "%VM_NAME%" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1

9.  Close the command prompt, run VirtualBox and start your virtual machine.

## Install macOS X 10.10.5 Yosemite

### Prepare the system disk

1.  Select the language you want to use,
2.  From the top menu, click the "Utilities" menu,
3.  Click on "Disk Utility...",
4.  Select the Hard Drive on which macOS will be installed,
5.  On the "Erase" tab, click "Erase..." button and confirm.
6.  Close the Disk Utility.

### Install Wizard

Follow the wizard to install macOS:

1.  Click "Continue",
2.  Click "Continue" and "Agree",
3.  Click on the HDD logo then on the "Continue" button,
4.  Wait during the system is installed.