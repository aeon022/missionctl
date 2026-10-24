# Vermögens-Karte (Entwurf, 2026-10-24)

**Befund:** budgetctl kennt keinen Kontostand, nur Transaktionen. Die Summe importierter Buchungen ist kein Saldo, weil Exporte mitten in der Historie beginnen. Eine „Vermögen“-Karte aus budgetctl + investctl wäre ohne Anker irreführend.

## Lösung
1. **budgetctl: Anfangsbestand pro Konto** — `budgetctl account balance NAME --as-of 2026-10-01 --amount 1234,50` speichert einen Ankerpunkt (Datum + Betrag). Saldo = Anker + alle Buchungen nach dem Datum. Ohne Anker zeigt budgetctl keinen Saldo („kein Anfangsbestand gesetzt“), nie einen geratenen.
2. `budgetctl balance --json` liefert pro Konto Saldo und Ankerdatum.
3. **missionctl Dashboard/`status`:** Karte „Vermögen“ = Summe der Salden mit Anker + investctl-Depotwert, **je Währung getrennt** (keine Umrechnung in v1). Konten ohne Anker werden als „n Konten ohne Anfangsbestand“ gemeldet.

## Nicht in v1
Wechselkurse, Verbindlichkeiten/Kredite, Verlaufsdiagramm (später: täglicher Snapshot in missionctl-core).
