import 'package:flutter_test/flutter_test.dart';
import 'package:brikolik_mvp/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BrikolikApp());
    expect(find.text('Brikolik'), findsOneWidget);
  });
}
