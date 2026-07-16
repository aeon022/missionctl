# Releasing — missionctl suite

Jedes Tool released unabhängig über goreleaser + GitHub Actions. Ein Release = ein Git-Tag.

## Ein Tool releasen

```bash
cd <tool>            # z.B. cd taskctl
git tag v0.1.0
git push origin v0.1.0
```

Das war's. Der `release`-Workflow baut dann automatisch:

1. macOS-Binaries (arm64 + amd64, CGO-frei, Version per ldflags injiziert)
2. GitHub Release mit `.tar.gz`-Archiven + `checksums.txt` + Changelog
3. Homebrew-Formula-Update in [aeon022/homebrew-tap](https://github.com/aeon022/homebrew-tap)

Danach installierbar mit:

```bash
brew install aeon022/tap/<tool>
```

## Einmalige Einrichtung (noch offen)

Der Homebrew-Schritt braucht ein Secret, das nur du anlegen kannst:

1. **Fine-grained PAT erstellen**: github.com → Settings → Developer settings →
   Fine-grained tokens → Repository access: nur `aeon022/homebrew-tap` →
   Permissions: **Contents: Read and write**
2. **Als Secret in jedes Tool-Repo setzen**:

```bash
for repo in mailctl calctl taskctl notectl budgetctl habctl timectl diaryctl missionctl-cli; do
  gh secret set HOMEBREW_TAP_TOKEN --repo aeon022/$repo --body "<DEIN_PAT>"
done
```

Ohne das Secret schlägt der Homebrew-Publish-Schritt fehl (Release-Assets auf GitHub
werden trotzdem erstellt).

## CI

Jedes Repo hat zusätzlich `ci.yml`: `go vet` + `go test` + `go build` auf macos-latest
bei jedem Push auf `main` und jedem PR.

## Versionierung

- Jedes Tool: `<tool> version` und `<tool> --version` (Cobra)
- Lokale Builds zeigen `dev`; Release-Builds bekommen die Tag-Version über
  `-ldflags "-X github.com/aeon022/<tool>/cmd.Version={{ .Version }}"`

## Offene Punkte

- [ ] `HOMEBREW_TAP_TOKEN` Secret setzen (siehe oben)
- [ ] LICENSE-Entscheidung: Kein Repo hat aktuell eine LICENSE-Datei. Für den
  Monetarisierungsplan (Open Source + bezahlte Binaries/Lizenz) bietet sich MIT an —
  muss aber bewusst entschieden werden, bevor die Repos beworben werden.
- [ ] Erste Tags setzen (Vorschlag: überall `v0.1.0` nach dem nächsten Commit)
