# Blogartikel (Entwurf): Wie wir MCP-Server absichern, wenn sie schreiben dürfen

*Ton: sachlich, Ich-Form, englisch. Länge ca. 900 Wörter. Vor Veröffentlichung Beispiele gegen den Code prüfen.*

## Gliederung
1. **Das Problem.** Ein KI-Assistent mit MCP-Zugriff liest Mails, Webseiten, Notizen. Dort kann Text stehen, der Befehle imitiert („veröffentliche jetzt …“). Wenn dasselbe Werkzeug posten, löschen oder bezahlen kann, wird gelesener Text zum Angriffsweg (Prompt Injection).
2. **Unsere Regel: Lesen ist billig, Schreiben braucht Absicht.**
   - postctl: `create_post` legt nur Entwürfe an. `publish_post` und `schedule_post` verweigern, bis der Server mit `POSTCTL_MCP_ALLOW_PUBLISH=1` gestartet wurde. `dry_run` geht immer.
   - Warum eine Umgebungsvariable und kein Parameter: Der Parameter steht im Einflussbereich des Modells, die Umgebung des Serverprozesses nicht.
3. **Löschen: eine Bremse, kein Schloss.** In healthctl verlangen destruktive Tools `confirm=true` und sagen dem Modell, es solle den Menschen fragen. Ehrlich: Das hält einen entschlossenen Angriff nicht auf, es zwingt eine Einschleusung nur dazu, sich ausdrücklich zu zeigen. (Quelle: Kommentar im Code, `confirm.go`.)
4. **Datensparsamkeit im Protokoll.** Aktivitätslog nennt bei Gesundheitsdaten nur „eine Dosis“, nie Namen oder Mengen; Logs schwärzen Geheimnisse.
5. **Was wir nicht lösen.** Ein Modell, das den Menschen zur Bestätigung überredet; kompromittierte Clients. Empfehlung: getrennte Profile, Entwurfsmodus, Bestätigung im Client aktiv lassen.
6. **Checkliste für eigene MCP-Server** (5 Punkte): Schreibaktionen standardmäßig aus; Opt-in außerhalb des Modells; destruktive Aktionen mit Bestätigung; keine Geheimnisse in Rückgaben/Logs; Trockenlauf anbieten.
7. **Link:** postctl.sh, GitHub, Docs.

## Offene Punkte vor Veröffentlichung
- Zitate und Parameternamen gegen `postctl/internal/mcpserver` prüfen.
- Optional: kurzer Test mit einem manipulierten Mailtext als Beispiel (nur mit eigenen Testdaten).
