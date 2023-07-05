#!/bin/bahs
#Développé par Benstitou Sofiane

#créations de trois partitions :
#512M : partition EFI pour le démarrage
#TOUT sauf 4G pour la partition racine
#4G/Le reste pour la Swap

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
