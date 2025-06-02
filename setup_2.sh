#!/bin/bash
#
#
# SOURCE CODE ASLI >> nixpoin.com & https://github.com/aurielly/DigitalOceanWindowsInstaller
# dimodifikasi oleh dxtstd

echo "Pilih OS yang ingin anda install"
echo "  1) Windows 2025"
echo "  2) Windows 2022"
echo "  5) Pakai link gz mu sendiri"

read -p "Pilih [1]: " PILIHOS

case "$PILIHOS" in
  1|"") PILIHOS="https://download1638.mediafire.com/poux3rz773agcGl0hFT5dhP5SDf-uOwhJ69CQ-q4bOqn2OvBB10oa7XQtMHjIBrDllo7gZZ3S7zfPcZRkGz4C_Ks6gCoHWzAYxwOXv4vN0_16_abDJkDqNEIeXxiH14qHAnmO9KxMt0Zq7Tr8LVdaWDJJ3seUwupfHw8GdRN1F3xKg/ra9ifdin25yzvoa/ws2k25.img.gz";;
  2|"") PILIHOS="https://download1334.mediafire.com/r4w1yzviogpgtzYf4eCROTJGPaVFSfaGnogg7KNks028tGchGQ7RGAjHJ-dTJYTyl8uFbzYa7SxrsZ88wFE-iDr7b6tmMLq3Ncw18j97_7uYmhG9Ds7plQIseHorBTr_kC7fKPOOB3M9H63SYrRdp13txb7VN-LMHcSt9MN-uof8CA/14oa4xygk76vhmm/ws2k22.img.gz";;
  5) read -p "Masukkan Link GZ mu : " PILIHOS;;
  *) echo "Pilihan salah, kode dihentikan..."; exit ;;
esac

IP_4=$(curl -4 -s ifconfig.me)
GW=$(ip route | awk '/default/ { print $3 }')

cat >/tmp/net.bat <<EOF

@ECHO OFF
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

for /f "tokens=3*" %%i in ('netsh interface show interface ^|findstr /I /R "Local.* Ethernet Ins*"') do (set InterfaceName=%%j)
netsh -c interface ip set address name="Ethernet Instance 0 2" source=static address=$IP_4 mask=255.255.240.0 gateway=$GW
netsh -c interface ip add dnsservers name="Ethernet Instance 0 2" address=8.8.8.8 index=1 validate=no
netsh -c interface ip add dnsservers name="Ethernet Instance 0 2" address=8.8.4.4 index=2 validate=no

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=Yes

cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q net.bat
exit

EOF

cat >/tmp/dpart.bat<<EOF

@ECHO OFF
echo JENDELA INI JANGAN DITUTUP
echo BANYAK AKAN KONFIGURASI DISINI

cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /f /q "%temp%\Admin.vbs"
exit /b 2)

ECHO SELECT VOLUME=%%SystemDrive%% > "%SystemDrive%\diskpart.extend"
ECHO EXTEND >> "%SystemDrive%\diskpart.extend"
START /WAIT DISKPART /S "%SystemDrive%\diskpart.extend"

del /f /q "%SystemDrive%\diskpart.extend"
cd /d "%ProgramData%/Microsoft/Windows/Start Menu/Programs/Startup"
del /f /q dpart.bat
timeout 50 >nul
echo JENDELA INI JANGAN DITUTUP
exit

EOF

wget --no-check-certificate -O- $PILIHOS | gunzip | dd of=/dev/vda bs=3M status=progress

echo "Wait... kita rehat sejenak"
sleep 5

echo "Umount all /dev/vda* for mounting"
umount /dev/vda1
umount /dev/vda2
umount /dev/vda3

sleep 5

echo "Put script to windows server startup"
mount.ntfs-3g /dev/vda3 /mnt
cd "/mnt/ProgramData/Microsoft/Windows/Start Menu/Programs/"
cd Start* || cd start*; \
cp -f /tmp/net.bat net.bat
cp -f /tmp/dpart.bat dpart.bat

echo 'Your server will turning off in 5 second'
sleep 5
poweroff
