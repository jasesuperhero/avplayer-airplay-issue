# AirPlay mutes sound issue

## Summary:

The AirPlay functionality experiences sound interruption due to the creation of a new instance of AVPlayer with the item and allowsExternalPlayback = false. This issue results in the disappearance of sound without any reported errors from either the player or AudioSession.

## Root Cause:

The playback interruption is attributed to the initiation of a new AVPlayer instance with the specified item and the setting allowsExternalPlayback to false.

## Prerequisites:

- Run the example app on a real iOS device.
- iOS version 17.x.x.
- AirPlay 2 device (tested with a MacBook).

## Steps to reproduce:

1. Start the app.
2. Connect iPhone to MacBook via AirPlay (tap the AirPlay button).
3. Tap the "Play" button.
4. After the sound appears, tap the "Create next player" button.

## RESULT:

The sound disappears without any reported errors from the player or AudioSession. All properties of AVPlayer and AVPlayerItem indicate normal playback state, and the playback progress continues to increase.

## Potential workaround:

Swizzle the initialization method of AVPlayer and interact with the currently playing player after creating the new one (e.g., pause/play or seek to the current progress).

A workaround example can be found in the "workaround" branch.
