FROM debian:11

# 1. Konfigurasi Lingkungan
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV USER=root

# 2. Update & Install Desktop + VNC Server + net-tools (PENTING)
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    net-tools \
    curl wget procps python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Setup Password VNC
RUN mkdir -p ~/.vnc \
    && echo "craxid12" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# 4. Perbaikan Script xstartup (Agar XFCE muncul dengan benar)
RUN echo "#!/bin/sh" > ~/.vnc/xstartup \
    && echo "xrdb \$HOME/.Xresources" >> ~/.vnc/xstartup \
    && echo "startxfce4 &" >> ~/.vnc/xstartup \
    && chmod +x ~/.vnc/xstartup

# 5. Buat script startup yang stabil
RUN echo "#!/bin/bash" > /start.sh \
    && echo "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1" >> /start.sh \
    && echo "vncserver :1 -geometry 1280x720 -depth 24" >> /start.sh \
    && echo "echo 'Starting noVNC Bridge on port 6080...'" >> /start.sh \
    # Menjalankan websockify secara manual agar lebih stabil di Railway
    && echo "/usr/bin/websockify --web /usr/share/novnc/ 6080 localhost:5901" >> /start.sh \
    && chmod +x /start.sh

# 6. Ekspose port noVNC
EXPOSE 6080

CMD ["/bin/bash", "/start.sh"]
