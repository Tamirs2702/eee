#!/bin/bash
set -e
CR=$'\n'

source /ez/util.sh

# Buffer into a variable so there's no delay between the logo and the banner
banner=$([ "$(s6-svstat -o up /run/s6/services/bwt 2> /dev/null)" == "true" ] \
  && wget -T1 -qO - --user="." --password="$(printcontenv AUTH_TOKEN)" --auth-no-challenge \
    http://$(printcontenv BIND_ADDR):3060/banner.txt | tail -n +7 || true)

[ "$1" == "-s" ] && [ -n "$banner" ] && banner="$banner${CR}${CR} SUPPORT DEV: 🚀  bc1qmuagsjvq0lh3admnafk0qnlql0vvxv08au9l2d ／ https://btcpay.shesek.info"

B=$LBLUE R=$RESTORE
cat << EZ

          ███████$B╗$R ███████$B╗$R
          ██$B╔════╝$R $B╚══$R███$B╔╝$R
          █████$B╗$R     ███$B╔╝$R
          ██$B╔══╝$R    ███$B╔╝$R
          ███████$B╗$R ███████$B╗$R
          $B╚══════╝$R $B╚══════╝$R
$banner${banner:+$CR }
EZ
