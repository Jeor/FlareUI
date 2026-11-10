# WoW development guidance

The user requested TheMizeGuy/wow-addon-dev as the skill/reference foundation for future FlareUI
work on 2026-11-10. It is installed project-locally in `.agents/skills/wow-addon-dev/` so the fork
carries it to future sessions and machines; no global skill configuration was changed.

- Source: https://github.com/TheMizeGuy/wow-addon-dev
- Pinned revision: `f928572a9428d29327a96c2549b0068101961c4e`
- License: MIT; original LICENSE preserved in the installed package.
- Local normalization: removed the extra blank line at the end of SKILL.md; instructions unchanged.
- Contents: one SKILL.md, eleven references, six example families, seven PowerShell scripts.
- Entry point for agents: repository `AGENTS.md`.

## Applying the source to Forever

The source primarily targets Retail Midnight and also discusses Classic. FlareUI targets Forever;
verify API names and templates against that client. Existing code and tested client behaviour take
precedence over unverified generic examples. In particular, keep the project's secret-value access
guards rather than relying on the source's `tonumber()` scrubbing suggestion. Its standalone-skill
shipping instructions do not authorize pushing FlareUI upstream or changing this fork's workflow.

Scripts are available for inspection and task-specific use; installing the skill does not execute
addon installation, release packaging, client-version changes or reads of SavedVariables. Read a
script before running it, supply the correct paths and respect the user's requested scope.

## Updating

Review a new source revision and its changes before replacing the pinned package. Preserve its
license, record the new commit here, recheck relative references and PowerShell syntax, and rerun
the FlareUI translation/syntax checks. Do not auto-pull instructions at session start. The package
and this guide are development material excluded by `.pkgmeta`.

## Verified lessons from settings previews

- A panel refresh must clear the old sample before rendering search or custom-tab content.
- Production palettes and shared aura/font helpers prevent examples from drifting from the addon.
- Pool preview widgets; stop both proc start/loop animations and OnUpdate when hidden.
- Scale bag-border edges and outsets with the sample slots, not independently.
- Textures can contain baked-in text; use a separate specimen for settings that toggle that text.
- Translation extraction currently recognizes double-quoted `L["..."]` only.
- Widget doubles verify logic/lifecycle; only the real client establishes atlas and visual fidelity.
