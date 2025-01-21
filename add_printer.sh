#!/bin/bash

# Funkció: Szolgáltatás elérhetőségének ellenőrzése
wait_for_service() {
  local service_name=$1
  local check_cmd=$2
  echo "Várakozás a ${service_name} indítására..."
  until eval "$check_cmd"; do
    echo "${service_name} még nem elérhető, várakozás..."
    sleep 5
  done
  echo "${service_name} elérhető."
}

echo "Várakozás a CUPS indítására..."
until curl -s http://localhost:631; do
  sleep 2
done
echo "CUPS elérhető."

# Nyomtató elérhetőségének ellenőrzése
wait_for_service "Nyomtató" "lpinfo -v | grep -q 'usb://HP/LaserJet%20Professional%20M1132%20MFP'"

# Nyomtató hozzáadása
echo "Nyomtató hozzáadása..."
lpadmin -p HP_M1132 \
    -v usb://HP/LaserJet%20Professional%20M1132%20MFP?serial=000000000QH4QM0KPR1a \
    -m everywhere \
    -E || echo "Nyomtató hozzáadása sikertelen."
if [ $? -eq 0 ]; then
  echo "Nyomtató sikeresen hozzáadva."
  lpoptions -d HP_M1132
else
  echo "Nyomtató hozzáadása sikertelen."
  exit 1
fi

# Hozzáadott nyomtatók ellenőrzése
echo "Hozzáadott nyomtatók:"
lpstat -p


