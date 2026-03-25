import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mess_hisab_tracker/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MessHisabApp()),
    );
    // App should render without crashing
    expect(find.byType(MessHisabApp), findsOneWidget);
  });
}
