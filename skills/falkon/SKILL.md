---
name: falkon
description: Drives the Falkon summer camp (tábor) admin app through the falkon CLI with an admin API token. Use for any Falkon task, such as listing terms (turnusy), applications (přihlášky) and their payments, the roster of children in a term, attendance (docházka) check-in and check-out, instructors and their term access, the season dashboard, or calling any other Falkon API procedure.
---

# Falkon CLI

Falkon is the administration app of a Czech children's summer camp. The `falkon` CLI talks to it with an admin API token and acts as the admin who issued that token. Everything you read or change is real data about children and their families.

## Safety rules

These apply to every Falkon task. Follow them before the rest of this file.

1. **Read before you write.** Find the exact records with a list or info command first.
2. **Confirm every write.** Before any command that changes data, show the user the command, the ids it targets (with the child's or family's name and the VS where you have them), and the values it will set. Run it only after the user says yes to that exact change. One yes covers one change, or one list of changes the user saw in full.
3. **`--yes` carries the user's confirmation.** Add it only after the user confirmed that specific change. It is never a way to get past the CLI's own check.
4. **Prefer typed commands for writes.** Use `falkon call` for a write only when no typed command does it, and show the user the full JSON body first.
5. **Do not retry a failed write in a loop.** Report the error and decide with the user.
6. **Keep the token secret.** It lives in the config file or in `FALKON_API_TOKEN`. Never print, log, paste, or pass it on the command line where it lands in shell history, and never print the config file.
7. **Personal data stays local.** Show the user only the rows the task needs. Do not copy names, birth dates, health conditions, or phone numbers into files, commits, or other services unless the user asks for it.

Writes are: `applications set-payment`, `applications send-paid-email` (sends a real email to a family), `attendance check-in`, `attendance check-out`, `applicants cancel-term`, `applicants restore-term`, `instructors grant`, `instructors revoke`, `tokens create`, `tokens revoke`, and any `falkon call` to a procedure whose name does not start with `List` or `Get`.

## Start here

Run `falkon whoami` first. It prints the account the token acts as and the server it talked to. Production is `https://falkon.taborsokol.cz` and is the default; staging is `https://staging-falkon.taborsokol.cz`. Tell the user which one you are on before the first write.

Exit codes:

- `0`: success.
- `1`: API or network failure. The server error appears on stderr as `error: <code>: <message>`.
  - `unauthenticated` (HTTP 401): the token was revoked, expired, or its issuer is no longer an admin. Stop and tell the user to issue a new token in the web app under Účet, Zabezpečení, "API tokeny". Do not try other tokens.
  - `aborted`: someone changed the record after you read it. Read it again (for attendance, `falkon attendance list`), show the user the new state, and confirm with them again before retrying.
- `2`: usage or configuration error, such as a bad flag, a missing or malformed token, or an unknown procedure. Fix the command; nothing reached the server.

Settings come from flags (`--base-url`, `--token`), then the environment (`FALKON_BASE_URL`, `FALKON_API_TOKEN`), then `~/.config/falkon/config.toml` (or `$XDG_CONFIG_HOME/falkon/config.toml`) with the keys `base_url` and `token`. If the CLI warns that the config file is readable by other users, tell the user and suggest `chmod 600` on it.

Output: tables go to stdout and a context line (for example the selected term) goes to stderr. Add `--json` to get the server's JSON answer whenever you will parse the output or need a field the table hides. The global flags may go before or after the subcommand: `falkon --json roster` and `falkon roster --json` are the same. Times print in the local zone.

Every id is a UUID that comes from a list command. Never guess one or build one from a name.

## Vocabulary

- **Term (turnus).** One week of camp, Monday to Friday. Terms belong to a season within a year. `terms list` shows each term's UUID, season, number, dates, price, how full it is (`FILLED` as applicants/capacity), and lifecycle: `draft`, `open`, or `closed`.
- **Application (přihláška).** One family's registration. It holds one or more applicants and one or more contact persons. Its process status is `created` (started, not submitted), `completed` (submitted), `accepted`, `rejected`, or `cancelled`. Its payment status is `paid` or `not paid`, set by an admin when the money arrives.
- **Variable symbol (VS).** The payment reference of an application. Bank transfers carry it, so it is how you match a payment to an application.
- **Applicant.** A child on an application. An applicant attends one or more terms; each applicant term is `active` or `cancelled`.
- **Contact person.** A guardian on an application, with email and phone.
- **Roster.** The participants of one term with VS, age, sex, payment status, whether the child may leave alone, the first guardian's contact, and health conditions.
- **Attendance (docházka).** A sheet per term with one row per active applicant and a cell per day, Monday to Friday. Each day records the arrival (check-in) and departure (check-out) time and whether the child stays overnight after that day (sleepover). Rows also carry a note.
- **Instructor.** A staff account that can open the attendance sheet of the terms it was granted. Admins grant and revoke this term access.
- **Dashboard.** The season summary: applicant counts, money paid, applications by status, and per-term fill and payment.

## Read commands

```sh
falkon whoami
falkon terms list                      # every term, with UUIDs (admin view)
falkon terms list --public             # the open terms guardians see; no token needed
falkon applications list [--year <YEAR>] [--status <STATUS>]   # default: this year, completed
falkon roster [--term <UUID>]
falkon attendance list [--term <UUID>] [--applicant <UUID>]
falkon applicants info <APPLICANT>     # one child with every term, cancelled ones included
falkon instructors list                # user IDs, emails, and the terms each may open
falkon dashboard [--year <YEAR>] [--season <SEASON>] [--term <UUID>]
falkon tokens list
```

`--status`, `--applicant`, and the dashboard's `--term` take several values, repeated or comma-separated. `--status` values: `created`, `completed`, `accepted`, `rejected`, `cancelled`.

Without `--term`, `roster` and `attendance list` use the current term, else the next one, else the last. The server also answers an unknown term UUID with a different term instead of an error. Check the `Term N (start to end)` line on stderr, or `selectedTermUuid` in the JSON, before you report on a term.

The `roster` table starts with the applicant and application UUIDs. `applications list` shows the application UUID, and `attendance list` shows the applicant UUID.

Example, "which children are in turnus 3":

```sh
falkon terms list                      # find the UUID of term 3 in the right season
falkon roster --term <term-uuid>
```

## Write commands

Each write prints one line on stderr that names the change. With `--json` the server's answer goes to stdout.

### Payments

```sh
falkon applications set-payment <APPLICATION> --status paid|not-paid
falkon applications send-paid-email <APPLICATION> [--force]
```

`set-payment` does not show the previous status and sends no email. `not-paid` also cancels a pending payment confirmation email. `send-paid-email` queues the confirmation email to the family; without `--force` the server skips an application whose confirmation was already sent. Ask the user separately before sending an email.

Example, "VS 2026045 paid":

```sh
falkon applications list --year 2026 --status completed    # find the row with VS 2026045
```

Show the user that row (UUID, VS, children, amount, current payment status). After a yes, run `falkon applications set-payment <uuid> --status paid`. If the user also wants the confirmation sent, ask, then run `falkon applications send-paid-email <uuid>`. A VS missing from `completed` may sit under another status; rerun with `--status created,completed,accepted`.

### Attendance

```sh
falkon attendance check-in <APPLICANT> --term <UUID> --day mon|tue|wed|thu|fri [--at <RFC3339>] [--reason <REASON>]
falkon attendance check-out <APPLICANT> --term <UUID> --day mon|tue|wed|thu|fri [--at <RFC3339>] [--reason <REASON>]
```

The command reads the applicant's row, then writes that one day with the new arrival or departure time (`--at`, default now) and keeps the other values of the day. Stdout shows the day before and after, for example `Mon: in -, out -  ->  in 08:12, out -`. `--at` takes an offset, for example `2026-07-06T08:12:00+02:00`.

Example, "Anna Nováková arrived at 8:10 on Tuesday":

```sh
falkon attendance list --term <term-uuid>    # find Anna's applicant UUID and today's cell
```

Check-in and check-out replace an arrival or departure time that is already set, and the CLI does not check that `--at` falls on `--day`. So look at the day's current cell first, tell the user if a time is already there and will be replaced, and make sure `--at` is on the calendar day that `--day` means in that term.

Confirm the child, day, and time with the user, then run `falkon attendance check-in <applicant-uuid> --term <term-uuid> --day tue --at 2026-07-07T08:10:00+02:00`. On `aborted`, run `falkon attendance list` again, show the new cell, and confirm with the user before retrying.

Sleepovers, notes, and nights have no typed command. Use `StaffService/UpdateAttendanceDay`, `UpdateAttendanceNote`, or `UpdateAttendanceNight` through `falkon call` (see Discovery), with `expectedUpdatedAt` from the row's `updatedAt` in `falkon --json attendance list`. `UpdateAttendanceDay` writes the whole day, so copy the day's current `arrivedAt` and `leftAt` into the body when you change only `sleepoverAfterDay`, or they are cleared.

### Cancel or restore a child's term

```sh
falkon applicants cancel-term <APPLICANT> --term <UUID> [--reason <REASON>] --yes
falkon applicants restore-term <APPLICANT> --term <UUID> [--acknowledge <code>:<fingerprint>]
```

Take the term UUID from `falkon applicants info <applicant>`; it lists the child's terms with their status. Without `--yes`, `cancel-term` changes nothing and exits 2. Restoring a term makes a cancelled application `completed` again.

Restoring onto a term that is no longer active fails first and lists each warning with the flag to add, for example `rerun with --acknowledge inactive_admin_assignment:<fingerprint>`. Show the user the warnings and add the flags only after they agree.

### Instructor access

```sh
falkon instructors grant <INSTRUCTOR> --term <UUID>
falkon instructors revoke <INSTRUCTOR> --term <UUID> --yes
```

`<INSTRUCTOR>` is the user ID from `falkon instructors list`. Example, "let petr@example.org open turnus 2": find his user ID in `instructors list` and the term UUID in `terms list`, confirm both with the user, then run `falkon instructors grant <user-id> --term <term-uuid>`.

### API tokens

```sh
falkon tokens create --name <NAME> --expires-in <DAYS>     # or --expires-at <RFC3339>
falkon tokens revoke <UUID>
```

Run `tokens create` only when the user asks for a new token. A token created with a token must expire within 90 days. The command prints the new token once on stdout, so send stdout straight into a file only the user can read:

```sh
(umask 077 && falkon tokens create --name <NAME> --expires-in 30 > token.txt)
```

Tell the user the file's path and leave the file unread: no `cat`, no file-reading tool. Revoking the token you are running on ends your access.

## Discovery: any other procedure

The typed commands cover the common tasks. For anything else:

```sh
falkon procedures                            # every procedure with its access note; works offline
falkon procedures AdminTermService/UpdateTerm    # one entry with an example and a minimal request
falkon call <Service/Method> --data '<json>'     # post a JSON object, print the JSON answer
```

`--data` also takes `@<file>` or `-` for stdin, and defaults to `{}`. The `exampleRequest` that `procedures` shows is placeholder data. Use it to learn the field names and which fields are required, and never send it. Build a write body from the record's real current values instead. For example, to change one field of a term:

```sh
falkon --json terms list                       # the term's current values; its revision goes into expectedRevision
falkon procedures AdminTermService/UpdateTerm  # field names and required fields
# write term.json from the real term with the one field changed, show it to the user, get a yes
falkon call AdminTermService/UpdateTerm --data @term.json
```

The access column says whether an admin token can use a procedure. `admin token ok` and `public` work. `browser session only` entries refuse tokens; do not call them. `guest flow (the token owner's own applications)` only sees the admin's own applications, so use the `StaffService` calls for families' data. `/api/prihlaskaPDF` returns a PDF, which `call` cannot print.

Enum values in JSON use their full names, for example `ATTENDANCE_DAY_KEY_MON` or `PAYMENT_STATUS_PAID`. Calls that guard against lost updates take `expectedUpdatedAt` or `expectedRevision`; copy it from a fresh read.

Changes to a whole term (`AdminTermService/UpdateTerm`, `ActivateTerm`, `DeactivateTerm`, `DeleteDraftTerm`) affect every family in it. They take the term's `expectedRevision` and may answer with warnings that need `warningAcknowledgements`. Show the user any warning and get a second yes before you resend with the acknowledgement.

## Reference

- [reference/commands.md](reference/commands.md): the full `--help` of every command. Open it when you need a flag this file does not show.
- [reference/procedures.md](reference/procedures.md): every procedure with request and response types and access. Open it when choosing a procedure for `falkon call`.
