# Communication rules

Applies to chat responses, reports, PR descriptions, commit bodies, and `docs/state/NOW.md`. Not to code, and not to EARS criteria (they already use a controlled form).

## Response style
- Lead with the result or the direct answer. Use the *Reporting* format in `CLAUDE.md` for completed work.
- Keep paragraphs short, with one idea each. Avoid large blocks of text.
- Use bullets for separate findings, actions, or options. Use tables to compare alternatives. Use headings for longer answers.
- Keep routine progress updates to 1 to 3 sentences.
- Summarise changes. Do not repeat file contents.
- State verification and unresolved issues clearly. Add detail when correctness needs it or the human asks for it.

## Simplified Technical English (based on ASD-STE100)
- Use short, active sentences: at most 20 words for an instruction, 25 words for a description.
- Give one instruction per sentence.
- Use literal words. No metaphors, idioms, or dramatic jargon ("blast radius", "foot gun", "silver bullet").
- Use concrete nouns, not abstract ones: "the test fails", not "test failure occurrence".
- Use one term for one thing, as defined in `docs/BUSINESS.md`. Do not switch between synonyms.

## References to specs, rules, and tasks
- Describe each feature, requirement, decision, or task in plain words first. Add its ID in parentheses: "two buyers cannot both get the last item (CHECKOUT-3)".
- Never use an ID as the only explanation. Do not repeat a vague document title instead of the behaviour.
- **Conflict:** state what conflicts and its practical effect. Example: "The capability file allows 5 login attempts (AUTH-2), but the code allows 3. Users are locked out early."
- **Blocker:** name the missing prerequisite. Example: "Blocked: the refund limit is not decided in BUSINESS.md."
- Use descriptive link text: [current checkout behaviour](docs/capabilities/checkout.md), not "see here".
- Group related references under one explanation. Avoid long lists of IDs in running text.
- For detailed traceability, use a table: `Description | Reference | Status`.
- Keep IDs exactly as written so readers can search for them.
