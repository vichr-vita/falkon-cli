# falkon CLI

`falkon` is the command-line client for Falkon, the administration app of a Czech summer camp at https://falkon.taborsokol.cz. It lists terms (turnusy), applications (přihlášky), payments, the roster of children, and attendance (docházka). It can also record payments, check children in and out, and manage instructor access.

It is meant for Falkon admins who want an AI agent or a script to do this work. Each command runs with an admin API token and acts as the admin who issued it.

## Get a token

Sign in to Falkon as an admin and open Účet, Zabezpečení, "API tokeny". Create a token with an expiry. It looks like `falkon_pat_...` and is shown only once, so copy it right away. Revoke it on the same page when you no longer need it.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.sh | sh
```

The script installs the latest release to `~/.local/bin` (or `$FALKON_INSTALL_DIR`), checks its SHA-256 checksum, and needs no sudo. It does not create a config file. On Windows, run `install.ps1` from PowerShell:

```powershell
irm https://raw.githubusercontent.com/vichr-vita/falkon-cli/main/install.ps1 | iex
```

Releases also carry archives for each platform, a `SHA256SUMS` file, and the agent skill as `falkon-skill-<version>.tar.gz`.

To have an agent do the whole setup, paste the text from [PROMPT.md](PROMPT.md) into it. The agent then follows [INSTALL.md](INSTALL.md), writes the config file, and installs the skill from [skills/falkon/](skills/falkon/).

## Use

Put the token in `~/.config/falkon/config.toml` as `token = "falkon_pat_..."` and keep the file at mode 600. The CLI talks to production by default. For staging, add `base_url = "https://staging-falkon.taborsokol.cz"`.

```sh
falkon whoami
falkon terms list
falkon --json roster
```

`falkon --help` lists every command, and `falkon procedures` lists every API call you can make with `falkon call`.

## Try it

Once setup works, ask your agent things like these. The command after each one is what the agent runs.

- "Who am I signed in as?" runs `falkon whoami`.
- "Jaké máme turnusy?" runs `falkon terms list`.
- "Show this year's přihlášky." runs `falkon applications list`.
- "Who is on the roster for the first turnus?" runs `falkon roster --term <term-uuid>`.
- "Show the season dashboard." runs `falkon dashboard`.
- "Show the docházka for this week." runs `falkon attendance list`.
- "What else can the API do?" runs `falkon procedures`.
- "Mark this application as paid." runs `falkon applications set-payment <application-uuid> --status paid`.
- "Check Anička in for Monday." runs `falkon attendance check-in <applicant-uuid> --term <term-uuid> --day mon`.

The agent looks up the UUIDs itself. The last two change data, so the agent shows you the change and waits for your yes before it runs them.

## Be careful

The CLI works on production data about children and their families. Anything it changes, it changes for real. The skill tells agents to show you each change and wait for your yes before they write anything. Read what your agent proposes before you agree.

## Source

The CLI is built from a private repository. This repository holds only the releases, the install scripts, and the documentation.
