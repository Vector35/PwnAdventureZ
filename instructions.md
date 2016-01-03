# Pwn Adventure Z
Welcome to Pwn Adventure Z! The latest iteration of the [Pwn Adventure Series](http://pwnadventure.com/).

This original Nintendo game was originally written for the Computer Security Awareness Week (CSAW) [capture-the-flag contest](https://ctf.isis.poly.edu/) in November, 2015.

For Awesome Games Done Quick 2016, it's been customized as a competition between human speedrunners and TASers!

Included in this zip file are:

- instructions.html - You're reading me!
- guide.html - Player's guide for normal gameplay and introduction into the game
- PwnAdventureZ.nes - The ROM itself
- PwnAdventureZ.nes.*.nl - FCEUX symbol files (also readable by the forthcoming release of Binary Ninja: http://binary.ninja)
- PwnAdventureZ.map - A symbol map file created by the compiler (same information as the FCEUX symbol files)
- PwnAdventureZ.html - Just for funsies, a JavaScript emulator version. Imaginary internet points to whomever implements a debugger on top of it.

## The Goal
The goal of this speedrun challenge is to be the first to reach the end credits of the game. Specifically, the `do_show_credits` function (beating the game normally will automatically trigger this). The exact memory location of this function can be found in `PwnAdventureZ.nes.1.nl`. You may use hard or apocalypse difficulty if you desire, but it is expected that the fastest solutions will use the normal difficulty as described in the tutorials section below.

## Differences
Several changes have been made for this AGDQ 2016 version compared to the original CSAW 2015 CTF contest version:

1. The secret code has been removed
2. The RNG was changed to determine drops solely based on the order rooms are entered, not the far more random system used in the CSAW build as it would have required constant frame-perfect control.
3. Some aspects of the game mechanics have been rebalanced based on feedback from beta testers
4. Startup screens customized for GDQ 

You can verify these changes yourself if you like in the source code as mentioned below.

## Tutorials
If you're creating a speedrun, please check out these writeups describing some of the flaws (intentional and otherwise) that can be used to beat the game quickly. You're welcome to look for more, but in the interests of time, it's probably safest to use one of these. 

### Beginner

A warp/spawn glitch that lets you jump straight to the final boss. This approach is described on [Vector35's blog](http://vector35.com/2015/12/18/pwnadventurez.html), the company behind the game. The most difficult aspect of this approach is accumulating enough sticks for the campfire required to trigger the glitch.

### Advanced
One of the contestants to the original CTF release of the game, Andrew Dutcher did a great [writeup](http://andrewdutcher.com/view/21/pwn-adventure-z---writeup) of the more advanced route possible, a total control / code execution vulnerability that was the original intended way to jump straight to the credits. The most difficult aspect of this approach is the money and items required to achieve the overflow.

## Map

### Raw Map Data
To help you in your run, you may find it useful to view raw map data from the source code. First, get the source code as described in the below section.

Next, open levels.inc in your favorite text editor, and copy the `.byte` lines under the section you are interested in (`normal_overworld_map`, or `normal_sewer_map`, or `normal_mine_map`, for example).

Finally, open mapcreator.html in a browser (tested with Chrome but should work with others as well), and paste in the data from levels.inc. When you click "load", you should see what the stored map data corresponds to. 

### Map View Mode
You can also enter a live map-view mode inside the game itself which shows more detail than the raw map data. Since each room is procedurally generated, you need to run the game live to figure out the exact placement of trees, for example. Just press UP+B immediately after selecting a save game slot to enter the map view mode.

### Sweet Loot
To determine what enemies drop what types of items, see the `normal_enemyname_drop_table` section inside each enemy `.asm` file. For example, `normal_shark_drop_table` in `shark.asm` lists the types of items the sharks can drop (unlike normal enemies, shark drops go directly into your inventory, not into something picked up). They drop gems 2/16 of the time, and drop an average of 1.5 gems per drop (minimum 1 gem with 50% chance of 1 more being added), so the expected average gems per shark is 3/16 of a gem.

## Useful Tips 
- Different shops sell and buy different items and for different amounts. 
- There are three shops in the game, shop.asm in the source code lists the items they each buy and sell. 
- The final boss takes 15 sniper shots to kill.

## Source Code
You can check out the source for the challenge (both the [CSAW version](https://github.com/vector35/PwnAdventureZ) and this [AGDQ version](https://github.com/vector35/pwnadventurez/tree/agdq)) on github.

If you are unfamiliar with git or github, you can also just download the source code of the version used for AGDQ as a [zip file](https://github.com/Vector35/PwnAdventureZ/archive/agdq.zip).


