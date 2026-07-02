# Valley of Story Mainnet - Usage Guide

How to run the tool, how to navigate it, and what every menu option does.

## Running the tool

```bash
bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Valley-of-Story-Mainnet/main/resources/valleyofStory.sh)
```

Or from a local clone:

```bash
bash resources/valleyofStory.sh
```

Run it as the same user that owns the Story node data. The script stores service names and environment variables in `~/.bash_profile`.

## Navigation

- Choose an option by typing number + letter together, for example `1f`, or type the number first and then the letter when prompted.
- Options that install, delete, schedule, update, stake, unstake, redelegate, or send tokens can change node state or funds.
- After exiting, run `source ~/.bash_profile` so exported variables apply to the current shell.

## Menu options explained

| Option | What it does | When to use | Destructive / risk |
|---|---|---|---|
| 1a. Deploy/re-Deploy Validator Node | Runs the main Story validator installer with Cosmovisor. | First setup or clean redeploy. | Yes - may replace services and node data. Backup keys first. |
| 1b. Manage Consensus Client | Opens consensus client management for Cosmovisor migration or version update. | Consensus binary maintenance. | Medium - service/binary changes. |
| 1c. Apply Snapshot | Applies a Story snapshot to speed up sync. | Recover or speed up sync. | Yes - can replace chain data. |
| 1d. Add Peers | Updates peer configuration. | When peer connectivity is weak. | Low - config change, restart recommended. |
| 1e. Update Geth Version | Runs the Story geth update script. | Execution client upgrade. | Medium - binary/service change. |
| 1f. Show Validator Node Status | Compares local and public RPC heights and shows sync status. | Routine health check. | No. |
| 1g. Show Consensus Client & Geth Logs Together | Tails both Story service logs. | Debugging. | No. |
| 1h. Show Consensus Client Logs | Tails consensus client logs. | Debugging consensus issues. | No. |
| 1i. Show Geth Logs | Tails execution client logs. | Debugging execution client issues. | No. |
| 2a. Create Validator | Builds and submits validator creation transaction. | Initial validator registration. | Yes - on-chain transaction. |
| 2b. Query Validator Public Key | Shows validator consensus public key. | Before validator creation or verification. | No. |
| 2c. Query Balance | Queries wallet balance. | Check funds. | No. |
| 2d. Stake Tokens | Delegates IP tokens. | Increase stake. | Yes - on-chain transaction. |
| 2e. Unstake Tokens | Undelegates IP tokens. | Begin unbonding. | Yes - on-chain transaction. |
| 2f. Export EVM Key | Exports the EVM key for the configured account. | Backup or external wallet import. | Sensitive - protect private key output. |
| 2g. Redelegate Tokens | Moves delegated stake to another validator. | Change validator without full unbond flow. | Yes - on-chain transaction. |
| 2h. Send IP Token | Transfers IP tokens to another address. | Manual token transfer. | Yes - on-chain transaction. |
| 3a. Restart Validator Node | Restarts both consensus and geth services. | After config or binary changes. | Low - downtime. |
| 3b. Restart Consensus Client Only | Restarts consensus service. | Consensus-only maintenance. | Low - downtime. |
| 3c. Restart Geth Only | Restarts geth service. | Execution-only maintenance. | Low - downtime. |
| 3d. Stop Validator Node | Stops both services. | Maintenance window. | Medium - node offline. |
| 3e. Stop Consensus Client Only | Stops consensus service. | Consensus maintenance. | Medium - validator offline. |
| 3f. Stop Geth Only | Stops geth service. | Execution maintenance. | Medium - execution client offline. |
| 3g. Backup Validator Key | Copies `priv_validator_key.json` to `$HOME`. | Before upgrades, redeploy, or deletion. | No, but protect the backup. |
| 3h. Delete Validator Node | Removes services, binaries, and node data. | Decommission or clean reinstall. | Yes - destructive. Backup seed/EVM key/validator key first. |
| 3i. Schedule Stop/Restart Validator Node | Schedules service stop/restart. | Planned maintenance timing. | Medium - planned downtime. |
| 3j. Update Go Version | Installs/updates Go version used by Story tooling. | When required by Story builds. | Medium - toolchain change. |
| 4. Install the Story App | Installs Story app binary only, without running a full node. | Need CLI transactions from another machine. | Medium - binary install. |
| 5. Show Grand Valley's Endpoints | Prints public endpoints and links. | Reference. | No. |
| 6. Show Guidelines | Shows in-tool navigation and option help. | First-time use. | No. |
| 7. Exit | Leaves the script. | Done. | No. |

## Recommended first-time flow

1. Run `1a`, then wait until `1f` shows the node is synced.
2. Use `2b` to confirm the validator pubkey.
3. Use `2a` to create the validator only after funding and final checks.
4. Immediately run `3g` and move the backup somewhere safe.
5. Use `1g`, `1h`, `1i`, and `1f` for routine monitoring.

## Safety notes

- Backup seed phrase, EVM private key, and `priv_validator_key.json` before redeploying or deleting anything.
- Treat exported keys as secrets. Do not paste them in public chats or tickets.
- Test destructive flows on a non-production node when possible.
