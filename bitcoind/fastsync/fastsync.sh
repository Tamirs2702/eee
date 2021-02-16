# -- expected to be `source`ed

# The keyring file for Stepan Snigirev, the signer of the prunednode.today snapshots, was created with:
# $ gpg --no-default-keyring --keyring ./stepan-snigirev.keyring --import <(curl https://stepansnigirev.com/ss-specter-release.asc)

[ "$NETWORK" == "bitcoin" ] || error fastsync TRUSTED_FASTSYNC can only be used with bitcoin mainnet
[ "$PRUNE" -ge 550 ] && [ "$PRUNE" -le 1000 ] || error fastsync TRUSTED_FASTSYNC must be used with prune '<=' 1000

if [ -d /data/bitcoin/blocks ]; then
  info fastsync Found existing datadir. Delete it to force a re-download of the fastsync snapshot.
  return 0
fi

info fastsync Setting up Bitcoin Core node in TRUSTED_FASTSYNC mode
warn fastsync This enables fast synchronization, but requires trusting the distributor of the snapshot.

# Find latest availalbe snapshot
latest_snapshot=$(wget -qO - https://prunednode.today/latest.txt | grep -o '^snapshot[0-9]\+')
age=$(( ($(date +%s) - $(date --date="${latest_snapshot#snapshot}" +%s) )/(60*60*24) ))
dest=/data/fastsync/$latest_snapshot

# Download
info fastsync Downloading $age days old snapshot from https://prunednode.today/$latest_snapshot.zip
wget --continue -qO $dest.zip https://prunednode.today/$latest_snapshot.zip --show-progress
wget -qO $dest.signed.txt https://prunednode.today/$latest_snapshot.signed.txt --show-progress

# Verify
info fastsync Verifying snapshot signature...
shasum=$(gpgv --keyring ./fastsync/stepan-snigirev.keyring --output - $dest.signed.txt \
  | grep "  $latest_snapshot.zip$" | cut -d' ' -f1)
info fastsync Verifying SHA256SUM...
pv $dest.zip | sha256sum -c <(echo "$shasum /dev/stdin") > /dev/null
echo >&2 $dest.zip: OK

# Extract
info fastsync Extracting snapshot...
unzip -n $dest.zip -x bitcoin.conf -d /data/bitcoin/ \
  | pv -pte -l -s $(unzip -Z -1 $dest.zip | wc -l) > /dev/null

[ -n "$KEEP_SNAPSHOT" ] || rm $dest.zip

info fastsync Ready to go!
