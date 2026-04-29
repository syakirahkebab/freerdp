FROM debian:12

# 1. Konfigurasi Lingkungan
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV USER=root

# 2. Install Desktop, VNC, dan Python 3.11 (Bawaan Debian 12)
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    net-tools \
    dbus dbus-x11 x11-xserver-utils \
    curl wget procps \
    # Python 3.11 sudah tersedia langsung di repo Debian 12
    python3 python3-venv python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Identitas Mesin untuk D-Bus (Mencegah error Settings Server)
RUN dbus-uuidgen > /var/lib/dbus/machine-id \
    && mkdir -p /var/run/dbus

# 4. Konfigurasi Desktop (xstartup)
RUN mkdir -p ~/.vnc \
    && echo "#!/bin/bash" > ~/.vnc/xstartup \
    && echo "xrdb \$HOME/.Xresources 2>/dev/null" >> ~/.vnc/xstartup \
    && echo "export XDG_CURRENT_DESKTOP=XFCE" >> ~/.vnc/xstartup \
    && echo "dbus-launch --exit-with-session startxfce4 &" >> ~/.vnc/xstartup \
    && chmod +x ~/.vnc/xstartup

# 5. Script Startup Utama (TANPA PASSWORD)
RUN echo "#!/bin/bash" > /start.sh \
    && echo "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1" >> /start.sh \
    && echo "/etc/init.d/dbus start" >> /start.sh \
    && echo "vncserver :1 -geometry 1280x720 -depth 24 -SecurityTypes None" >> /start.sh \
    && echo "echo 'Server Siap di Debian 12! Python 3.11 Aktif.'" >> /start.sh \
    && echo "/usr/bin/websockify --web /usr/share/novnc/ 6080 localhost:5901" >> /start.sh \
    && chmod +x /start.sh

# 6. Port Railway
EXPOSE 6080

CMD ["/bin/bash", "/start.sh"]
