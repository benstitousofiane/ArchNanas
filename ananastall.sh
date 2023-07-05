sh 0salutation.sh

echo -n "Entrez le nom du disque : "
read -r disk

echo "Nom du disque choisis : $disk"

echo -n "Est-tu sûr de l'installer sur ce disque ? [o/n] : "

read -r validation

if [ $validation == "o" ]; then
	echo "c'est partie mon kiwi ! >:)"
else
	exit 0
fi

