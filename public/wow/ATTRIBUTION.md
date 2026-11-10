# WoW preview assets

World of Warcraft imagery is copyright Blizzard Entertainment. These game assets are included only as references in this FlareUI settings demo, and are not relicensed under the code's MIT license.

- gryphon.png: Interface/MainMenuBar/UI-MainMenuBar-EndCap-Dwarf, converted PNG supplied by https://github.com/Gethe/wow-ui-textures/blob/312a6e61bab69370c65ccc0a08f1075d62196294/MainMenuBar/UI-MainMenuBar-EndCap-Dwarf.PNG . This is the legacy fallback used by FlareUI's action-bar preview.
- Spell and item icons: https://wow.zamimg.com/images/wow/icons/large/ . Each JPG retains the corresponding lowercase WoW icon name. Retrieved 2026-11-10. They match the native spell/item names used in the addon preview samples, with additional Arcane Intellect, Rejuvenation, Shadow Word: Pain and pet-wolf examples.
- FlareUI screenshots in ../art/Tour and fonts in ../fonts retain the original restrictions and licenses documented in ../licenses.
- Unit portraits, frame geometry, timer masks and radial geometry are simplified HTML/CSS/SVG specimens authored for this demo. No screenshot was used to extract the gryphons or spell icons.

## Frame specimens

- `frames/unit-atlas.png`: native HUD/UIUnitFrame2x.PNG from Gethe/wow-ui-textures revision e80e3278cc833c89e1f3fc79557b68315d750935. Ring extraction uses the source ART.target.box coordinates (252.78..375, 1.67..123.89) at render time.
- `frames/portrait-undead.png`: native CHARACTERFRAME/TEMPORARYPORTRAIT-MALE-SCOURGE.PNG from revision d23deaf8f44a7d280dc974a5c9d5321c013db59b. Static game portrait rather than a live 3D model.
- `frames/class-warlock.jpg`: native class icon from the same Wowhead icon endpoint above. The example character uses Warlock class colour (0.53, 0.53, 0.93), matching the purple class styling in the supplied references.
- `frames/health.png`, `power.png`, `flat.png`, `bright.png`, `border-thin.png`, `border-frame.png`: lossless format conversions of FlareUI's Media/Bars and Media/Borders textures. Original restrictions still apply. The optional conversion script expects an adjacent ../repo addon checkout.
- Unit geometry follows Settings/PreviewSamples.lua Unit and Modules/UnitFramesRing.lua PLATE: Forever's 194x68 coordinate space, name slot 4..125/11..26, health 4..125/29..42, power 4..125/45..53. Left-side frames mirror the slot layout. Simple target-of-target has no power bar. Borders are vector geometry with the source bronze colour; this web renderer does not reproduce the client's full plate atlas ornamentation or animated portrait models.
