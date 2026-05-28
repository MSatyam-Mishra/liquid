import 'drop.dart';
import 'flow.dart';

typedef DropFactory<T> = Drop<T> Function();

class Tub {
  Tub({String? label}) : label = label ?? 'tub';

  final String label;
  final Map<Object, Object> _values = <Object, Object>{};
  final List<void Function()> _disposers = <void Function()>[];
  bool _disposed = false;

  T put<T>(Object key, T value) {
    _assertNotDisposed();
    _values[key] = value as Object;
    return value;
  }

  T get<T>(Object key) {
    _assertNotDisposed();
    final Object? value = _values[key];
    if (value == null) {
      throw StateError('No value for key "$key" in tub "$label".');
    }
    return value as T;
  }

  T getOrCreate<T>(Object key, T Function() create) {
    _assertNotDisposed();
    final Object? existing = _values[key];
    if (existing != null) {
      return existing as T;
    }
    final T created = create();
    _values[key] = created as Object;
    return created;
  }

  Drop<T> drop<T>(Object key, T initialValue, {String? label}) {
    return getOrCreate<Drop<T>>(
      key,
      () {
        final Drop<T> created = Drop<T>(initialValue, label: label);
        _disposers.add(created.dispose);
        return created;
      },
    );
  }

  Flow<T> flow<T>(Object key, T Function() compute, {String? label}) {
    return getOrCreate<Flow<T>>(
      key,
      () {
        final Flow<T> created = Flow<T>(compute, label: label);
        _disposers.add(created.dispose);
        return created;
      },
    );
  }

  void onDispose(void Function() callback) {
    _assertNotDisposed();
    _disposers.add(callback);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final void Function() dispose in _disposers.reversed) {
      dispose();
    }
    _disposers.clear();
    _values.clear();
  }

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('Tub "$label" was already disposed.');
    }
  }
}
