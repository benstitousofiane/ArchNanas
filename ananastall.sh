#---SALUTATION---
echo "Bienvenue sur ArchNanas, selectionnez le disque dans lequel vous voulez l'installer"
#----------------

echo -n "Entrez le nom du disque (exemple : /dev/sda) : "
read -r disk

echo "Nom du disque choisis : $disk"

echo -n "Est-tu sûr de l'installer sur ce disque ? [o/n] : "

read -r validation

if [ $validation == "o" ]; then
	echo "c'est partie mon kiwi ! >:)"

	echo "NE TOUCHEZ PLUS A RIEN AVANT LE MESSAGE 'FINI LOL'"
	
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
 	mkfs.vfat -F 32 ${disk}1
  	mkfs.ext4 ${disk}2
   	mkswap ${disk}3


	#Montage de la patition racine et swapon sur la partition swap:
 	mount --mkdir ${disk}1 /mnt/boot
	mount ${disk}2 /mnt
 	swapon ${disk}3

  	#Un coup de reflector : acutaliser la recherche de mise à jour trier sur les 12 dernières heures, paquets provenant d'Allemagne (plus stable que celui de France) et rangé en fonction des notes.
   	reflector --country Germany --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

 	#installer les paquets de bases pour pouvoir faire un chroot, base pour la base du système et la compilation du noyau linux, linux le noyau, linux-firmware pour les appareil, et vim pour éditer du texte si besoin 
    	pacstrap -K /mnt base linux linux-firmware vim

	#Génération du fstab pour la liste des disque et appareils pouvant occuper le système à une certaine position après détection.
     	genfstab -U /mnt >> /mnt/etc/fstab

	#Entrer dans le système avec un environnement chroot pour faire la configuration du système
      	arch-chroot /mnt
  
	#-------- FIN PARITIONNEMENT ----------


else
	exit 0
fi

