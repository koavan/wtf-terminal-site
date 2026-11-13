# Install

Download builds from the
[GitHub releases](https://github.com/koavan/wtf-terminal/releases) page.

## macOS

Download the `.dmg` from the latest release and drag **wtf** to Applications.

To build from source you need Xcode (the full app, not only the Command Line
Tools) and Go 1.25+:

```sh
macos/build.sh                          # bin/native/wtf.app
macos/build.sh release universal dmg    # arm64 + x86_64 and a .dmg
```

## Linux

Use the `.deb` (Ubuntu 24.04+, Debian 13+) or `.rpm` (Fedora 40+) for your
processor from the release:

```sh
sudo apt install ./wtf_<version>_amd64.deb
sudo dnf install ./wtf-<version>-1.x86_64.rpm
```

It replaces an older Wails build of wtf and keeps your windows and settings
(`~/.config/wtf`).

## Next

Start with [Welcome to wtf](manual/getting-started.md).
