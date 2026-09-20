# Student Runner — Game Design & Technical Spec

> Endless runner 3-lane bertema anak sekolah berlari menuju sekolah, menghindari obstacle dan mengumpulkan hadiah.
> Engine: **Godot 4.x (GDScript)** | Target device: **Samsung Galaxy A15 & Galaxy Tab A9**

---

## 1. Ringkasan Game

| Aspek | Detail |
|---|---|
| Genre | Endless Runner (3-lane, side-scrolling ilusi depth) |
| Kontrol | Swipe kiri/kanan (pindah lane), swipe atas (lompat), swipe bawah (slide/duck) |
| Tema | Anak sekolah berlari menuju sekolah, melewati jalan/trotoar kota |
| Target platform | Android (portrait mode) |
| Referensi | Subway Surfers, Cat Runner |
| Objektif pemain | Bertahan sejauh mungkin, kumpulkan koin/hadiah, hindari obstacle |

---

## 2. Core Gameplay Mechanics

- **Lane system**: 3 lane (kiri, tengah, kanan). Player default di lane tengah.
- **Speed**: kecepatan lari meningkat bertahap seiring jarak/waktu (difficulty curve).
- **Obstacle** memaksa aksi tertentu:
  - **Batu** → harus pindah lane (dihindari kiri/kanan)
  - **Trotoar (barrier rendah)** → harus lompat
  - **Portal/gerbang (rendah menggantung)** → harus **slide/duck**
  - **Kotak** → harus **lompat**
- **Collectible**: koin/hadiah melayang di jalur lane, disentuh otomatis saat player lewat di lane yang sama.
- **Power-up**: sudah termasuk di versi awal (v1), bukan fase lanjutan. Spawn dengan frekuensi lebih jarang dari koin.
- **Game Over**: menabrak obstacle → animasi gagal → skor akhir ditampilkan.
- **Skor**: kombinasi jarak tempuh (meter) + jumlah koin dikumpulkan.

---

## 3. Spesifikasi Teknis

- **Godot version**: 4.x Stable, Standard (GDScript, bukan .NET)
- **Resolusi target**: 1080 x 2400 (portrait), scaling mode `canvas_items` agar adaptif ke Galaxy A15 & Tab A9 (rasio layar berbeda)
- **Orientation**: Portrait, locked
- **Target FPS**: 60 fps (fallback 30 fps untuk device lebih rendah)
- **Physics/movement**: tween atau lerp untuk perpindahan lane (bukan collision fisik penuh), AABB/Area2D untuk deteksi tabrakan
- **Asset format**: PNG dengan transparansi (alpha channel), sprite sheet untuk animasi karakter
- **Build target**: APK (Android), sign dengan keystore debug/release sesuai kebutuhan
- **Version control**: Git, `.gitignore` standar Godot (`.godot/`, `export_presets.cfg` jika perlu privat)

---

## 4. Asset List

### 4.1 Karakter (Anak Sekolah)
| Aset | Deskripsi | Jumlah Frame (perkiraan) |
|---|---|---|
| Run cycle | Animasi lari loop | 6–8 frame |
| Jump | Animasi lompat (naik-turun) | 4–6 frame |
| Slide/Duck | Animasi merunduk/meluncur | 3–4 frame |
| Hit/Fail | Animasi tertabrak/jatuh | 3–5 frame |
| Idle (opsional, untuk main menu) | Berdiri santai | 2–4 frame |

> Bisa dibuat 1 sprite sheet per aksi, atau 1 sprite sheet besar berisi semua aksi (baris per aksi).

### 4.2 Obstacle
- Batu (1–2 variasi ukuran)
- Trotoar/pembatas rendah (1–2 variasi)
- Portal/gerbang menggantung (1–2 variasi)
- Kotak (1–2 variasi, misal kardus/peti)

### 4.3 Collectible
- Koin (dengan 3–4 frame animasi berputar, opsional)
- Bintang/hadiah (opsional variasi bonus poin)
- **Power-up (masuk versi awal / v1)** — contoh: sepatu cepat (speed boost), payung/perisai (invincibility sementara), magnet koin. Perlu ikon unik per power-up agar mudah dibedakan pemain.

### 4.4 Environment (Background Parallax)
- Layer jauh: langit + awan
- Layer tengah: rumah/gedung/pepohonan kota (looping horizontal/vertikal sesuai arah scroll)
- Layer dekat: trotoar/jalan (road tile, looping seamless)
- Elemen penanda finish (opsional): gerbang sekolah untuk versi "checkpoint" jika ada mode level

### 4.5 UI
- Tombol Play
- Tombol Pause
- Tombol Restart
- Panel skor (jarak + koin)
- Layar Game Over (background + tombol restart/menu)
- Background Main Menu

### 4.6 Efek (opsional, bisa native Godot Particle2D)
- Efek sentuh koin (sparkle)
- Efek tabrakan (debu/asap)

---

## 5. Prompt Generate Asset via Gemini

> **Catatan umum untuk semua prompt**: tambahkan konsistensi gaya visual di setiap prompt (flat cartoon vector, warna cerah, outline tebal) agar semua aset terlihat satu keluarga visual. Selalu minta **background transparan/PNG transparent** dan **tanpa watermark/teks**.

### 5.1 Karakter — Run Cycle
```
Create a 2D mobile game character sprite: a cheerful elementary school kid running,
wearing a school uniform (white shirt, red/blue shorts or skirt, backpack on back),
flat cartoon vector art style, bold clean outlines, vibrant flat colors, simple shading,
side-view (profile) running pose captured mid-stride with arms and legs in dynamic motion,
transparent background, no text, no watermark, centered composition,
mobile game asset style similar to Subway Surfers character design,
high detail on face expression (happy, energetic).
```

### 5.2 Karakter — Jump Pose
```
Same character as before (school kid, uniform, backpack), flat cartoon vector art style,
bold outlines, vibrant colors, side-view jumping pose with legs tucked and arms raised up,
mid-air dynamic action pose, transparent background, no text, no watermark,
consistent art style and color palette with the running sprite, mobile endless runner game asset.
```

### 5.3 Karakter — Slide/Duck Pose
```
Same character as before (school kid, uniform, backpack), flat cartoon vector art style,
bold outlines, vibrant colors, side-view sliding/ducking pose low to the ground,
motion blur lines behind to show sliding movement, transparent background,
no text, no watermark, consistent art style and color palette with previous sprites,
mobile endless runner game asset.
```

### 5.4 Karakter — Hit/Fail Pose
```
Same character as before (school kid, uniform, backpack), flat cartoon vector art style,
bold outlines, side-view falling/tripping pose showing surprised or dizzy expression,
small motion lines and stars around head to show impact, transparent background,
no text, no watermark, consistent art style and color palette with previous sprites,
mobile endless runner game asset.
```

### 5.5 Obstacle — Batu
```
Create a 2D mobile game obstacle asset: a rounded gray rock/boulder,
flat cartoon vector art style, bold clean outlines, simple flat shading with subtle highlight,
side-view suitable for a lane-based endless runner game, transparent background,
no text, no watermark, medium size obstacle proportion relative to a human character.
```

### 5.6 Obstacle — Trotoar / Pembatas Rendah
```
Create a 2D mobile game obstacle asset: a low street barrier/curb-style obstacle
(concrete pavement block or low fence), flat cartoon vector art style, bold outlines,
vibrant but muted colors (gray/orange stripes), side-view, transparent background,
no text, no watermark, designed to be jumped over by a running character in an endless runner game.
```

### 5.7 Obstacle — Portal / Gerbang Menggantung
```
Create a 2D mobile game obstacle asset: a low hanging gate/arch or warning barrier
positioned at head height, flat cartoon vector art style, bold outlines, vibrant colors
(yellow-black hazard stripes or glowing portal ring), side-view, transparent background,
no text, no watermark, designed to force a running character to slide/duck underneath
in an endless runner game.
```

### 5.8 Obstacle — Kotak
```
Create a 2D mobile game obstacle asset: a stack of cardboard boxes or a wooden crate,
flat cartoon vector art style, bold clean outlines, simple flat shading,
side-view, transparent background, no text, no watermark,
medium size obstacle proportion relative to a human character in an endless runner game.
```

### 5.9a Power-Up — Sepatu Cepat (Speed Boost)
```
Create a 2D mobile game power-up icon: a winged sneaker/running shoe glowing with speed lines,
flat cartoon vector art style, bold outlines, bright blue/yellow color scheme with glow highlight,
circular icon composition, transparent background, no text, no watermark,
iconic and instantly readable design suitable for a mobile endless runner game power-up.
```

### 5.9b Power-Up — Perisai/Payung Pelindung (Shield/Invincibility)
```
Create a 2D mobile game power-up icon: a glowing protective shield or open umbrella
surrounding a small sparkle effect, flat cartoon vector art style, bold outlines,
bright cyan/purple color scheme with glow highlight, circular icon composition,
transparent background, no text, no watermark,
iconic and instantly readable design suitable for a mobile endless runner game power-up.
```

### 5.9c Power-Up — Magnet Koin (Coin Magnet)
```
Create a 2D mobile game power-up icon: a classic red horseshoe magnet with small coin
sparkles being attracted to it, flat cartoon vector art style, bold outlines,
bright red/gray color scheme with glow highlight, circular icon composition,
transparent background, no text, no watermark,
iconic and instantly readable design suitable for a mobile endless runner game power-up.
```

### 5.9 Collectible — Koin
```
Create a 2D mobile game collectible asset: a shiny gold coin with a star or sparkle symbol
in the center, flat cartoon vector art style, bold outlines, bright gold/yellow color with
highlight shine, front-facing circular view, transparent background, no text, no watermark,
simple and iconic design suitable for a mobile endless runner game collectible.
```

### 5.10 Background — Layer Langit
```
Create a 2D mobile game background layer: a bright daytime sky with soft cartoon clouds,
flat vector art style, gradient blue sky, seamless horizontally tileable, no text, no watermark,
wide landscape composition suitable for a scrolling parallax background in a mobile endless runner game.
```

### 5.11 Background — Layer Kota/Rumah
```
Create a 2D mobile game background layer: a row of colorful simple houses and trees
along a suburban street, flat cartoon vector art style, bold outlines, vibrant colors,
seamless horizontally tileable, side-view, no text, no watermark,
mid-ground parallax layer for a mobile endless runner game set in a neighborhood near a school.
```

### 5.12 Background — Jalan/Trotoar (Road Tile)
```
Create a 2D mobile game ground/road tile: a clean sidewalk/street path with lane markings
matching a 3-lane runner game, flat cartoon vector art style, bold outlines, light gray/beige
pavement color, top-down slightly angled perspective, seamless vertically tileable
(for continuous scrolling), no text, no watermark, mobile endless runner game asset.
```

### 5.13 UI — Tombol & Panel
```
Create a 2D mobile game UI button set: a rounded rectangular "Play" button, "Pause" button,
and "Restart" button, flat cartoon vector art style, bold outlines, playful bright colors
(green for play, orange for pause/restart), consistent design language, transparent background,
no text baked into image (icon only), mobile casual game UI style.
```

### 5.14 UI — Game Over Screen Background
```
Create a 2D mobile game UI background panel: a simple rounded rectangle panel
for a "Game Over" screen, flat cartoon vector art style, soft gradient background
(warm orange/red tone), bold outline border, transparent background outside the panel,
no text, no watermark, playful casual mobile game style.
```

---

## 6. Struktur Folder Asset (Rekomendasi)

```
assets/
├── character/
│   ├── run/
│   ├── jump/
│   ├── slide/
│   └── hit/
├── obstacles/
│   ├── rock.png
│   ├── barrier.png
│   ├── portal.png
│   └── box.png
├── collectibles/
│   ├── coin_spritesheet.png
│   └── powerups/
│       ├── speed_boost.png
│       ├── shield.png
│       └── magnet.png
├── background/
│   ├── sky.png
│   ├── houses.png
│   └── road_tile.png
├── ui/
│   ├── buttons/
│   └── gameover_panel.png
└── audio/
    ├── sfx/
    └── bgm/
```

---

## 7. Tahapan Development (Milestone Usulan)

1. **Prototype core loop** — player + 3 lane movement + 1 obstacle jenis (belum pakai asset final, pakai placeholder shape)
2. **Integrasi asset karakter & animasi** — run/jump/slide/hit
3. **Integrasi obstacle & collision detection** (batu = pindah lane, trotoar & kotak = jump, portal = slide)
4. **Sistem skor & collectible** (koin + power-up: speed boost, shield, magnet)
5. **Background parallax & polish visual**
6. **UI lengkap (main menu, pause, game over)**
7. **Audio (SFX & BGM via AI)** — lihat Bagian 9
8. **Testing di device target (Galaxy A15 & Tab A9)** — cek performa FPS, scaling layar
9. **Build APK & optimasi ukuran/performa**

---

## 9. Audio — Generate via AI

### 9.1 Daftar Kebutuhan Audio
| Jenis | Aset | Catatan |
|---|---|---|
| SFX | Lompat (jump) | Pendek, ringan, "whoosh" naik |
| SFX | Slide/duck | "swoosh" cepat rendah |
| SFX | Ambil koin | "ting"/chime pendek, ceria |
| SFX | Ambil power-up | Chime lebih tebal/magis, beda dari koin |
| SFX | Tabrak obstacle (game over) | Bunyi "bump"/impact ringan (hindari terlalu keras/menakutkan, target anak-anak) |
| SFX | Tombol UI (tap) | Klik pendek netral |
| BGM | Gameplay loop | Ceria, tempo cepat, energik, cocok tema anak sekolah, loopable seamless |
| BGM | Main menu | Lebih santai/ringan dibanding BGM gameplay |
| BGM | Game over jingle | Pendek (2–4 detik), nada turun tapi tetap ramah anak |

### 9.2 Rekomendasi Tools AI untuk Audio
- **SFX pendek**: ElevenLabs Sound Effects, atau tool text-to-sfx sejenis — cocok untuk efek singkat seperti coin/jump/hit.
- **BGM/musik**: Suno atau Udio — cocok untuk membuat loop musik ceria dengan deskripsi genre & mood.
- Setelah digenerate, semua audio sebaiknya dikonversi/trim ke format **`.ogg`** (format audio yang direkomendasikan Godot untuk kompresi & performa mobile).

### 9.3 Contoh Prompt Audio

**SFX — Lompat**
```
A short, light "whoosh" jump sound effect for a casual mobile game,
energetic and cartoonish, under 1 second, no vocals.
```

**SFX — Ambil Koin**
```
A short, cheerful "coin collect" chime sound effect for a casual mobile game,
bright bell-like tone, playful and rewarding, under 1 second, no vocals.
```

**SFX — Ambil Power-Up**
```
A short magical "power-up collected" sound effect for a casual mobile game,
sparkly rising tone, more energetic and distinct than a simple coin sound,
under 1.5 seconds, no vocals.
```

**SFX — Tabrak Obstacle**
```
A short, soft "bump" impact sound effect suitable for a kid-friendly casual mobile game,
not harsh or scary, slightly comedic tone, under 1 second, no vocals.
```

**BGM — Gameplay Loop**
```
An upbeat, energetic instrumental background music loop for a kid-friendly mobile endless
runner game about a school kid running to school, cheerful and playful mood, moderate-fast
tempo, seamless loop, light percussion and bright melodic instruments, no vocals.
```

**BGM — Main Menu**
```
A relaxed, cheerful instrumental background music loop for a mobile game main menu,
light and welcoming mood, slower tempo than gameplay music, seamless loop, no vocals.
```

---

## 10. Catatan untuk Kolaborasi dengan Claude (Coding)

- Struktur project Godot: scene per komponen (`Player.tscn`, `Obstacle.tscn`, `Coin.tscn`, `GameManager.tscn`, `UI.tscn`)
- Gunakan `Area2D` untuk deteksi collision player-obstacle dan player-coin
- Gunakan signal Godot untuk komunikasi antar node (misal `body_entered` → GameManager)
- State management sederhana: `MENU`, `PLAYING`, `PAUSED`, `GAME_OVER`
- Spawner obstacle/coin berbasis timer + randomisasi lane
