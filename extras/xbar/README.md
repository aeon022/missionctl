# xbar / SwiftBar plugin

Menu bar view of **timectl** and **habctl**: the running timer (with a Stop button) or "habits done today" (`◔ 2/6`), and a dropdown to check habits off. Refreshes every minute, after each click right away.

```bash
cp missionctl.1m.sh ~/Library/Application\ Support/xbar/plugins/
chmod +x ~/Library/Application\ Support/xbar/plugins/missionctl.1m.sh
```

SwiftBar: copy into your SwiftBar plugin folder instead. Needs `timectl` and/or `habctl` on the PATH (`~/.local/bin` and Homebrew are looked up). Without them the plugin shows an install link. A habit name containing a double quote cannot be checked from the menu.
