#!/usr/bin/env bash

# Fetch server
if [[ ! $SERVER ]] ; then
  echo -n "Enter server [srv191.donenad.nl]: "
  read SERVER
  [[ ! $SERVER ]] && SERVER=srv191.donenad.nl
fi

# Fetch username
if [[ ! $USR ]] ; then
  echo -n "Enter username [vpstask]: "
  read USR
  [[ ! $USR ]] && USR=vpstask
fi

# Fetch site name
if [[ ! $SITENAME ]] ; then
  echo -n "Enter site name [trackthis.nl]: "
  read SITENAME
  [[ ! $SITENAME ]] && SITENAME=trackthis.nl
fi

# Fetch start date
if [[ ! $STARTDATE ]] ; then
  echo -n "Enter start date [yesterday]: "
  read STARTDATE
  [[ ! $STARTDATE ]] && STARTDATE=yesterday
  STARTDATE=$(date -d "$STARTDATE" '+%Y-%m-%d')
fi

# Fetch stop date
if [[ ! $STOPDATE ]] ; then
  echo -n "Enter stop date [yesterday]: "
  read STOPDATE
  [[ ! $STOPDATE ]] && STOPDATE=yesterday
  STOPDATE=$(date -d "$STOPDATE" '+%Y-%m-%d')
fi

# Fetch key to use
if [[ ! $SSH_KEY_FILE ]] ; then
  SSH_KEY_FILE_DEFAULT=$([[ -f "${HOME}/.ssh/master_key" ]] && echo "${HOME}/.ssh/master_key" || echo "${HOME}/.ssh/id_rsa")
  echo -n "Enter ssh key file [${SSH_KEY_FILE_DEFAULT}]: "
  read SSH_KEY_FILE
  [[ ! $SSH_KEY_FILE ]] && SSH_KEY_FILE=$SSH_KEY_FILE_DEFAULT
fi

sshprefix="ssh -i ${SSH_KEY_FILE} ${USR}@${SERVER}"
commands="cd /home/sites/${SITENAME}/cron && php -d memory_limit=1G run.php 'importers=InvoicePayoutSummary&period=${STARTDATE} 00:00:00,${STOPDATE} 23:59:59&reporterOptions[verbose]=3'"

shortdate=$(date -d "$STARTDATE" +20%y%m)
outputfolder="/tmp/payoutsummary-${shortdate}"

mkdir -p $outputfolder
copycommand="scp -i ${SSH_KEY_FILE} -r ${USR}@${SERVER}:${outputfolder}-* ${outputfolder}"
archivefile=$outputfolder/payoutsummary-$shortdate.zip

echo "Generating payoutsummary"
cmd1=$($sshprefix "$commands")
cmd2=$($copycommand)
zip $archivefile $outputfolder/*.csv
echo "File at: $archivefile"
