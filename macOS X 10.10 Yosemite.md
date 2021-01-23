# Apple macOS X 10.10 Yosemite

In this guide, you will:

-   Download the Yosemite disk from Apple's server,
-   Create an installation disk from the downloaded one,
-   Create a Virtual Machine using VirtualBox,
-   Install Yosemite from the installation disk.

## Create the macOS X 10.10 Yosemite Installation Disk file from official source

As the `hdiutil` tool is proprietary, we do not have the choice to use an macOS to create the ISO file. I've used macOS 10.10 to create this ISO.

1. Download the InstallMacOSX.dmg from the Apple's servers (you will need an account).

        http://updates-http.cdn-apple.com/2019/cert/061-41343-20191023-02465f92-3ab5-4c92-bfe2-b725447a070d/InstallMacOSX.dmg

    I've renamed it "MacOS_X_10.10_Yosemite_Downloaded_Disk.dmg".

2. Check the checksum of the downloaded DMG to be sure it is safe.

        CRC    = 8948187C
        MD5    = 453536DDF8406CFC40EC776DABF3491E
        SHA1   = C542681961CC7FAFB9C15BFD4AF152A3A57F07FA
        SHA256 = DE869907CE4289FE948CBD2DEA7479FF9C369BBF47B06D5CB5290D78FB2932C6

3. Insert the disk "MacOS_X_10.10_Yosemite_Downloaded_Disk.dmg".
   
4. Open "InstallMacOSX.pkg".

5. Follow the steps to install the package.

6. When the installation is over, click on the Close button and eject the disk "Install OS X".

7. Open a terminal, then: 

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
        
        # Copy the real Packages folder (the missing slash '/', at the end of "Packages" folder name, is very important)
        cp -Rp ~/Downloads/install_esd/Packages ~/Downloads/build_install_disk/System/Installation/
        
        # Copy the installer necessary files.
        cp -p ~/Downloads/install_esd/BaseSystem.* ~/Downloads/build_install_disk/
        
        # Unmount both image (install_esd=source, build_install_disk=destination).
        hdiutil detach ~/Downloads/install_esd/
        hdiutil detach ~/Downloads/build_install_disk/
        
        # Reduce the image size
        hdiutil resize -size $(hdiutil resize -limits ~/Downloads/BaseSystem_UDSP.sparseimage | tail -n 1 | awk '{ print $1 }')b ~/Downloads/BaseSystem_UDSP.sparseimage
        
        # Convert the sparseimage to DMG file.
        hdiutil convert -format UDZO -o ~/Downloads/MacOS_X_10.10_Yosemite_Install_Disk ~/Downloads/BaseSystem_UDSP.sparseimage

## Create a new Virtual Machine from this ISO

1.  Create a new virtual machine, give the name you want, I called mine "macOS_X_10.10_Yosemite".
    You will need its exact name during the step 8.

2.  Give it enough RAM, at least 4096 MB.

3.  Create a new fixed size VirtualBox Disk Image (VDI) with at least 20 GB.

4.  In the VM's system settings, add CPU if you can (2 CPU is good).

5.  In the VM's display settings, use 128 MB of video memory.

6.  In the VM's storage settings, attach the MacOS_X_10.10_Yosemite_Install_Disk.dmg to the empty CD/DVD drive.

7.  Click OK then close VirtualBox

8.  Open a command prompt (cmd.exe) as administrator, then:

        cd "C:\Program Files\Oracle\VirtualBox"
        SET VM_NAME="macOS_X_10.10_Yosemite"
        VBoxManage.exe modifyvm "%VM_NAME%" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1

9.  Close the command prompt and run VirtualBox.

## Install macOS X 10.10 Yosemite

### Prepare the system disk

1.  From the top menu, click the "Utilities" menu,
2.  Click on "Disk Utility...",
3.  Select the Hard Drive on which macOS will be installed,
4.  On the "Erase" tab, click "Erase..." button and confirm.
5.  Close the Disk Utility.

### Install Wizard

Follow the wizard to install macOS:

1.  Select the language you want to use,
2.  Click "Continue",
3.  Click "Continue" and "Agree",
4.  Click on the HDD logo then on the "Continue" button,
5.  Wait during the system is installed.