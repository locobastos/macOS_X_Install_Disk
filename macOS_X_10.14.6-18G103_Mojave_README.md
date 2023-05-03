# Apple macOS X 10.14.6-18G103 Mojave

In this guide, you will

-   Download the Mojave disk from Apple's server,
-   Create an installation disk from the downloaded one,
-   Create a virtual machine using Oracle VirtualBox,
-   Install Mojave from the installation disk.

## Create the macOS X 10.14.6-18G103 Mojave Install Disk from official sources

As the `hdiutil` tool is proprietary, we do not have the choice to use an macOS to create the ISO file. I have used macOS 10.11 to create this ISO.

1.  Download these 3 files from Apple's servers.

        https://swcdn.apple.com/content/downloads/17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el/BaseSystem.chunklist
        https://swcdn.apple.com/content/downloads/17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el/BaseSystem.dmg
        https://swcdn.apple.com/content/downloads/17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el/InstallESDDmg.pkg

    I have renamed them "macOS_X_10.14.6-18G103_Mojave_Downloaded_Disk.pkg", "macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.dmg" and "macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.chunklist".

2.  Check the checksum of the downloaded files to be sure there are safe.

        NAME   = macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.chunklist
        CRC    = 72CF1360
        MD5    = 15E9B12279342D012B93DECA01709AE0
        SHA1   = F11FD3B226FE534775CAC499049690C60E1F5A2C
        SHA256 = 15257B761187499CFB5A8CA978E686D1304F94CCFA85FEE47AA41CB0481FD94C
        
        NAME   = macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.dmg
        CRC    = 37F1EE3C
        MD5    = E209D418788A54253DFA492D2076CACE
        SHA1   = 82E147E9858A67336D8687D9CEA616C76D50D373
        SHA256 = C1BB8A816A9ECD916E824C975368A3921F4BCBC9469AA63E9C9FE10A783931AD

        NAME   = macOS_X_10.14.6-18G103_Mojave_Downloaded_Disk.pkg
        CRC    = 800268CC
        MD5    = 73340F4C61B669554D4EAA873243B154
        SHA1   = B026794F0989F7B7EEDDB9A4BD796F8020C91C26
        SHA256 = DEFD3E8FDAAED4B816EBDD7FDD92EBC44F12410A0DEEB93E34486C3D7390FFB7

3.  Open a terminal, then: 

        # Extract the file InstallESD.dmg from the pkg
        pkgutil --expand ~/Downloads/macOS_X_10.14.6-18G103_Mojave_Downloaded_Disk.pkg ~/Downloads/10.14.6-18G103/
        
        # Mount the installer on the host machine.
        hdiutil attach ~/Downloads/10.14.6-18G103/InstallESD.dmg -verify -nobrowse -mountpoint ~/Downloads/InstallESD
        
        # Create an empty image.
        hdiutil create -o macOS_10.14.6_Temp_Disk -size 8000m -layout SPUD -fs HFS+J
        
        # Mount the image.
        hdiutil attach macOS_10.14.6_Temp_Disk.dmg -noverify -nobrowse -mountpoint ~/Downloads/InstallDisk
        
        # Restore Base System to the image.
        asr restore -source ~/Downloads/macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.dmg -target ~/Downloads/InstallDisk -noprompt -erase
        
        # Delete the symbolic link to the Packages folder.
        rm /Volumes/macOS\ Base\ System/System/Installation/Packages
        
        # Copy the real Packages folder (the missing slash '/', at the end of "Packages" folder name, is very important).
        cp -Rp ~/Downloads/InstallESD/Packages /Volumes/macOS\ Base\ System/System/Installation
        
        # Copy the installer necessary files.
        cp -p ~/Downloads/macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.dmg /Volumes/macOS\ Base\ System/BaseSystem.dmg
        cp -p ~/Downloads/macOS_X_10.14.6-18G103_Mojave_Downloaded_BaseSystem.chunklist /Volumes/macOS\ Base\ System/BaseSystem.chunklist
        
        # Unmount both image (InstallESD=source, OS X Base System=destination).
        hdiutil detach ~/Downloads/InstallESD/
        hdiutil detach /Volumes/macOS\ Base\ System/
        
        # Resize the temp disk.
        hdiutil resize -size $(hdiutil resize -limits macOS_10.14.6_Temp_Disk.dmg | tail -n 1 | awk '{ print $1 }')b macOS_10.14.6_Temp_Disk.dmg
        
        # Convert the image to save space.
        hdiutil convert -o macOS_X_10.14.6-18G103_Mojave_Install_Disk -format UDZO macOS_10.14.6_Temp_Disk.dmg










## Create a new Virtual Machine from this install disk

1.  Create a new virtual machine, give the name you want, I called mine "macOS_X_10.12.6-16G29_Sierra".
   You will need its name during the step 8.

2.  Give it enough RAM, at least 4096 MB.

3.  Create a new fixed-size VirtualBox Disk Image (VDI) with at least 30 GB.

4.  In the VM's system settings, add CPU if you can (2 CPU is good) and change the Paravirtualization Interface to None.

5.  In the VM's display settings, use 128 MB of video memory.

6.  In the VM's storage settings, attach the macOS_X_10.12.6-16G29_Sierra_Install_Disk.dmg to the empty CD/DVD drive.

7.  Click OK then close VirtualBox

8.  Open a command prompt (cmd.exe) as administrator, then:

        cd "C:\Program Files\Oracle\VirtualBox"
        SET VM_NAME="macOS_X_10.12.6-16G29_Sierra"
        VBoxManage.exe modifyvm "%VM_NAME%" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Mac-F22589C8"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemSerial" "CK1156I6DB6"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1

9.  Close the command prompt, run VirtualBox and start your virtual machine.

## Install macOS X 10.12.6 Sierra

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

