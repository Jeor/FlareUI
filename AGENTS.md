# FlareUI development

## Project and remotes

- This checkout is the user's fork, `Jeor/FlareUI`; `malkkav/FlareUI` is upstream.
- Start feature work from a verified up-to-date base and use a feature branch. Preserve local work.
- Keep development and review on the fork. Do not push, merge or open a PR upstream without the
  user's explicit approval. Do not enable the disabled upstream push URL as a routine setup step.
- This is World of Warcraft: Forever. The current TOC targets Interface `16001`; do not replace
  it with a Retail or Classic Interface number copied from a generic guide.

## Skills and reference material

For WoW addon work, read `.agents/skills/wow-addon-dev/SKILL.md` and follow its task router to the
relevant references. This is the user-requested TheMizeGuy/wow-addon-dev skill, vendored at a pinned
revision with its MIT license, scripts, examples and lessons. See `docs/development-guidance.md`
for provenance, updates and project-specific qualifications. Read references selectively.

Useful references:
- UI and preview work: `references/ui-and-secure-templates.md`.
- Bug reports: `references/debugging-and-taint.md`.
- State/load order: `references/savedvariables-and-load-order.md` and `references/ace3-and-libraries.md`.
- Prior lessons: `references/lessons-from-ccc.md`; record new FlareUI-specific lessons in
  `docs/development-guidance.md` after they are verified.
- TOCs/releases: `references/toc-format.md` and `references/distribution-and-packaging.md`.

The skill's Retail examples are reference material, not client evidence. Match FlareUI's actual
client APIs and existing architecture. Preserve `canaccessvalue`/`issecretvalue` checks; do not
treat `tonumber()` as a general way to remove secret-value restrictions. Do not add polling,
event deferral, startup prints, or addon-message traffic solely because an example uses them.
The vendored repository's CLAUDE.md describes maintaining that skill, not shipping FlareUI.

## Implementation conventions

- Preserve FlareUI's modular namespace, settings registry, existing render helpers and library use.
- Use real addon/client artwork. Preview sample data must not mutate settings or live/protected
  frames. Only an explicit control action should call the settings row setter.
- Reuse widgets; stop preview animation/timers when switching or hiding their canvas.
- Keep behavioural controls text-only. Major style choices get cards; minor visual choices use
  the existing Info Panel. Preserve search, disabled states, localization and controller navigation.
- Use `L["..."]` for player-facing strings and run `node tools/enus.js`. Do not hand-edit generated
  Settings/Copy.lua or Locales/enUS.lua; do not pull example skill strings into translation output.
- Development-only `.agents/`, AGENTS.md, docs and tools must stay out of the addon release package.

## Validation and reporting

Run relevant tests, `luajit tools/tests/syntax.lua`, and `git diff --check` after Lua changes.
For previews, run `luajit tools/tests/settings-previews.lua` and follow `docs/settings-previews.md`.
After a TOC edit, use the vendored `scripts/validate-toc.ps1` against a correctly named `FlareUI/`
staging directory (this checkout may have another directory name). Verify actual client build
before changing Interface numbers. A syntax/smoke pass is not in-game verification.
Report exactly which checks ran. Client visual/layout/combat tests remain pending until actually
performed. For added TOC files, recommend a full client restart when installing the changed addon.
