# Set up the Falkon CLI with your agent

Paste one of the blocks below into your AI agent and replace `<paste token>` with your API token. The agent stores the token in the CLI's config file and should never repeat it back to you.

Pasting the token puts it into the chat transcript, so make a token just for this with a short expiry, and revoke it in Falkon when you are done. If you would rather keep it out of the chat, write `~/.config/falkon/config.toml` yourself and paste the prompt without the token line:

```toml
token = "falkon_pat_..."
base_url = "https://staging-falkon.taborsokol.cz"   # staging only; leave this line out for production
```

For production:

```text
Install the Falkon CLI by following https://github.com/vichr-vita/falkon-cli/blob/main/INSTALL.md
My API token is: <paste token>
```

For staging:

```text
Install the Falkon CLI by following https://github.com/vichr-vita/falkon-cli/blob/main/INSTALL.md
Use the base URL https://staging-falkon.taborsokol.cz
My API token is: <paste token>
```

The agent installs the `falkon` binary, writes `~/.config/falkon/config.toml`, installs the Falkon skill, and runs `falkon whoami` to check that the token works.
