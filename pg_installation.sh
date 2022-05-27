#!/bin/bash

help(){

	echo "${0} 	[OPTIONS] [PG_DIRECTORY]"
	echo "-v	specify the version of pg"
	echo "-d	specify the data directory/by default if not set will be /var/lib/pgsql12/data"
	exit 1
}

initDB(){
	
	local VERSION=${1}
	echo "sudo /usr/pgsql-${VERSION}/bin/postgresql-${VERSION}-setup initdb"
	echo "sudo systemctl enable postgresql-${VERSION}"
	echo "sudo systemctl start postgresql-${VERSION}"
}

if [[ $# -eq 0 ]]; then
	help
fi

#This script can be used to install postgres in a specific data directory

while getopts v:d: OPTION
do
	case ${OPTION} in
	
	v) 
	   VERSION=${OPTARG}
	   ;;

	d)
	   DIRECTORY=${OPTARG}
	   ;;
	
	*)
	   help
	   ;;
	
	esac
done

shift "$(( OPTIND - 1 ))"

if [[ -z ${VERSION} ]] ; then
	echo "ERROR: Please provide a Postgres Version"
	exit 1
fi

echo "sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm"
# Install PostgreSQL:
echo "sudo yum install -y postgresql${VERSION}-server"

if [[ -z ${DIRECTORY} ]]; then
	
	initDB ${VERSION}	

else
	
	echo "systemctl edit postgresql-${VERSION}.service"
	echo "[Service]"
	echo "Environment=PGDATA=${DIRECTORY}"
	echo "cat /etc/systemd/system/postgresql-${VERSION}.service.d/override.conf"
	echo "systemctl daemon-reload"
	
	initDB ${VERSION}
fi
