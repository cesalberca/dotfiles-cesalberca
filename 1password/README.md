# 1password - SSH agent config (Personal vault)

[`agent.toml`](./agent.toml) is this plugin's **fragment** of the 1Password SSH agent config: it enables the **Personal** vault. The org vaults are owned by their own plugins ([`dotfiles-tii`](https://github.com/cesalberca/dotfiles-tii) -> TII, [`dotfiles-ttcc`](https://github.com/cesalberca/dotfiles-ttcc) -> TTCC).

## Why a fragment, not a whole file

The 1Password SSH agent reads exactly one file, `~/.config/1Password/ssh/agent.toml`, with no include or merge directive. If each plugin symlinked its own copy there, the last `dotfiles install` to run would clobber the rest. So instead every plugin's `install.sh` merges its fragment into that single file, wrapped in markers it alone owns:

```toml
# >>> dotfiles-cesalberca >>>
[[ssh-keys]]
vault = "Personal"
# <<< dotfiles-cesalberca <<<
```

Re-running install replaces only this block; blocks owned by other plugins are left untouched. The first run converts any pre-existing symlink to a managed regular file and backs up an unmanaged file once (`*.bak.<epoch>`). After merging, it logs a reminder to create the vault this fragment enables; if the `op` CLI is installed and signed in, it actively verifies the vault exists and prints `[ACTION NEEDED]` if not.

## After install

1. 1Password -> Settings -> Developer -> **Use the SSH agent**.
2. Restart 1Password (or toggle the agent) so it re-reads `agent.toml`.
3. Confirm keys are offered:
   ```bash
   SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ssh-add -l
   ```
