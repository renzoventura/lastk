# LastK

**Your runs. Your vibe. One tap to share.**

LastK turns your Strava runs into shareable cards with your own photos and stickers—no design skills required. Pick a run, pick a background, add some flair, and post.

---

## What’s the deal?

You run. Strava tracks it. LastK makes it look good.

Log in with Strava, scroll your run feed, tap a run, choose a photo from your camera roll, tweak it in the editor, throw on stickers (distance, pace, location, etc.), then **Save** to your photos or **Share** to Instagram, Messages, or wherever. The whole flow stays inside the app: feed → background picker → editor → export.

---

## Features

### Strava

- **Sign in with Strava** — OAuth; no separate account.
- **Run feed** — Your runs in a clean grid, newest first, with infinite scroll.

### Run cards

- **Map preview** — Each card shows the route on a 1:1 map (from Strava’s polyline).
- **Stats at a glance** — Distance (e.g. 5.42 km), pace (e.g. 5:17/km), and date right on the card.
- **Tap to customize** — Tap a card to pick a background and open the editor.

### Background selection

- **Camera Roll** — Browse Recents, Favorites, All Albums, or any album.
- **Instagram-style grid** — 3-column photo grid, smooth scrolling.
- **One tap** — Select a photo and the editor opens with that image.

### Photo editor

- **Zoom & pan** — Pinch to zoom (0.25×–4×), drag to move; you can even drag the image off-screen for a cropped look.
- **Stickers** — Floating “+” button opens a sticker picker. Add distance badges, location, pace, elevation, time, and more. Stickers are draggable and pinchable; they stay within the canvas and keep aspect ratio.
- **Save** — Export the current canvas (image + stickers) to your photo library.
- **Share** — Same export via the system share sheet (Stories, Messages, etc.).
- **Clean layout** — Black top (Back) and bottom (Story / Save / Share), gray canvas. Sticker button floats over the canvas.

### Stickers

- **Pre-made options** — e.g. “5.42 KM”, “San Francisco”, “5:17 /km”, “120 m”, “32:04”, “42 KM”, “10K” (mock set; can be wired to run data later).
- **Drag to move, pinch to resize** — Each sticker keeps its own position and scale.
- **Included in export** — Whatever you see in the editor is what gets saved and shared.

### Tech & UX

- **SwiftUI + Swift 6** — `@Observable`, modern concurrency, no `ObservableObject`.
- **iOS 26** — Liquid glass where used; native feel.
- **Maps** — MapKit snapshots for route thumbnails; no third-party map SDKs.
- **Photos** — Photo library for camera roll and saving; no cloud dependency for images.

---

## Flow in one sentence

**Strava → Run feed → Tap run → Pick photo → Edit (zoom/pan + stickers) → Save or Share.**

---

## Secrets & API keys

**You’re not committing any secrets.** Strava client ID and client secret are read at runtime from:

- **Environment variables** — `STRAVA_CLIENT_ID` and `STRAVA_CLIENT_SECRET` (e.g. in the Xcode scheme: Edit Scheme → Run → Arguments → Environment Variables), or  
- **Info.plist** — if you add them under the target’s custom keys.

The code in `StravaConfiguration.swift` does not hardcode these values. **Keep it that way:** don’t add your real client secret to any committed file. Use a local `.xcconfig` (and add it to `.gitignore`) or scheme env vars so only your machine has the secret.

---

## Requirements

- iOS 26+
- Strava account
- Photo library access (for choosing backgrounds and saving)

---

## Project layout

- **Feed** — Run cards, feed VM, map snapshot, polyline decoding.
- **Profile** — Athlete summary when logged in.
- **Strava** — Auth, API client, token store, config.
- **BackgroundSelection** — Photo library service, album picker, photo grid, sticker model/picker/overlay, zoomable canvas, editor, export.

---

*LastK — because the last K is the one you share.*
