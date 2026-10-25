import { greet } from "./greeting.js";

const result = greet(process.argv[2] ?? "world");
if (result.ok) {
  process.stdout.write(`${result.value}\n`);
} else {
  console.error(result.error);
  process.exitCode = 1;
}
