# Pwn Adventure Z

![Title Screen](https://github.com/Vector35/PwnAdventureZ/raw/master/images/title-screen.png)

Pwn Adventure Z (PwnZ) continues the long tradition in the [Pwn Adventure series](http://pwnadventure.com/) of being a fully hackable game.

PwnZ is an NES game (yes, the original NES) based on [Mapper 1](http://wiki.nesdev.com/w/index.php/MMC1) hardware--similar to the hardware that powered The Legend of Zelda. 

The game was originally released at the [CSAW CTF 2015](https://ctf.isis.poly.edu/) competition, an in-person CTF where each team was given a physical cartridge to solve the built-in challenges for. 

## Screenshots

![Blocky Challenge](https://github.com/Vector35/PwnAdventureZ/raw/master/images/blocky.png)
![It's a trap!!](https://github.com/Vector35/PwnAdventureZ/raw/master/images/trap.png)
![Horde](https://github.com/Vector35/PwnAdventureZ/raw/master/images/horde.png)
![NPCs](https://github.com/Vector35/PwnAdventureZ/raw/master/images/npcs.png)
![Shop](https://github.com/Vector35/PwnAdventureZ/raw/master/images/shop.png)
![Laser sharks](https://github.com/Vector35/PwnAdventureZ/raw/master/images/laser-sharks.png)

## ROM
The ROM released at the CSAW CTF exactly as the students played it is available in the [PwnAdventureZ-csaw-student.zip](https://github.com/Vector35/PwnAdventureZ/blob/master/PwnAdventureZ-csaw-student.zip) file. If you just want to play the game, download the zip and the only file you need to extract is the `PwnAdventureZ.NES` 

If you would like to play with the version of the ROM that contained the actual flags, you can either use the [PwnAdventureZ-csaw-withkeys.bin](https://github.com/Vector35/PwnAdventureZ/blob/master/PwnAdventureZ-csaw-withkeys.bin) by programming it on real hardware, or download the [PwnAdventureZ-csaw-withkeys.nes](https://github.com/Vector35/PwnAdventureZ/blob/master/PwnAdventureZ-csaw-withkeys.nes) rom file.

## Difficulty

PwnZ is not just for people looking to solve CTF challenges. It's also a fun game completely playable in its own right! The default easy mode is not meant as a challenge at all, but was intentionally easy to play so that it didn't impede the competition, but `HARD` and `APOCALYPSE` difficulty modes are much more challenge. To play in `HARD`, first enter your name as `QUEST 2.0` when starting a new game, and to play as `APOCALYPSE`, enter `UNBEARABLE` as your name. 

## Symbols
If you are working on the reverse engineering / vulnerability research challenges in the game, you'll be interested in the symbols included in the above `zip` file that allow debuggers like [FCEUX](http://www.fceux.com/web/home.html) and [Binary Ninja](https://binary.ninja/) (note that the open source verison does not support NES roms) to include names while analyzing the program. Simply unzip the original zip in the same place, and the symbols should automatically load. 

## Playing on Real Hardware

If you'd like to try the game on real hardware, we used components from [infiniteneslives.com](http://www.infiniteneslives.com/nessupplies.php). Specifically, you'll need to purchase an [INL Retro](http://www.infiniteneslives.com/kazzo.php) programmer, as well as a [Mapper 1 256kb with Save Battery](http://www.infiniteneslives.com/nessupplies.php#MMC1) rom.  

Alternatively, fully assembled and programmed boards with art will be available from [infiniteneslives.com](http://www.infiniteneslives.com/) shortly. Keep an eye out

## License

See [LICENSE.md](https://github.com/Vector35/PwnAdventureZ/blob/master/LICENSE.md) for licensing information.

