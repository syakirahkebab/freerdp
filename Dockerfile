FROM debian:11

# 1. Konfigurasi Lingkungan
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV USER=root

# 2. Install Desktop Environment + VNC + Tools
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    net-tools \
    curl wget procps python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Setup Folder dan Password VNC
RUN mkdir -p ~/.vnc \
    && echo "craxid12" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# 4. FIX: Membuat file xstartup agar Desktop Muncul
# Kita menghapus file lama dan membuat yang baru dengan instruksi menjalankan XFCE
RUN echo "#!/bin/sh" > ~/.vnc/xstartup \
    && echo "unset SESSION_MANAGER" >> ~/.vnc/xstartup \
    && echo "unset DBUS_SESSION_BUS_ADDRESS" >> ~/.vnc/xstartup \
    && echo "startxfce4 &" >> ~/.vnc/xstartup \
    && chmod +x ~/.vnc/xstartup

# 5. Script Startup Utama
RUN echo "#!/bin/bash" > /start.sh \
    && echo "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1" >> /start.sh \
    && echo "vncserver :1 -geometry 1280x720 -depth 24" >> /start.sh \
    && echo "echo 'Server siap! Mengaktifkan jembatan noVNC...'" >> /start.sh \
    && echo "/usr/bin/websockify --web /usr/share/novnc/ 6080 localhost:5901" >> /start.sh \
    && chmod +x /start.sh

# 6. Port untuk Railway
EXPOSE 6080

CMD ["/bin/bash", "/start.sh"]
