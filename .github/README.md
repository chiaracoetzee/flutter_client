# Tyne for Android

The Android app for [Tyne](https://github.com/tyne-chat/tyne), a chat app for friends and
communities. It is a fork of
[Fluxer's mobile client](https://github.com/fluxerapp/flutter_client), built with Flutter, that
adds Tyne's features:

- **Personas.** Several identities under one account, each with its own name and avatar. Write,
  react and be mentioned as one, and have each channel remember which you last used there.
- **Signals.** The row of emoji above the message box that shows how people are, as on the web.
- **A quick switcher** for jumping between conversations, and timestamps that show in each
  reader's time zone.
- **Updates from this repository.** The app checks the releases here and installs them itself.

## Tyne and Fluxer

Tyne is an independent project. It is not affiliated with, endorsed by or supported by Fluxer
Platform AB. "Fluxer" and the Fluxer logo are trademarks of Fluxer Platform AB; this project uses
the name only to say what it is based on and what it works with, as
[Fluxer's name and marks policy](https://github.com/fluxerapp/fluxer/blob/main/.github/GOVERNANCE.md#name-and-marks)
allows. Because Tyne changes how the app works, that policy asks it to carry its own name and
logo, and it does.

- This is a modified version of Fluxer's mobile client. Its changes are the commits on top of
  Fluxer's `canary` branch; the first were made in 2026.
- The branch you are looking at, `tyne`, is rebuilt on top of Fluxer's latest code regularly, so
  its history is rewritten.
- Problems with Tyne belong in
  [this repository's issues](https://github.com/tyne-chat/tyne-mobile/issues), not with Fluxer.

Fluxer's own README is unchanged in the [repository root](../README.md), with its notes on
building the app.

## Getting Tyne

APKs are on the [releases page](https://github.com/tyne-chat/tyne-mobile/releases). The app is
`chat.tyne.app` and checks that page for updates itself. Only Android is built at the moment.

## Licence

[GNU Affero General Public License, version 3 or later](../LICENSE), the licence Fluxer's client
is published under. Most of the code is copyright Fluxer Platform AB and its contributors; Tyne's
changes are copyright their authors.
