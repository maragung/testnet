#!/bin/bash
echo -e "\033[32m"
cat << "EOF"
                  _                         _
  __   __    ____ (_)__  ____   ____  _   _ (_)__    ____
 (__)_(__)  (____)(____)(____) (____)(_) (_)(____)  (____)
(_) (_) (_)( )_( )(_)  ( )_( )( )_(_)(_)_(_)(_) (_)( )_(_)
(_) (_) (_) (__)_)(_)   (__)_) (____) (___) (_) (_) (____)
                              (_)_(_)              (_)_(_)
                               (___)                (___)
EOF
echo -e "\033[0m"


echo "Enter/Paste the password from the $(tput setaf 2)community-xxx-password.txt$(tput sgr0) file, which you received from the team via email. (type 'exit' to exit): "
read value_input

if [[ "$value_input" == "exit" ]]; then
  echo "Exiting the program."
  exit 0
fi

# Ensure value_input is not empty
if [[ -n "$value_input" ]]; then
  # Set the [value] variable to the user's input
  RAYON_NUM_THREADS=6
  UPTIME_PRIVKEY_PASS="$value_input"
  MINA_LIBP2P_PASS="$value_input"
  MINA_PRIVKEY_PASS="$value_input"
  export MINA_LIBP2P_PASS


  EXTRA_FLAGS="--log-json --log-snark-work-gossip true --internal-tracing --insecure-rest-server --log-level Debug --file-log-level Debug --config-directory /root/.mina-config/ --external-ip $(curl -s ipinfo.io/ip) --itn-keys  f1F38+W3zLcc45fGZcAf9gsZ7o9Rh3ckqZQw6yOJiS4=,6GmWmMYv5oPwQd2xr6YArmU1YXYCAxQAxKH7aYnBdrk=,ZJDkF9EZlhcAU1jyvP3m9GbkhfYa0yPV+UdAqSamr1Q=,NW2Vis7S5G1B9g2l9cKh3shy9qkI1lvhid38763vZDU=,Cg/8l+JleVH8yNwXkoLawbfLHD93Do4KbttyBS7m9hQ= --itn-graphql-port 3089 --uptime-submitter-key  /root/keys/my-wallet --uptime-url https://block-producers-uptime-itn.minaprotocol.tools/v1/submit --metrics-port 10001 --enable-peer-exchange  true --libp2p-keypair /root/keys/keys --log-precomputed-blocks true --max-connections 200 --peer-list-url  https://storage.googleapis.com/seed-lists/testworld-2-0_seeds.txt --generate-genesis-proof  true --block-producer-key /root/keys/my-wallet --node-status-url https://nodestats-itn.minaprotocol.tools/submit/stats  --node-error-url https://nodestats-itn.minaprotocol.tools/submit/stats  --file-log-rotations 500"

  # Check if the variable already exists in ~/.mina-env
  if grep -q "UPTIME_PRIVKEY_PASS=" ~/.mina-env; then
    sed -i 's/^UPTIME_PRIVKEY_PASS=.*$/UPTIME_PRIVKEY_PASS="'"$UPTIME_PRIVKEY_PASS"'"/' ~/.mina-env
  else
    echo "UPTIME_PRIVKEY_PASS=\"$UPTIME_PRIVKEY_PASS\"" >> ~/.mina-env
  fi

  if grep -q "MINA_LIBP2P_PASS=" ~/.mina-env; then
    sed -i 's/^MINA_LIBP2P_PASS=.*$/MINA_LIBP2P_PASS="'"$MINA_LIBP2P_PASS"'"/' ~/.mina-env
  else
    echo "MINA_LIBP2P_PASS=\"$MINA_LIBP2P_PASS\"" >> ~/.mina-env
  fi

  if grep -q "MINA_PRIVKEY_PASS=" ~/.mina-env; then
    sed -i 's/^MINA_PRIVKEY_PASS=.*$/MINA_PRIVKEY_PASS="'"$MINA_PRIVKEY_PASS"'"/' ~/.mina-env
  else
    echo "MINA_PRIVKEY_PASS=\"$MINA_PRIVKEY_PASS\"" >> ~/.mina-env
  fi
  if grep -q "EXTRA_FLAGS=" ~/.mina-env; then
    sed -i 's/^EXTRA_FLAGS=.*$/EXTRA_FLAGS="'"$EXTRA_FLAGS"'"/' ~/.mina-env
  else
    echo "EXTRA_FLAGS=\"$EXTRA_FLAGS\"" >> ~/.mina-env
  fi
  if grep -q "RAYON_NUM_THREADS=" ~/.mina-env; then
    sed -i 's/^RAYON_NUM_THREADS=.*$/RAYON_NUM_THREADS='"$RAYON_NUM_THREADS"'/' ~/.mina-env
  else
    echo "RAYON_NUM_THREADS=$RAYON_NUM_THREADS" >> ~/.mina-env
  fi
  
  sudo chmod 600 ~/.mina-env
  mkdir ~/keys -p
  echo "Generating Keys..."
  echo "The keys will be generated based on the password you provided earlier."
  mina libp2p generate-keypair -privkey-path /root/keys/keys


  # Display confirmation message
  echo "Variables have been written to ~/.mina-env."
else
  echo "Password cannot be empty."
fi
