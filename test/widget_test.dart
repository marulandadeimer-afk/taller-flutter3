import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_agenda/main.dart';

void main() {
  testWidgets('GestorAgendaApp renders initial placeholder', (tester) async {
    await tester.pumpWidget(const GestorAgendaApp());

    expect(find.text('Gestor de Agenda'), findsOneWidget);
  });
}
