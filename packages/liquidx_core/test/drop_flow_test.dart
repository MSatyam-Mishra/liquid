import 'package:liquidx_core/liquidx_core.dart';
import 'package:test/test.dart';

void main() {
  test('drop updates and notifies listeners', () {
    final Drop<int> count = Drop<int>(0, label: 'count');
    var notifications = 0;

    count.addListener(() {
      notifications++;
    });

    count.value = 1;
    count.update((int current) => current + 1);

    expect(count.value, 2);
    expect(notifications, 2);
  });

  test('flow recomputes when dependencies change', () {
    final Drop<int> a = Drop<int>(1, label: 'a');
    final Drop<int> b = Drop<int>(2, label: 'b');
    var recomputes = 0;

    final Flow<int> sum = Flow<int>(() {
      recomputes++;
      return a.value + b.value;
    }, label: 'sum');

    expect(sum.value, 3);
    expect(sum.value, 3);
    expect(recomputes, 1);

    a.value = 10;
    expect(sum.value, 12);
    expect(recomputes, 2);
  });
}
