import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class NotesRepository {
  NotesRepository(this._client);

  final SupabaseClient _client;

  Future<String> uploadNoteImage({
    required String ownerId,
    required String fileName,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path = '$ownerId/${DateTime.now().microsecondsSinceEpoch}_$safeName';
    await _client.storage.from('note-images').uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType),
    );
    return _client.storage.from('note-images').getPublicUrl(path);
  }

  Future<void> deleteNoteImages(List<String> publicUrls) async {
    const publicPath = '/object/public/note-images/';
    final paths = publicUrls.map((url) {
      final path = Uri.parse(url).path;
      final markerIndex = path.indexOf(publicPath);
      if (markerIndex < 0) return null;
      return Uri.decodeComponent(path.substring(markerIndex + publicPath.length));
    }).whereType<String>().toList();
    if (paths.isNotEmpty) {
      await _client.storage.from('note-images').remove(paths);
    }
  }

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
