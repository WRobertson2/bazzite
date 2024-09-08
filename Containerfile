ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG BASE_IMAGE_FLAVOR="${BASE_IMAGE_FLAVOR:-main}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.10.4-201.fsync.fc40.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$BASE_IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG JUPITER_FIRMWARE_VERSION="${JUPITER_FIRMWARE_VERSION:-jupiter-20240813.1}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

FROM ghcr.io/ublue-os/${KERNEL_FLAVOR}-kernel:${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS fsync
FROM ghcr.io/ublue-os/akmods:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-extra:${KERNEL_FLAVOR}-${FEDORA_MAJOR_VERSION}-${KERNEL_VERSION} AS akmods-extra

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS bazzite

ARG IMAGE_NAME="${IMAGE_NAME:-bazzite}"
ARG IMAGE_VENDOR="${IMAGE_VENDOR:-ublue-os}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG KERNEL_FLAVOR="${KERNEL_FLAVOR:-fsync}"
ARG KERNEL_VERSION="${KERNEL_VERSION:-6.10.4-201.fsync.fc40.x86_64}"
ARG IMAGE_BRANCH="${IMAGE_BRANCH:-main}"
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-kinoite}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-40}"
ARG JUPITER_FIRMWARE_VERSION="${JUPITER_FIRMWARE_VERSION:-jupiter-20240813.1}"
ARG SHA_HEAD_SHORT="${SHA_HEAD_SHORT}"
ARG VERSION_TAG="${VERSION_TAG}"
ARG VERSION_PRETTY="${VERSION_PRETTY}"

COPY system_files/desktop/shared system_files/desktop/${BASE_IMAGE_NAME} /

# Update packages that commonly cause build issues
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        vulkan-loader \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        alsa-lib \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gnutls \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        glib2 \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        nspr \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        nss-softokn \
        nss-softokn-freebl \
        nss-util \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        atk \
        at-spi2-atk \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libaom \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        gstreamer1 \
        gstreamer1-plugins-base \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libdecor \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libtirpc \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libuuid \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libblkid \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libmount \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        cups-libs \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libinput \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libopenmpt \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        llvm-libs \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        zlib-ng-compat \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        pciutils-libs \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libdrm \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libX11 \
        libX11-common \
        libX11-xcb \
        || true && \
    rpm-ostree override replace \
    --experimental \
    --from repo=updates \
        libv4l \
        || true && \
    rpm-ostree override remove \
        glibc32 \
        || true && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Setup Copr repos
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    curl -Lo /usr/bin/copr https://raw.githubusercontent.com/ublue-os/COPR-command/main/copr && \
    chmod +x /usr/bin/copr && \
    curl -Lo /etc/yum.repos.d/_copr_kylegospo-bazzite.repo https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-bazzite-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-bazzite-multilib-fedora-"${FEDORA_MAJOR_VERSION}".repo?arch=x86_64 && \
    curl -Lo /etc/yum.repos.d/_copr_ublue-os-staging.repo https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo?arch=x86_64 && \
    curl -Lo /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-LatencyFleX-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-wallpaper-engine-kde-plugin-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_ycollet-audinux.repo https://copr.fedorainfracloud.org/coprs/ycollet/audinux/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ycollet-audinux-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-rom-properties-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_hhd-dev-hhd.repo https://copr.fedorainfracloud.org/coprs/hhd-dev/hhd/repo/fedora-"${FEDORA_MAJOR_VERSION}"/hhd-dev-hhd-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_hikariknight-looking-glass-kvmfr.repo https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/hikariknight-looking-glass-kvmfr-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_matte-schwartz-sunshine.repo https://copr.fedorainfracloud.org/coprs/matte-schwartz/sunshine/repo/fedora-"${FEDORA_MAJOR_VERSION}"/matte-schwartz-sunshine-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_rok-cdemu.repo https://copr.fedorainfracloud.org/coprs/rok/cdemu/repo/fedora-"${FEDORA_MAJOR_VERSION}"/rok-cdemu-fedora-"${FEDORA_MAJOR_VERSION}".rep && \
    curl -Lo /etc/yum.repos.d/_copr_rodoma92-kde-cdemu-manager.repo https://copr.fedorainfracloud.org/coprs/rodoma92/kde-cdemu-manager/repo/fedora-"${FEDORA_MAJOR_VERSION}"/rodoma92-kde-cdemu-manager-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    curl -Lo /etc/yum.repos.d/_copr_rodoma92-rmlint.repo https://copr.fedorainfracloud.org/coprs/rodoma92/rmlint/repo/fedora-"${FEDORA_MAJOR_VERSION}"/rodoma92-rmlint-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    ostree container commit

# Install kernel-fsync
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=fsync,src=/tmp/rpms,dst=/tmp/fsync-rpms \
    rpm-ostree cliwrap install-to-root / && \
    if [[ "${KERNEL_FLAVOR}" =~ "fsync" ]]; then \
        echo "Will install ${KERNEL_FLAVOR} kernel" && \
        rpm-ostree override replace \
        --experimental \
            /tmp/fsync-rpms/kernel-[0-9]*.rpm \
            /tmp/fsync-rpms/kernel-core-*.rpm \
            /tmp/fsync-rpms/kernel-modules-*.rpm \
            /tmp/fsync-rpms/kernel-uki-virt-*.rpm \
    ; else \
        echo "will use kernel from ${KERNEL_FLAVOR} images" \
    ; fi && \
    rpm-ostree install \
        scx-scheds && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Setup firmware
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    mkdir -p /tmp/linux-firmware-neptune && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-cali.bin && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-cali.wmfw https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-cali.wmfw && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-prot.bin && \
    curl -Lo /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-prot.wmfw https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/cs35l41-dsp1-spk-prot.wmfw && \
    xz --check=crc32 /tmp/linux-firmware-neptune/cs35l41-dsp1-spk-{cali.bin,cali.wmfw,prot.bin,prot.wmfw} && \
    mv -vf /tmp/linux-firmware-neptune/* /usr/lib/firmware/cirrus/ && \
    rm -rf /tmp/linux-firmware-neptune && \
    mkdir -p /tmp/linux-firmware-galileo && \
    curl https://gitlab.com/evlaV/linux-firmware-neptune/-/archive/"${JUPITER_FIRMWARE_VERSION}"/linux-firmware-neptune-"${JUPITER_FIRMWARE_VERSION}".tar.gz?path=ath11k/QCA206X -o /tmp/linux-firmware-galileo/ath11k.tar.gz && \
    tar --strip-components 1 --no-same-owner --no-same-permissions --no-overwrite-dir -xvf /tmp/linux-firmware-galileo/ath11k.tar.gz -C /tmp/linux-firmware-galileo && \
    xz --check=crc32 /tmp/linux-firmware-galileo/ath11k/QCA206X/hw2.1/* && \
    mv -vf /tmp/linux-firmware-galileo/ath11k/QCA206X /usr/lib/firmware/ath11k/QCA206X && \
    rm -rf /tmp/linux-firmware-galileo/ath11k && \
    rm -rf /tmp/linux-firmware-galileo/ath11k.tar.gz && \
    ln -s QCA206X /usr/lib/firmware/ath11k/QCA2066 && \
    curl -Lo /tmp/linux-firmware-galileo/hpbtfw21.tlv https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpbtfw21.tlv && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21.309 https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21.309 && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21.bin && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21g.309 https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21g.309 && \
    curl -Lo /tmp/linux-firmware-galileo/hpnv21g.bin https://gitlab.com/evlaV/linux-firmware-neptune/-/raw/"${JUPITER_FIRMWARE_VERSION}"/qca/hpnv21g.bin && \
    xz --check=crc32 /tmp/linux-firmware-galileo/* && \
    mv -vf /tmp/linux-firmware-galileo/* /usr/lib/firmware/qca/ && \
    rm -rf /tmp/linux-firmware-galileo && \
    rm -rf /usr/share/alsa/ucm2/conf.d/acp5x/Valve-Jupiter-1.conf && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Add ublue packages, add needed negativo17 repo and then immediately disable due to incompatibility with RPMFusion
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
    --mount=type=bind,from=akmods-extra,src=/rpms,dst=/tmp/akmods-extra-rpms \
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    ## Not working with mainline kernels for some weird rpm-ostree conflict
    rpm-ostree install \
            /tmp/akmods-rpms/kmods/*v4l2loopback*.rpm \
            /tmp/akmods-rpms/kmods/*framework-laptop*.rpm \
            /tmp/akmods-extra-rpms/kmods/*zenergy*.rpm \
            /tmp/akmods-extra-rpms/kmods/*ryzen-smu*.rpm && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo && \
    rpm-ostree override replace \
        --experimental \
        --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
            fwupd \
            fwupd-plugin-flashrom \
            fwupd-plugin-modem-manager \
            fwupd-plugin-uefi-capsule-data && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install custom Sobremesa builds
RUN rpm-ostree override replace \
    --experimental \
    --from repo=sobremesa \
    mesa-filesystem \
    mesa-libxatracker \
    mesa-libglapi \
    mesa-dri-drivers \
    mesa-libgbm \
    mesa-libEGL \
    mesa-vulkan-drivers \
    mesa-libGL && \
    ostree container commit

# Install Valve's patched Mesa, Pipewire, Bluez, and Xwayland
# Install patched switcheroo control with proper discrete GPU support

# RUN rpm-ostree override remove \
#         mesa-va-drivers-freeworld && \
RUN    rpm-ostree override replace \
    --experimental \
    --from repo=copr:copr.fedorainfracloud.org:kylegospo:bazzite-multilib \
        ## Use Sobremesa for these
        # mesa-filesystem \
        # mesa-libxatracker \
        # mesa-libglapi \
        # mesa-dri-drivers \
        # mesa-libgbm \
        # mesa-libEGL \
        # mesa-vulkan-drivers \
        # mesa-libGL \
        pipewire \
        pipewire-alsa \
        pipewire-gstreamer \
        pipewire-jack-audio-connection-kit \
        pipewire-jack-audio-connection-kit-libs \
        pipewire-libs \
        pipewire-pulseaudio \
        pipewire-utils \
        pipewire-plugin-libcamera \
        bluez \
        bluez-obexd \
        bluez-cups \
        bluez-libs \
        xorg-x11-server-Xwayland && \
    rpm-ostree install \
        # mesa-va-drivers-freeworld \
        # mesa-vdpau-drivers-freeworld.x86_64 \
        libaacs \
        libbdplus \
        libbluray && \
    ostree container commit

# Remove unneeded packages
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    rpm-ostree override remove \
        ublue-os-update-services \
        firefox \
        firefox-langpacks && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install new packages
RUN rpm-ostree install \
        age \
        minisign \
        yubico-piv-tool \
        tor \
        bcachefs-tools \
        pcsc-lite-devel \
        pcsc-lite-ccid \
        opensc \
        openssl-pkcs11 \
        python3-pip \
        libadwaita \
        duperemove \
        sqlite \
        xwininfo \
        xrandr \
        compsize \
        ryzenadj \
        input-remapper \
        i2c-tools \
        udica \
        ladspa-caps-plugins \
        ladspa-noise-suppression-for-voice \
        python3-icoextract \
        tailscale \
        virt-manager \
        btop \
        lshw \
        wmctrl \
        libcec \
        yad \
        f3 \
        pulseaudio-utils \
        unrar \
        lzip \
        libxcrypt-compat \
        vulkan-tools \
        # glibc.i686 \
        fastfetch \
        glow \
        gum \
        vim \
        cockpit-networkmanager \
        cockpit-podman \
        cockpit-selinux \
        cockpit-system \
        cockpit-navigator \
        cockpit-storaged \
        topgrade \
        ydotool && \
        zstd && \
    pip install --prefix=/usr topgrade && \
    rpm-ostree install \
        ublue-update && \
    mkdir -p /etc/xdg/autostart && \
    sed -i '1s/^/[include]\npaths = ["\/etc\/ublue-os\/topgrade.toml"]\n\n/' /usr/share/ublue-update/topgrade-user.toml && \
    sed -i 's/min_battery_percent.*/min_battery_percent = 20.0/' /etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_cpu_load_percent.*/max_cpu_load_percent = 100.0/' /etc/ublue-update/ublue-update.toml && \
    sed -i 's/max_mem_percent.*/max_mem_percent = 90.0/' /etc/ublue-update/ublue-update.toml && \
    sed -i 's/dbus_notify.*/dbus_notify = false/' /etc/ublue-update/ublue-update.toml && \
    curl -Lo /usr/bin/installcab https://raw.githubusercontent.com/KyleGospo/steam-proton-mf-wmv/master/installcab.py && \
    chmod +x /usr/bin/installcab && \
    curl -Lo /usr/bin/install-mf-wmv https://github.com/KyleGospo/steam-proton-mf-wmv/blob/master/install-mf-wmv.sh && \
    chmod +x /usr/bin/install-mf-wmv && \
    curl -Lo /usr/share/thumbnailers/exe-thumbnailer.thumbnailer https://raw.githubusercontent.com/jlu5/icoextract/master/exe-thumbnailer.thumbnailer && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

RUN rpm-ostree install keybase || true && ostree container commit

# Configure KDE & GNOME
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    if grep -q "kinoite" <<< "${BASE_IMAGE_NAME}"; then \
        rpm-ostree install \
            qt \
            krdp && \
        rpm-ostree override remove \
            plasma-welcome && \
        rpm-ostree override replace \
        --experimental \
        --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
            kf6-kio-doc \
            kf6-kio-widgets-libs \
            kf6-kio-core-libs \
            kf6-kio-widgets \
            kf6-kio-file-widgets \
            kf6-kio-core \
            kf6-kio-gui && \
        rpm-ostree install \
            wallpaper-engine-kde-plugin \
            kdeconnectd \
            kdeplasma-addons \
            rom-properties-kf6 \
            ptyxis && \
        git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git --depth 1 --branch main /tmp/wallpaper-engine-kde-plugin && \
        kpackagetool6 --type=Plasma/Wallpaper --global --install /tmp/wallpaper-engine-kde-plugin/plugin && \
        rm -rf /tmp/wallpaper-engine-kde-plugin && \
        sed -i 's@\[Desktop Action new-window\]@\[Desktop Action new-window\]\nX-KDE-Shortcuts=Ctrl+Alt+T@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i '/^Comment/d' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i 's@Exec=ptyxis@Exec=kde-ptyxis@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        sed -i 's@Keywords=@Keywords=konsole;console;@g' /usr/share/applications/org.gnome.Ptyxis.desktop && \
        cp /usr/share/applications/org.gnome.Ptyxis.desktop /usr/share/kglobalaccel/org.gnome.Ptyxis.desktop && \
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.konsole.desktop && \
        rm -f /usr/share/kglobalaccel/org.kde.konsole.desktop && \
        setcap 'cap_net_raw+ep' /usr/libexec/ksysguard/ksgrd_network_helper \
    ; else \
        rpm-ostree override replace \
        --experimental \
        --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
            mutter \
            mutter-common \
            gnome-shell && \
        rpm-ostree install \
            ptyxis \
            nautilus-open-any-terminal \
            nautilus-gsconnect \
            steamdeck-backgrounds \
            gnome-randr-rust \
            gnome-shell-extension-user-theme \
            gnome-shell-extension-gsconnect \
            gnome-shell-extension-compiz-windows-effect \
            gnome-shell-extension-compiz-alike-magic-lamp-effect \
            gnome-shell-extension-just-perfection \
            gnome-shell-extension-blur-my-shell \
            gnome-shell-extension-hanabi \
            gnome-shell-extension-gamerzilla \
            gnome-shell-extension-bazzite-menu \
            gnome-shell-extension-hotedge \
            gnome-shell-extension-caffeine \
            rom-properties-gtk3 \
            ibus-mozc \
            openssh-askpass && \
        rpm-ostree override remove \
            gnome-software-rpm-ostree \
            gnome-classic-session \
            gnome-classic-session-xsession \
            gnome-tour \
            gnome-extensions-app \
            gnome-terminal \
            gnome-terminal-nautilus \
            gnome-initial-setup \
            gnome-shell-extension-background-logo \
            gnome-shell-extension-apps-menu && \
        mkdir -p /tmp/tilingshell && \
        curl -s https://api.github.com/repos/domferr/tilingshell/releases/latest | \
            jq -r '.assets | sort_by(.created_at) | .[] | select (.name|test("^tilingshell@.*zip$")) | .browser_download_url' | \
            wget -qi - -O /tmp/tilingshell/tilingshell@ferrarodomenico.com.zip && \
        unzip /tmp/tilingshell/tilingshell@ferrarodomenico.com.zip -d /usr/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com && \
        rm -rf /tmp/tilingshell && \
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.gnome.SystemMonitor.desktop && \
        systemctl enable dconf-update.service \
    ; fi && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Install Gamescope, ROCM, and Waydroid on non-Nvidia images
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    rpm-ostree install \
        ## More broken dependencies
        # gamescope.x86_64 \
        # gamescope-libs.i686 \
        # gamescope-shaders \
        # gamescope-legacy \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo \
        waydroid \
        cage \
        wlr-randr && \
    sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Bash Prexec
RUN --mount=type=cache,dst=/var/cache/rpm-ostree \
    curl -Lo /usr/share/bash-prexec https://raw.githubusercontent.com/ublue-os/bash-preexec/master/bash-preexec.sh &&\
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Cleanup & Finalize
COPY system_files/overrides /
RUN rm -f /etc/profile.d/toolbox.sh && \
    mkdir -p /usr/etc/skel/.config/autostart/ && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop && \
    sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/yad-icon-browser.desktop && \
    sed -i 's/#UserspaceHID.*/UserspaceHID=true/' /etc/bluetooth/input.conf && \
    sed -i "s/^SCX_SCHEDULER=.*/SCX_SCHEDULER=scx_lavd/" /etc/default/scx && \
    rm -f /usr/share/vulkan/icd.d/lvp_icd.*.json && \
    mkdir -p "/etc/profile.d/" && \
    mkdir -p "/usr/etc/xdg/autostart" && \
    cp "/usr/share/ublue-os/firstboot/yafti.yml" "/etc/yafti.yml" && \
    echo "import \"/usr/share/ublue-os/just/80-bazzite.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/81-bazzite-fixes.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-apps.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-cdemu.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-sunshine.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-rmlint.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/82-bazzite-waydroid.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/83-bazzite-audio.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/84-bazzite-virt.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/85-bazzite-image.just\"" >> /usr/share/ublue-os/justfile && \
    echo "import \"/usr/share/ublue-os/just/90-bazzite-de.just\"" >> /usr/share/ublue-os/justfile && \
    sed -i 's/stage/none/g' /etc/rpm-ostreed.conf && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-bazzite-multilib.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-latencyflex.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-wallpaper-engine-kde-plugin.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ycollet-audinux.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_hhd-dev-hhd.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_hikariknight-looking-glass-kvmfr.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/charm.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo && \
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-updates-testing.repo && \
    mkdir -p /usr/etc/flatpak/remotes.d && \
    curl -Lo /usr/etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo && \
    systemctl enable btrfs-dedup@var-home.timer && \
    systemctl enable input-remapper.service && \
    systemctl unmask bazzite-flatpak-manager.service && \
    systemctl enable bazzite-flatpak-manager.service && \
    systemctl disable rpm-ostreed-automatic.timer && \
    ## I do updates manually
    # systemctl enable ublue-update.timer && \
    systemctl enable incus-workaround.service && \
    systemctl enable bazzite-hardware-setup.service && \
    systemctl enable tailscaled.service && \
    systemctl enable dev-hugepages1G.mount && \
    systemctl --global enable bazzite-user-setup.service && \
    systemctl --global enable podman.socket && \
    systemctl --global enable systemd-tmpfiles-setup.service && \
    systemctl disable waydroid-container.service && \
    curl -Lo /etc/dxvk-example.conf https://raw.githubusercontent.com/doitsujin/dxvk/master/dxvk.conf && \
    curl -Lo /usr/bin/waydroid-choose-gpu https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh && \
    chmod +x /usr/bin/waydroid-choose-gpu && \
    curl -Lo /usr/lib/sysctl.d/99-bore-scheduler.conf https://github.com/CachyOS/CachyOS-Settings/raw/master/usr/lib/sysctl.d/99-bore-scheduler.conf && \
    /usr/libexec/containerbuild/image-info && \
    mkdir -p /var/tmp && chmod 1777 /var/tmp && \
    /usr/libexec/containerbuild/build-initramfs && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit
