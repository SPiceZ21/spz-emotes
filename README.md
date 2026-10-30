# spz-emotes

> Emote menu: dances, gestures, poses, shared emotes, walk styles and moods.

![version](https://img.shields.io/badge/version-1.0.0-ff6200) ![SPiceZ-Core](https://img.shields.io/badge/SPiceZ--Core-beta-18181b)

## Overview

`O` opens an emote menu with search, categories, favourites and animated previews. `/e <name>` plays one directly, `X` stops it. Shared emotes (handshake, hug, high five) ask the nearest player to accept.

## Features

- ~100 base-game emotes
- Animated previews
- Favourites
- Shared two-player emotes
- Walk styles and moods that persist

## Requirements

| Resource | Type |
|---|---|
| `ox_lib` | third-party |
| `spz-core` | SPiceZ module |

## Installation

Included in the [txAdmin recipe](https://github.com/SPiceZ21/spz-txrecipe). Manual install:

1. Download `spz-emotes` from GitHub (latest release, or the repository) into your `resources` folder.
2. Add to `server.cfg`, after its requirements:

```cfg
ensure spz-emotes
```

## Configuration

- `config.lua`

See the file for every option.

## Commands

| Command | Who | Description |
|---|---|---|
| `/e` | player | `/e <name>` play an emote, `/e` stop |
| `/emotes` | player | Open the menu |

## Key binds

Rebindable in **Settings → Key Bindings → FiveM**.

| Action | Default |
|---|---|
| Emotes: open menu | `O` |
| Emotes: stop emote | `X` |

## Exports

| Export | Side |
|---|---|
| `OpenMenu` | client |
| `Play` | client |
| `Stop` | client |

```lua
exports["spz-emotes"]:OpenMenu(...)
```

---

Part of **SPiceZ-Core** — [documentation](https://github.com/SPiceZ21/Docs) · [all modules](https://github.com/SPiceZ21/Docs/blob/main/modules/README.md)
