# Notely

一款以 Flutter 與 Supabase 打造的雲端記事本。支援 Email／密碼登入與註冊、筆記新增／編輯／刪除、搜尋、分類標籤、顏色標記與置頂。

## 技術組成

- Flutter 3.47.3
- Dart 3.13.3
- Supabase Flutter 2.17.2
- Supabase Auth：Email／密碼登入與註冊
- Supabase Postgres：筆記資料儲存
- Row Level Security（RLS）：每位使用者只能讀寫自己的筆記

## 啟用 Supabase

1. 在 [Supabase](https://supabase.com/) 建立一個專案。
2. 開啟 **SQL Editor**，貼上並執行 [`supabase/schema.sql`](supabase/schema.sql)。這會建立 `notes` 資料表、索引、權限與 RLS policies。
3. 在 Supabase 專案的 **Project Settings → API** 複製：
   - Project URL
   - Publishable key（新版專案使用 `sb_publishable_...`；若你的專案仍顯示 anon key，也可作為 client-side key 使用）
4. 在 Supabase **Authentication → Providers → Email** 確認 Email provider 已啟用。若保留 Confirm email，註冊後要先完成信箱驗證。

## 執行

在專案根目錄執行：

```bash
flutter pub get
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://你的專案.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=你的_publishable_key
```

也可以使用 Android 或 iOS 裝置：

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://你的專案.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=你的_publishable_key
```

如果沒有帶入設定，App 會顯示設定引導畫面，而不會嘗試初始化 Supabase。

## 驗證

```bash
flutter analyze
flutter test
flutter build web --release \
  --dart-define=SUPABASE_URL=https://你的專案.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=你的_publishable_key
```

## 專案結構

```text
lib/
  core/app_config.dart              # 編譯期 Supabase 設定
  models/note.dart                   # 筆記資料模型
  repositories/notes_repository.dart # Supabase CRUD
  screens/
    auth_gate.dart                   # 登入狀態路由
    login_screen.dart                # 登入／註冊
    home_screen.dart                 # 清單、搜尋、刪除、登出
    note_editor_screen.dart          # 新增／編輯筆記
    supabase_setup_screen.dart       # 未設定時的引導
  theme/app_theme.dart               # Notely 視覺主題
  main.dart                          # App 入口
supabase/schema.sql                  # 資料表與 RLS 設定
```

## 安全備註

Flutter client 只應使用 Supabase 的 Project URL 與 publishable／anon key；不要把 `service_role` key 放進 App、Git repository 或前端環境。資料安全依賴資料庫端的 RLS policies，而不是只依賴 UI。
