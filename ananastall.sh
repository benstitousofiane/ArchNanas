sh 0salutation.sh

echo -n "Entrez le nom du disque : "
read -r disk

echo "Nom du disque choisis : $disk"

echo -n "Est-tu sûr de l'installer sur ce disque ? [o/n] : "

read -r validation

if [ $validation == "o" ]; then
	echo "c'est partie mon kiwi ! >:)"

	echo "NE TOUCHEZ PLUS A RIEN AVANT LE MESSAGE 'FINI LOL'"
	sh 1partitionnement.sh
else
	exit 0
fi

