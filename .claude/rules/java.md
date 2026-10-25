---
paths:
  - "**/*.java"
  - "**/*.gradle.kts"
  - "gradle/libs.versions.toml"
---

# Java rules

## Toolchain
- **Java 25 LTS** via the Gradle toolchain, **Gradle via the wrapper** (`./gradlew`, committed, never a global `gradle`). Build scripts use the **Kotlin DSL** (`build.gradle.kts`).
- Gate: `./gradlew check` = Spotless check (google-java-format) + compile with `-Xlint:all -Werror` + unit tests (`test`) + integration tests (`integrationTest` suite) + JaCoCo coverage verification.
- **Versions live only in `gradle/libs.versions.toml`** (version catalog). Reference them as `libs.<alias>`; no version strings in `build.gradle.kts`.
- Keep the build cacheable: configuration cache and build cache are on in `gradle.properties`. Use lazy APIs (`tasks.named`, `tasks.register`, `configureEach`), never `tasks.getByName` or eager `tasks.withType<T> { }` in loops.
- Update the wrapper with `./gradlew wrapper --gradle-version <x.y>`, never by hand-editing (the hook blocks it).
- Format with `./gradlew spotlessApply` (run by `scripts/check.sh --fix`). Don't fight the formatter.

## Code
- **Package by feature**, not by layer: `com.acme.orders` contains its controller, service, repository, and model. Package-private by default; `public` only for the feature's API.
- **Immutability:** `record` for value objects and DTOs, `final` fields, `List.copyOf` / unmodifiable collections at boundaries.
- **Null:** never return `null` from a public method. Use `Optional` for "maybe absent" return values only (not fields or params). Validate params with `Objects.requireNonNull` at public entry points.
- Use `sealed` interfaces + `switch` pattern matching for closed sets of states and results.
- Use `var` only when the type is obvious from the right-hand side.
- **Exceptions:** unchecked domain exceptions extending one base (`OrdersException`), always with a message and cause. Never catch `Exception`/`Throwable` except at the outermost boundary. Never swallow `InterruptedException` (restore the flag).
- Logging via SLF4J with placeholders (`log.info("Order {} paid", id)`), never string concatenation, never `System.out`.
- Use `java.time` with an injected `Clock`. No `Date`/`Calendar`.
- Static utility classes are `final` with a private constructor. Prefer instance collaborators you can fake.

## Tests (JUnit 6 + AssertJ)
- `src/test/java` mirrors the package and holds unit tests (`*Test`). Integration tests (`*IT`) go in `src/integrationTest/java`.
- Run one test: `./gradlew test --tests "com.acme.XTest.method"` (or `integrationTest --tests …`).
- Use AssertJ (`assertThat(...)`), `@ParameterizedTest` for case tables, and `@DisplayName` or method names that read as behaviour.
- Mockito only for collaborators you own and only at boundaries. No `PowerMock`, no mocking of value objects.
- Property-based: jqwik (`@Property` + `@ForAll`), added to the version catalog when the first edge-case REQ needs it. Check its JUnit Platform version matches the one in use before adding it.
- Concurrency: `Executors.newVirtualThreadPerTaskExecutor()` + `CountDownLatch` start gate, `Future.get` with a timeout, then assert the invariant. Pattern: `.claude/skills/edge-cases/references/concurrency.md`.
