# Twist Engine Alpha v2 — Documentation for Beginners

## Table of Contents
1. [Why This Version?](#why-this-version)
2. [Getting Started](#getting-started)
3. [Main Menu](#main-menu)
4. [Chart Editor](#chart-editor)
5. [Creating a New Song](#creating-a-new-song)
6. [Stage Editor](#stage-editor)
7. [Character Editor](#character-editor)
8. [Week Editor](#week-editor)
9. [Mods Manager](#mods-manager)
10. [Stage Preview](#stage-preview)
11. [Split Vocals](#split-vocals)
12. [Importing Songs from Psych Engine](#importing-songs-from-psych-engine)
13. [File Structure](#file-structure)
14. [Keyboard Shortcuts](#keyboard-shortcuts)
15. [Troubleshooting](#troubleshooting)

---

## Why This Version?

The original Twist Engine Alpha was archived in an unfinished state with many issues:

| Problem | Original | Fixed Version |
|---|---|---|
| **Compilation** | Many compilation errors, wouldn't build with current libraries | All errors fixed, CI/CD builds working |
| **Stage Editor crash** | Crashed when removing default characters (bf, dad, gf) | Fixed with null-safety checks |
| **Stage Preview** | Not functional | Working alpha — shows characters and stage behind notes |
| **Mods loading** | Hardcoded to specific mod ("5rubles"), other mods wouldn't load | Loads any mod correctly |
| **New Song creation** | Required manually creating folders and JSON files | Built-in "Create Song" button in Chart Editor |
| **Week Editor** | Didn't exist | Full Week Editor accessible from editors menu |
| **Mods Manager** | Didn't exist | Mod browser with enable/disable, accessible from main menu |
| **Split Vocals** | Only Voices_Player/Voices_Opponent format | Also supports Voices-bf.ogg / Voices-dad.ogg |
| **Undo/Redo in Stage Editor** | Didn't exist | CTRL+Z / CTRL+Y support |
| **Character Editor silhouettes** | Disabled | Working, toggle with G key |

---

## Getting Started

### Installation
1. Download the latest release from [Releases](https://github.com/FrostiXS/TwistEngine-Alpha-v2/releases)
2. Extract the ZIP file
3. Run `TwistEngine.exe`

### First Launch
The engine starts at the **Title Screen**. Press ENTER to go to the **Main Menu**.

---

## Main Menu

The main menu has these options:
- **Story Mode** — Play through weeks in order
- **Freeplay** — Play any unlocked song
- **Options** — Configure settings (including DEV tab with Stage Preview toggle)
- **Credits** — View credits

### Hidden Controls
- **Press 7** — Opens the **Editors Menu** (Chart Editor, Character Editor, Stage Editor, Week Editor)
- **Press M** — Opens the **Mods Manager**

---

## Chart Editor

The Chart Editor is where you create and edit song charts (note patterns).

### How to Open
1. From **Freeplay**, select a song and press **7**
2. Or from **Main Menu**, press **7** → select **Chart Editor**

### Interface
The editor has a **note grid** in the center and **tabs** on the right:
- **Song** tab — Song settings, BPM, speed, characters, stage, save/load
- **Charting** tab — Grid settings, stage preview toggle, waveform options
- **Properties** tab — Song metadata (artist, charter)

### Placing Notes
- **Left click** on the grid to place a note
- **Right click** to delete a note
- Notes on the **left side** are for the opponent (dad)
- Notes on the **right side** are for the player (boyfriend)

### Saving
Click **"Save"** in the Song tab. A file dialog will open — save the JSON file to `data/songname/songname.json`.

---

## Creating a New Song

### Method 1: Built-in Create Song (Recommended)
1. Open the **Chart Editor** (Main Menu → press 7 → Chart Editor)
2. Go to the **Song** tab (right panel)
3. Find the **"New Song Name"** field — type your song name
4. Set the **"New Song BPM"** — adjust the BPM stepper
5. Click **"Create Song"** (green button)
6. The engine automatically creates:
   - `data/your-song/your-song.json` (empty chart template)
   - `songs/your-song/` (folder for audio)
7. The editor reloads with your new song

### Method 2: Manual
1. Create folder: `assets/songs/my-song/`
2. Place `Inst.ogg` in that folder (your instrumental track)
3. Optionally place vocal files:
   - `Voices.ogg` (combined vocals)
   - OR `Voices-bf.ogg` + `Voices-dad.ogg` (split vocals)
4. Create folder: `assets/data/my-song/`
5. Copy an existing chart JSON and rename it to `my-song.json`
6. Open Chart Editor, select your song from the dropdown

### Audio Requirements
- Format: **OGG Vorbis** (.ogg)
- You can convert from MP3/WAV using [Audacity](https://www.audacityteam.org/) (File → Export → Export as OGG)

---

## Stage Editor

Create and edit stages (backgrounds) for songs.

### How to Open
Main Menu → press 7 → **Stage Editor**

### Features
- Drag and drop stage sprites
- Set character positions (boyfriend, girlfriend, opponent)
- Configure camera positions
- Set zoom level
- **Undo/Redo**: CTRL+Z / CTRL+Y

### Saving
- **Save JSON** — Saves stage configuration as JSON
- **Save Lua** — Exports as Lua script for compatibility

### Important
When you set character positions in Stage Editor, those positions are used in the Chart Editor's Stage Preview. This ensures characters appear exactly where you placed them.

---

## Character Editor

Edit character sprites and animations.

### How to Open
Main Menu → press 7 → **Character Editor**

### Features
- Preview character animations
- Edit animation offsets
- **Silhouettes**: Press **G** to toggle reference silhouettes for easier positioning
- Health icon editing (click to flip player side)

---

## Week Editor

Create and edit weeks for Story Mode.

### How to Open
Main Menu → press 7 → **Week Editor**

### Creating a Week
1. **Week File Name** — Internal name used for the JSON file (e.g., "week1")
2. **Story Display Name** — Name shown in Story Mode menu (e.g., "DADDY DEAREST")
3. **Week Before** — Which week must be completed to unlock this one (e.g., "week1" for week2)
4. **Background** — Background image name for Story Mode
5. **Characters** — Three characters shown in Story Mode menu (left, center, right)
6. **Songs tab** — Add songs to the week by name
7. Click **Save Week** to save as JSON

### Week JSON Format
Week files are saved in Psych Engine format in `assets/weeks/` or `mods/{modname}/weeks/`. They're compatible with Psych Engine.

---

## Mods Manager

Browse, enable, and switch between mods.

### How to Open
From **Main Menu**, press **M**

### Features
- Lists all available mods from the `mods/` directory
- Shows mod name and description (from `pack.json`)
- Press **ENTER** to switch to a mod
- Active mod is indicated with `[ ACTIVE ]`

### Mod Structure
To create a mod, make a folder in the `mods/` directory:
```
mods/
  my-mod/
    pack.json          (mod info: name, description)
    songs/             (song audio files)
    data/              (chart JSONs)
    characters/        (character JSONs)
    stages/            (stage JSONs)
    weeks/             (week JSONs)
    images/            (sprite assets)
```

### pack.json Example
```json
{
  "name": "My Cool Mod",
  "description": "A fun FNF mod with new songs!",
  "version": "1.0"
}
```

---

## Stage Preview

See characters and the stage behind the note grid while editing charts.

### How to Enable
**Method 1**: Options → DEV tab → check **"STAGE PREVIEW"**  
**Method 2**: In Chart Editor → Charting tab → check **"Stage Preview"**

### What It Does
- Shows stage background and front sprites behind the note grid
- Characters appear at positions defined in Stage Editor
- Characters **dance on beat** (idle animation)
- Characters **sing when notes play** (singLEFT, singDOWN, singUP, singRIGHT)
- Note grid becomes **semi-transparent** (60% opacity) so you can see through it

### Limitations (Alpha)
- No stage scripts/lua execution — only visual preview
- Stage sprites are rendered from the stage JSON, not from scripts
- To test with full scripting, play the song normally (press ENTER in Chart Editor)

---

## Split Vocals

The engine supports separate vocal tracks for boyfriend and opponent.

### Supported Naming Conventions
1. **Combined**: `Voices.ogg` — single file with all vocals
2. **Split (Psych format)**: `Voices_Player.ogg` + `Voices_Opponent.ogg`
3. **Split (Alternative)**: `Voices-bf.ogg` + `Voices-dad.ogg`

### Priority Order
The engine tries to load in this order:
1. `Voices.ogg` (if found, uses this)
2. `Voices_Player.ogg` / `Voices_Opponent.ogg` (Psych Engine format)
3. `Voices-bf.ogg` / `Voices-dad.ogg` (alternative format)

### Benefits
- Mute/adjust player and opponent vocals independently in Chart Editor
- Better audio mixing control

---

## Importing Songs from Psych Engine

This version includes week configurations for Weeks 1-7. To get the actual song files:

### Step 1: Get Psych Engine
Download [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine/releases) or use an existing installation.

### Step 2: Copy Song Data
From your Psych Engine folder, copy:
- `assets/data/{songname}/` → to Twist Engine `assets/data/{songname}/`
- `assets/songs/{songname}/` → to Twist Engine `assets/songs/{songname}/`

### Step 3: Copy Character Data
From Psych Engine, copy:
- `assets/characters/` → character JSON files
- `assets/images/characters/` → character sprite sheets

### Step 4: Copy Stage Assets
From Psych Engine, copy:
- `assets/images/stageName/` → stage background sprites

### Songs Included (Week Configs)
| Week | Songs | Stage |
|------|-------|-------|
| Week 1 | Tutorial, Bopeebo, Fresh, Dad Battle | stage |
| Week 2 | Spookeez, South, Monster | spooky |
| Week 3 | Pico, Philly Nice, Blammed | philly |
| Week 4 | Satin Panties, High, MILF | limo |
| Week 5 | Cocoa, Eggnog, Winter Horrorland | mall/mallEvil |
| Week 6 | Senpai, Roses, Thorns | school/schoolEvil |
| Week 7 | Ugh, Guns, Stress | tank |

---

## File Structure

```
TwistEngine/
├── assets/
│   ├── data/              # Chart JSON files
│   │   └── songname/
│   │       └── songname.json
│   ├── songs/             # Audio files
│   │   └── songname/
│   │       ├── Inst.ogg
│   │       └── Voices.ogg (or Voices-bf.ogg + Voices-dad.ogg)
│   ├── characters/        # Character JSON configs
│   ├── stages/            # Stage JSON configs
│   ├── weeks/             # Week JSON configs
│   └── images/            # Sprite sheets and images
├── mods/                  # Mod folders go here
└── TwistEngine.exe
```

---

## Keyboard Shortcuts

### Main Menu
| Key | Action |
|-----|--------|
| 7 | Open Editors Menu |
| M | Open Mods Manager |
| Arrow Keys / Mouse Wheel | Navigate |
| ENTER / Click | Select |

### Chart Editor
| Key | Action |
|-----|--------|
| SPACE | Play/Pause |
| ENTER | Playtest song |
| A / D | Previous/Next section |
| W / S | Scroll up/down |
| Q / E | Change note sustain length |
| Z | Zoom in/out |
| CTRL+S | Quick save |
| CTRL+Z | Undo |
| CTRL+Y | Redo |

### Stage Editor
| Key | Action |
|-----|--------|
| CTRL+Z | Undo |
| CTRL+Y | Redo |
| CTRL+S | Save |
| Arrow Keys | Move selected sprite |
| Delete | Remove selected sprite |

### Character Editor
| Key | Action |
|-----|--------|
| G | Toggle silhouettes |
| Arrow Keys | Adjust offset |
| CTRL+S | Save |

---

## Troubleshooting

### "Song not found" / Empty dropdown
Make sure your song has:
1. A chart JSON in `assets/data/songname/songname.json`
2. Audio in `assets/songs/songname/Inst.ogg`
3. Song name matches folder name (lowercase, no spaces — use hyphens)

### Stage Preview not showing
1. Check Options → DEV tab → "STAGE PREVIEW" is enabled
2. Check the song has a valid stage set in the Song tab
3. Stage JSON must exist in `assets/stages/stagename.json`

### Mods not loading in Freeplay
1. Check your mod folder has proper structure (see Mod Structure section)
2. Make sure week JSON files are in `mods/modname/weeks/`
3. Press M in main menu to switch to the correct mod

### Characters not appearing
1. Character JSON must exist in `assets/characters/charname.json`
2. Character sprite sheet must exist in `assets/images/characters/`
3. Check character names match exactly (case-sensitive)

### No audio playing
1. Audio must be in OGG format (.ogg)
2. File must be named exactly `Inst.ogg` (capital I)
3. For vocals: `Voices.ogg` or `Voices-bf.ogg` + `Voices-dad.ogg`

### Build from source
```bash
# Install Haxe 4.3.x
# Clone the repo
git clone https://github.com/FrostiXS/TwistEngine-Alpha-v2.git
cd TwistEngine-Alpha-v2
# Run setup
haxelib install hmm
haxelib run hmm install
# Build
lime build windows
```

---

*Twist Engine Alpha v2 — Fixed and improved by the community. Based on [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine).*
