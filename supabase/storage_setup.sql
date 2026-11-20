insert into storage.buckets (id, name, public)
values ('note-images', 'note-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Users can upload their note images" on storage.objects;
create policy "Users can upload their note images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'note-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users can delete their note images" on storage.objects;
create policy "Users can delete their note images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'note-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);