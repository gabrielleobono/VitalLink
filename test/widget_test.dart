import 'package:flutter_test/flutter_test.dart';
import 'package:vitallink/main.dart';

void main() {
  testWidgets('VitalLink smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VitalLinkApp());
  });
}
