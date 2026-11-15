# Install the Falkon CLI

You are setting up the `falkon` command-line client for a user who administers Falkon, a Czech summer camp app. The user gave you an admin API token (it starts with `falkon_pat_`) and maybe a base URL, or wrote the config file themselves and gave you no token. Do the steps in order. The installation is done when `falkon whoami` succeeds and the skill is in place.

Treat the token as a password for production data about children. It appears in exactly one place you write: the config file in step 3. Keep it out of your replies, command lines, logs, and every other file.

## 1. Install the binary

On Linux and macOS:

```sh
curl -fsSL https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.sh | sh
```

On Windows, in PowerShell:

```powershell
irm https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.ps1 | iex
```

The scripts install the latest release, verify its SHA-256 checksum, use no sudo, and touch no config. The binary goes to `~/.local/bin/falkon` (Windows: `%LOCALAPPDATA%\Programs\falkon\falkon.exe`). Set `FALKON_INSTALL_DIR` to choose another directory.

For a specific release, pass the flag through the pipe with `sh -s --`, or set `FALKON_VERSION`:

```sh
curl -fsSL https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.sh | sh -s -- --version vX.Y.Z
curl -fsSL https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.sh | FALKON_VERSION=vX.Y.Z sh
```

In PowerShell, `irm | iex` cannot pass `-Version`, so set the variable first:

```powershell
$env:FALKON_VERSION = 'vX.Y.Z'; irm https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.ps1 | iex
```

If you may not pipe a script into a shell, install by hand from the latest release at https://github.com/vichr-vita/falkon-cli/releases/latest

1. Download `falkon-<version>-<target>.tar.gz` for the machine (`x86_64-unknown-linux-musl`, `aarch64-unknown-linux-musl`, `x86_64-apple-darwin`, or `aarch64-apple-darwin`; Windows uses `falkon-<version>-x86_64-pc-windows-gnu.zip`) and `SHA256SUMS`.
2. Check the archive: `sha256sum -c --ignore-missing SHA256SUMS` (macOS: `shasum -a 256 -c --ignore-missing SHA256SUMS`). Stop if it does not print `OK`.
3. Extract it and copy `falkon` to `~/.local/bin/`, then `chmod 755 ~/.local/bin/falkon`.

The step is done when `falkon --version` prints a version.

## 2. Make sure you can run it

If the installer warned that `~/.local/bin` is not on `PATH`, call the binary by its full path, `~/.local/bin/falkon`, for the rest of this session. Tell the user at the end that they should add the directory to `PATH` in their shell profile. Do not edit their profile yourself.

## 3. Write the config file

If the user wrote the config file themselves, leave its content alone: run only the `ls -l` mode check at the end of this step, then go to step 4.

Without a base URL from the user, the CLI uses production (`https://falkon.taborsokol.cz`), so the token is the only setting. Add `base_url` only when the user gave you another URL, such as staging (`https://staging-falkon.taborsokol.cz`).

Create the directory and an empty file that only the user can read:

```sh
mkdir -p ~/.config/falkon
(umask 077 && : > ~/.config/falkon/config.toml)
chmod 600 ~/.config/falkon/config.toml
```

If `XDG_CONFIG_HOME` is set, use `$XDG_CONFIG_HOME/falkon/config.toml` instead. On Windows the CLI looks for a config file only when `XDG_CONFIG_HOME` or `HOME` is set. If neither is, skip the file and use the environment variable described at the end of this step.

Then write the content with your file-writing tool, typing the token once:

```toml
token = "falkon_pat_..."
```

With a non-production URL from the user, add a second line:

```toml
base_url = "https://staging-falkon.taborsokol.cz"
```

Use the file-writing tool, not `echo` or `printf` with the token in the shell. A command line ends up in shell history and in your transcript. If you have no file-writing tool, ask the user to paste the token into the file themselves.

After writing, run `ls -l ~/.config/falkon/config.toml` and confirm the mode is `-rw-------`. An editor or a file-writing tool may recreate the file with mode `-rw-r--r--`. If the mode is anything other than `-rw-------`, run `chmod 600 ~/.config/falkon/config.toml` and check again. Do not print the file.

If the user prefers not to store the token in a file, they set `FALKON_API_TOKEN` themselves: `export FALKON_API_TOKEN=...` in their shell, or a user environment variable on Windows. Skip the file and tell them the variable must be set wherever `falkon` runs. Do not set it for them, since that puts the token on a command line.

## 4. Install the skill

The skill teaches you, and later sessions, how to use Falkon safely. It is the `skills/falkon/` directory of this repository: `SKILL.md` plus a `reference/` folder.

Get it with git:

```sh
git clone --depth 1 https://github.com/vichr-vita/falkon-cli.git falkon-cli-src
```

Or download `falkon-skill-<version>.tar.gz` from the latest release and extract it. It unpacks to `skills/falkon/`, the same layout as the repository.

Copy `skills/falkon/` to the skills directory of the agent you are:

- Claude Code: `~/.claude/skills/falkon/` for every project, or `.claude/skills/falkon/` inside one project if the user wants it limited to that project.
- Codex and other agents: the equivalent skills or instructions directory of that agent.
- An agent without a skills directory: leave the files where they are and tell the user the path, so they can load `SKILL.md` into future sessions.

Remove the clone or the extracted archive afterwards. The step is done when `falkon/SKILL.md` and `falkon/reference/` exist in the target directory.

## 5. Verify

```sh
falkon whoami
falkon terms list
```

`whoami` prints the account and the server. `terms list` prints the camp terms. Both only read data.

- Exit code `0`: done.
- Exit code `1` with `unauthenticated`: the server rejected the token. It was revoked, it expired, or its issuer is no longer an admin. Tell the user exactly that and stop. They need a new token from the web app under Účet, Zabezpečení, "API tokeny".
- Exit code `1` with another error: report the message to the user and stop.
- Exit code `2`: a configuration problem, such as a malformed token or a bad base URL. Read the message, fix the config file, and run `falkon whoami` again. If the token itself is malformed, ask the user to check it.

## 6. Report to the user

Tell the user:

- the installed version and the binary's path,
- the config file's path and the server it points at (production or staging),
- where you installed the skill,
- the account `falkon whoami` reported,
- whether they need to add `~/.local/bin` to `PATH`.

Leave the token out of the report.

## What not to do

- Never print, log, echo, or paste the token, and never `cat` the config file.
- Never run a command that changes data during installation. `whoami` and `terms list` are the only Falkon commands this guide needs.
- Leave the base URL at the production default unless the user gave you one.
