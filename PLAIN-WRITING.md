# Plain Writing

Working copy of the plain-writing guidance from `~/.claude/CLAUDE.md`. Edit here,
then write it back to the global file.

---

Write plainly. Aim for how good technical documentation reads.

- Say the fact in ordinary word order. Avoid constructions chosen for effect:
  - showy word choice: "hop" for a dispatch, "under the hood", "spin up", "table stakes", "first-class citizen"
  - clefts and inversions that hold the point until the end of the sentence
  - two clauses built in matching shape, so the pair sounds like a saying
  - the "X, not Y" and "not just X but Y" contrast
  - a "Where X did A, Y does B" frame, which sets two balanced clauses against each other: "Where that form counted with an index, a range supplies the numbers." Say what the construct does, and name the older one plainly if the reader needs the mapping.
  - an image invented on top of a term that already exists. The established term stays: say "the importing code" rather than "code on the other side" of a module boundary. This includes code constructs as actors — a path does not carry cleanup, a `guard` is not "a place to forget" something, and you iterate over a sequence rather than walk it.
  - a clause added after a comma that the sentence did not need: "leaves the current scope, whichever way it leaves"
  - a sentence true by definition, presented as a finding: "A path that leaves before reaching it never registers it."
  - a closer that tells the reader the paragraph mattered: "This is what makes `defer` the right place for cleanup."
- Define a term by saying what it means. Do not defer the answer to a later paragraph.
- Cut:
  - filler: `actually`, `just`, `very`, `simply`
  - openers like "It is important to note that"
  - a sentence that repeats the one before it
  - a trailing "so that..." clause explaining something already clear
  - "in order to", which is "to"
- Keep:
  - the real names for types, patterns, and APIs. The reader is technical, so use the field's vocabulary.
  - qualifiers that are true, and the "because" behind a claim
  - an example that makes an abstract rule concrete
  - outside programming, a common word, or an explanation of the term the first time it appears
- These constructions appear most often in transition sentences: the abstract line, the sentence after a heading, the one before a code block. There the fact is already stated and the sentence only bridges. Remove it; if the reader loses nothing, leave it out.
- Being short matters less than being complete. Use the fewest words that still say the whole thing.
