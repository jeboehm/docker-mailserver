#!/bin/sh
SA_HOME="/var/lib/spamassassin/.spamassassin"
PYZOR_HOME="/var/lib/spamassassin/.pyzor"
RAZOR_HOME="/var/lib/spamassassin/.razor"
echo "Starting spamassassin.."

create_homedir() {
  if ! [ -d ${SA_HOME} ]
  then
      mkdir ${SA_HOME}
      chown debian-spamd ${SA_HOME}
  fi
}

pyzor_discover() {
  start-stop-daemon \
    --chuid debian-spamd:debian-spamd --start \
    --exec /usr/bin/pyzor -- \
    --homedir ${PYZOR_HOME} discover
}

razor_setup() {
  if [ -d $RAZOR_HOME ]
  then
    return 0
  fi

  mkdir $RAZOR_HOME

  razor-admin -home=$RAZOR_HOME -register
  razor-admin -home=$RAZOR_HOME -create
  razor-admin -home=$RAZOR_HOME -discover
}

create_homedir
pyzor_discover
razor_setup

/usr/local/bin/sa-update.sh --startup

spamd \
    --username=debian-spamd \
    --syslog stderr \
    --pidfile=/run/spamd.pid \
    --max-children 5 \
    --helper-home-dir \
    --nouser-config
