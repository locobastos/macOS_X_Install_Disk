# Apple macOS X 10.13.6-17G66 High Sierra

In this guide, you will

-   Download the High Sierra disk from Apple's server,
-   Create an installation disk from the downloaded one,
-   Create a virtual machine using Oracle VirtualBox,
-   Install High Sierra from the installation disk.

## Create the macOS X 10.13.6-17G66 High Sierra Install Disk from official sources

As the `hdiutil` tool is proprietary, we do not have the choice to use an macOS to create the ISO file. I have used macOS 10.11 to create this ISO.

1.  Download these 3 files from Apple's servers.

        https://swcdn.apple.com/content/downloads/06/50/041-91758-A_M8T44LH2AW/b5r4og05fhbgatve4agwy4kgkzv07mdid9/BaseSystem.chunklist
        https://swcdn.apple.com/content/downloads/06/50/041-91758-A_M8T44LH2AW/b5r4og05fhbgatve4agwy4kgkzv07mdid9/BaseSystem.dmg
        https://swcdn.apple.com/content/downloads/06/50/041-91758-A_M8T44LH2AW/b5r4og05fhbgatve4agwy4kgkzv07mdid9/InstallESDDmg.pkg

    I have renamed them "macOS_X_10.13.6-17G66_High_Sierra_Downloaded_Disk.pkg", "macOS_X_10.13.6-17G66_High_Sierra_Downloaded_BaseSystem.dmg" and "macOS_X_10.13.6-17G66_High_Sierra_Downloaded_BaseSystem.chunklist".

2.  Check the checksum of the downloaded files to be sure there are safe.

        NAME   = macOS_X_10.13.6-17G66_High_Sierra_Downloaded_BaseSystem.chunklist
        CRC    = 9376A0D4
        MD5    = 0D57A34F14F04F522E85AE62D4305254
        SHA1   = FA5B94BC1A03D67094BDF9878C8EB39BBC1E13EA
        SHA256 = E07212704EB587FD45535D35284E67F7CF2FB450827AB73BF5381CBCEC7BB29D
        
        NAME   = macOS_X_10.13.6-17G66_High_Sierra_Downloaded_BaseSystem.dmg
        CRC    = 077A6F06
        MD5    = 04AA8EB7C42FA37905373EB3172DC62F
        SHA1   = CF7C315C0EE033697D8648E6D87825061B3A9CB5
        SHA256 = 85CCF37D0BDA28F8C62117E452FDDFC26FA7B0CFBCDD16396CEFD3D97F949B02
        
        NAME   = macOS_X_10.13.6-17G66_High_Sierra_Downloaded_Disk.pkg
        CRC    = E5B78A9E
        MD5    = 2C0AA6371DE3D580265F73F17FB95FF7
        SHA1   = 9082686F9CAABE2FFE73A8B2D3883DD6FB0FD974
        SHA256 = F922284FC560D34ECA84752AE9C030D2C37FF00115ED87B32BAAF78D98EBB1BF

3.  Open a terminal, then: 

        # Extract the file InstallESD.dmg from the pkg
        pkgutil --expand ~/Downloads/macOS_X_10.13.6-17G66_High_Sierra_Downloaded_Disk.pkg ~/Downloads/10.13.6-17G66/
        
        # Mount the installer on the host machine.
        hdiutil attach ~/Downloads/10.13.6-17G66/InstallESD.dmg -verify -nobrowse -mountpoint ~/Downloads/InstallESD
        
        # Create an empty image.
        hdiutil create -o macOS_10.13.6_Temp_Disk -size 8000m -layout SPUD -fs HFS+J
        
        # Mount the image.
        hdiutil attach macOS_10.13.6_Temp_Disk.dmg -noverify -nobrowse -mountpoint ~/Downloads/InstallDisk
        
        # Restore Base System to the image.
        asr restore -source ~/Downloads/macOS_X_10.13.6-17G66_High_Sierra_Downloaded_BaseSystem.dmg -target ~/Downloads/InstallDisk -noprompt -erase
        
        # Delete the symbolic link to the Packages folder.
        rm /Volumes/OS\ X\ Base\ System/System/Installation/Packages
        
        # Copy the real Packages folder (the missing slash '/', at the end of "Packages" folder name, is very important).
        cp -Rp ~/Downloads/InstallESD/Packages /Volumes/OS\ X\ Base\ System/System/Installation
        
        # Copy the installer necessary files.
        cp -p ~/Downloads/macOS_X_10.13.6-17G66_High_Sierra_Downloaded_BaseSystem.dmg /Volumes/OS\ X\ Base\ System/BaseSystem.dmg
        cp -p ~/Downloads/macOS_X_10.13.6-17G66_High_Sierra_Downloaded_BaseSystem.chunklist /Volumes/OS\ X\ Base\ System/BaseSystem.chunklist
        
        # Unmount both image (InstallESD=source, OS X Base System=destination).
        hdiutil detach ~/Downloads/InstallESD/
        hdiutil detach /Volumes/OS\ X\ Base\ System/
        
        # Resize the temp disk.
        hdiutil resize -size $(hdiutil resize -limits macOS_10.13.6_Temp_Disk.dmg | tail -n 1 | awk '{ print $1 }')b macOS_10.13.6_Temp_Disk.dmg
        
        # Convert the image to save space.
        hdiutil convert -o macOS_X_10.13.6-17G66_High_Sierra_Install_Disk -format UDZO macOS_10.13.6_Temp_Disk.dmg










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

