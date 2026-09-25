import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class NotesRepository {
  NotesRepository(this._client);

  final SupabaseClient _client;

  Future<List<Note>> fetchNotes() async {
    final rows = await _client
        .from('notes')
        .select()
        .order('is_pinned', ascending: false)
        .order('updated_at', ascending: false);

    return (rows as List<dynamic>)
        .map((row) => Note.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<Note> createNote({
    required String ownerId,
    required Note draft,
  }) async {
    final row = await _client
        .from('notes')
        .insert(draft.toInsertMap(ownerId))
        .select()
        .single();
    return Note.fromMap(row);
  }

  Future<Note> updateNote(Note note) async {
    final row = await _client
        .from('notes')
        .update(note.toUpdateMap())
        .eq('id', note.id)
        .select()
        .single();
    return Note.fromMap(row);
  }

  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }
}
