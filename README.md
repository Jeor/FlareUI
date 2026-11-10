# FlareUI settings demo

Live demo: https://jeor.github.io/FlareUI/

This branch contains the standalone browser settings demo. It does not replace the addon branches. The layout comparison toolbar is retained; design review notes and links are removed.

## Development

Requires Node.js 20.19+ or 22.12+ and npm.

```sh
npm ci
npm run dev
```

Open http://127.0.0.1:5173. Both layouts share a browser-local sample profile. Reset sample clears the demo values. No WoW profiles or files are read or written.

```sh
npm run test
npm run test:previews
npm run build
```

Tests use locally installed Google Chrome through Playwright, with the dev server running. Set TEST_URL to test the hosted site instead. Test output goes to ignored test-results/. The build emits the deployable website into docs/ using /FlareUI/ as the asset base path.

## Publishing updates

On this gh-pages branch, run npm ci and npm run build, then commit the source and docs/ together and push to Jeor/FlareUI. GitHub Pages publishes from gh-pages, /docs. No custom build workflow or secrets are required. Do not deploy this branch as a WoW addon or push it to malkkav/FlareUI.

## Scope and source

The 14-section settings metadata in src/source-settings.json was exported from the FlareUI settings registry during preview development. Values form a demonstration profile, not a live profile. Interactive specimens are HTML/CSS simulations; representative visual options update the scene. Unsupported game actions explain their in-game purpose. Combat, protected frames, Lua behavior and native rendering require testing in WoW.

Bundled artwork is from FlareUI's Media/Art and remains subject to its original restrictions; it is not covered by the code's MIT license. Fonts retain their original licenses. See LICENSE.txt and public/licenses/. Reference mode shows the bundled addon artwork; portraits and geometry remain simplified. Spell/item icons and gryphon end caps now use bundled WoW assets with provenance in public/wow/ATTRIBUTION.md.

## Interactive specimen coverage

Unit Frames: player, pet and target-of-target samples; aura hover composition; palette hover/selection; named party/raid/boss specimens with power bars and cast spell icon.
Action Bars: native WoW gryphon end caps, spell textures, foreground/background layering, cooldown/proc states and all four quest-XP modes.
Resource Bars: all seven resources with independent enabled states, combo gems and animated swing timers.
Auras: WoW icons, square/round shapes, icon/border/both/off cooldowns, all timer placements, timer colour, sorting and arrival motion.
Minimap: source layout with day/night drawer button, separate clock tooltip with FPS/latency, coordinates and middle-click-menu sample.
Chat: edit box above/inside/below; social/channel/menu/volume/copy controls; text formatting and opacity.
Quest Tracker: per-quest focus and voice indicators (voice availability is simulated).
Bags: columns, gaps, integrated bag buttons, rarity/thickness, junk coin, upgrade arrow and pet-food marker.
Radial: highlighted action, moving cursor, name/scale/activation display. Animations can be paused and respect reduced-motion preferences.

Assets and provenance: public/wow/ATTRIBUTION.md. These remain illustrative samples, not a game renderer. The unchanged layout comparison toolbar and browser-local storage are retained.
