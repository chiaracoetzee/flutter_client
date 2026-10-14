#!/usr/bin/env python3
"""Gives the iOS project of the shipped flavour (canary) Tyne's identity instead of Fluxer's.

The fork does not commit these changes to upstream's Xcode project, entitlements and Swift
files: they would conflict with upstream on every nightly rebase that touches nearby lines.
The TestFlight workflow (.github/workflows/fork-ios-testflight.yml) runs this script on its
fresh checkout before building; run it the same way before a local build, and undo it with
`git checkout -- ios` afterwards.

Each change checks that upstream's text is still there and stops with an error when it is
not, so a rename upstream fails the build instead of shipping a half-renamed app. Running the
script twice is harmless.

Usage: tool/fork_ios_identity.py [--team-id TEAM_ID]
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

BUNDLE_ID = "chat.tyne.app"
APP_GROUP = "group.chat.tyne"
DOMAIN = "temple.hypersystem.xyz"
LINK_SCHEME = "tyne"
DEFAULT_TEAM_ID = "2VU375L9T2"

UPSTREAM_TEAM_ID = "3G5837T29K"
UPSTREAM_CANARY_BUNDLE_ID = "com.fluxer.canary"
UPSTREAM_APP_GROUP = "group.com.fluxer"


class IdentityError(Exception):
    pass


def rewrite(relative: str, *changes: tuple[str, str] | tuple[str, str, str]) -> None:
    """Applies changes to a file: (text, replacement) or (regex, replacement, applied).

    A change that no longer matches is fine only when its result is already there (the
    script ran before): the replacement for plain text, `applied` for a regex. Otherwise
    upstream changed the file and this script has to follow.
    """
    path = ROOT / relative
    text = path.read_text()
    for change in changes:
        if len(change) == 3:
            pattern, replacement, applied = change
            text, count = re.subn(pattern, replacement, text)
        else:
            pattern, replacement = change
            applied = replacement
            count = text.count(pattern)
            text = text.replace(pattern, replacement)
        if count == 0 and applied not in text:
            raise IdentityError(f"{relative}: upstream's text is gone: {pattern!r}")
    path.write_text(text)
    print(f"Updated {relative}")


def plist_string_array(key: str, values: list[str]) -> tuple[str, str, str]:
    """Replaces the whole <array> of strings under `key` in a plist file."""
    items = "".join(f"\n\t\t<string>{value}</string>" for value in values)
    return (
        rf"(<key>{re.escape(key)}</key>\s*<array>)(?:\s*<string>[^<]*</string>)*(\s*</array>)",
        rf"\g<1>{items}\g<2>",
        f"<key>{key}</key>\n\t<array>{items}",
    )


def apply(team_id: str) -> None:
    rewrite(
        "ios/Runner.xcodeproj/project.pbxproj",
        # The canary configurations of the app and its three extensions.
        (
            rf"PRODUCT_BUNDLE_IDENTIFIER = {re.escape(UPSTREAM_CANARY_BUNDLE_ID)}"
            r"(\.(?:BroadcastExtension|NotificationService|ShareExtension))?;",
            rf"PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID}\1;",
            f"PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};",
        ),
        (f"DEVELOPMENT_TEAM = {UPSTREAM_TEAM_ID};", f"DEVELOPMENT_TEAM = {team_id};"),
        # Read by the share extension and receive_sharing_intent as AppGroupId.
        (f"CUSTOM_GROUP_ID = {UPSTREAM_APP_GROUP};", f"CUSTOM_GROUP_ID = {APP_GROUP};"),
        ('INFOPLIST_KEY_CFBundleDisplayName = "Fluxer Canary";', "INFOPLIST_KEY_CFBundleDisplayName = Tyne;"),
        ('INFOPLIST_KEY_CFBundleDisplayName = "Fluxer Screen Share";', 'INFOPLIST_KEY_CFBundleDisplayName = "Tyne Screen Share";'),
        ('INFOPLIST_KEY_CFBundleDisplayName = "Share to Fluxer";', 'INFOPLIST_KEY_CFBundleDisplayName = "Share to Tyne";'),
    )

    keychain_groups = [f"$(AppIdentifierPrefix){BUNDLE_ID}"]
    rewrite(
        "ios/Runner/Runner.entitlements",
        (UPSTREAM_APP_GROUP, APP_GROUP),
        plist_string_array("keychain-access-groups", keychain_groups),
        # Passkeys and saved passwords of the instance. No applinks: like the Android app, Tyne
        # does not claim the instance's https links.
        plist_string_array("com.apple.developer.associated-domains", [f"webcredentials:{DOMAIN}"]),
    )
    rewrite(
        "ios/NotificationService/NotificationService.entitlements",
        (UPSTREAM_APP_GROUP, APP_GROUP),
        plist_string_array("keychain-access-groups", keychain_groups),
    )
    rewrite("ios/ShareExtension/ShareExtension.entitlements", (UPSTREAM_APP_GROUP, APP_GROUP))
    rewrite("ios/BroadcastExtension/BroadcastExtension.entitlements", (UPSTREAM_APP_GROUP, APP_GROUP))

    rewrite(
        "ios/Runner/Info.plist",
        ("<key>CFBundleName</key>\n\t<string>fluxer</string>", "<key>CFBundleName</key>\n\t<string>Tyne</string>"),
        # Tyne opens tyne:// links, like the Android app, and leaves fluxer:// to Fluxer's app.
        # The sign-in callback (fluxer://auth/sso/callback) needs no registration: the web
        # authentication session catches it itself.
        (
            "<key>CFBundleURLName</key>\n\t\t\t<string>fluxer</string>\n"
            "\t\t\t<key>CFBundleURLSchemes</key>\n\t\t\t<array>\n\t\t\t\t<string>fluxer</string>",
            f"<key>CFBundleURLName</key>\n\t\t\t<string>{LINK_SCHEME}</string>\n"
            f"\t\t\t<key>CFBundleURLSchemes</key>\n\t\t\t<array>\n\t\t\t\t<string>{LINK_SCHEME}</string>",
        ),
        # The screen-share extension's app group, read by flutter_webrtc.
        (
            f"<key>RTCAppGroupIdentifier</key>\n\t<string>{UPSTREAM_APP_GROUP}</string>",
            f"<key>RTCAppGroupIdentifier</key>\n\t<string>{APP_GROUP}</string>",
        ),
    )
    rewrite("ios/Runner/Assistant/AssistantDefaults.swift", (f'"{UPSTREAM_APP_GROUP}"', f'"{APP_GROUP}"'))
    rewrite("ios/BroadcastExtension/SampleHandler.swift", (f'"{UPSTREAM_APP_GROUP}"', f'"{APP_GROUP}"'))

    # The canary flavour's app icon. Written by tyne-tools scripts/install_icon_kit.py.
    icon_source = ROOT / "tool" / "fork_ios" / "CanaryAppIcon.icon"
    icon_target = ROOT / "ios" / "Runner" / "CanaryAppIcon.icon"
    if not (icon_source / "icon.json").is_file():
        raise IdentityError(f"{icon_source.relative_to(ROOT)} is missing")
    if not icon_target.is_dir():
        raise IdentityError(f"{icon_target.relative_to(ROOT)} is gone upstream")
    shutil.rmtree(icon_target)
    shutil.copytree(icon_source, icon_target)
    print(f"Replaced {icon_target.relative_to(ROOT)}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--team-id", default=DEFAULT_TEAM_ID)
    args = parser.parse_args(argv)
    if not re.fullmatch(r"[A-Z0-9]{10}", args.team_id):
        parser.error("--team-id must be a 10-character Apple team ID")
    try:
        apply(args.team_id)
    except IdentityError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
