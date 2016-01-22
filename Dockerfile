FROM xrdp-syncthing

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    git \
                    curl openssl ca-certificates \
                    libgtk2.0-0 \
                    libxtst6 \
                    libnss3 \
                    libgconf-2-4 \
                    libasound2 \
                    fakeroot \
                    gconf2 \
                    gconf-service \
                    libcap2 \
                    libnotify4 \
                    libxtst6 \
                    libnss3 \
                    gvfs-bin \
                    xdg-utils \
                    build-essential \
                    ack-grep \
                    exuberant-ctags \
                    g++ \
                    openjdk-7-jdk maven \
                    vim-gtk \
                    libpq-dev \
                    postgresql-client \
                    libx11-xcb-dev \
                    libxcb1-dev \
                    uncrustify \
                    wmname xcompmgr \
                    software-properties-common \
                    xclip tmux tree jq &&\
                    apt-get remove -y vim-tiny &&\
                    apt-get clean -y

ENV JAVA8_UPD 66
ENV JAVA8_BUILD 17
ENV JAVA_HOME /opt/java

RUN     cd /tmp \
        && wget -qO jdk8.tar.gz \
         --header "Cookie: oraclelicense=accept-securebackup-cookie" \
         http://download.oracle.com/otn-pub/java/jdk/8u${JAVA8_UPD}-b${JAVA8_BUILD}/jdk-8u${JAVA8_UPD}-linux-x64.tar.gz \
        && tar xzf jdk8.tar.gz -C /opt \
        && mv /opt/jdk* /opt/java \
        && rm /tmp/jdk8.tar.gz \
        && update-alternatives --install /usr/bin/java java /opt/java/bin/java 100 \
        && update-alternatives --install /usr/bin/javac javac /opt/java/bin/javac 100 \
        && update-alternatives --install /usr/bin/jar jar /opt/java/bin/jar 100 \
        && update-alternatives --set java /opt/java/bin/java \
        && update-alternatives --set jar /opt/java/bin/jar


ENV JRUBY_VERSION 1.7.21
ENV JRUBY_SHA1 4955b69a913b22f96bd599eff2a133d8d1ed42c6 && echo "$JRUBY_SHA1 /tmp/jruby.tar.gz" | sha1sum -c -

RUN wget https://s3.amazonaws.com/jruby.org/downloads/${JRUBY_VERSION}/jruby-bin-${JRUBY_VERSION}.tar.gz \
       -O /tmp/jruby.tar.gz &&\ 
      mkdir /opt/jruby \
      && tar -zx --strip-components=1 -f /tmp/jruby.tar.gz -C /opt/jruby \
      && rm /tmp/jruby.tar.gz \
      && update-alternatives --install /usr/local/bin/ruby ruby /opt/jruby/bin/jruby 1

ENV PATH /opt/jruby/bin:$PATH

RUN echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc

RUN gem install bundler

# https://github.com/GoogleCloudPlatform/golang-docker/blob/master/base/Dockerfile
# https://golang.org/dl/
ENV GOLANG_VERSION 1.5.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 43afe0c5017e502630b1aea4d44b8a7f059bf60d7f29dfd58db454d4e4e0ae53

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz


ENV PATH /go/bin:/usr/local/go/bin:$PATH
ENV GOPATH /go:/go/src/app/_gopath

RUN mkdir -p /go/src/app /go/bin && chmod -R 777 /go

RUN ln -s /go/src/app /app
                                                             
ENV ATOM_VERSION v1.4.0
RUN curl -L https://github.com/atom/atom/releases/download/${ATOM_VERSION}/atom-amd64.deb > /tmp/atom.deb && \
    dpkg -i /tmp/atom.deb && \                                                                                
    rm -f /tmp/atom.deb
                                                                                                               
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

#https://nodejs.org/en/
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 5.4.1

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc


RUN  apt-get build-dep -y erlang && \
     apt-get install -y libwxgtk2.8-dev  &&\
     cd / && curl -LO http://www.erlang.org/download/otp_src_18.1.tar.gz &&\
     tar xvf otp_src_18.1.tar.gz &&\
     cd otp_src_18.1 && ./configure && make install && \
     cd / && rm -r -f opt_src_18.1 &&\
     apt-get clean -y

ENV HOME_BRC /home/dockerx/.bashrc
RUN echo "export GOROOT=/usr/local/go" >> $HOME_BRC &&\
    echo "export GOPATH=/home/dockerx/go" >> $HOME_BRC &&\
    echo "export PATH=\$PATH:\$GOROOT/bin" >> $HOME_BRC &&\
    echo "export JAVA_HOME=/opt/java" >> $HOME_BRC &&\
    echo "java -version " >> $HOME_BRC &&\
    echo "go version" >> $HOME_BRC &&\
    echo "node --version" >> $HOME_BRC &&\
    echo "erl -noshell -eval 'io:fwrite(\"~s\\n\", [erlang:system_info(otp_release)]).' -s erlang halt" >> $HOME_BRC


ADD cclip /usr/local/bin/
ADD get_clip /usr/local/bin
ADD set_clip /usr/local/bin

EXPOSE 3389

ENV ROOT_BRC /root/.bashrc
RUN echo "export GOROOT=/usr/local/go" >> $ROOT_BRC &&\
    echo "export GOPATH=/home/dockerx/go" >> $ROOT_BRC &&\
    echo "export PATH=\$PATH:\$GOROOT/bin" >> $HOME_BRC &&\
    echo "java -version " >> $ROOT_BRC &&\
    echo "go version" >> $ROOT_BRC &&\
    echo "node --version" >> $ROOT_BRC &&\
    echo "erl -noshell -eval 'io:fwrite(\"~s\\n\", [erlang:system_info(otp_release)]).' -s erlang halt" >> $ROOT_BRC &&\
    echo "[ -z "$DISPLAY" ] && export TERM=linux" >> $ROOT_BRC

RUN npm install -g babel-cli gulp-cli

ADD ratpoisonrc /home/dockerx/.ratpoisonrc

#ADD firefox_override.ini /usr/lib/firefox/override.ini
#RUN sed -i -e 's/EnableProfileMigrator=1/EnableProfileMigrator=0/g' /usr/lib/firefox/application.ini

#RUN dpkg --add-architecture i386 &&\
#    apt-get dist-upgrade -y &&\
#    add-apt-repository -y ppa:ubuntu-wine/ppa &&\ 
#    apt-get update && apt-get install -y wine1.7 &&\
#    apt-get clean

#https://dl.winehq.org/wine/source/1.8/, /1.9/
RUN export WINE_BRANCH=1.9 &&\
    export WINE_VER=1.9.1 &&\
    dpkg --add-architecture i386 &&\
    apt-get update -y &&\
    apt-get install -y bison flex build-essential gcc-multilib libx11-dev:i386 libfreetype6-dev:i386 libxcursor-dev:i386 libxi-dev:i386 libxshmfence-dev:i386 libxxf86vm-dev:i386 libxrandr-dev:i386 libxinerama-dev:i386 libxcomposite-dev:i386 libglu1-mesa-dev:i386 libosmesa6-dev:i386 libpcap0.8-dev:i386 libdbus-1-dev:i386 libncurses5-dev:i386 libsane-dev:i386 libv4l-dev:i386 libgphoto2-dev:i386 liblcms2-dev:i386 gstreamer0.10-plugins-base:i386 libcapi20-dev:i386 libcups2-dev:i386 libfontconfig1-dev:i386 libgsm1-dev:i386 libtiff5-dev:i386 libmpg123-dev:i386 libopenal-dev:i386 libldap2-dev:i386 libgnutls-dev:i386 libjpeg-dev:i386 &&\
    cd / && curl -LO https://dl.winehq.org/wine/source/${WINE_BRANCH}/wine-${WINE_VER}.tar.bz2 &&\
    tar xvf  wine-${WINE_VER}.tar.bz2 && cd  wine-${WINE_VER} &&\
    ./configure &&\
    make && make install &&\
    cd / && rm -rf /wine-${WINE_VER} &&\
    apt-get purge -y libx11-dev:i386 libfreetype6-dev:i386 libxcursor-dev:i386 libxi-dev:i386 libxshmfence-dev:i386 libxxf86vm-dev:i386 libxrandr-dev:i386 libxinerama-dev:i386 libxcomposite-dev:i386 libglu1-mesa-dev:i386 libosmesa6-dev:i386 libpcap0.8-dev:i386 libdbus-1-dev:i386 libncurses5-dev:i386 libsane-dev:i386 libv4l-dev:i386 libgphoto2-dev:i386 liblcms2-dev:i386 gstreamer0.10-plugins-base:i386 libcapi20-dev:i386 libcups2-dev:i386 libfontconfig1-dev:i386 libgsm1-dev:i386 libtiff5-dev:i386 libmpg123-dev:i386 libopenal-dev:i386 libldap2-dev:i386 libgnutls-dev:i386 libjpeg-dev:i386 &&\
    apt-get clean -y


RUN echo "[ -f /syncthing/data/configs/\`hostname\`/bash_config.sh ] && source /syncthing/data/configs/\`hostname\`/bash_config.sh " >> $HOME_BRC &&\
    echo "[ \$SYNCTHING_API_KEY ] &&  echo -n 'syncthing version:' && curl --silent -X GET -H \"X-API-Key: \$SYNCTHING_API_KEY\" http://localhost:8384/rest/system/version | jq .version" >> $HOME_BRC

# https://github.com/elixir-lang/elixir/releases/
ENV ELIXIR_VER 1.2.1
WORKDIR /elixir
RUN curl -LO https://github.com/elixir-lang/elixir/releases/download/v$ELIXIR_VER/Precompiled.zip &&\
    unzip Precompiled.zip && \
    rm -f Precompiled.zip && \
    ln -s /elixir/bin/elixirc /usr/local/bin/elixirc && \
    ln -s /elixir/bin/elixir /usr/local/bin/elixir && \
    ln -s /elixir/bin/mix /usr/local/bin/mix && \
    ln -s /elixir/bin/iex /usr/local/bin/iex

# Install local Elixir hex and rebar
RUN /usr/local/bin/mix local.hex --force && \
    /usr/local/bin/mix local.rebar --force

WORKDIR /

RUN apt-get install -y devscripts dh-make dpkg-dev checkinstall apt-transport-https


RUN echo "deb http://dl.bintray.com/jhermann/deb /" \
       > /etc/apt/sources.list.d/bintray-jhermann.list \
       && apt-get update \
       && apt-get install -y -o "APT::Get::AllowUnauthenticated=yes" dput-webdav
 
ADD start.sh /
RUN echo "deb http://dl.bintray.com/hernad/deb /" \
       > /etc/apt/sources.list.d/bintray-hernad.list \
       && apt-get update \
       && apt-get install -y -o "APT::Get::AllowUnauthenticated=yes" harbour

# postgresql repository
RUN  echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/postgresql.list &&\
     wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add  - &&\
     apt-get update -y &&\
     apt-get install -y postgresql pgadmin3

# harbour dependencies 
RUN apt-get install -y libmysqlclient-dev libpq-dev libx11-dev

# ag - silver search
RUN  apt-get install -y automake pkg-config libpcre3-dev zlib1g-dev liblzma-dev &&\
     mkdir -p /usr/src && cd /usr/src/ ; git clone https://github.com/ggreer/the_silver_searcher.git &&\
     cd the_silver_searcher && export LDFLAGS="-static" && ./build.sh &&\
     make install

# --- aws cli
RUN apt-get install -y python-virtualenv &&\
    cd /opt &&\
    virtualenv --python=/usr/bin/python aws &&\
    cd /opt/aws &&\
    . bin/activate && pip install --upgrade pip &&\
    pip install awscli


#http://download.qt.io/official_releases/qt/5.5/

ENV QT_VER=5.5 QT_VER_MINOR=1

RUN apt-get update -y &&\
    apt-get build-dep -y qt5-default &&\
    apt-get install -y libgl1-mesa-dev  &&\
    mkdir -p /usr/src && cd /usr/src && curl -LO \
    http://download.qt.io/official_releases/qt/${QT_VER}/${QT_VER}.${QT_VER_MINOR}/single/qt-everywhere-opensource-src-${QT_VER}.${QT_VER_MINOR}.tar.gz

RUN  cd /usr/src && tar -xf qt-everywhere-opensource-src-${QT_VER}.${QT_VER_MINOR}.tar.gz &&\
     cd qt-everywhere-opensource-src-${QT_VER}.${QT_VER_MINOR} &&\
     ./configure \
       -confirm-license -opensource \
       -nomake examples -nomake tests -no-compile-examples \
       -no-xcb \
       -prefix "/usr/local/Qt" &&\
     make -j4 all &&\
     make install &&\
     cd /usr/src && rm -r -f qt-everywhere-opensource-src-${QT_VER}.${QT_VER_MINOR}

RUN echo "===> Adding Ansible's PPA..."  && \
    echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee /etc/apt/sources.list.d/ansible.list           && \
    echo "deb-src http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/ansible.list    && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7BB9C367    && \
    DEBIAN_FRONTEND=noninteractive  apt-get update  && \
    \
    \
    echo "===> Installing Ansible..."  && \
    apt-get install -y ansible  && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    echo '[local]\nlocalhost\n' > /etc/ansible/hosts

# --- ansible
# RUN cd /opt &&\
#    virtualenv --python=/usr/bin/python ansible &&\
#    cd /opt/ansible &&\
#    . bin/activate && pip install --upgrade pip &&\
#    pip install ansible


# https://github.com/swiftdocker/docker-swift/blob/master/Dockerfile
ENV SWIFT_VERSION 2.2-SNAPSHOT-2016-01-06-a
ENV SWIFT_PLATFORM ubuntu14.04

RUN apt-get -y upgrade &&\
    apt-get -y install \
    cmake \
    ninja-build \
    clang-3.6 \
    uuid-dev \
    libicu-dev \
    icu-devtools \
    libbsd-dev \
    libedit-dev \
    libxml2-dev \
    libsqlite3-dev \
    swig \
    libpython-dev \
    libncurses5-dev \
    pkg-config &&\
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100 &&\
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100 &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Swift keys
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -

# Install Swift Ubuntu 14.04 Snapshot
RUN SWIFT_ARCHIVE_NAME=swift-$SWIFT_VERSION-$SWIFT_PLATFORM && \
    SWIFT_URL=https://swift.org/builds/$(echo "$SWIFT_PLATFORM" | tr -d .)/swift-$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz && \
    curl -LO $SWIFT_URL && \
    curl -LO $SWIFT_URL.sig && \
    gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig && \
    tar -xvzf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 && \
    rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/* &&\
    echo "swift --version" >> $HOME_BRC


# https://www.brightbox.com/docs/ruby/ubuntu/
RUN apt-get install  -y software-properties-common &&\
    apt-add-repository -y ppa:brightbox/ruby-ng &&\
    apt-get update -y &&\
    apt-get install -y  ruby2.3 ruby2.3-dev ruby-switch &&\
    ruby-switch --set ruby2.3 &&\
    echo "ruby --version" >> $HOME_BRC

# java
RUN apt-get install -y ant


RUN apt-get install -y cups-bsd

ADD https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks /usr/local/bin/
RUN chmod +x /usr/local/bin/winetricks

COPY .ctags /home/dockerx/.ctags
RUN apt-get install -y exuberant-ctags p7zip-full cabextract

CMD ["bash", "-c", "/etc/init.d/dbus start ; /etc/init.d/cups start; /start.sh ; /usr/bin/supervisord"]
