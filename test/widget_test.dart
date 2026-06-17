import 'package:flutter_test/flutter_test.dart';
import 'package:temu_disabilitas/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TemuDisabilitasApp());
    expect(find.text('TemuDisabilitas'), findsOneWidget);
  });
}
