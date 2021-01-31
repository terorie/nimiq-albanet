#!/usr/bin/env bash

set -euo pipefail

if ! options=$(
  getopt \
  -o "" \
  --longoptions "network:,message:,validators:,initial_stake:" \
  -- "$@"
)
then
  echo "Incorrect usage"
  exit 1
fi
eval set -- "$options"

network="dev-albatross"
message="Albatross Kubernetes network"
validators=3
initial_stake=100000000

while [[ "$#" != 0 ]]; do
  case "$1" in
    --network)
      shift
      network="$1"
      ;;
    --message)
      shift
      message="$1"
      ;;
    --validators)
      shift
      validators="$1"
      ;;
    --initial_stake)
      shift
      initial_stake="$1"
  esac
  shift
done

echo "name = \"$network\""
echo "seed_message = \"$message\""
echo "signing_key = \"$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | xxd -p -c 64)\""
echo "timestamp = \"$(date --rfc-3339=ns)\""

function gen_address ()
{
  # Remove the prefixed labels from each line.
  # e.g. "Label: VALUE" => "VALUE"
  nimiq-address | sed -e 's/^[^:]*: *//'
}

function gen_bls ()
{
  # Remove the comments and empty lines.
  nimiq-bls | grep --color=never '^[0-9a-f]'
}

mapfile -t staking_account <<< "$(gen_address)"
echo "staking_contract = \"${staking_account[0]}\""
echo "# private key for staking contract: ${staking_account[3]}"

for (( i=1; i<="$validators"; i++ ))
do
  echo
  echo "[[validators]]"
  mapfile -t validator_account <<< "$(gen_address)"
  echo "reward_address = \"${validator_account[0]}\""
  echo "# private key for reward address: ${validator_account[3]}"
  echo "balance = $initial_stake"
  mapfile -t validator_bls <<< "$(gen_bls)"
  echo "# secret_key = \"${validator_bls[1]}\""
  echo "validator_key = \"${validator_bls[0]}\""
done
