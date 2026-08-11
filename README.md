# Abyssgarding

Abyssgarding, as the name suggests, is a Hololive indie game about the two demonic dog twins Fuwawa and Mococo Abyssgard fron Hololive English Advent

## World planning

- World 1: Underworld/Abyss
- World 2: Underground
- World 3: Underwater
- World 4: Above Water
- World 5: Above Ground
- World 6: Castle

## How to compile

This rom uses [create-nes-game](https://create-nes-game.nes.science/) to build. Download a copy
of that to start.

### First time setup

1. Download [create-nes-game](https://create-nes-game.nes.science/), if you haven't already.
2. (Optional) Run `./create-nes-game install` to install the tool globally
3. Run `create-nes-game download-dependencies` to download dependencies of this game into this folder
4. Proceed to the next section to build the rom.

### Building the game

To build the rom, run `create-nes-game build` in the same directory as this readme file.

You can run the game using the selected emulator (if available on your operating system) using the
`create-nes-game run` command. Alternatively, the rom is available in the `rom/` folder.

### Running unit tests

This rom includes unit tests that can be used to verify that the game works. Run them using the
`create-nes-game test` command.

The tests are located in the `test/` folder.

## Directory layout

```text
abyssgarding
└─ config/                  - Configuration for the assembler/compiler
└─ graphics/                - Graphics data - backgrounds, palettes, and nametables
|    graphics.config.asm    - Add references to new graphics files here to use them from code
|    YOUR_FILE_NAME.chr     - Graphics data in binary form, such as exported from nesst
|                             Will automatically be run-length encoded into files with the .rle.chr suffix
|    YOUR_FILE_NAME.nam     - Nametable data in binary form, such as exported from nesst
|                             Will automatically be run-length encoded into files with the .rle.nam suffix
└─ rom/
|    YOUR_GAME.nes          - The game rom
|    YOUR_GAME.dbg          - Debugging information for the game - Mesen can use this to debug your code directly
└─ source/
|    assembly/              - All game code lives here
|        main.asm           - This is the main entrypoint of the game
|        system-defines.asm - Constants and symbols commonly used in nes development
|        mapper.asm         - Helpers for working with the rom's mapper
└─ temp/                    - Temporary storage for the compiler. Usually safe to ignore
└─ test/                    - Test files for the game, written in javascript. Uses nes-test
└─ tools/                   - Compile and emulation tools required by the game, downloaded by nes-test
```

## Music

Music is created using [FamiStudio 4.5.x](https://famistudio.org). Once you have music you like, you'll need to
export it for use with this engine. Follow these steps to do so:

> The `.fms` is NOT usable, but you can to import the file `source/soundFiles/Abyssgarding (FUWAMOCO).txt`
> into Famistudio

1. In the `Export` menu, select `Export FamiStudio Music Code` and use format 'CA65'
2. Select the music you wanna use
3. Turn on "Seperate Files"
4. Use the song name pattern `music_{project}_{song}` and DMC name pattern `{project}_dmc`
5. Save the generated file into the `source/assembly/sound/` folder as `music.s`

Next time you run `create-nes-game build` your new music will be added to the game.

## SFX

SFX are created using [FamiStudio 4.5.x](http://famistudio.org). Once you have sfx you like, you'll need to
export it for use with this engine. Follow these steps to do so:

1. In the `Export` menu, select `Export FamiStudio SFX Code`
2. Select the Menu SFX
3. Save the generated file into the `source/assembly/sound/` folder as `sfx_men.s`
4. Go into the generated file and change `sounds` to `sounds_menu` and remove or comment out `.export _sounds:=sounds`
5. Go into the generated include file and remove the SFX Strings to prevent a CA65 error
6. Select the In-Game SFX
7. Save the generated file into the `source/assembly/sound/` folder as `sfx_gam.s`
8. Go into the generated file and change `sounds` to `sounds_game`
9. Go into the generated include file and remove the SFX Strings to prevent a CA65 error

Next time you run `create-nes-game build` your new sfx will be added to the game.

---

This rom uses [create-nes-game](https://create-nes-game.nes.science/)!
