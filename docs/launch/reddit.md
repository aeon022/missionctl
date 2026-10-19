# Reddit (Entwürfe)

Regeln vorher lesen: viele Subreddits verlangen Selbstwerbung nur als Teil aktiver Teilnahme; Flair beachten; nicht mehrere Subreddits am selben Tag.

## r/commandline
**Titel:** I built a terminal scheduler for social media posts (Markdown in, scheduled posts out)

Text: Short intro (2 Sätze), GIF `postctl/docs/demo.gif`, was es tut (Markdown + Frontmatter, `postctl import`, TUI-Kalender, Scheduler-Dienst, Profile), Link GitHub. Ehrlich: Pro ist ein Abo, Core MIT kostenlos für 2 Netzwerke. Frage am Ende: „Welche Plattform fehlt dir?“

## r/ClaudeAI
**Titel:** An MCP server for social posts that can't publish unless you allow it

Text: Fokus auf die Sicherheitsentscheidung (Publish/Schedule per MCP aus, bis `POSTCTL_MCP_ALLOW_PUBLISH=1`; Drafts gehen immer; `dry_run` immer). Warum: Prompt Injection über gelesene Mails/Webseiten. Link auf den Blogartikel. Frage: „Wie geht ihr mit schreibenden MCP-Tools um?“

## r/selfhosted
**Titel:** postctl: self-hosted social media scheduler, no SaaS, data in local SQLite

Text: Local-first, kein Cloud-Konto, Scheduler als launchd/systemd-Dienst, Daten lokal, Lizenzprüfung nur bei Pro. Klar sagen, dass Plattform-APIs (Meta, X) natürlich eigene Zugangsdaten brauchen. Link GitHub und Docs.

**Nicht behaupten:** Nutzerzahlen, „beliebt“, Vergleiche mit konkreten Zahlen, die nicht stimmen.
