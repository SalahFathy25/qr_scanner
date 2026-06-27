import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code/app/models/qr_code_model.dart';
import 'package:qr_code/app/widgets/qr_card.dart';

void main() {
  testWidgets('qrCard displays title and data', (tester) async {
    final qrCode = QrCodeModel(
      id: 'test1',
      title: 'Test Title',
      data: 'test data',
      category: 'text',
    );

    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: qrCard(
          qrCode: qrCode,
          onTap: () => tapped = true,
          onDelete: () {},
          onFavoriteToggle: () {},
        ),
      ),
    ));

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('test data'), findsOneWidget);

    await tester.tap(find.text('Test Title'));
    expect(tapped, true);
  });

  testWidgets('qrCard favorite icon toggles', (tester) async {
    final qrCode = QrCodeModel(
      id: 'test2',
      title: 'Fav Test',
      data: 'data',
      category: 'text',
    );

    bool favorited = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: qrCard(
          qrCode: qrCode,
          onTap: () {},
          onDelete: () {},
          onFavoriteToggle: () => favorited = true,
        ),
      ),
    ));

    final favButton = find.byIcon(Icons.favorite_border_rounded);
    expect(favButton, findsOneWidget);

    await tester.tap(favButton);
    expect(favorited, true);
  });

  testWidgets('qrCard shows favorite icon when favorited', (tester) async {
    final qrCode = QrCodeModel(
      id: 'test3',
      title: 'Fav',
      data: 'data',
      category: 'text',
      isFavorite: true,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: qrCard(
          qrCode: qrCode,
          onTap: () {},
          onDelete: () {},
          onFavoriteToggle: () {},
        ),
      ),
    ));

    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });
}
