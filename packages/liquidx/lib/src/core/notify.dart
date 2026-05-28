import 'diagnostics.dart';
import 'drop.dart';
import 'pool.dart';

class Notify implements ReactiveSource {
  Notify({String? label}) : label = label ?? 'notify';

  @override
  final String label;
  final Set<LiquidListener> _listeners = <LiquidListener>{};
  bool _disposed = false;

  @override
  void addListener(LiquidListener listener) {
    _assertNotDisposed();
    _listeners.add(listener);
  }

  @override
  void removeListener(LiquidListener listener) {
    _listeners.remove(listener);
  }

  void fire({Map<String, Object?>? data}) {
    _assertNotDisposed();
    LiquidDiagnostics.emit(
      LiquidEvent(
        type: LiquidEventType.notifyFired,
        label: label,
        data: data,
      ),
    );
    for (final LiquidListener listener in List<LiquidListener>.from(_listeners)) {
      listener();
    }
  }

  void dispose() {
    _disposed = true;
    _listeners.clear();
  }

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('Notify "$label" was already disposed.');
    }
  }
}
