ARG FEDORA_VERSION=44

FROM quay.io/fedora/fedora:${FEDORA_VERSION} AS build

# Restore documentation stripped by the base image, then install packages
RUN set -euo pipefail \
  && sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf \
  && echo '%_install_langs en' > /etc/rpm/macros.image-language-conf \
  && dnf -y upgrade \
  && dnf -y install --allowerasing coreutils \
  && dnf -y swap glibc-minimal-langpack glibc-langpack-en \
  && dnf -y reinstall $(rpm -qa --qf '[%{=NAME} %{FILESTATES:fstate}\n]' \
  | awk '/ not installed$/ {print $1}' | sort -u) \
  && dnf -y install \
  autoconf automake bison cmake flex gcc gcc-c++ gdb gettext libtool make \
  meson ninja-build patch pkgconf-pkg-config strace \
  dnf5-plugins git gnupg2 openssh-clients \
  bash-completion fish info less man-db man-pages \
  bzip2 diffutils file findutils gzip hostname iproute iputils ncurses \
  procps-ng ripgrep shadow-utils sudo tar tree tzdata unzip util-linux \
  vim-minimal which xz zip zstd \
  podman \
  && mandb -q \
  && compgen -G '/usr/share/man/man1/ls.1*' > /dev/null \
  && dnf clean all \
  && rm -rf /var/log/dnf5.log*

# Locale, timezone, and unprivileged user
ARG USERNAME=dev
ARG USER_UID=1000
RUN echo 'LANG=en_GB.UTF-8' > /etc/locale.conf \
  && ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime \
  && useradd --uid "${USER_UID}" --create-home --shell /usr/bin/fish "${USERNAME}" \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
  && chmod 0440 "/etc/sudoers.d/${USERNAME}"

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint

# Rebuild final image from scratch to avoid carrying over unnecessary layers
FROM scratch
COPY --from=build / /

LABEL org.opencontainers.image.description="Base container image for my development environment" \
  org.opencontainers.image.authors="Christian Sutter" \
  org.opencontainers.image.source="https://github.com/csutter/machines"

ARG USERNAME=dev
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV LANG=en_GB.UTF-8 CONTAINER=true

ENTRYPOINT ["/usr/local/bin/entrypoint"]
CMD ["sleep", "infinity"]
