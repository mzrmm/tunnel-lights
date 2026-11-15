# VPN Menu Bar for macOS

**A lightweight, customizable VPN status indicator for your macOS menu bar.**

VPN Menu Bar is a small native macOS utility that displays your current VPN connection status as a single colored dot in the menu bar.

No clutter, no unnecessary text — just a quick visual indication of which VPN is active.

Designed for **Apple Silicon Macs**, with support for **WireGuard** and **Surfshark**.

## Features

- **Minimal menu bar indicator** — A single colored dot shows your VPN status.
- **Automatic VPN detection** — Detects connected VPN services using macOS network configuration.
- **Customizable colors** — Assign your preferred color to each VPN status.
- **Launch at Login** — Option to start automatically when you log in to macOS.
- **Adjustable settings** — Change preferences through a native settings window.
- **Automatic refresh** — Checks your VPN connection every 3 seconds.
- **Lightweight** — Native macOS application built with Swift and AppKit.
- **No account required** — No registration, subscriptions, or external services.

## Default Status Colors

| Status | Default Color | Meaning |
|---|---|---|
| WireGuard | 🔴 Red | WireGuard VPN connected |
| Surfshark | 🔵 Blue | Surfshark VPN connected |
| No VPN | 🟢 Green | No VPN connection detected |
| Unknown | 🟠 Orange | Unknown VPN connection or uncertain status |

All four colors can be customized in the application settings.

**Note:** Green does not guarantee that all network traffic is unencrypted or that no VPN tunnel exists. It means that no active VPN connection was detected through the supported macOS network service checks.

## How It Works

VPN Menu Bar uses macOS system utilities to identify active VPN connections.

It checks the output of:

```bash
scutil --nc list
```

Connected services are identified using their macOS VPN identifiers.

| VPN Client | Identifier |
|---|---|
| WireGuard | `com.wireguard.macos` |
| Surfshark | `com.surfshark.vpnclient.macos` |

The application distinguishes Surfshark from WireGuard even when Surfshark uses the WireGuard protocol.

If an active connection cannot be identified, the indicator displays the configured unknown-status color.

The status is refreshed automatically every three seconds.

### Detection Limitations

Some VPN applications do not expose their connection status through `scutil --nc list`.

Consequently, VPN Menu Bar may not detect every VPN client or network tunnel. It is a visual status utility, not a security monitor, firewall, or VPN kill switch.

## Installation

### Requirements

- macOS 13 or later (target version)
- Apple Silicon Mac (M1 or newer)
- Apple Command Line Tools for building from source

### Build from Source

**1. Download the project**

Clone the repository:

```bash
git clone https://github.com/YOUR-USERNAME/VPN-Menu-Bar.git
```

Or download the source code as a ZIP file from GitHub.

**2. Install Apple's Command Line Tools**

If they are not already installed:

```bash
xcode-select --install
```

You do not need the full Xcode application.

**3. Build the application**

Open Terminal in the project directory and run:

```bash
bash build.command
```

The script compiles the application and creates:

```text
build/VPN Menu Bar.app
```

**4. Install**

Move `VPN Menu Bar.app` into your Applications folder.

Launch the application and look for the colored dot in your macOS menu bar.

Because the application is built locally and is not distributed through the Mac App Store, macOS may display a security confirmation when opening it for the first time.

## Settings

Click the colored menu bar dot and select **Settings…**.

### Custom Colors

Choose individual indicator colors for:

- WireGuard
- Surfshark
- No VPN
- Unknown VPN

Color preferences are saved locally and restored when the application starts.

### Launch at Login

Enable **Launch at Login** to start VPN Menu Bar automatically when you sign in to your Mac.

For reliable automatic startup, move the application into `/Applications` before enabling this option.

You can also manage startup applications in:

**System Settings → General → Login Items & Extensions**

## Privacy

VPN Menu Bar is designed to operate locally.

- No account or registration required.
- No VPN passwords or credentials are collected.
- No analytics or tracking services are required.
- No VPN connection data needs to be sent to external servers.
- Preferences are stored locally on your Mac.

The application reads macOS network service information to determine VPN connection status.

## Technology

- **Language:** Swift
- **Platform:** macOS
- **Interface:** AppKit / native macOS controls
- **VPN detection:** `scutil`
- **Preferences:** Local macOS settings storage
- **Architecture:** Apple Silicon (ARM64)

## Roadmap

Potential improvements include:

- Support for additional VPN clients.
- More detailed VPN connection information.
- Customizable indicator size.
- Optional connection-change notifications.
- Improved detection of VPNs using Network Extensions.
- Universal binary support for Intel and Apple Silicon Macs.

## Contributing

Contributions, bug reports, and feature suggestions are welcome.

If you encounter an issue, please open a GitHub issue and include:

- Your macOS version.
- Your VPN client and version.
- The expected behavior.
- The actual behavior.

For VPN detection issues, the output of `scutil --nc list` may help. Please remove any sensitive information before posting diagnostic output.

## Disclaimer

VPN Menu Bar is an independent utility and is not affiliated with, endorsed by, or sponsored by WireGuard or Surfshark.

The application provides a convenient visual indication of VPN connection status but should not be relied upon as proof of network security, privacy, or VPN connectivity.

## License

No license has been selected yet. Add a `LICENSE` file to specify the terms under which others may use, modify, and distribute this project.

---

Made for macOS. Simple VPN visibility, right in your menu bar.
