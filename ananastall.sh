#---SALUTATION---
echo "Bienvenue sur ArchNanas, selectionnez le disque dans lequel vous voulez l'installer"
#----------------

echo -n "Entrez le nom du disque (exemple : /dev/sda) : "
read -r disk

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

	echo -e "g\nn\n\n\n+512M\nn\n\n\n-4G\nn\n\n\n-0G\nw" | fdisk $disk

	#ce que fait cette ligne :
	#-Crée une table de partition GPT
	#-Fait un saut de ligne
	#
	#-Selectionne le mode crée une partition
	#-Fait trois saut de lignes
	#-Choisis comme taille de partition "512M"
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
 	mkfs.fat -F 32 ${disk}1
  	mkfs.ext4 ${disk}2
   	mkswap ${disk}3


	#Montage de la patition racine et swapon sur la partition swap:
 	#Remarque : il faut d'abord monter, la racine avant la partition EFI
	mount ${disk}2 /mnt
 	mount --mkdir ${disk}1 /mnt/boot/EFI
 	swapon ${disk}3

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
	echo -e "lol\nlol" | passwd
 	\n

	#installation de paquetspour pouvoir démaré le système sans chroot et affichage de la config
 	pacman -S grub efibootmgr neofetch --noconfirm
  	\n
      	#installation de grub sur la partition EFI
      	grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
       	\n
	#ajout de la configuration de grub
 	grub-mkconfig -o /boot/grub/grub.cfg
  	\n
  	neofetch"
  	) | arch-chroot /mnt
   	#--------- CONFIGURATION SYSTEME I FIN ---------
    
 	echo "LOL"
     	echo ""
      	echo "Installation dud system de base terminé !"

else
	exit 0
fi

