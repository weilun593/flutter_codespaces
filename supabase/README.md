# Supabase Storage setup

Run `storage_setup.sql` in the Supabase SQL Editor to create the public `note-images` bucket and its upload/delete policies. Authenticated users can upload and remove files only from their own user-id folder. Public read access is enabled so saved note images can be displayed.

After adding the `image_picker` dependency, run `flutter pub get` in the project root.
