#!/bin/bash

#for s in bitcoind bwt nginx letsencrypt tor btc-rpc-explorer dropbear specter; do
#  echo -n "-v $PWD/$s:/etc/services.d/$s:ro "
#done
echo -n "-v $PWD/util.sh:/ez/util.sh:ro "
echo -n "-v $PWD/entrypoint.sh:/ez/entrypoint.sh:ro "
#echo -n "-v $HOME/workspace/bwt-dev/bwt/target/release/bwt:/usr/local/bin/bwt:ro "

echo -n "-v $PWD/s6/service.sh:/ez/bin/service:ro "
echo -n "-v $PWD/docker/networking.sh:/ez/networking.sh:ro "
echo -n "-v $PWD/bitcoind/bitcoin-cli:/ez/bin/bitcoin-cli:ro "
echo -n "-v $PWD/bitcoind/shutdown-message.sh:/etc/cont-finish.d/bitcoind-shutdown-message.sh:ro "
echo -n "-v $PWD/bwt/banner.sh:/ez/bin/banner:ro "
echo -n "-v $PWD/s6/shutdown-status.sh:/etc/cont-finish.d/shutdown-status.sh:ro "
echo -n "-v $PWD/s6/default-finish.sh:/ez/default-finish.sh:ro "

#echo -n "-v $HOME/workspace/cont/btc-rpc-explorer/app.js:/home/btcexp/.npm-global/lib/node_modules/btc-rpc-explorer/app.js:ro "
#echo -n "-v $HOME/workspace/cont/btc-rpc-explorer/app:/home/btcexp/.npm-global/lib/node_modules/btc-rpc-explorer/app:ro "
#echo -n "-v $HOME/workspace/cont/btc-rpc-explorer/views:/home/btcexp/.npm-global/lib/node_modules/btc-rpc-explorer/views:ro "
#echo -n "-v $HOME/workspace/cont/btc-rpc-explorer/routes:/home/btcexp/.npm-global/lib/node_modules/btc-rpc-explorer/routes:ro "
