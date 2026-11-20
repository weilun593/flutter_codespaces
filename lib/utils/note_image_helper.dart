import 'package:image_picker/image_picker.dart';

import '../repositories/notes_repository.dart';

class NoteImageHelper {
  NoteImageHelper._();

  static Future<String?> pickAndUpload({
    required NotesRepository repository,
    required String ownerId,
  }) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;

    final extension = image.name.split('.').last.toLowerCase();
    final contentType = image.mimeType ?? switch (extension) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    return repository.uploadNoteImage(
      ownerId: ownerId,
      fileName: image.name,
      contentType: contentType,
      bytes: await image.readAsBytes(),
    );
  }
}