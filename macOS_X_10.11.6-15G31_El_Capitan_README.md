# Apple macOS X 10.11.6-15G31 El Capitan

In this guide, you will

-   Download the El Capitan disk from Apple's server,
-   Create an installation disk from the downloaded one,
-   Create a virtual machine using Oracle VirtualBox,
-   Install El Capitan from the installation disk.

## Create the macOS X 10.11.6 El Capitan Install Disk from official sources

As the `hdiutil` tool is proprietary, we do not have the choice to use an macOS to create the ISO file. I have used macOS 10.11 to create this ISO.

1.  Download the InstallMacOSX.dmg from Apple's servers.

        http://updates-http.cdn-apple.com/2019/cert/061-41424-20191024-218af9ec-cf50-4516-9011-228c78eda3d2/InstallMacOSX.dmg

    Source: https://support.apple.com/en-us/HT211683
    I have renamed it "macOS_X_10.11.6-15G31_El_Capitan_Downloaded_Disk.dmg".

2.  Check the checksum of the downloaded DMG to be sure it is safe.

        CRC    = 255D936C
        MD5    = 5040A59D785D7DA609755244C4ED136C
        SHA1   = 21E45136E34C6F805E0F1977E38D6FF029A9A1E2
        SHA256 = BCA6D2B699FC03E7876BE9C9185D45BF4574517033548A47CB0D0938C5732D59

3.  Insert the disk "macOS_X_10.11.6-15G31_El_Capitan_Downloaded_Disk.dmg".

4.  Open "InstallMacOSX.pkg".

5.  Follow the steps to install the package.

6.  When the installation is over, click on the Close button and eject the disk "Install OS X".

7.  Open a terminal, then: 

        # Mount the installer on the host machine.
        hdiutil attach /Applications/Install\ OS\ X\ El\ Capitan.app/Contents/SharedSupport/InstallESD.dmg -verify -nobrowse -mountpoint /Volumes/InstallESD
        
        # Create an empty image.
        hdiutil create -o macOS_10.11.Temp_Disk -size 8000m -layout SPUD -fs HFS+J
        
        # Mount the image.
        hdiutil attach macOS_10.11.Temp_Disk.dmg -noverify -nobrowse -mountpoint /Volumes/InstallDisk
        
        # Restore Base System to the image.
        asr restore -source /Volumes/InstallESD/BaseSystem.dmg -target /Volumes/InstallDisk -noprompt -erase
        
        # Delete the symbolic link to the Packages folder.
        rm /Volumes/OS\ X\ Base\ System/System/Installation/Packages
        
        # Copy the real Packages folder (the missing slash '/', at the end of "Packages" folder name, is very important).
        cp -Rp /Volumes/InstallESD/Packages /Volumes/OS\ X\ Base\ System/System/Installation
        
        # Copy the installer necessary files.
        cp -p /Volumes/InstallESD/BaseSystem.* /Volumes/OS\ X\ Base\ System/
        
        # Unmount both image (InstallESD=source, OS X Base System=destination).
        hdiutil detach /Volumes/InstallESD/
        hdiutil detach /Volumes/OS\ X\ Base\ System/
        
        # Resize the temp disk.
        hdiutil resize -size $(hdiutil resize -limits macOS_10.11.Temp_Disk.dmg | tail -n 1 | awk '{ print $1 }')b macOS_10.11.Temp_Disk.dmg
        
        # Convert the image to save space.
        hdiutil convert -o macOS_X_10.11.6-15G31_El_Capitan_Install_Disk -format UDZO macOS_10.11.Temp_Disk.dmg

## Create a new Virtual Machine from this install disk

1.  Create a new virtual machine, give the name you want, I called mine "macOS_X_10.11.6_El_Capitan".
   You will need its name during the step 8.

2.  Give it enough RAM, at least 4096 MB.

3.  Create a new fixed-size VirtualBox Disk Image (VDI) with at least 30 GB.

4.  In the VM's system settings, add CPU if you can (2 CPU is good).

5.  In the VM's display settings, use 128 MB of video memory.

6.  In the VM's storage settings, attach the macOS_X_10.10.6-15G31_El_Capitan_Install_Disk.dmg to the empty CD/DVD drive.

7.  Click OK then close VirtualBox

8.  Open a command prompt (cmd.exe) as administrator, then:

        cd "C:\Program Files\Oracle\VirtualBox"
        SET VM_NAME="macOS_X_10.11.6_El_Capitan"
        VBoxManage.exe modifyvm "%VM_NAME%" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
        VBoxManage.exe setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1

9.  Close the command prompt, run VirtualBox and start your virtual machine.

## Install macOS X 10.10.6 El Capitan

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