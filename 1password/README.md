# 1password - SSH agent config (all vaults)

[`agent.toml`](./agent.toml) is the **complete** 1Password SSH agent config. It lists every vault whose keys the agent should offer: **Personal**, **TII**, and **TTCC**. This personal plugin owns the whole file; the org plugins ([`dotfiles-tii`](https://github.com/cesalberca/dotfiles-tii), [`dotfiles-ttcc`](https://github.com/cesalberca/dotfiles-ttcc)) carry only their SSH host configs and public keys.

## One file, all vaults

The 1Password SSH agent reads exactly one file, `~/.config/1Password/ssh/agent.toml`, with no include or merge directive. Rather than have several plugins each contribute a fragment (and dance around clobbering each other), this one plugin holds the entire config and [`install.sh`](./install.sh) just symlinks it into place. Adding or removing a vault is a one-line edit to `agent.toml`.

## After install

1. 1Password -> Settings -> Developer -> **Use the SSH agent**.
2. Restart 1Password (or toggle the agent) so it re-reads `agent.toml`.
3. Confirm keys are offered:
   ```bash
   SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ssh-add -l
   ```
