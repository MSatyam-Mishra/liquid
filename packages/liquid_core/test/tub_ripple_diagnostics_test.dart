import 'package:liquid_core/liquid_core.dart';
import 'package:test/test.dart';

void main() {
  setUp(LiquidDiagnostics.reset);

  test('tub stores drops and disposes in reverse order', () {
    final Tub tub = Tub(label: 'feature_tub');
    final List<String> disposalOrder = <String>[];

    tub.onDispose(() => disposalOrder.add('custom'));
    final Drop<int> count = tub.drop<int>('count', 0, label: 'count');
    tub.onDispose(() => disposalOrder.add('tail'));

    expect(tub.get<Drop<int>>('count').value, 0);
    count.value = 3;
    expect(tub.get<Drop<int>>('count').value, 3);

    tub.dispose();
    expect(disposalOrder, <String>['tail', 'custom']);
    expect(count.isDisposed, isTrue);
  });

  test('ripple triggers effect and diagnostics receives events', () {
    final Drop<int> source = Drop<int>(0, label: 'source');
    final LiquidTimelineObserver timeline = LiquidTimelineObserver();
    LiquidDiagnostics.addObserver(timeline);

    var fired = 0;
    final Ripple ripple = Ripple(
      source: source,
      label: 'source_ripple',
      effect: () {
        fired++;
      },
    );

    source.value = 1;
    source.value = 2;

    expect(fired, 2);
    expect(
      timeline.events.where((LiquidEvent e) => e.type == LiquidEventType.rippleFired).length,
      2,
    );

    ripple.dispose();
  });
}
