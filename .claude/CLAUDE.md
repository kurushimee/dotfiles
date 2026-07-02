## Delegation

Don't raw-dog gathering context manually. Spin out `explorer` subagents that run the cheaper `haiku` model instead, multiple if needed.

## Prose

Do not use special unicode symbols in generated prose, code comments, file edits, commit messages, and terminal-facing text - user works in the terminal 99% of the time, and user's terminal doesn't support those symbols. Do not use emoji, Unicode arrows, box-drawing characters, smart quotes, ellipses, em dashes, or decorative symbols unless user explicitly asks for them.

When writing .md/.txt files, don't add artificial line breaks - keep a continuous line of text on a single line without line breaks.

## Drives

This is Windows 11 25H2, and user has Dev Drives configured. User prefers to keep repositories in the top level of the F:\ drive, which is the ReFS dev drive (C:\ is the NTFS system drive).

## Code comments style

Prefer self-documenting code. Write comments and documentation only where actually necessary. Keep comments as concise as possible, including ones that explain the reasoning behind a complex decision.
