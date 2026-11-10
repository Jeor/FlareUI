# Settings visual previews implementation plan

**Goal:** Preview visual settings across FlareUI without reloading or crowding settings rows.

**Architecture:** One reusable, non-interactive sample canvas in the existing Info Panel. Unit frame and minimap style choices get compact cards. Hover/focus previews never write settings; clicking cards uses the existing row setter and reload footer. Use shipped tour captures, registered textures and shared rendering helpers, not generated artwork.

**Tech stack:** WoW Lua, existing settings registry, LibSharedMedia, LuaJIT smoke tests.

**Spec:** User-approved discussion in this chat: all visual sections; real FlareUI designs; work in Jeor fork; no upstream pushes.

## Constraints and review focus
- Preserve descriptions, search, disabled controls, localization, controller navigation and reload tracking.
- Samples must not touch live game frames or secure/unit data, and must stop animation when hidden.
- Pool sample widgets; do not allocate a new frame on every hover.
- Preview updates must survive row refresh; leaving an option restores the current selection.
- Preserve radial editor ownership of the right column; behavioural options stay text-only.
- Fork main is synced to upstream; feature work stays on feat/settings-visual-previews.

## Tasks
- [x] Add tests for visual routing, preview-only style overrides, read-only rendering and canvas reuse.
- [x] Add shared preview registry/canvas and compact style cards; integrate panel lifecycle and fonts.
- [x] Add samples for Unit Frames, Minimap, Auras, Chat, Tooltips, Tracker, Action Bars, Meter, Resources, Bags, Nameplates and radial options.
- [x] Run Lua syntax and smoke tests, regenerate English phrases, review diff and document in-game checks.
- [x] Prepare the Jeor feature branch for commit; upstream push URL disabled. Publication is limited to this fork branch, with no upstream PR.

## Validation
Run `luajit tools/tests/settings-previews.lua`, parse all shipped Lua, run `node tools/enus.js`, and `git diff --check`. In-game checks cover textures/atlas availability, animation, localized layout and controller focus; do not claim a game-client run unless performed.

## Execution record

- Base: `14d0086f3b2f7331880a0090155eba8236d227ec`; fork main/upstream main initially identical.
- Routing tests first failed because Preview.lua did not yet exist; pass after implementation.
- 93 Lua files parse; 131 setting variants and actual registry integration pass under LuaJIT.
- Independent source review identified search cleanup, sample state gaps, palette/tooltip fidelity,
  localization, text bounds, animation cleanup and bag border scaling; addressed before commit.
- Ruling: leave sorting/automation and live-frame enable switches text-only; they are behavioural
  controls, and generic unchanged pictures would add noise. Every requested visual section is covered.
- Client acceptance remains explicitly unverified; see `docs/settings-previews.md`.
