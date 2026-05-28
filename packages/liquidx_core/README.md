# liquidx_core

Minimal reactive state engine for Dart applications and Onion Architecture.

`liquidx_core` is framework-agnostic. Use it in pure Dart services, CLI tools,
server applications, or as the foundation for UI bindings like Flutter.

## Features

- Simple mutable state with `Drop<T>`
- Memoized derived state with `Flow<T>`
- Scoped lifecycle management with `Tub`
- Side effects via `Ripple`
- Async state model through `StreamDrop<T>`
- Diagnostics/events for observability and debugging

## Installation (pub.dev)

```yaml
dependencies:
  liquidx_core: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

### Example 1: Basic state with `Drop`

```dart
import 'package:liquidx_core/liquidx_core.dart';

void main() {
  final count = Drop<int>(0, label: 'count');
  count.addListener(() => print('count changed -> ${count.value}'));

  count.value = 1;
  count.update((current) => current + 10);
}
```

### Example 2: Derived state with `Flow`

```dart
import 'package:liquidx_core/liquidx_core.dart';

void main() {
  final price = Drop<double>(100, label: 'price');
  final tax = Drop<double>(0.18, label: 'tax');

  final total = Flow<double>(
    () => price.value + (price.value * tax.value),
    label: 'total',
  );

  print(total.value); // 118.0
  price.value = 200;
  print(total.value); // 236.0
}
```

### Example 3: Feature scope with `Tub`

```dart
import 'package:liquidx_core/liquidx_core.dart';

void main() {
  final tub = Tub(label: 'cart_feature');
  final items = tub.drop<int>('items', 0, label: 'items');
  final isEmpty = tub.flow<bool>('is_empty', () => items.value == 0);

  items.value = 2;
  print(isEmpty.value); // false

  tub.dispose();
}
```

### Example 4: Side effects using `Ripple`

```dart
import 'package:liquidx_core/liquidx_core.dart';

void main() {
  final status = Drop<String>('idle', label: 'status');
  final ripple = Ripple(
    source: status,
    label: 'status_logger',
    effect: () => print('status -> ${status.value}'),
  );

  status.value = 'loading';
  status.value = 'done';
  ripple.dispose();
}
```

### Example 5: Async loading with `StreamDrop`

```dart
import 'package:liquidx_core/liquidx_core.dart';

Future<List<String>> fetchTodos() async {
  return <String>['one', 'two', 'three'];
}

Future<void> main() async {
  final todos = StreamDrop<List<String>>(label: 'todos');
  await todos.run(fetchTodos);

  final state = todos.value;
  if (state is AsyncData<List<String>>) {
    print(state.value.length); // 3
  }
}
```

## Diagnostics

Subscribe to lifecycle/state events:

```dart
import 'package:liquidx_core/liquidx_core.dart';

void main() {
  final timeline = LiquidTimelineObserver(maxEvents: 100);
  LiquidDiagnostics.addObserver(timeline);

  final count = Drop<int>(0, label: 'count');
  count.value = 1;

  print(timeline.events.last.type); // LiquidEventType.dropSet
  LiquidDiagnostics.removeObserver(timeline);
}
```

## Onion Architecture Guidance

- Domain:
  - expose pure entities/value objects
  - optionally accept `ReadDrop<T>` where reactive reads help
- Application:
  - create and own `Tub` for each module/use-case boundary
  - coordinate writes and derived computations
- Infrastructure:
  - map external streams/futures to `StreamDrop`
  - keep IO concerns outside domain logic

## API Surface

Public exports:

- `Drop`, `ReadDrop`
- `Flow`, `ReactiveSource`
- `Tub`
- `Ripple`
- `StreamDrop`, `AsyncIdle`, `AsyncLoading`, `AsyncData`, `AsyncError`
- `LiquidDiagnostics` and diagnostic event types

## Testing Tips

- Instantiate fresh `Tub` per test for isolated state graphs.
- Use direct value assertions for `Drop` and `Flow`.
- For async behavior, assert final `StreamDrop` state is `AsyncData`/`AsyncError`.
