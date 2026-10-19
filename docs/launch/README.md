# Launch-Entwürfe (nichts davon ist veröffentlicht)

Stand 2026-10-19. Alles hier ist **Entwurf**: nichts wird ohne ausdrückliche Freigabe gepostet, gesendet oder als Pull Request geöffnet.
Vor dem Veröffentlichen prüfen: Zahlen (Stars, Downloads, Tool-Anzahl), Preise, Links, und dass der Release v0.5.0 wirklich live ist.

| Datei | Inhalt | Wann |
|---|---|---|
| `show-hn.md` | Titel, Beschreibung, erster Kommentar, Antwortbausteine | Di–Do morgens nach dem Release (nicht Sonntag) |
| `reddit.md` | Varianten für r/commandline, r/ClaudeAI, r/selfhosted (Regeln der Subreddits vorher lesen) | 1.11. bis Woche 1, je ein Subreddit pro Tag |
| `blog-mcp-absichern.md` | Artikelentwurf „Wie wir MCP-Server absichern“ | 1.11. |
| `verzeichnisse.md` | Einträge für MCP-/awesome-Listen | nach dem Release |

Faktenbasis (geprüft am 2026-10-19):
- postctl Pro: €4,90/Monat oder €39/Jahr, Launch-Code −37 % (Yearly, bis 31.12.2026); Core bleibt kostenlos (MIT), 2 verbundene Netzwerke.
- Veröffentlichen über MCP ist aus, bis `POSTCTL_MCP_ALLOW_PUBLISH=1` gesetzt ist (postctl README).
- Destruktive MCP-Tools in healthctl verlangen `confirm=true` („Bremse, kein Schloss“, so steht es im Code).
- Alle Daten bleiben lokal (SQLite); Lizenzprüfung ruft nur die Polar-API (postctl Pro).
- Ban-Schutz (postctl): überfällige Posts werden in 20-Minuten-Schritten verteilt, X hat 60 Minuten Mindestabstand (`internal/scheduler/scheduler.go`). Keine allgemeinen Rate-Limits behaupten.
- Scheduler-Dienst: `postctl daemon install` ist nur macOS (launchd); Linux-Binaries gibt es, einen systemd-Dienst nicht.
- Keine Zahlen zu Nutzern oder Umsatz erfinden.
