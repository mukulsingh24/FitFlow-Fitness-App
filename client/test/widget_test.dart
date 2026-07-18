import 'package:flutter_test/flutter_test.dart';
import 'package:client/main.dart';

void main() {
  testWidgets('FitFlow app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const FitFlowApp());

    expect(find.text('FitFlow'), findsWidgets);
  });
}
