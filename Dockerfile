FROM debian:11

# 1. Konfigurasi Lingkungan
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6080

# 2. Install Desktop Environment (XFCE) dan VNC Server
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    curl wget procps python3 \
    && apt-get clean

# 3. Setup Password VNC (Default: 'craxid')
RUN mkdir -p ~/.vnc \
    && echo "craxid" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# 4. Buat script startup untuk menjalankan VNC & noVNC
RUN echo "#!/bin/bash" > /start.sh \
    && echo "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1" >> /start.sh \
    && echo "vncserver :1 -geometry 1280x720 -depth 24" >> /start.sh \
    && echo "/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080" >> /start.sh \
    && chmod +x /start.sh

# 5. Ekspose port noVNC (Akses via Browser)
EXPOSE 6080

CMD ["/start.sh"]
