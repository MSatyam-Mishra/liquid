# Liquid + Onion Architecture

Liquid keeps state simple while preserving clean layer boundaries.

## Layer responsibilities

- Domain layer:
  - Holds entities and business rules.
  - Stays Flutter-free and IO-free.
  - Reads state through interfaces (`ReadDrop<T>`) or plain values.
- Application layer:
  - Creates `Tub` scopes.
  - Coordinates use-cases and writes to `Drop`/`StreamDrop`.
  - Exposes `Flow` values for presentation.
- Infrastructure layer:
  - Adapts API/database streams into `StreamDrop`.
  - Never mutates UI directly.
- Presentation layer:
  - Uses `LiquidScope`, `WatchDrop`, `RippleEffect`.
  - Renders `Flow` outputs and dispatches intents.

## Migration examples

### `setState` -> `Drop`

- Before: local mutable field + `setState`.
- After: create a `Drop<int>` and write `drop.value = next`.

### GetX mental model -> Liquid

- `Rx<T>` -> `Drop<T>`.
- Controller-level derived values -> `Flow<T>`.
- Workers/effects -> `Ripple`.
- Route/controller lifecycle -> `Tub` scope lifecycle.

### Riverpod mental model -> Liquid

- Provider state -> `Drop<T>`.
- Computed providers -> `Flow<T>`.
- `ref.listen` side effects -> `Ripple`.
- Scope overrides/testing -> per-test `Tub` instances.
