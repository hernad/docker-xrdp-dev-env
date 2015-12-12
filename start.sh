#!/bin/bash

SYNCTHING_USER=dockerx

HOME_DIR=/home/$SYNCTHING_USER

WINE_TGZ=/syncthing/data/configs/${SYNCTHING_USER}_wine.tar.gz
if [ ! -d $HOME_DIR/.wine ] && [ -f $WINE_TGZ ] ; then
  cd $HOME_DIR
  tar xzf $WINE_TGZ
fi

FIREFOX_TGZ=/syncthing/data/configs/${SYNCTHING_USER}_firefox.tar.gz
if [ ! -d $HOME_DIR/.mozilla ] && [ -f $FIREFOX_TGZ ] ; then
  cd $HOME_DIR
  tar xzf $FIREFOX_TGZ
fi

ATOM_TGZ=/syncthing/data/configs/${SYNCTHING_USER}_atom.tar.gz
if [ ! -d $HOME_DIR/.mozilla ] && [ -f $ATOM_TGZ ] ; then
  cd $HOME_DIR
  tar xzf $ATOM_TGZ
fi


chown -R $SYNCTHING_USER:$SUNCTHING_USER /home/$SYNCTHING_USER

# if this if the first run, generate a useful config
[ -f /syncthing/config/config.xml ] && exit 0


CONFIG=/syncthing/config/config.xml

echo "generating config"
/syncthing/bin/syncthing --generate="/syncthing/config"
# don't take the whole volume with the default so that we can add additional folders
sed -e "s/id=\"default\" path=\"\/root\/Sync\/\"/id=\"default\" path=\"\/home\/$SYNCTHING_USER\/syncthing_default\/\"/" -i $CONFIG

# ensure we can see the web ui outside of the docker container
sed -e "s/<address>127.0.0.1:8384/<address>0.0.0.0:8080/" -i $CONFIG

chown $SYNCTHING_USER.users -R /syncthing
