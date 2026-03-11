import 'package:ankara_guess/src/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen shows play button', (WidgetTester tester) async {
    await tester.pumpWidget(const AnkaraGuessApp());
    expect(find.text('OYNA'), findsOneWidget);
  });
}
