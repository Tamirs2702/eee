#!/bin/bash
set -xeo pipefail

apt-get update -qq
apt-get install -qqy --no-install-recommends wget procps ca-certificates

mkdir /ez /ez/bin /important /data
mv entrypoint.sh util.sh docker/networking.sh s6/default-finish.sh /ez/
mv docker/backup.sh /ez/bin/backup

install() {
  local name=$1
  (cd $name && ./install.sh)
  [ -f $name/finish ] || ln -s /ez/default-finish.sh $name/finish
  [ -f $name/fix-attrs ] && mv $name/fix-attrs /etc/fix-attrs.d/$name
  [ -f $name/run ] && mv $name /etc/services.d/
  true
}

install s6
for name in $(grep -E -o '[a-z0-9-]+' <<< $INSTALL); do
  install $name
done

apt-get autoremove --purge -y && apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/* /usr/local/share/{fonts,man} /usr/share/{fonts,doc}
