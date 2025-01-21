FROM debian:bullseye

# Alapcsomagok telepítése
RUN apt-get update && apt-get install -y \
    usbutils \
    cups \
    hplip \
    avahi-daemon \
    printer-driver-all \
    && apt-get clean

# CUPS konfiguráció módosítása
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i '/<Location \/>/,/<\/Location>/ s/Order allow,deny/Allow all/' /etc/cups/cupsd.conf && \
    sed -i '/<Location \/admin>/,/<\/Location>/ s/Order allow,deny/Allow all/' /etc/cups/cupsd.conf && \
    sed -i '/Browsing Off/c\Browsing On' /etc/cups/cupsd.conf

# Avahi konfiguráció frissítése
RUN sed -i 's/#allow-interfaces=.*/allow-interfaces=eth0/' /etc/avahi/avahi-daemon.conf

# Felhasználó hozzáadása az lpadmin csoporthoz
RUN useradd -m admin && echo "admin:admin" | chpasswd && usermod -aG lpadmin admin

# Add plugin to the container
COPY  hplip-3.24.4.run /tmp/hplip-3.24.4.run

# Install the plugin
# Set permissions and run the installer
RUN chmod +x /tmp/hplip-3.24.4.run && \
    bash /tmp/hplip-3.24.4.run --accept --quiet --noexec --target /tmp/hplip && \
    cd /tmp/hplip && \
    ./hplip-install --yes --force --no-gui && \
    hp-plugin -i --force

# Nyomtató hozzáadása (script)
COPY add_printer.sh /usr/local/bin/add_printer.sh
RUN chmod +x /usr/local/bin/add_printer.sh

# Port megnyitása és szolgáltatások indítása
EXPOSE 631
CMD service dbus start && \
    service avahi-daemon start && \
    service cups start && \
    /usr/local/bin/add_printer.sh && \
    tail -f /var/log/cups/access_log
