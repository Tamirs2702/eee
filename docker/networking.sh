# -- expected to be `source`ed

# Detect Docker's networking mode and determining the address to bind on.
if [ -z "$BIND_ADDR" ]; then
  addrs=$(hostname -I)

  # In a virtual docker network env, our hostname will resolve to a single IP
  # address in the 172.x.x.x range (there will typically be multiple on the host).
  # Bind on it explicitly instead of using 0.0.0.0 to make the services
  # URLs/URIs shown to the user easily accessible from the host.
  if grep -Eq '^172\.\S+ ' <<< $addrs; then
    export BIND_ADDR=${addrs/ /}

  # Bind on 127.0.0.1 in host networking mode as a safety precaution
  else
    export BIND_ADDR=127.0.0.1
    warn networking "You appear to be running in docker host networking mode (--net host)." \
              "Services will be bound on 127.0.0.1 by default, to prevent them from accidentally being left exposed to the world." \
              "Set BIND_ADDR=0.0.0.0 if you'd like to accept remote connections."
    # This could be a false positive, if the user reconfigured docker's IP range.
    # I couldn't find a more reliable way to do this.
  fi
fi

# Automagically add an entry to /ez/hosts (mounted from the hosts's /etc/hosts)
if [ -f "/ez/hosts" ]; then
  : ${HOST_ALIAS:=ez}
  cat <<< $(grep -v "^\S\+ $HOST_ALIAS\$" /ez/hosts) > /ez/hosts
  info networking Adding /etc/hosts entry: \
    $(echo "$(hostname -i) $HOST_ALIAS" | tee -a /ez/hosts)
  info networking "Your node will be available via the '$HOST_ALIAS' hostname"
fi
