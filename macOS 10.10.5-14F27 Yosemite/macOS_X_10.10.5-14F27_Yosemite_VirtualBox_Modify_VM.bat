@ECHO OFF

SET /p VM_NAME="VM Name: "
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm "%VM_NAME%" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata "%VM_NAME%" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" setextradata "%VM_NAME%" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 0

PAUSE
