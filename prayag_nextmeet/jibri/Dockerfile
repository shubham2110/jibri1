ARG JITSI_REPO=jitsi
FROM ${JITSI_REPO}/base-java

#ARG CHROME_RELEASE=latest
#ARG CHROMEDRIVER_MAJOR_RELEASE=latest
ARG CHROME_RELEASE=78.0.3904.97
ARG CHROMEDRIVER_MAJOR_RELEASE=78

ENV RCLONE_VER=1.52.3 \
    BUILD_DATE=20202408T131603 \
    ARCH=amd64 \
    SUBCMD="" \
    CONFIG="--config /config/rclone/rclone.conf" \
    PARAMS=""

LABEL build_version="Version:- ${RCLONE_VER} Build-date:- ${BUILD_DATE}"

LABEL Prayag Singh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y jibri libgl1-mesa-dri unzip wget rsync stunnel4 \
        && apt-cleanup

RUN \
        [ "${CHROME_RELEASE}" = "latest" ] \
        && curl -4s https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
        && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
        && apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y google-chrome-stable \
        && apt-cleanup \
        || true

RUN \
        [ "${CHROME_RELEASE}" != "latest" ] \
        && curl -4so "/tmp/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" "http://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" \
        && apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y "/tmp/google-chrome-stable_${CHROME_RELEASE}-1_amd64.deb" \
        && apt-cleanup \
        || true

RUN \
        [ "${CHROMEDRIVER_MAJOR_RELEASE}" = "latest" ] \
        && CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE)" \
        || CHROMEDRIVER_RELEASE="$(curl -4Ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROMEDRIVER_MAJOR_RELEASE})" \
        && curl -4Ls "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_RELEASE}/chromedriver_linux64.zip" \
        | zcat >> /usr/bin/chromedriver \
        && chmod +x /usr/bin/chromedriver \
        && chromedriver --version

RUN \
        apt-dpkg-wrap apt-get update \
        && apt-dpkg-wrap apt-get install -y jitsi-upload-integrations jq \
        && apt-cleanup

RUN curl -O https://downloads.rclone.org/v${RCLONE_VER}/rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    unzip rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    cd rclone-*-linux-${ARCH} && \
    cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    cd ../ && \
    rm -f rclone-v${RCLONE_VER}-linux-${ARCH}.zip && \
    rm -r rclone-*-linux-${ARCH}

RUN mkdir -p /home/jibri/.config/rclone/ && \
    chown -R jibri:jibri /home/jibri/.config/rclone

COPY rootfs/ /

COPY ./jibri.jar /opt/jitsi/jibri/jibri.jar

RUN chmod 777 -R /home/

RUN mkdir -p /etc/stunnel

COPY stunnel.conf /etc/stunnel/stunnel.conf

RUN sed -i -e 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

#RUN echo "export PATH=/opt/util/:$PATH" >> /home/jibri/.bashrc

COPY startstunnel /usr/bin/startstunnel
RUN chmod +x /usr/bin/startstunnel

RUN mkdir -p /opt/util/
COPY ffmpeg /opt/util/ffmpeg
COPY ffmpeg2 /opt/util/ffmpeg2

RUN mv /usr/bin/ffmpeg /usr/bin/ffmpeg3
RUN ln -s /opt/util/ffmpeg /usr/bin/ffmpeg
RUN ln -s /opt/util/ffmpeg2 /usr/bin/ffmpeg2

RUN chmod +x /usr/bin/ffmpeg
RUN chmod +x /usr/bin/ffmpeg2

VOLUME /config


