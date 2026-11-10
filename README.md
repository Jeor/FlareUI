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
npm run build
```

Tests use locally installed Google Chrome through Playwright, with the dev server running. Set TEST_URL to test the hosted site instead. Test output goes to ignored test-results/. The build emits the deployable website into docs/ using /FlareUI/ as the asset base path.

## Publishing updates

On this gh-pages branch, run npm ci and npm run build, then commit the source and docs/ together and push to Jeor/FlareUI. GitHub Pages publishes from gh-pages, /docs. No custom build workflow or secrets are required. Do not deploy this branch as a WoW addon or push it to malkkav/FlareUI.

## Scope and source

The 14-section settings metadata in src/source-settings.json was exported from the FlareUI settings registry during preview development. Values form a demonstration profile, not a live profile. Interactive specimens are HTML/CSS simulations; representative visual options update the scene. Unsupported game actions explain their in-game purpose. Combat, protected frames, Lua behavior and native rendering require testing in WoW.

Bundled artwork is from FlareUI's Media/Art and remains subject to its original restrictions; it is not covered by the code's MIT license. Fonts retain their original licenses. See LICENSE.txt and public/licenses/. Reference mode shows the bundled addon artwork; synthetic portraits, icons and end caps are schematic.
