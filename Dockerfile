FROM debian:11

# 1. Konfigurasi Lingkungan
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV USER=root

# 2. Install Desktop Environment + VNC + Tools
# FIX: Menambahkan 'dbus-x11' dan 'x11-xserver-utils' agar XFCE tidak crash
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    net-tools \
    dbus-x11 x11-xserver-utils \
    curl wget procps python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Setup Folder dan Password VNC
RUN mkdir -p ~/.vnc \
    && echo "craxid12" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# 4. FIX: Script xstartup dengan dbus-launch
RUN echo "#!/bin/bash" > ~/.vnc/xstartup \
    && echo "xrdb \$HOME/.Xresources 2>/dev/null" >> ~/.vnc/xstartup \
    && echo "export XDG_CURRENT_DESKTOP=XFCE" >> ~/.vnc/xstartup \
    && echo "export XDG_MENU_PREFIX=xfce-" >> ~/.vnc/xstartup \
    && echo "dbus-launch --exit-with-session startxfce4 &" >> ~/.vnc/xstartup \
    && chmod +x ~/.vnc/xstartup

# 5. Script Startup Utama
RUN echo "#!/bin/bash" > /start.sh \
    && echo "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1" >> /start.sh \
    && echo "vncserver :1 -geometry 1280x720 -depth 24" >> /start.sh \
    && echo "echo 'Mengaktifkan noVNC...'" >> /start.sh \
    && echo "/usr/bin/websockify --web /usr/share/novnc/ 6080 localhost:5901" >> /start.sh \
    && chmod +x /start.sh

# 6. Port untuk Railway
EXPOSE 6080

CMD ["/bin/bash", "/start.sh"]
