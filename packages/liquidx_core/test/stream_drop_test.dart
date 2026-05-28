import 'dart:async';

import 'package:liquidx_core/liquidx_core.dart';
import 'package:test/test.dart';

void main() {
  test('stream drop keeps latest successful result only', () async {
    final StreamDrop<int> drop = StreamDrop<int>(label: 'remote_count');
    final Completer<int> slow = Completer<int>();

    unawaited(drop.run(() => slow.future));
    await drop.run(() async => 2);
    slow.complete(1);
    await Future<void>.delayed(Duration.zero);

    final AsyncDropState<int> state = drop.value;
    expect(state, isA<AsyncData<int>>());
    expect((state as AsyncData<int>).value, 2);
  });

  test('stream drop emits async errors', () async {
    final StreamDrop<int> drop = StreamDrop<int>(label: 'failing_task');
    await drop.run(() async => throw StateError('boom'));

    final AsyncDropState<int> state = drop.value;
    expect(state, isA<AsyncError<int>>());
  });
}
