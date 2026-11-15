# VPN Menu Bar for macOS

A lightweight macOS menu bar app that displays your VPN connection status as a single colored dot.

Built with Swift for **Apple Silicon Macs**. Supports **WireGuard, Surfshark, and Tunnelblick**.

## Features

- Minimal menu bar indicator with a larger, easy-to-see dot
- Automatic VPN detection every 3 seconds
- Customizable colors for each VPN status
- Optional automatic launch at login
- Native macOS settings window
- Free, lightweight, and open source

## Status Colors

| Color | Status |
|---|---|
| 🔴 Red | WireGuard connected |
| 🔵 Blue | Surfshark connected |
| 🟣 Purple | Tunnelblick connected |
| 🟢 Green | No VPN detected |
| 🟠 Orange | Unknown VPN or status |

All colors can be customized in **Settings**.

## Installation

**Requirements:** macOS 13 or later, Apple Silicon (M1 or newer).

### Download

1. Download the latest ZIP from [GitHub Releases](../../releases).
2. Extract `VPN Menu Bar.app`.
3. Move it to your **Applications** folder.
4. Launch the app.

### Build from Source

Install Apple's Command Line Tools if needed:

```bash
xcode-select --install
```

Run the build script from the project directory:

```bash
bash build.command
```

The compiled app will be created at:

```text
build/VPN Menu Bar.app
```

## Settings

Click the menu bar dot and select **Settings…** to customize status colors and enable or disable **Launch at Login**.

Preferences are stored locally.

## How It Works

VPN Menu Bar uses macOS `scutil --nc list` to detect supported VPN connections and checks the OpenVPN process to identify Tunnelblick.

Detection is not guaranteed to be complete or instantaneous. Some VPN clients may not be recognized, and Tunnelblick may appear connected while OpenVPN is still establishing its connection.

## Privacy

VPN Menu Bar operates locally and requires no account, analytics, tracking, or external service to check VPN status.

## Disclaimer

**VPN Menu Bar is provided as a free, open-source utility for informational purposes only.**

VPN detection may be incomplete, delayed, or inaccurate. The application does not guarantee that a VPN connection is active, that internet traffic is encrypted, or that your identity or data is protected.

**A green indicator means no supported VPN connection was detected. It does not guarantee that your network connection is secure.**

VPN Menu Bar is not a security tool, firewall, or VPN kill switch. Users should verify their VPN connection using their VPN provider's official application.

The software is provided without warranties, subject to applicable law. See the [LICENSE](LICENSE) file for details.

## Contributing

Bug reports, suggestions, and pull requests are welcome.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

VPN Menu Bar is an independent project and is not affiliated with WireGuard, Surfshark, or Tunnelblick.
