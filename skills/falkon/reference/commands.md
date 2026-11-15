# falkon command reference

The `--help` text of every command of `falkon 0.1.0`, verbatim except that the global options block appears only once, under `falkon`. Run `falkon <command> --help` to check the installed version. The global options at the top apply to every command and may go before or after the subcommand.

## falkon

```text
falkon: command-line client for the Falkon API

Usage: falkon [OPTIONS] <COMMAND>

Commands:
  whoami        Show who the token authenticates as
  tokens        Manage admin API tokens
  terms         Camp terms
  applications  Camp applications
  roster        Participant roster of a term
  dashboard     Season dashboard summary
  instructors   Instructor accounts and term access
  attendance    Attendance sheet, check-in and check-out
  applicants    One applicant and their terms: info, cancel, restore
  procedures    List the callable API procedures, or show one with an example request. Works offline
  call          Call any API procedure with a JSON body and print the JSON answer
  help          Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version

Global options:
      --base-url <URL>  API base URL [env: FALKON_BASE_URL] [default: https://falkon.taborsokol.cz]
      --token <TOKEN>   Admin API token (falkon_pat_...) [env: FALKON_API_TOKEN]
      --config <PATH>   Config file [default: $XDG_CONFIG_HOME/falkon/config.toml or ~/.config/falkon/config.toml]
      --json            Print the server's JSON answer instead of tables
```

## falkon whoami

```text
Show who the token authenticates as

Usage: falkon whoami [OPTIONS]

Options:
  -h, --help  Print help
```

## falkon tokens create

```text
Issue a new token. The token goes to stdout once; details go to stderr

Usage: falkon tokens create [OPTIONS] --name <NAME> <--expires-in <DAYS>|--expires-at <RFC3339>>

Options:
      --name <NAME>           Label of the token, for example "ci-export"
      --expires-in <DAYS>     Lifetime in days from now (at most 90). The expiry is set one minute earlier than that, so a client clock slightly ahead of the server's does not break the 90-day limit
      --expires-at <RFC3339>  Absolute expiry in RFC 3339, for example 2026-12-31T23:59:59Z
  -h, --help                  Print help
```

## falkon tokens list

```text
List the tokens of every admin, revoked and expired ones included

Usage: falkon tokens list [OPTIONS]

Options:
  -h, --help  Print help
```

## falkon tokens revoke

```text
Revoke a token by UUID

Usage: falkon tokens revoke [OPTIONS] <UUID>

Arguments:
  <UUID>  Token UUID (see `falkon tokens list`)

Options:
  -h, --help  Print help
```

## falkon terms list

```text
List every managed term (admin view), or the open ones with --public

Usage: falkon terms list [OPTIONS]

Options:
      --public  Use the public listing of open terms that guardians see; needs no token
  -h, --help    Print help
```

## falkon applications list

```text
List the applications created in one year

Usage: falkon applications list [OPTIONS]

Options:
      --year <YEAR>      Year the applications were created in [default: the current year]
      --status <STATUS>  Only these process statuses; repeat or comma-separate [default: completed] [possible values: created, completed, accepted, rejected, cancelled]
  -h, --help             Print help
```

## falkon applications set-payment

```text
Set the payment status of one application. Sends no email; not-paid also skips the application's pending payment confirmation email

Usage: falkon applications set-payment [OPTIONS] --status <STATUS> <APPLICATION>

Arguments:
  <APPLICATION>  Application UUID (see `falkon applications list`)

Options:
      --status <STATUS>  The new payment status [possible values: paid, not-paid]
  -h, --help             Print help
```

## falkon applications send-paid-email

```text
Queue the payment confirmation email of one application

Usage: falkon applications send-paid-email [OPTIONS] <APPLICATION>

Arguments:
  <APPLICATION>  Application UUID (see `falkon applications list`)

Options:
      --force  Send it even when it was sent before; without it the email worker skips a sent one
  -h, --help   Print help
```

## falkon roster

```text
Participant roster of a term

Usage: falkon roster [OPTIONS]

Options:
      --term <UUID>  Term UUID (see `falkon terms list`). Omitted, the server picks the current term, else the next one, else the last
  -h, --help         Print help
```

## falkon dashboard

```text
Season dashboard summary

Usage: falkon dashboard [OPTIONS]

Options:
      --year <YEAR>      Year to report on [default: chosen by the server]
      --season <SEASON>  Season number within the year
      --term <UUID>      Only these term UUIDs; repeat or comma-separate
  -h, --help             Print help
```

## falkon instructors list

```text
List instructors with the terms they may open

Usage: falkon instructors list [OPTIONS]

Options:
  -h, --help  Print help
```

## falkon instructors grant

```text
Let an instructor open the attendance sheet of a term

Usage: falkon instructors grant [OPTIONS] --term <UUID> <INSTRUCTOR>

Arguments:
  <INSTRUCTOR>  Instructor user ID (see `falkon instructors list`)

Options:
      --term <UUID>  Term UUID (see `falkon terms list`)
  -h, --help         Print help
```

## falkon instructors revoke

```text
Take an instructor's access to a term away. Needs --yes

Usage: falkon instructors revoke [OPTIONS] --term <UUID> <INSTRUCTOR>

Arguments:
  <INSTRUCTOR>  Instructor user ID (see `falkon instructors list`)

Options:
      --term <UUID>  Term UUID (see `falkon terms list`)
      --yes          Confirm the revocation
  -h, --help         Print help
```

## falkon attendance list

```text
List the attendance sheet of a term, Monday to Friday

Usage: falkon attendance list [OPTIONS]

Options:
      --term <UUID>       Term UUID (see `falkon terms list`). Omitted, the server picks the current term, else the next one, else the last
      --applicant <UUID>  Only these applicants; repeat or comma-separate
  -h, --help              Print help
```

## falkon attendance check-in

```text
Record an arrival on one day; the departure and the sleepover stay as they are

Usage: falkon attendance check-in [OPTIONS] --term <UUID> --day <DAY> <APPLICANT>

Arguments:
  <APPLICANT>  Applicant UUID (see `falkon attendance list`)

Options:
      --term <UUID>      Term UUID (see `falkon terms list`)
      --day <DAY>        Day of the camp week [possible values: mon, tue, wed, thu, fri]
      --at <RFC3339>     Time in RFC 3339, for example 2026-07-06T08:12:00+02:00 [default: now]
      --reason <REASON>  Reason recorded in the attendance history
  -h, --help             Print help
```

## falkon attendance check-out

```text
Record a departure on one day; the arrival and the sleepover stay as they are

Usage: falkon attendance check-out [OPTIONS] --term <UUID> --day <DAY> <APPLICANT>

Arguments:
  <APPLICANT>  Applicant UUID (see `falkon attendance list`)

Options:
      --term <UUID>      Term UUID (see `falkon terms list`)
      --day <DAY>        Day of the camp week [possible values: mon, tue, wed, thu, fri]
      --at <RFC3339>     Time in RFC 3339, for example 2026-07-06T08:12:00+02:00 [default: now]
      --reason <REASON>  Reason recorded in the attendance history
  -h, --help             Print help
```

## falkon applicants info

```text
Show an applicant with every term, cancelled ones included

Usage: falkon applicants info [OPTIONS] <APPLICANT>

Arguments:
  <APPLICANT>  Applicant UUID (see `falkon roster` or `falkon attendance list`)

Options:
  -h, --help  Print help
```

## falkon applicants cancel-term

```text
Cancel one active term of an applicant. Needs --yes

Usage: falkon applicants cancel-term [OPTIONS] --term <UUID> <APPLICANT>

Arguments:
  <APPLICANT>  Applicant UUID

Options:
      --term <UUID>      Term UUID (see `falkon applicants info`)
      --reason <REASON>  Cancellation reason stored with the term
      --yes              Confirm the cancellation
  -h, --help             Print help
```

## falkon applicants restore-term

```text
Restore a cancelled term of an applicant; a cancelled application becomes completed

Usage: falkon applicants restore-term [OPTIONS] --term <UUID> <APPLICANT>

Arguments:
  <APPLICANT>  Applicant UUID

Options:
      --term <UUID>            Term UUID (see `falkon applicants info`)
      --acknowledge <WARNING>  Acknowledge a warning the server named on an earlier attempt, as <code>:<fingerprint>; repeat for several
  -h, --help                   Print help
```

## falkon procedures

```text
List the callable API procedures, or show one with an example request. Works offline

Usage: falkon procedures [OPTIONS] [PROCEDURE]

Arguments:
  [PROCEDURE]  Show one entry with example requests: `Service/Method`, `/api/...`, or `/rpc/falkon.v1.Service/Method`

Options:
  -h, --help  Print help
```

## falkon call

```text
Call any API procedure with a JSON body and print the JSON answer

Usage: falkon call [OPTIONS] <PROCEDURE>

Arguments:
  <PROCEDURE>  `Service/Method` as `falkon procedures` lists it, or a path sent verbatim: `/api/...` or `/rpc/falkon.v1.Service/Method`

Options:
      --data <JSON|@FILE|->  Request body: JSON text, `@<file>` to read a file, or `-` to read stdin. It must be a JSON object [default: {}]
  -h, --help                 Print help
```
