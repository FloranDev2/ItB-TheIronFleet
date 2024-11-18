# The Iron Fleet (v1.0.1)
by Truelch and tob260

## Table of Contents
1. [Description]
2. [Credits]
3. [Changelog]
4. [TODO]
5. [Ideas for the balance]
6. [Misc / notes]


## Description
A mix of technology from varying ages creating a great air-supremacy force.

### Gunship Mech (Brute)
An Old-Earth ground striker not technologically comparable with the aircraft of the current age, however packed with ordnance, is still a force to be reckoned with. Ordnance includes a rotary cannon loaded with a belt of high-grade bright tracer rounds, which can be seen for miles, even on the sunniest days, and a load of modified Air-to-Ground missiles with radar tracking, allowing for fire-and-forget way of demolishing radar-locked Vek.

### Airship Mech (Ranged)
A glorious sight to behold. Massive flying behemoth, fitted with the latest radio-transmission technology, able to call in fighter strafes from nearby allied airfields. The fact that it hovers high over the battlefield gives it a great field of view, which allows for use of tracer rounds for means of marking target locations. Just beware the fragile nature and the clumsiness of the Airship.

### Designator Mech (Science)
Small and nimble biped mech intended for reconnaissance, armed with a hand-mounted high calibre rifle for self defence, as well as for recon by the means of shooting a radar transmitter - fitted slugs under the thick Vek skin, which shows up on allied radars afterwards. Additionally, it carries a high-powered surveillance radar adjusted for certain compounds found in Vek bodies, enabling it to seek out all Vek in a radius around the mech and transmit their location to allies. It has its shortcomings too, namely not great area of effect, and the high power draw, translating into limited usage of such equipment.


## Credits
Thanks for Lemonymous and NamesAreHard for coding support!

Also, thanks for TheGreenDigi for sharing your ideas. We haven't forgot your propositions, in fact, we are planning to do a tune-down version that may include your ideas. (at least marks that disappear at some point)

## Changelog

### 1.0.2
- Compatibility with tosx' Mecha Ronin's Hunter Mech's marking! (it works both ways: when Iron Fleet marks an enemy, it's in the ronin marking list and vice-versa)
- Changed the sweep anim of the Designator's radar (from a circular anim to something that indicates clearly what tiles are affected)
- Added mod options:
  - Enable / disable Iron Fleet to also mark for tosx' Hunter pursuit drone
  - Enable / disable tosx' Hunter pursuit drone to also mark for the Iron Fleet
  - Choice between old and new sweep anim for the Designator Mech

### 1.0.1
- Fixed TwoClick hook

### 1.0.0
- Release!
- Fixed lag after using Fighter Strafe while keeping the fake mark in the tip image
- Achievements showing up again

### 0.2.0
- Moved mark to its own folder, with his own scripts, libs and images, to prepare it for being shipped as a separate lib.
- WIP custom tip images
- WIP options

### 0.1.5
- Added achievements:
  - Oh, hi Mark!
    Have " .. tostring(HI_MARK_GOAL) .. " marked enemies at the end of your turn
  - Ride of the Valkyries
    Kill 5 enemies in a single attack
  - Around the World in Eighty Days
    Reach every corner of the map with the Airship Mech before the end of a mission
- Changed modApiExt (again) to add skillStartTC and skillEndTC (the later was used for my achievements)

### 0.1.4
- Fixed Airship Mech damage upgrade (forgot to change the field in the upgrades when I changed the behaviour of the attack!)
- WIP achievements

### 0.1.3
- Fixed the passive! (by modifying modApiExt to have a new hook: skillBuildSecondClickHook)
- Options:
  - Mark Bonus Damage: 0 / 1 (if == 1, missiles and fighters will do 1 less damage. Note: fighters will now do 0 damage, need to tell them to still benifit from passive)
  - Airships' weapon main target:
    - Damage : 1 / 0
    - Mark : false / true
  - Mark disappear:
    - Never
    - After being used (if bonus damage >= 1 or with missiles / fighters)
    - At the end of the turn
    - Both after use and at the end of the turn?
I have noted this about balance:
- Remove +1 damage passive upgrade on Surveillance Radar
- Add an upgrade that allows to stack or maintain marks on enemies

Question: remove Musket bonus damage against marked enemies? Sounds redundant with mark bonus damage = 1 by default.

### 0.1.2
- Changed the Gunship Mech's weapon so that you don't waste the turn using it for nothing when targetting an occupied tile.
- Added weapons to the weapons' deck
- Some minor fixes

### 0.1.1
- Improved Fighter Strafe, Rotary Cannon / Missiles and Surveillance Radar's descriptions.
- Changed Airship's fighter color to the squad palette.
- Removed "The" in the name (https://discord.com/channels/417639520507527189/434468424173748224/1008490783478906880)
- Made the Gunship Mech anim slower (test)
- New Airship's broken sprite
- Added explosive to Airship Mech (https://discord.com/channels/417639520507527189/434468424173748224/1008481969690120243)
- Make the plane higher
Thx "Useless", "The Ghost of Hornet's past" and "Machin" for your feedback!

### 0.1.0
We are very proud and excited to present you this first release!
It's a beta test. We are aware that the squad is certainly over-powered.
We just want to present the current version before to get feedback before proceeding to do the balance changes, we are very curious about how people will receive the squad!

We hope you'll like it!

### 0.0.0
Internal tests.


## TODO

### Do a different effect for the marking plane
Hell, maybe even have a different plane for the main target?

### Move mark to a separate folder with its resources to make it a separate lib

### Make a separate script for images' importation

### Make tutorial tips
For mark mechanic, and at least the Gunship's weapon.

### Custom tip images
KnightMiner about custom tip images: https://discord.com/channels/417639520507527189/1000986841954131978/1008993805258731640
-> see confuse shot

truelch_RotaryCannon tip image
- I could use the previewer but I couldn't do make it work for the TipImage
  -> Utiliser aussi Board:AddAnimation ici ???

Musket's tip image: fire twice to show the bonus damage effect?

Custom TipImage:
- Iron Legion actually has two different pawns attacking:
  - the Carrier launches a Drone
  - the Drone attacks an enemy
- Hydro Leviathans Surge Mech's weapon (Dowsing Charge) displays a weapon preview icons during TipImage
- There are also custom effects (anims) during the TipImage
- Gravity Bombers show multiple friendlies. Maybe it can choose what friendly is displayed

### Custom tip images
Half-transparent marks during enemy turn? Or even during player turn while he's not arming a weapon?


## Ideas for the balance

Mark:
- The mark is consumed (removed) when a unit attack the target
- Damage on marked enemies is increased by 1
- Remove +1 damage passive upgrade on Surveillance Radar
- Add an upgrade that allows to stack or maintain marks on enemies

Airship Mech:
- Damage upgrade is removed
- Attacking a unmarked unit is removed
- New upgrade that allows to attack an unmarked unit (in addition to marked unit). This attack marks the target.