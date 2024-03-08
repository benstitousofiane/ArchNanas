#---SALUTATION---
echo "Bienvenue sur ArchNanas, selectionnez le disque dans lequel vous voulez l'installer"
echo ""
echo "Vous devez avoir ecrit les partitions via cfdisk ou fdisk"
echo "Si ca n'a pas ete fait, quitez le programme et faisez le"
#----------------

echo -n "[1/7] Entrez le nom du disque (exemple : /dev/sda) : "
read -r disk
echo -n "[2/7] La partition de demarrage (EFI) est $disk"
read -r bootpartition
echo -n "[3/7] La parition principale (/) est $disk"
read -r rootpartition
echo -n "[4/7] La patition swap est $disk"
read -r swappartition
echo -n "[5/7] Entrez le nom de l'utilisateur (sera sudoer) : "
read -r username
echo -n "[6/7] Entrez le mot de passe de l'utilisateur : "
read -r userpassword
echo -n "[7/7] : Entrez le mot de passe de l'utilisateur root : "
read -r rootpassword

echo "Nom du disque choisis : $disk"

echo -n "Est-tu sûr de l'installer sur ce disque ? [o/n] : "

read -r validation

if [ $validation == "o" ]; then
	

	echo "NE TOUCHEZ PLUS A RIEN AVANT LE MESSAGE 'FINI LOL'"
 	echo "3"
  	sleep 1
  	echo "2"
   	sleep 1
   	echo "1"
    	sleep "1"
	echo "c'est partie mon kiwi ! >:)"
	#------- PARTITIONNEMENT -----------

	#Initialisation du Système de fichier :
 	mkfs.fat -F 32 ${disk}${bootpartition}
  	mkfs.ext4 ${disk}${rootpartition}
   	mkswap ${disk}${swappartition}

	#Montage de la patition racine et swapon sur la partition swap:
 	#Remarque : il faut d'abord monter, la racine avant la partition EFI
	mount ${disk}${rootpartition} /mnt
 	mount --mkdir ${disk}${bootpartition} /mnt/boot/EFI
 	swapon ${disk}${swappartition}

  	#Un coup de reflector : acutaliser la recherche de mise à jour trier sur les 12 dernières heures, paquets provenant d'Allemagne (plus stable que celui de France) et rangé en fonction des notes.
   	reflector --country Germany --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

 	#installer les paquets de bases pour pouvoir faire un chroot, base pour la base du système et la compilation du noyau linux, linux le noyau, linux-firmware pour les appareil, et vim pour éditer du texte si besoin 
    	pacstrap -K /mnt base linux linux-firmware vim

	#Génération du fstab pour la liste des disque et appareils pouvant occuper le système à une certaine position après détection.
     	genfstab -U /mnt >> /mnt/etc/fstab
	#-------- FIN PARITIONNEMENT ----------


 	#--------- CONFIGURATION SYSTEME I ---------
	#Entrer dans le système avec un environnement chroot pour faire la configuration du système
      	(echo -e "
       
       	#Ajout d'un lien symbolique et le sauvegarde comme un fichier sur le fichie du fiseau horaire
	ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
 	\n
 	#Copie du temps du système vers une horloge
  	hwclock --systohc
   	\n
    	#Choix d'affichage fuseau horaire
   	echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
    	\n
    	#Application du fuseau horaire
     	locale-gen
      	\n
     	#création du fichier de configuration locale
  	touch /etc/locale.conf
   	\n
   	#Ajout de la lanfue du system sur le fichier crée
    	echo "LANG=fr_FR.UTF-8" >> etc/locale.conf
     	\n
     	#Edition de la langue du clavier
      	echo "KEYMAP=fr-latin1" >> /etc/vconsole.conf
       	\n
       	#Création du fichier hostname
	touch /etc/hostname
 	\n
	#Choix du nom de la machine (après le @)
 	echo "ArchNanas" >> /etc/hostname
  	\n
  	#mot de passe pass défaut de l'utilisateur root
	echo -e '$rootpassword\n$rootpassword' | passwd
 	\n

	#installation de paquets pour pouvoir démaré le système sans chroot et configuration du réseau
 	pacman -S grub efibootmgr networkmanager wireless_tools --noconfirm
  	\n
      	#installation de grub sur la partition EFI
      	grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
       	\n
	#ajout de la configuration de grub
 	grub-mkconfig -o /boot/grub/grub.cfg
  	\n
   	systemctl enable NetworkManager
    	\n
   	#actication du réseau avec le service de networkmanager
   	systemctl enable NetworkManager
	\n
	pacman -Syyu && pacman -S sudo --noconfirm
        \n
	useradd -m -G wheel $username
        \n
        echo -e '$userpassword\n$userpassword' | passwd $username
        \n
	echo '%wheel ALL=(ALL:ALL) ALL' >> /etc/sudoers
        \
	#installation de l'environnement graphique (lightdm driver intel, alacritty, i3-gaps, picom, feh, polybar, rofi)
	pacman -S xf86-video-intel xorg --noconfirm
        \n
	pacman -S lightdm lightdm-gtk-greeter --noconfirm
        \n
	pacman -S i3 --noconfirm
        \n
	pacman -S i3-gaps picom feh polybar rofi --noconfirm
        \n
	pacman -S alacritty --noconfirm
        \n
	echo 'greeter-session=lightdm-gtk-greeter' >> /etc/lightdm/lightdm.conf
        \n
	systemctl enable lightdm
        \n
 	#ajout du son à configurer graphiquement avec pavucontrol si ça ne fonctionne pas via périphérique de sortie et cliquer sur la tout première à coche tout à droite
  	pacman -S pulseaudio pavucontrol --noconfirm
        \n
	#Ajout des fonts de meilleurs qualité, affichagede d'autre alphabet (arabe, hébreu, japonais...) et émojis
	pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji --noconfirm
        \n
	#Pour l'appareillage bluetooth
 	pacman -S bluez bluez-utils blueman pulseaudio-bluetooth --noconfirm
  	\n
   	systemctl enable bluetooth.service
    	\n
   	"
  	) | arch-chroot /mnt
   	#Mise en place du clavier en français azerty
   	cp preconfig/00-keyboard.conf /mnt/etc/X11/xorg.conf.d/
    	mkdir /mnt/home/${unername}
     	mkdir /mnt/home/${username}/.config
    	cp -r postconfig/wallpapers/ /mnt/home/${username}/
     	cp -r postconfig/config/* /mnt/home/${username}/.config/
      	cp postconfig/apresinstallation.txt /mnt/home/${username}/
   	#--------- CONFIGURATION SYSTEME I FIN ---------
    
 	echo "LOL"
     	echo ""
      	echo "Installation du systeme de base termine !"

else
	exit 0
fi
