FROM debian:11

# 1. Konfigurasi Lingkungan
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6080
# Perbaikan: Tambahkan variabel USER di sini
ENV USER=root

# 2. Update & Install Desktop + VNC Server
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    curl wget procps python3 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Setup Password VNC
RUN mkdir -p ~/.vnc \
    && echo "craxid12" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# 4. Buat script startup yang lebih lengkap
RUN echo "#!/bin/bash" > /start.sh \
    && echo "echo 'Starting VNC Server as USER: \$USER' " >> /start.sh \
    && echo "rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1" >> /start.sh \
    # Jalankan vncserver dengan menentukan USER secara eksplisit jika perlu
    && echo "USER=root vncserver :1 -geometry 1280x720 -depth 24" >> /start.sh \
    && echo "echo 'Starting noVNC Bridge on port 6080...'" >> /start.sh \
    && echo "/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6080" >> /start.sh \
    && chmod +x /start.sh

# 5. Ekspose port noVNC
EXPOSE 6080

CMD ["/bin/bash", "/start.sh"]
