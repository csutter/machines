ARG FEDORA_VERSION=44
FROM quay.io/fedora/fedora:${FEDORA_VERSION}

ARG USERNAME=dev
ARG UID=1000

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# Restore documentation and translations removed by the base image; install packages
RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf \
  && echo '%_install_langs all' > /etc/rpm/macros.image-language-conf \
  && dnf -y upgrade \
  && dnf -y reinstall '*' \
  && dnf -y swap glibc-minimal-langpack glibc-all-langpacks \
  && dnf -y install --allowerasing \
  @c-development @development-tools \
  dbus-broker git gzip fish hostname info iproute iputils less man-db man-pages ncurses \
  pinfo podman procps-ng ripgrep shadow-utils sudo systemd tar tree unzip util-linux \
  vim-minimal which xz zip \
  && dnf clean all

# Set appropriate locale and timezone
RUN echo 'LANG=en_GB.UTF-8' > /etc/locale.conf \
  && ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

# Add unprivileged user with fixed UID (so home volumes stay valid across image rebuilds)
RUN useradd --uid ${UID} --create-home --shell /usr/bin/fish ${USERNAME} \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}

# Set up entrypoint script
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

# Switch to unprivileged user and set appropriate environment
USER ${USERNAME}
WORKDIR /home/${USERNAME}
ENV COLORTERM=truecolor
ENV CONTAINER=true
ENV HOME=/home/${USERNAME}
ENV TERM=xterm-256color
SHELL ["/usr/bin/fish", "-c"]
