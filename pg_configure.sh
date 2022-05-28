#!/bin/bash
#Authored by zjafar - 2022-05-27

help(){

	echo "${0}	[OPTIONS] [USERNAME]" >&2 
	echo "-d	provide the data directory"
	echo "-v	provide the version"
	exit 1
}

while getopts d:v: OPTION
do
	case ${OPTION} in
	
	d) DATA_DIR=${OPTARG}
	   ;;
	
	v) VERSION=${OPTARG}
	   ;;
	*)
	   help
	   ;;
	esac
done

shift "$(( OPTIND - 1 ))"

if [[ -z ${DATA_DIR} ]] || [[ -z ${VERSION} ]]; then
	help
fi

grep -q "local   all             postgres                                trust" ${DATA_DIR}/pg_hba.conf

if [[ $? -eq 1 ]]; then

	sed -i '/"local" is for Unix domain socket connections only.*/a local   all             postgres                                trust' ${DATA_DIR}/pg_hba.conf

	if [[ $? -eq 0 ]]; then
		echo "Postgres User added to Trust configuration"
		systemctl restart postgresql-${VERSION} &> /dev/null

		if [[ $? -eq 0 ]]; then
        		echo "Postgres restarted successfully"
		else
        		echo "ERROR: Postgres Restart Failed"
        		exit 1
		fi
	else
		echo "ERROR: an error occurred while trying to add user to TRUST"
		exit 1
	fi
else
	echo "Postgres User was already added to Trust configuration"
fi

grep -q "psql -U postgres" ~/.bashrc

if [[ $? -eq 1 ]]; then

	sed -i '/User specific aliases and functions.*/alias psql="psql -U postgres"\n/' ~/.bashrc

	if [[ "$?" -eq 0 ]]; then
		echo "Postgres Alias setup correctly"
	else
		echo "ERROR: an error occured while trying to setup the alias"
		echo "We will continue the script"
	fi
else
	echo "Alias was already present"
fi
