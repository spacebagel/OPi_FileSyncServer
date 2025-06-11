# 🍊OrangePi File Sync Server
📜**Description:** this repository contains a step-by-step guide for building a file synchronization server based on OrangePi Zero 2W.

![OPiServer](https://github.com/user-attachments/assets/33faf06e-472a-4008-b0b1-2e805e2603ab)


### Table of Contents
**[Assembly Instructions](#assembly-instructions)**<br>
**[OS Installation](#os-installation)**<br>
**[System Setup](#system-setup)**<br>
**[Syncthing Installation](#syncthing-installation)**<br>
**[SSD Mounting](#ssd-mounting)**<br>
**[Syncthing Setting](#syncthing-setting)**<br>

## Assembly Instructions
### 🔨 Main parts:
- x1 OrangePi Zero 2W
- x1 Expansion board*
- x1 SATA SSD
- x1 SATA to USB connector
- x1 Micro SD card

*It may still work without expansion board if you perform the initial setup without an SSD, and then connect it via a USB-A to USB-C adapter.

### 🎄 Optional:
- x1 OPi Case with screws
- x1 PC case fun (80x80)
- x2 Short wire
- x1 Cotton swab
- x2 SSD/HDD screw
- x4 Female screw
- x1 3D printer & plastic


### 📙 OPi Assembly
You can start by assembling the base.

![OPi](https://github.com/user-attachments/assets/79365469-efde-402f-84f6-5465eda46bfe)

Then connect the SSD, display and keyboard.

![OPiWithDevices](https://github.com/user-attachments/assets/6d309504-5cf2-45a0-bb06-98a116762157)

For the basic version - that's all.

If you need to make the same "open case"...
Download 3D models** from [Models](https://github.com/spacebagel/OPi_FileSyncServer/tree/main/Models) folder and print them.

**The models are rough estimates. It works but, for the best result you should change sizes for SSD screw plate.

Force the female screws into the rear of the "case" and screw the OPi into it.

![Back Screws](https://github.com/user-attachments/assets/7cfe70b5-576e-48dc-9864-8437f1b4752a)


![OPi and Back plate](https://github.com/user-attachments/assets/a0cb78c1-a794-452a-8373-f276b4388942)

Insert both parts of the case into the fun (again with force, if you did'nt change the 3D models) and screw it into the SSD.

![Parts in Fun](https://github.com/user-attachments/assets/55276986-9c3e-4b6d-8a5a-a8ba7f71a709)

Manage wires with some like cotton swab.

![Cotton swab](https://github.com/user-attachments/assets/72563133-bbfa-4b4a-9647-1a6c867cb558)

Connect the +wire to 5V and the -wire to GND pins.

![OPi pins](https://github.com/user-attachments/assets/d2081216-65cd-467e-8e2d-960f3f335c4a)


## OS Installation
### 🐍 Download
Download the image from the [official page](http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-Zero-2W.html). 

![Download page](https://github.com/user-attachments/assets/c50be021-a414-49dd-96d7-705c914a1a13)

I used the Debian Bookworm Server.

![Image name](https://github.com/user-attachments/assets/0784177a-7d26-4a1c-a5f8-5349a8e5f3c6)

### 💽 Making the image
To write the image to Micro SD, you can use [balenaEtcher](https://www.balena.io/etcher) or another similar program.

Unpack the archive and select it.

![balenaEtcher select image](https://github.com/user-attachments/assets/e624e315-7644-4bf3-9d4e-bdaab69310f3)

Put the SD card into your PC and select the device. Press Flash!

![balenaEtcher select device](https://github.com/user-attachments/assets/5f7551c1-e4ed-4e94-9dd9-db30722fc5cd)

## System Setup
**Comment:** all scripts you can find in the [folder](https://github.com/spacebagel/OPi_FileSyncServer/tree/main/Scripts). Btw, you can use your own file names.

### 🛜 Wi-Fi configuration

Make the [wpa_supplicant.conf](https://github.com/spacebagel/OPi_FileSyncServer/blob/main/Scripts/wifi_connect.sh) file.

```bash
sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
```

```bash
network={
ssid="YOUR_WIFI_SSID"
psk="YOUR_WIFI_PASSWORD"
priority=1
}
```

Make the [wifi_connect.sh](https://github.com/spacebagel/OPi_FileSyncServer/blob/main/Scripts/wifi_connect.sh) for auto connecting.

```bash
sudo nano /usr/sbin/wifi_connect.sh
```

```bash
#!/bin/bash
ip link set wlan0 up
wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```

Make the [wlan0_ip_add.sh](https://github.com/spacebagel/OPi_FileSyncServer/blob/main/Scripts/wlan0_ip_add.sh) to configure a static IP for the interface. This is necessary for connecting via SSH. Check your default route address before that.

```bash
sudo nano /usr/sbin/wlan0_ip_add.sh
```

```bash
#!/bin/bash
sleep 10
sudo ip addr add 192.168.0.169/24 dev wlan0
sudo ip route add default via 192.168.0.1 dev wlan0
```

Activate scripts
```bash
sudo chmod +x /usr/sbin/wlan0_ip_add.sh
sudo chmod +x /usr/sbin/wifi_connect.sh
```

Add paths to the **/etc/rc.local**.
```bash
...
/usr/sbin/wifi_connect.sh
/usr/sbin/wlan0_ip_add.sh
exit 0
```

### 😐 DNS configuration
```bash
sudo nano /etc/network/interfaces
```

Add dns-nameservers line.
```
...
dns-nameservers 8.8.8.8 1.1.1.1
```

```bash
sudo reboot
```

Now you can connect OPi form your PC via SSH. Default login/pass: orangepi/orangepi.

![ssh](https://github.com/user-attachments/assets/88d8acbb-e50f-433b-ba5a-ff14982188a5)

## Syncthing Installation
Syncthing project repo: https://github.com/syncthing/syncthing

Steps to install and configure the package.
```bash
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
```

```bash
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
```

```bash
sudo apt-get update
sudo apt-get install syncthing
```

Configuring the program.

```bash
syncthing
sudo nano ~/.config/syncthing/config.xml
```

Change the address to 0.0.0.0 to ensure external connectivity.

![Syncthing config](https://github.com/user-attachments/assets/80f379e2-9a62-4c8a-896e-f70511810417)

Enable and start Syncthing daemon:

```bash
systemctl enable syncthing@orangepi
systemctl start syncthing@orangepi
```

Check the Syncthing daemon status:

```bash
systemctl status syncthing@orangepi
```

![Syncthing status](https://github.com/user-attachments/assets/2b85db20-c127-4636-9845-67369883238e)

## SSD Mounting
Check the /dev/... disk name.

```bash
sudo fdisk -l
```
### 🔥 If the disk is not yet partitioned

```bash
sudo fdisk /dev/sda
```

Creating new GPT-table, new part* and save changes:

```
g
n
w
```

*Enter -> Enter -> ... for default params.

Making filesystem:

```bash
sudo mkfs.ext4 /dev/sda1
```

### 🗿 If the disk is already partitioned
Make the mount point:

```bash
sudo mkdir /mnt/ssd_meow
```

Mount the disk:

```bash
sudo mount /dev/sda1 /mnt/ssd_meow
sudo chown orangepi:orangepi /mnt/ssd_meow
mkdir /mnt/ssd_meow/files
```

Use the [mount_ssd.sh](https://github.com/spacebagel/OPi_FileSyncServer/blob/main/Scripts/mount_ssd.sh) script for auto mounting the disk.

```bash
sudo nano /usr/sbin/mount_ssd.sh
```

```bash
#!/bin/bash
sudo mount /dev/sda1 /mnt/ssd_meow
sudo systemctl daemon-reload
```
Activate the script:

```bash
sudo chmod +x /usr/sbin/mount_ssd.sh
```
Check the [/etc/rc.local](https://github.com/spacebagel/OPi_FileSyncServer/blob/main/Scripts/rc.local) and add the line.

```bash
nano /etc/rc.local
```

```
...
/usr/sbin/mount_ssd.sh
...
```

## Syncthing Setting
Download the [Syncthing](https://syncthing.net/) on your devices and run it.

Use the web panel linked by OPi IP and default 8384 port. Click Actions -> Show ID -> Copy the line.
![Show ID](https://github.com/user-attachments/assets/81caf3aa-444d-4723-af01-0f1a7e0ed0b2)

Use another device. Click Add Remote Devices and paste the ID.

![Add device](https://github.com/user-attachments/assets/768a3b7f-4f42-4834-b35c-1216642409bb)

![Paste ID](https://github.com/user-attachments/assets/f5020fce-013c-4951-90c6-3e28dcfa81b1)

Add folder and unique ID.

![Add floder](https://github.com/user-attachments/assets/90492c00-47f4-481c-b54f-3b9621a7b76b)

Select sharing rules for the devices.

![Select sharing rule](https://github.com/user-attachments/assets/87d6a91d-d249-4ec2-9f68-6b024bb18309)

Add folder sync through the OPi web panel.

![Add folder](https://github.com/user-attachments/assets/1d2554ba-c137-4de4-aae4-4ebf40b8100e)

