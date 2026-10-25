import { describe, expect, it } from "vitest";
import { greet } from "./greeting.js";

describe("greet", () => {
  it("returns a greeting for a name", () => {
    const result = greet("Ada");

    expect(result).toEqual({ ok: true, value: "Hello, Ada!" });
  });

  it("rejects a blank name", () => {
    const result = greet("   ");

    expect(result).toEqual({ ok: false, error: "EMPTY_NAME" });
  });
});
