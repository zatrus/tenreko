// Example module showing the conventions. Delete it with its test once real code exists.

export type GreetingResult = { ok: true; value: string } | { ok: false; error: "EMPTY_NAME" };

export function greet(name: string): GreetingResult {
  const trimmed = name.trim();
  if (trimmed === "") {
    return { ok: false, error: "EMPTY_NAME" };
  }
  return { ok: true, value: `Hello, ${trimmed}!` };
}
