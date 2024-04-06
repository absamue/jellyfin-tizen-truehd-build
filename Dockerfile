FROM ubuntu:latest

# Install prerequisites
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install curl git expect -y && \
    useradd tizen && \
    mkdir /tizen && \
    chown tizen:tizen /tizen && \
    usermod -d /tizen tizen 

USER tizen
WORKDIR /tizen

#install nvm to provide node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install node

# install tizen, and create a security profile to sign the package build
#RUN curl -o tizen-installer "https://usa.sdk-dl.tizen.org/web-cli_Tizen_Studio_5.6_usa_ubuntu-64.bin" && \
RUN curl -o tizen-installer "https://download.tizen.org/sdk/Installer/tizen-studio_4.5.1/web-cli_Tizen_Studio_4.5.1_ubuntu-64.bin" && \
    chmod +x tizen-installer && \
    ./tizen-installer --accept-license "/tizen/tizen-studio" && \
    /tizen/tizen-studio/tools/ide/bin/tizen certificate -a Jellyfin -p 1234 -c NZ -s Aukland -ct Aukland -o Tizen -n Jellyfin -e jellyfin@example.org -f tizencert && \
    /tizen/tizen-studio/tools/ide/bin/tizen security-profiles add -n Jellyfin -a "/tizen/tizen-studio-data/keystore/author/tizencert.p12" -p 1234 && \
    /tizen/tizen-studio/tools/ide/bin/tizen cli-config "profiles.path=/tizen/tizen-studio-data/profile/profiles.xml" && \
    chmod 755 "/tizen/tizen-studio-data/profile/profiles.xml" && \
    sed -i "s|/tizen/tizen-studio-data/keystore/author/tizencert.pwd|1234|g" /tizen/tizen-studio-data/profile/profiles.xml && \
    sed -i "s|/tizen/tizen-studio-data/tools/certificate-generator/certificates/distributor/tizen-distributor-signer.pwd|tizenpkcs12passfordsigner|g" /tizen/tizen-studio-data/profile/profiles.xml && \
    sed -i 's|password=""|password="tizenpkcs12passfordsigner"|g' /tizen/tizen-studio-data/profile/profiles.xml

# jellyfin web/tizen setup
# see jellyfin-tizen repo 
RUN git clone https://github.com/jellyfin/jellyfin-tizen.git && \
    git clone -b release-10.8.z https://github.com/jellyfin/jellyfin-web.git && \
    cd /tizen/jellyfin-web && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    SKIP_PREPARE=1 npm ci --no-audit && \
    USE_SYSTEM_FONTS=1 npm run build:production && \
    cd /tizen/jellyfin-tizen && \
    sed -i 's/enableSsaRender: true/enableSsaRender: true, supportsTrueHd: true/g' tizen.js && \
    JELLYFIN_WEB_DIR=../jellyfin-web/dist npm ci --no-audit && \
    /tizen/tizen-studio/tools/ide/bin/tizen build-web -e ".*" -e gulpfile.js -e README.md -e "node_modules/*" -e "package*.json" -e "yarn.lock"

# use expect to fill out the interactive prompts when building the package
COPY package.exp /tizen/package.exp

RUN expect /tizen/package.exp
