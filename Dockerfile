FROM fedora:40

# Prevent interactive prompts
ENV TERM=xterm-256color

# Install base tools and development dependencies
RUN dnf -y update && \
    dnf -y install \
        ansible \
        java-17-openjdk \
        nodejs \
        npm \
        go \
        gcc \
        python3-devel \
        libxml2-devel \
        libxslt-devel \
        git \
        curl \
        wget \
        tar \
        which && \
    dnf clean all

# Install pnpm globally
RUN npm install -g pnpm

# Install yq (mikefarah version)
RUN wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
        -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Verify versions (optional but useful for CI visibility)
RUN java -version && \
    ansible --version && \
    go version && \
    pnpm --version && \
    yq --version

WORKDIR /workspace

CMD ["/bin/bash"]
