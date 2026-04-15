import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/components/components.dart';

void main() {
  Widget createWidgetUnderTest({
    required String title,
    String imageUrl = '',
    Color color = Colors.black,
    List<Widget>? actions,
    Widget? leading,
    bool isCenter = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        appBar: MyAppBar(
          title: title,
          imageUrl: imageUrl,
          color: color,
          actions: actions,
          leading: leading,
          isCenter: isCenter,
        ),
      ),
    );
  }

  testWidgets('MyAppBar displays title correctly', (WidgetTester tester) async {
    const testTitle = 'Test Title';
    await tester.pumpWidget(createWidgetUnderTest(title: testTitle));

    expect(find.text(testTitle), findsOneWidget);
  });

  testWidgets('MyAppBar uses custom color for title', (WidgetTester tester) async {
    const testTitle = 'Colored Title';
    const testColor = Colors.red;
    await tester.pumpWidget(createWidgetUnderTest(title: testTitle, color: testColor));

    final textWidget = tester.widget<Text>(find.text(testTitle));
    expect(textWidget.style?.color, testColor);
  });

  testWidgets('MyAppBar renders leading widget when provided', (WidgetTester tester) async {
    const leadingKey = Key('leading-icon');
    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Title',
      leading: const Icon(Icons.menu, key: leadingKey),
    ));

    expect(find.byKey(leadingKey), findsOneWidget);
  });

  testWidgets('MyAppBar renders actions when provided', (WidgetTester tester) async {
    const actionKey1 = Key('action-1');
    const actionKey2 = Key('action-2');
    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Title',
      actions: [
        const Icon(Icons.search, key: actionKey1),
        const Icon(Icons.more_vert, key: actionKey2),
      ],
    ));

    expect(find.byKey(actionKey1), findsOneWidget);
    expect(find.byKey(actionKey2), findsOneWidget);
  });

  testWidgets('MyAppBar centers title when isCenter is true', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Centered Title',
      isCenter: true,
    ));

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.centerTitle, true);

    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisAlignment, MainAxisAlignment.center);
  });

  testWidgets('MyAppBar does not center title when isCenter is false', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Left Title',
      isCenter: false,
    ));

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.centerTitle, false);

    final row = tester.widget<Row>(find.byType(Row).first);
    expect(row.mainAxisAlignment, MainAxisAlignment.start);
  });

  testWidgets('MyAppBar shows image when imageUrl is provided', (WidgetTester tester) async {
    // Note: Image.asset might fail in tests if the asset is not found,
    // but here we just check if the Image widget is present.
    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Title with Image',
      imageUrl: 'assets/images/brand/poltek.png',
    ));

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('MyAppBar does not show image when imageUrl is empty', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      title: 'Title without Image',
      imageUrl: '',
    ));

    expect(find.byType(Image), findsNothing);
  });
}
