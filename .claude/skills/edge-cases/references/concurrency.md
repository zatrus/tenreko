# Concurrency patterns and tests

Load this when a design has an invariant on shared state ("stock ≥ 0", "paid at most once", "one active subscription per user").

**Verified on 2026-10-25** against Postgres 18 in Docker: for each stack below, the parallel test passed with the atomic version and **failed with the naive "check, then write" version** (10 of 10 buyers got the single item, even inside `@Transactional` and with a `CHECK (stock >= 0)` constraint, because every buyer writes `0`). The Spring Boot code ran inside the template's scaffold with persistence enabled. The Python and Node tests ran against a plain Postgres container. In a project, start that container with Testcontainers (`testcontainers[postgres]` / `@testcontainers/postgresql`); that wiring wasn't part of the run.

## 1. Pick a mechanism

| Situation | Mechanism | Loser sees |
|---|---|---|
| A counter or balance with a limit (stock, seats, credit) | **Conditional update** in one statement: `UPDATE … SET n = n - :q WHERE id = :id AND n >= :q`, then check the row count | 0 rows → domain error |
| "At most one" (unique username, one active subscription, one vote) | **Unique constraint** or partial unique index (`… WHERE active`) | constraint violation → domain error |
| Complex update of one aggregate (many fields, rules in code) | **Optimistic locking**: version column (`@Version` in JPA) | version conflict → 409, client retries |
| Several rows must change together, conflicts are frequent | **Pessimistic lock**: `SELECT … FOR UPDATE` (lock rows in a fixed order to avoid deadlocks) | waits; set a lock timeout |
| Retries and duplicate deliveries of side effects (payment, email, webhook) | **Idempotency key**: unique constraint on the key; store and replay the first response | the same response as the first call |

Not mechanisms: `if (x.stock > 0) save(x.stock - 1)`, `@Transactional` on its own (READ COMMITTED lets both readers see `1`), an in-memory lock or `synchronized` (breaks with two app instances), a check in the UI.

## 2. The test shape (all stacks)

1. **Arrange** the boundary state: stock `1`, balance exactly the price, and so on.
2. **Act:** N workers (10 is enough) wait behind **one start gate** and then all call the real service with real DB connections. No sleeps.
3. **Assert** the exact outcome: exactly 1 success, N−1 domain errors (no other exceptions), and the final state (stock `0`).
4. **Prove it bites:** before writing the mechanism, run the test against the naive implementation and see it fail. Write that in the task's *Verify* line.

Use the real datastore (Testcontainers). H2 and SQLite lock differently and can hide or invent races.

## 3. Spring Boot (JPA + Flyway + Testcontainers)

Enable persistence: uncomment the persistence lines in `build.gradle.kts` (main dependencies, plus `data.jpa.test`, `spring.boot.testcontainers`, `testcontainers.junit.jupiter`, `testcontainers.postgresql` in the `integrationTest` suite) and the `jpa`/`datasource` block in `application.yml`. Then add the container config and `@Import` it in **every** `*IT`, including the existing `ApplicationIT`.

`src/main/resources/db/migration/V1__create_product.sql`
```sql
create table product (
    id    bigint generated always as identity primary key,
    name  text not null,
    stock integer not null check (stock >= 0)
);
```

`ProductRepository.java`
```java
public interface ProductRepository extends JpaRepository<Product, Long> {

  /** Atomic check-and-decrement. Returns 1 if the stock was taken, 0 if not enough was left. */
  @Modifying
  @Query(
      "update Product p set p.stock = p.stock - :quantity"
          + " where p.id = :id and p.stock >= :quantity")
  int takeStock(@Param("id") long id, @Param("quantity") int quantity);
}
```

`PurchaseService.java` (`OutOfStockException extends DomainException`, so the scaffold's `ApiExceptionHandler` returns 422 problem+json)
```java
@Service
public class PurchaseService {

  private final ProductRepository products;

  PurchaseService(ProductRepository products) {
    this.products = products;
  }

  /**
   * Invariant: stock is never negative and never oversold. The database checks and decrements in
   * one statement, so two buyers can't both take the last item.
   */
  @Transactional
  public void purchase(long productId, int quantity) {
    if (products.takeStock(productId, quantity) == 0) {
      throw new OutOfStockException(productId);
    }
  }
}
```
If "unknown product" must differ from "out of stock", check `existsById` only after the update returned 0.

`src/integrationTest/java/<pkg>/TestcontainersConfiguration.java`
```java
/** Real Postgres for every *IT. Import it with @Import(TestcontainersConfiguration.class). */
@TestConfiguration(proxyBeanMethods = false)
public class TestcontainersConfiguration {

  @Bean
  @ServiceConnection
  PostgreSQLContainer postgres() {
    return new PostgreSQLContainer("postgres:18-alpine"); // org.testcontainers.postgresql
  }
}
```

`src/integrationTest/java/<pkg>/stock/ParallelPurchaseIT.java`
```java
/** REQ-x.y: two buyers can never both get the last item. Runs against real Postgres. */
@SpringBootTest
@ActiveProfiles("test")
@Import(TestcontainersConfiguration.class)
class ParallelPurchaseIT {

  private static final int BUYERS = 10;

  @Autowired private PurchaseService purchases;
  @Autowired private ProductRepository products;

  @Test
  void only_one_buyer_gets_the_last_item() throws Exception {
    // Arrange
    long id = products.save(new Product("lamp", 1)).getId();

    // Act
    List<Boolean> bought = runAtTheSameTime(BUYERS, () -> tryPurchase(id));

    // Assert
    assertThat(bought).containsOnlyOnce(true).hasSize(BUYERS);
    assertThat(products.findById(id)).get().extracting(Product::getStock).isEqualTo(0);
  }

  private boolean tryPurchase(long id) {
    try {
      purchases.purchase(id, 1);
      return true;
    } catch (OutOfStockException e) {
      return false;
    }
  }

  /** Starts all tasks behind one gate so they really overlap, then waits for every result. */
  private static <T> List<T> runAtTheSameTime(int count, Callable<T> task) throws Exception {
    CountDownLatch startGate = new CountDownLatch(1);
    try (var pool = Executors.newVirtualThreadPerTaskExecutor()) {
      List<Future<T>> futures =
          IntStream.range(0, count)
              .mapToObj(
                  i ->
                      pool.submit(
                          () -> {
                            startGate.await();
                            return task.call();
                          }))
              .toList();
      startGate.countDown();
      List<T> results = new ArrayList<>();
      for (Future<T> future : futures) {
        results.add(future.get(30, TimeUnit.SECONDS));
      }
      return results;
    }
  }
}
```
`tryPurchase` catches only the domain exception. Anything else (deadlock, pool timeout) fails the test, as it should. Move `runAtTheSameTime` into a shared test helper once a second test needs it.

Other mechanisms in Spring:
- `@Version private long version;` on the entity, plus a `version bigint not null default 0` column. Map `ObjectOptimisticLockingFailureException` to 409.
- `@Lock(LockModeType.PESSIMISTIC_WRITE)` on a repository `find` method, inside the service's `@Transactional`.
- Unique constraint in the migration. Map `DataIntegrityViolationException` (for that constraint only) to a domain error.

## 4. Python (pytest + psycopg)

```python
def take_stock(conn: psycopg.Connection, product_id: int, quantity: int) -> None:
    """Atomic check-and-decrement: 0 rows updated means not enough stock."""
    with conn.transaction():
        cur = conn.execute(
            "UPDATE product SET stock = stock - %s WHERE id = %s AND stock >= %s",
            (quantity, product_id, quantity),
        )
        if cur.rowcount == 0:
            raise OutOfStockError(product_id)


def run_at_the_same_time(count: int, task: Callable[[], bool]) -> list[bool]:
    """Start all workers behind one barrier so they really overlap."""
    barrier = threading.Barrier(count)

    def worker() -> bool:
        barrier.wait(timeout=10)
        return task()

    with ThreadPoolExecutor(max_workers=count) as pool:
        futures = [pool.submit(worker) for _ in range(count)]
        return [f.result(timeout=30) for f in futures]


def test_only_one_buyer_gets_the_last_item(product_id: int, dsn: str) -> None:  # REQ-x.y
    def try_purchase() -> bool:
        with psycopg.connect(dsn) as conn:  # one connection per buyer, like a pool
            try:
                take_stock(conn, product_id, 1)
                return True
            except OutOfStockError:
                return False

    bought = run_at_the_same_time(10, try_purchase)

    assert bought.count(True) == 1
    with psycopg.connect(dsn) as conn:
        assert conn.execute("SELECT stock FROM product WHERE id = %s", (product_id,)).fetchone() == (0,)
```
`dsn` comes from a session fixture that starts `PostgresContainer("postgres:18-alpine")` from `testcontainers.postgres`. With SQLAlchemy, the same statement is `update(Product).where(Product.id == id, Product.stock >= q).values(stock=Product.stock - q)`. For async code, use `asyncio.gather` with one connection per task.

## 5. Node (Vitest + pg)

```ts
// Atomic check-and-decrement: 0 rows updated means not enough stock.
export async function takeStock(db: Queryable, productId: string, quantity: number): Promise<void> {
  const result = await db.query(
    'UPDATE product SET stock = stock - $1 WHERE id = $2 AND stock >= $1',
    [quantity, productId],
  );
  if (result.rowCount === 0) throw new OutOfStockError(productId);
}

test('only one buyer gets the last item', async () => { // REQ-x.y
  const id = await insertProduct({ stock: 1 });

  const bought = await Promise.all(Array.from({ length: 10 }, () => tryPurchase(id)));

  expect(bought.filter(Boolean)).toHaveLength(1);
  expect(await stockOf(id)).toBe(0);
});
```
Use a `pg.Pool` with `max` ≥ the number of buyers, so the calls really run on separate connections. Node is single-threaded, but every `await` between a read and a write is a race window: the naive `SELECT` then `UPDATE` version failed this test every time. Start Postgres with `@testcontainers/postgresql` in Vitest `globalSetup`.

## 6. Idempotency key (retries, double submit, duplicate messages)

```sql
create table idempotency_key (
    key        text primary key,          -- sent by the client, e.g. Idempotency-Key header
    request    text not null,             -- hash of the request body: same key + other body = 422
    response   jsonb,                     -- null while in progress
    created_at timestamptz not null default now()
);
```
Insert the key in the **same transaction** as the side effect. A unique violation means the request was seen before: return the stored response, or 409 if it's still in progress. Test it with N identical requests in parallel: exactly one side effect, and all N get the same response.
