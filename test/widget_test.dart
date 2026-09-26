// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonara/app/sonara_app.dart';

void main() {
  testWidgets('muestra la pantalla de descubrimiento', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SonaraRecognitionApp());
    await tester.pumpAndSettle();

    expect(find.text('Encuentra el sonido.'), findsOneWidget);
    expect(find.text('Grabar 8 segundos'), findsOneWidget);
    expect(
      find.text('Graba un fragmento y envialo para reconocerlo.'),
      findsOneWidget,
    );
    expect(find.text('RECONOCER DESDE UN ENLACE'), findsNothing);
  });

  testWidgets('restaura y muestra la ultima cancion reconocida', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'last_recognized_track': jsonEncode({
        'title': 'After Hours',
        'artist': 'The Weeknd',
        'album': 'Single',
        'artwork': '',
        'genre': 'R&B/Soul',
        'releaseDate': '2020',
        'links': {'shazam': '', 'appleMusic': '', 'spotify': '', 'deezer': ''},
      }),
    });
    await tester.pumpWidget(const SonaraRecognitionApp());
    await tester.pumpAndSettle();

    expect(find.text('Ultimo resultado'), findsOneWidget);
    expect(find.text('After Hours'), findsOneWidget);
    expect(find.text('The Weeknd'), findsOneWidget);
  });
}
