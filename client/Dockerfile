FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-client \
    ftp \
    nmap \
    hydra \
    hping3 \
    pssh \
    wget \
    curl \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Instalar GoldenEye (herramienta DoS)
RUN git clone https://github.com/jseidl/GoldenEye.git /opt/goldeneye && \
    chmod +x /opt/goldeneye/goldeneye.py

WORKDIR /root

CMD ["/bin/bash"]
