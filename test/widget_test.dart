import 'package:flutter_test/flutter_test.dart';

import 'package:notely/main.dart';
import 'package:notely/models/note.dart';

void main() {
  testWidgets('shows Supabase setup guidance when app is not configured', (
    tester,
  ) async {
    await tester.pumpWidget(const NotelyApp());

    expect(find.text('Notely 還差最後一步'), findsOneWidget);
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
  });

  test('maps a note to the Supabase insert payload', () {
    final note = Note(
      id: '',
      userId: '',
      title: '今天的想法',
      content: '記得把想法寫下來。',
      tag: '日記',
      color: 'coral',
      isPinned: true,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

    expect(note.toInsertMap('user-123'), {
      'user_id': 'user-123',
      'title': '今天的想法',
      'content': '記得把想法寫下來。',
      'tag': '日記',
      'color': 'coral',
      'is_pinned': true,
    });
  });
}
