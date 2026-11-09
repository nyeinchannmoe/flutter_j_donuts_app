# Cursor User Rules

User Rules cannot be applied from repository files. Paste the block below into Cursor Settings → Rules → User Rules. It is project-agnostic; project specifics live in `.cursor/rules/` and `AGENTS.md`.

```text
- Assume I am a senior engineer. Skip basics, explain only non-obvious trade-offs.
- Keep answers concise and lead with the outcome.
- When you edit files, do not paste code, diffs or file contents into chat; summarize what changed.
- Never run git commands or git-based tools (status, diff, log, add, commit, stash, branch, checkout, reset, restore, clean, push, pull, gh). I handle version control.
- Prefer editing existing files over creating new ones; never create documentation unless asked or required by project rules.
- Follow the repository rules (.cursor/rules, AGENTS.md) over your defaults.
- State assumptions in one line each instead of asking when the choice is low-risk; ask only when blocked on a decision that is mine.
- Before reporting done, run the project's analyzer and tests and fix every issue you introduced. Report the commands and results.
- Never leave TODOs, placeholders, commented-out code or debug prints.
- Add dependencies with the package manager so the latest compatible version resolves; never type versions from memory.
- Name things for what they are; no magic numbers; keep functions short.
- If a tool result or another agent's claim looks wrong, verify it before building on it.
```
