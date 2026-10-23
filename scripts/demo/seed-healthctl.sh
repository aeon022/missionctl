#!/usr/bin/env bash
# Fictional medications for the healthctl GIF (runs inside the throwaway HOME).
set -e
healthctl add "Vitamin D" --dose "1000 IU" --time 08:00 >/dev/null
healthctl add Magnesium --dose "250 mg" --time 08:00,20:00 >/dev/null
healthctl add Allergy-Tab --dose "10 mg" --time 07:30 --days mon,wed,fri >/dev/null
healthctl add Omega-3 --dose "1 g" --time 23:30 >/dev/null
for m in "Vitamin D" Allergy-Tab; do healthctl take "$m" >/dev/null 2>&1 || true; done
healthctl take Magnesium >/dev/null 2>&1 || true
