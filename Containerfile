FROM registry.access.redhat.com/ubi9/ubi-minimal@sha256:4a0b20f428991925e4599bc17a0bddc0a0a823606426860206f93d20b65af3fe

ARG AWS_NUKE_VERSION=3.64.1
ARG AWS_CLI_VERSION=2.34.19

RUN microdnf install -y \
        tar \
        gzip \
        unzip \
        shadow-utils \
        bash \
        sed \
        gawk \
        grep \
        findutils \
    && microdnf clean all

# AWS CLI v2
RUN arch=$(uname -m) && \
    case "${arch}" in \
        x86_64)  AWS_ARCH="x86_64" ;; \
        aarch64) AWS_ARCH="aarch64" ;; \
    esac && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip -qo awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip ./aws && \
    aws --version

# aws-nuke v3 (checksum-verified)
RUN arch=$(uname -m) && \
    case "${arch}" in \
        x86_64)  NUKE_ARCH="amd64" ;; \
        aarch64) NUKE_ARCH="arm64" ;; \
    esac && \
    NUKE_BASE="https://github.com/ekristen/aws-nuke/releases/download/v${AWS_NUKE_VERSION}" && \
    NUKE_TAR="aws-nuke-v${AWS_NUKE_VERSION}-linux-${NUKE_ARCH}.tar.gz" && \
    curl -fsSLO "${NUKE_BASE}/${NUKE_TAR}" && \
    curl -fsSLO "${NUKE_BASE}/checksums.txt" && \
    grep "  ${NUKE_TAR}$" checksums.txt | sha256sum -c - && \
    tar -xzf "${NUKE_TAR}" -C /usr/local/bin aws-nuke && \
    chmod +x /usr/local/bin/aws-nuke && \
    rm -f "${NUKE_TAR}" checksums.txt && \
    aws-nuke --version
