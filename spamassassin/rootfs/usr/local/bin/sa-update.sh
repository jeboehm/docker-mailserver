#!/bin/sh

PIDFILE="/run/spamd.pid"

do_update() {
  start-stop-daemon \
    --chuid debian-spamd:debian-spamd --start \
    --exec /usr/bin/sa-update -- \
    --gpghomedir /var/lib/spamassassin/sa-update-keys 2>&1
}

do_reload() {
  kill -1 $(cat $PIDFILE)
}

if [ "$1" = "--startup" ]
then
  do_update
  exit 0
fi

sleep 60

while true
do
  if ! [ -r $PIDFILE ]
  then
      "spamd not running. Exit."
      exit 1
  fi

  do_update

  case $? in
    0)
      echo "Rule updates installed."
      do_reload
      ;;
    1)
      echo "No rule updates found."
      ;;
    *)
      echo "sa-update failed for unknown reasons."
      ;;
  esac

	sleep 6h
done
