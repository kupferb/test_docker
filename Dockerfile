# Use official NVIDIA CUDA runtime image compatible with Blackwell (RTX 5090) 
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=host.docker.internal:0.0

# 1. Install system utilities, Python 3.10, and Java (required for PyCharm)
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget curl git nano \
    libgl1-mesa-glx \
    libglib2.0-0 \
    openjdk-17-jdk \
    python3.11 python3.11-dev python3.11-distutils python3-pip \
    #xfce4 \
    #xfce4-goodies \
    mate-desktop-environment-core \
    mate-notification-daemon \
    dbus-x11 \
    x11-utils \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# 2. Download and install JetBrains PyCharm Community Edition for Linux
#RUN wget https://download.jetbrains.com/python/pycharm-2026.2.3.tar.gz -O /tmp/pycharm.tar.gz && \
#    tar -xzf /tmp/pycharm.tar.gz -C /opt/ && \
#    mv /opt/pycharm-* /opt/pycharm && \
#    rm /tmp/pycharm.tar.gz

# 3. Copy requirements.txt into the container image
COPY requirements.txt /tmp/requirements.txt

# 4. Install the Python packages from the requirements file using Python 3.10 pip
#RUN python3 -m pip install --no-cache-dir --upgrade pip && \
#    python3 -m pip install --no-cache-dir -r /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir -r /tmp/requirements.txt && \
    python3 -m pip install --no-cache-dir pipdeptree && \
    echo "===== Installed packages =====" && \
    pip list && \
    echo "===== PyJWT dependency =====" && \
    pipdeptree --reverse --packages PyJWT || true
# 5. Set working directory and default startup command to launch PyCharm
#WORKDIR /workspace
#CMD ["/opt/pycharm/bin/pycharm.sh"]
# 5. Set up a startup script to launch VNC and XFCE desktop
WORKDIR /workspace

# Default command starts the XFCE desktop session directly over X11
CMD ["dbus-run-session", "mate-session"]

# Default command starts VNC server and tails logs
#CMD ["sh", "-c", "vncserver :1 -geometry 1920x1080 -depth 24 && tail -f ~/.vnc/*.log"]
