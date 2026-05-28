# Liquid

Liquid is a lightweight state management system for Dart and Flutter focused on:

- very small API surface
- deterministic updates
- clean Onion Architecture boundaries
- easy testability without hidden globals

This repository is a monorepo with two packages:

- `packages/liquid_core`: framework-agnostic reactive core for Dart
- `packages/liquid_flutter`: Flutter bindings package (`liquidx`)

## Why Liquid

Liquid aims to keep the "simple path" smaller than typical state libraries:

- one primitive for state: `Drop<T>`
- one primitive for derived state: `Flow<T>`
- one scope/lifecycle container: `Tub`
- one side-effect primitive: `Ripple`
- one async state model: `StreamDrop<T>`

It avoids service-locator style hidden dependency reads and encourages explicit scope ownership through `Tub`.

## Core Concepts

### `Drop<T>`

Smallest mutable state unit.

- Read with `drop.value`
- Write with `drop.value = next` or `drop.update(...)`
- Subscribe via `addListener`

### `Flow<T>`

Memoized computed state with dependency tracking.

- Recomputes when upstream `Drop`/`Flow` dependencies change
- Caches between reads
- Enables granular UI subscriptions

### `Tub`

Scoped container for state graph lifecycle.

- Creates and stores Drops/Flows by key
- Owns cleanup and disposal
- Maps cleanly to feature/module scope

### `Ripple`

Side-effect listener for reactive sources.

- Runs effects on source changes
- Disposable lifecycle
- Useful for navigation, analytics, logging, and command triggers

### `StreamDrop<T>`

Async state holder with race protection.

- States: `AsyncIdle`, `AsyncLoading`, `AsyncData`, `AsyncError`
- Supports future tasks and stream binding
- Ignores stale results from older async executions

## GitHub Usage Guide

### 1) Pure Dart Counter (Drop + Flow)

```dart
import 'package:liquid_core/liquid_core.dart';

void main() {
  final tub = Tub(label: 'counter_scope');
  final count = tub.drop<int>('count', 0, label: 'count');
  final doubled = tub.flow<int>('doubled', () => count.value * 2);

  count.value = 3;
  print(count.value);   // 3
  print(doubled.value); // 6

  tub.dispose();
}
```

### 2) Async Data Fetch (StreamDrop)

```dart
import 'package:liquid_core/liquid_core.dart';

Future<String> fetchProfile() async => 'satya';

Future<void> main() async {
  final profile = StreamDrop<String>(label: 'profile');
  await profile.run(fetchProfile);

  final state = profile.value;
  if (state is AsyncData<String>) {
    print('User: ${state.value}');
  }
}
```

### 3) Flutter Widget Rebuild Control (WatchDrop Selector)

```dart
import 'package:flutter/material.dart';
import 'package:liquidx/liquidx.dart';

class EvenOddText extends StatelessWidget {
  EvenOddText({super.key});
  final count = Drop<int>(0, label: 'count');

  @override
  Widget build(BuildContext context) {
    return WatchDrop<int, bool>(
      source: count,
      select: (value) => value.isEven,
      builder: (context, isEven, _) => Text(isEven ? 'even' : 'odd'),
    );
  }
}
```

## Onion Architecture Mapping

- Domain layer:
  - no Flutter dependency
  - no direct IO concerns
  - can use read-only contracts (`ReadDrop<T>`) where needed
- Application layer:
  - owns `Tub` scope setup
  - orchestrates use-cases and writes to Drops
- Infrastructure layer:
  - adapts APIs/repositories/streams into `StreamDrop` or command methods
- Presentation layer:
  - uses `LiquidScope`, `WatchDrop`, and `RippleEffect`

For a deeper architecture guide and migration references, see `docs/onion_architecture.md`.

## Package Links

- `liquid_core` docs: `packages/liquid_core/README.md`
- `liquidx` docs: `packages/liquid_flutter/README.md`

## Development (Monorepo)

```bash
dart pub get
dart run melos bootstrap
dart run melos exec -- flutter analyze
dart run melos exec -- flutter test
```
