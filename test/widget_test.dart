import 'package:flutter_test/flutter_test.dart';

import 'package:student_task_manager/main.dart';

void main() {
  testWidgets('app loads and shows login screen', (tester) async {
    await tester.pumpWidget(const StudentTaskManagerApp());

    expect(find.text('Student Task Manager'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
