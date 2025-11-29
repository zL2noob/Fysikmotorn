source ./backup.sh
cd ..

FILES=()
NAME="fnkth.se"

exit # TODO denna är inte klar, beror på vilka filer som mountas
case $1 in
	upload|u)
		upload_backup $NAME ${FILES[@]}
	;;
	download|d)
		read -p "Do you really want to download a backup? This will remove current data. (y/n): " confirmation
		case $confirmation in
			y|yes)
				download_backup $NAME:$2 ${FILES[@]}
				#chmod -R o-rwx services/bittan_marke/bittan_marke_postgres.env services/bittan_marke/bittan_marke_server.env services/bittan_marke/postgres_data services/bittan_marke/swish_certificates services/bittan_marke/gmail_creds services/bittan_marke/logs
				#chown root:root services/bittan_marke/bittan_marke_postgres.env services/bittan_marke/bittan_marke_server.env services/bittan_marke/postgres_data services/bittan_marke/swish_certificates services/bittan_marke/gmail_creds services/bittan_marke/logs
			;;
			n|no)
				echo "Aborting."; exit 1;;
			*)
				echo "Invalid choice. Aborting."; exit 1;;
		esac
	;;
	*) echo "Did not choose option"; exit 1;;
esac;

