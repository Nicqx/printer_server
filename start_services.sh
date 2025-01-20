#!/bin/bash

# Indítsd el a DBus-t
service dbus start
if ! service dbus status > /dev/null; then
  echo "DBus failed to start"
  exit 1
fi

# Indítsd el az Avahi-daemon-t
service avahi-daemon start
if ! service avahi-daemon status > /dev/null; then
  echo "Avahi-daemon failed to start"
  exit 1
fi

# Indítsd el a CUPS-t
service cups start
if ! service cups status > /dev/null; then
  echo "CUPS failed to start"
  exit 1
fi

# Ellenőrizd a /var/log/cups/error_log létezését
if [ ! -f /var/log/cups/error_log ]; then
  touch /var/log/cups/error_log
fi

# Tartsd a konténert futásban
tail -f /var/log/cups/error_log

