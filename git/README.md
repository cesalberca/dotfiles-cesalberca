# git

Git configuration with per-platform SSH signing via 1Password.

## Files in this directory

| File | Symlinked to | Purpose |
|------|--------------|---------|
| `.gitconfig.symlink` | `~/.gitconfig` | Main config, aliases, delta, signing setup, includeIfs |
| `.gitconfig-github.symlink` | `~/.gitconfig-github` | GitHub signing key (pubkey) |
| `.gitconfig-gitlab.symlink` | `~/.gitconfig-gitlab` | GitLab signing key (pubkey, shared with gitlab.com + self-hosted) |

`.symlink` suffix is convention — link manually with `ln -s`.

## How signing routes

`~/.gitconfig` uses conditional `includeIf` blocks:

- `hasconfig:remote.*.url:**github.com**` → loads `~/.gitconfig-github` → uses GitHub pubkey
- `hasconfig:remote.*.url:**gitlab.com**` → loads `~/.gitconfig-gitlab` → uses GitLab pubkey
- `hasconfig:remote.*.url:**gitlab.innovium.ai**` → loads `~/.gitconfig-gitlab` → uses GitLab pubkey
- `gitdir:~/workspace/tii/` → loads `~/.gitconfig-work` → overrides `user.email` to work address

Each platform URL is covered in three forms: `https://`, `git@host:`, `ssh://git@host/`.

Pattern note: `git@host:**/**` (two stars + slash + two stars) is required for SCP-style SSH URLs to match nested groups; `git@host:**` alone does not cross `/`.

Signing key holder is 1Password (`op-ssh-sign`); `signingkey` here is the public half only.

## Files kept OUT of the repo (machine-local)

These contain work identity / signing trust and must NOT be committed:

- `~/.gitconfig-work` — work email override
- `~/.config/git/allowed_signers` — email→pubkey trust map for local `--show-signature` verification

## New machine bootstrap

After cloning dotfiles and linking the three repo files:

```bash
# 1. Work identity override (used by ~/workspace/tii/* repos)
cat > ~/.gitconfig-work <<'EOF'
[user]
	email = cesar.alberca@leanmind.es
EOF

# 2. Allowed signers — required by gpg.ssh.allowedSignersFile in ~/.gitconfig
mkdir -p ~/.config/git
cat > ~/.config/git/allowed_signers <<'EOF'
cesar@cesalberca.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGRos8BTCuHSAiocGJ6GX5ptUqIW0FJUVOX5+ECIfDih
cesar@cesalberca.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3qc6JMYbS5cwtuLjmLajDsrqoIbUNyUbR/0bE0o2sf
cesar.alberca@leanmind.es namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3qc6JMYbS5cwtuLjmLajDsrqoIbUNyUbR/0bE0o2sf
EOF
```

Each line: `<email> namespaces="git" <pubkey>`. Add a row per email/key pair that should be trusted locally.

## 1Password integration

`~/.gitconfig` points to `op-ssh-sign`:

```
[gpg "ssh"]
	program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
```

Private keys live in 1Password. SSH integration must be enabled in 1Password (Settings → Developer → Use the SSH agent).

## Server-side verification (GitHub / GitLab)

Each platform shows the green "Verified" badge only when:

1. The matching pubkey is registered on that account as a **Signing** key (not just auth).
2. The commit author email matches a verified email on the same account.

For self-hosted GitLab with custom org emails (e.g. `gitlab.innovium.ai`), use the `gitdir:` includeIf to override `user.email` for those repos.

## Verify locally

```bash
git commit --allow-empty -m "test sign"
git log --show-signature -1
```

Expect: `Good "git" signature for <email>`.

If `gpg.ssh.allowedSignersFile needs to be configured` → the file at `~/.config/git/allowed_signers` is missing.

If `No signature` or `Different user's signature` → check the commit's author email matches a row in `allowed_signers` (local) and a verified email on the platform account (server).
