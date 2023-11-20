#---SALUTATION---
echo "Bienvenue sur ArchNanas, selectionnez le disque dans lequel vous voulez l'installer"
#----------------

echo -n "[1/4] Entrez le nom du disque (exemple : /dev/sda) : "
read -r disk
echo -n "[2/4] Entrez le nom de l'utilisateur (sera sudoer) : "
read -r username
echo -n "[3/4] Entrez le mot de passe de l'utilisateur : "
read -r userpassword
echo -n "[4/4] : Entrez le mot de passe de l'utilisateur root : "
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

	#créations de trois partitions :
	#512M : partition EFI pour le démarrage
	#TOUT sauf 4G pour la partition racine
	#4G/Le reste pour la Swap

	#Suppression de tous les partitions et de leurs signature du disque avec wipefs pour ne pas avoir d'erreurs sur une réinstallation du ou d'un autre système

  	wipefs --all $disk

	#génère des entré et envoit avec le pipe | les info à fdisk
	#(ça évite d'utiliser sfdisk plus dure à manipuler)

	#remarque : la partition dos demandera à chaque fois si on crée une partition primaire (simple) 
        #ou étendu (qui peut avoir des sous partitions)
	echo -e "o\nn\n\n\n\n-4G\nn\n\n\n\n-0G\nw" | fdisk $disk

	#ce que fait cette ligne :
	#-Crée une table de partition DOS
	#-Fait un saut de ligne
	#
	#-Selectionne le mode crée une partition
	#-Fait trois saut de lignes
	#-Choisis comme taille de partition "Tout et laissé 4G"
	#-Fait un saut de ligne
	#
	#-Selectionne le mode crée une partition
	#-Fait trois saut de lignes
	#-Choisis comme taille de partition 4G (le reste)
	#-Fait un saut de ligne
	#
	#Enregistre les modidications

	#Initialisation du Système de fichier :
  	mkfs.ext4 ${disk}1
   	mkswap ${disk}2


	#Montage de la patition racine et swapon sur la partition swap:
	mount ${disk}1 /mnt
 	swapon ${disk}2

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
 	pacman -S grub networkmanager wireless_tools --noconfirm
  	\n
      	#installation de grub dans le disque
      	grub-install --target=i386-pc /dev/sda
       	\n
	#ajout de la configuration de grub
 	grub-mkconfig -o /boot/grub/grub.cfg
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
	#installation de l'environnement graphique (i3-caps, lightdm driver intel et alacritty)
	pacman -S xf86-video-intel xorg --noconfirm
        \n
	pacman -S lightdm lightdm-gtk-greeter --noconfirm
        \n
	pacman -S i3 --noconfirm
        \n
	pacman -S i3-gaps dmenu --noconfirm
        \n
	pacman -S alacritty --noconfirm
        \n
	echo 'greeter-session=lightdm-gtk-greeter' >> /etc/lightdm/lightdm.conf
        \n
	systemctl enable lightdm
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
   	#--------- CONFIGURATION SYSTEME I FIN ---------
    	
 	echo "Fini LOL"
     	echo ""
      	echo "Installation du système de base terminé !"

else
	exit 0
fi
