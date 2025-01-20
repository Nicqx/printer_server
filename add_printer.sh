#!/bin/bash

# D-Bus indítása
service dbus start

# Avahi indítása
service avahi-daemon start

# CUPS indítása
service cups start

# Várakozás, amíg a CUPS teljesen elindul
echo "Várakozás a CUPS szolgáltatás elindulására..."
sleep 10

# Nyomtató hozzáadása
lpadmin -p HP_M1132 \
    -v usb://HP/LaserJet%20Professional%20M1132%20MFP?serial=000000000QH4QM0KPR1a \
    -m everywhere \
    -E

# Alapértelmezett nyomtató beállítása
lpoptions -d HP_LaserJet_Professional_M1132_MFP

