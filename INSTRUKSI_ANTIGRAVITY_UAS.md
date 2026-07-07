# Instruksi Pengerjaan UAS Mobile Computing — Le Soie App

## Konteks
Project ini adalah lanjutan dari UTS: aplikasi Flutter **Le Soie** (Beauty Care & Clinic).
Repo sudah punya UI untuk Login, Register, Home, dan Jurnal Rutinitas (AM/PM checklist),
dengan bottom navigation 5 tab: **Beranda, Belanja, AI, Konsultasi, Jurnal**.
Tab Belanja, AI, dan Konsultasi saat ini masih placeholder kosong.

Semua state saat ini pakai `setState` biasa dan tidak ada folder pemisahan logic —
task UAS ini adalah merapikan arsitektur + menambahkan 4 kemampuan wajib: state management,
API integration, local storage, dan mobile feature (device capability).

Tenggat: **Minggu, 12 Juli 2026, 23:59 WIB**. Kerjakan dengan prioritas menyelesaikan
semua item wajib dulu sebelum polish visual tambahan.

---

## Keputusan Teknis (Sudah Difinalkan — Jangan Diganti Tanpa Konfirmasi)

| Aspek | Pilihan |
|---|---|
| Software Architecture | MVC ringan (models / services / providers / screens / widgets) |
| State Management | `provider` package |
| API Integration | DummyJSON — `GET https://dummyjson.com/products/category/skincare` (list produk, ditampilkan di tab **Belanja**) |
| Local Storage | `shared_preferences` — menyimpan status login (`isLoggedIn`, dan opsional `userEmail`) untuk auto-login |
| Mobile Feature | Local Notification — reminder rutinitas skincare AM/PM, dijadwalkan via `flutter_local_notifications` |

---

## 1. Dependencies

Tambahkan ke `pubspec.yaml` (jangan hapus dependency yang sudah ada: `google_fonts`, `flutter_svg`, `cupertino_icons`):

```yaml
dependencies:
  provider: ^6.1.2
  http: ^1.2.2
  shared_preferences: ^2.3.2
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4
```

Setelah edit, jalankan `flutter pub get`.

Untuk Android, cek `android/app/src/main/AndroidManifest.xml`:
- Tambahkan permission notification (Android 13+):
  `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`
- Tambahkan permission exact alarm kalau diperlukan untuk scheduled notif:
  `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>`
- Set ikon notifikasi default di `<application>` sesuai dokumentasi `flutter_local_notifications`.

Untuk iOS, di `ios/Runner/AppDelegate.swift` pastikan delegate notification center di-set sesuai
panduan resmi `flutter_local_notifications` (biasanya cukup default plugin registration).

---

## 2. Struktur Folder Target

Restrukturisasi `lib/` menjadi:

```
lib/
├── main.dart
├── core/
│   └── theme/                    # sudah ada, tidak diubah
│       ├── app_colors.dart
│       └── app_theme.dart
├── models/
│   ├── routine_item.dart         # pindahkan class RoutineItem dari jurnal_screen.dart
│   └── product.dart              # model produk hasil parsing API DummyJSON
├── services/
│   ├── auth_storage_service.dart # wrapper SharedPreferences utk status login
│   ├── product_api_service.dart  # fetch produk dari DummyJSON
│   └── notification_service.dart # init + schedule local notification
├── providers/
│   ├── auth_provider.dart        # status login, login()/logout(), auto-login check
│   ├── routine_provider.dart     # refactor logic JurnalScreen (AM/PM, add/toggle item)
│   ├── product_provider.dart     # fetch & simpan list produk, loading/error state
│   └── notification_provider.dart # toggle aktif/nonaktif reminder + jam reminder
├── screens/
│   ├── login_screen.dart         # refactor: pakai AuthProvider
│   ├── register_screen.dart      # tidak wajib banyak berubah
│   ├── main_screen.dart          # tidak banyak berubah, hanya wiring
│   ├── home_screen.dart          # tidak banyak berubah
│   ├── belanja_screen.dart       # BARU — list produk dari ProductProvider
│   └── jurnal_screen.dart        # refactor: pakai RoutineProvider + toggle reminder
└── widgets/
    ├── custom_button.dart        # sudah ada
    ├── custom_text_field.dart    # sudah ada
    └── product_card.dart         # BARU — kartu produk utk Belanja
```

---

## 3. Detail Implementasi per Item Wajib

### A. Software Architecture (MVC ringan)
- `models/` = data class murni (tidak ada logic UI atau network).
- `services/` = akses eksternal murni (HTTP call, SharedPreferences, notification API) — tidak boleh import widget Flutter UI.
- `providers/` = penghubung service ↔ UI, extends `ChangeNotifier`, memanggil `notifyListeners()` saat state berubah.
- `screens/` & `widgets/` = presentation layer, hanya `context.watch<...>()` / `context.read<...>()` ke provider, tidak ada logic bisnis langsung di dalamnya.
- Pastikan `JurnalScreen` yang sekarang berisi `List<RoutineItem>` hardcoded dan logic toggle langsung di `State`, dipindah semuanya ke `RoutineProvider`. Widget hanya menampilkan data dari provider.

### B. State Management (Provider)
Di `main.dart`, bungkus `MaterialApp` dengan `MultiProvider`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()..checkAutoLogin()),
    ChangeNotifierProvider(create: (_) => RoutineProvider()),
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ],
  child: const MyApp(),
)
```
- `AuthProvider` harus expose: `bool isLoggedIn`, `bool isLoading`, `Future<void> login(String email, String password)`, `Future<void> logout()`, `Future<void> checkAutoLogin()`.
- Routing: setelah `checkAutoLogin()` selesai, jika `isLoggedIn == true` arahkan ke `/main`, kalau tidak ke `/login`. Bisa pakai `Consumer<AuthProvider>` di root widget atau splash sederhana sambil loading.

### C. API Integration (tab Belanja)
- `ProductApiService.fetchSkincareProducts()` → GET `https://dummyjson.com/products/category/skincare`, parse field `products` (list) jadi `List<Product>`.
- `Product` model minimal: `id, title, description, price, thumbnail, category, rating`.
- `ProductProvider`: state `List<Product> products`, `bool isLoading`, `String? errorMessage`, method `fetchProducts()`.
- `BelanjaScreen`: saat pertama kali dibuka panggil `context.read<ProductProvider>().fetchProducts()` (di `initState`), tampilkan:
  - loading indicator saat `isLoading == true`
  - pesan error + tombol retry kalau `errorMessage != null`
  - `GridView` atau `ListView` kartu produk (`product_card.dart`) berisi thumbnail, nama, harga (format ke Rupiah opsional, atau tampilkan USD asli — sebutkan sumber data di README)
- Ganti placeholder Belanja di `main_screen.dart` dengan `BelanjaScreen()`.

### D. Local Storage (SharedPreferences)
- `AuthStorageService` dengan method: `Future<void> saveLoginStatus(bool value)`, `Future<bool> getLoginStatus()`, `Future<void> clear()`.
- Dipanggil dari `AuthProvider.login()` (simpan `true` setelah validasi sukses) dan `AuthProvider.logout()` (clear/set `false`).
- `LoginScreen`: submit form → panggil `context.read<AuthProvider>().login(email, password)` → kalau sukses, `Navigator.pushReplacementNamed(context, '/main')`.
- Validasi login boleh sederhana (cek email & password tidak kosong / format email valid) karena tidak ada backend auth sungguhan — fokus rubrik adalah penyimpanan status login, bukan sistem auth production.

### E. Mobile Feature (Local Notification)
- `NotificationService`:
  - `init()` — inisialisasi plugin + timezone (`tz.initializeTimeZones()`), minta permission notifikasi (Android 13+/iOS).
  - `scheduleDailyReminder({required int id, required String title, required String body, required TimeOfDay time})` — jadwalkan notifikasi harian berulang jam tertentu (pakai `zonedSchedule` + `DateTimeComponents.time` supaya repeat harian).
  - `cancelReminder(int id)`.
- `NotificationProvider`: state `bool amReminderOn`, `bool pmReminderOn`, method `toggleAmReminder(bool value)` dan `toggleForPmReminder(bool value)` yang memanggil `NotificationService` dan menyimpan preferensi toggle-nya juga ke SharedPreferences (biar tetap tersimpan setelah app ditutup).
- Default waktu: AM reminder jam 07:00, PM reminder jam 21:00 (boleh dibuat bisa diubah user lewat time picker sederhana, ini nilai tambah tapi tidak wajib).
- Tambahkan 2 switch/toggle di `JurnalScreen` (bagian atas, dekat tab AM/PM): "Pengingat rutinitas AM" dan "Pengingat rutinitas PM", terhubung ke `NotificationProvider`.
- Panggil `NotificationService.init()` sekali di `main()` sebelum `runApp()`.

---

## 4. Urutan Pengerjaan yang Disarankan

1. Tambahkan dependencies di `pubspec.yaml`, jalankan `flutter pub get`.
2. Buat folder `models/`, `services/`, `providers/`. Pindahkan `RoutineItem` ke `models/routine_item.dart`.
3. Implementasikan `AuthStorageService` + `AuthProvider`, wiring ke `LoginScreen` dan `main.dart` (auto-login).
4. Implementasikan `RoutineProvider` dari isi `JurnalScreen` yang sudah ada, refactor `JurnalScreen` supaya konsumsi provider (pastikan checklist AM/PM & tambah rutinitas tetap berfungsi sama seperti sebelumnya).
5. Implementasikan `ProductApiService` + `Product` model + `ProductProvider` + `BelanjaScreen` + `ProductCard`. Test fetch data dari API beneran.
6. Implementasikan `NotificationService` + `NotificationProvider`, tambahkan toggle di `JurnalScreen`, test notifikasi muncul (boleh test dengan delay singkat dulu misal 10 detik sebelum ganti ke jadwal harian beneran).
7. Rapikan `main_screen.dart` supaya `BelanjaScreen` menggantikan placeholder.
8. Jalankan `flutter analyze` dan pastikan tidak ada error. Test manual seluruh flow: login → auto-login setelah restart app → lihat produk di Belanja → centang rutinitas di Jurnal → aktifkan reminder.
9. Tulis README (lihat bagian 5).
10. Ambil screenshot tiap halaman utama (Login, Home, Belanja, Jurnal + notifikasi jika bisa di-capture).
11. Commit & push ke GitHub repo yang sama (`Sisilfr/Le-Soie` atau repo baru khusus UAS, sesuaikan).

---

## 5. Checklist README.md (WAJIB, jangan lupa)

README harus memuat:
- [ ] Deskripsi singkat aplikasi (boleh reuse dari README UTS, update bagian fitur)
- [ ] Daftar fitur utama termasuk yang baru (Belanja + API, reminder notifikasi)
- [ ] **Link desain Figma yang bisa diakses publik** — ini item penilaian tersendiri (poin 7 rubrik), pastikan link Figma di-set share "Anyone with the link can view" sebelum ditaruh di README.
- [ ] Penjelasan singkat arsitektur (folder `models/services/providers/screens`)
- [ ] Penjelasan state management yang dipakai (Provider) + gimana cara kerjanya secara singkat
- [ ] Penjelasan sumber API (`dummyjson.com`) dan endpoint yang dipakai
- [ ] Penjelasan local storage (SharedPreferences → status login)
- [ ] Penjelasan mobile feature (local notification reminder AM/PM)
- [ ] Screenshot implementasi (taruh di `docs/screenshots/` seperti README UTS sebelumnya, atau lampirkan sebagai file terpisah)
- [ ] Instruksi cara run project (`flutter pub get` → `flutter run`)

---

## 6. Hal yang Perlu Dicek Ulang Sebelum Submit

- Deadline: Minggu, 12 Juli 2026, 23.59 WIB — commit terakhir harus sebelum jam ini.
- Tautan repo GitHub yang dikumpulkan harus publik atau minimal bisa diakses dosen.
- Semua 6 poin wajib (UI/UX konsisten, Arsitektur, API, State Management, Local Storage, Mobile Feature) harus benar-benar jalan saat di-run, bukan cuma ada kodenya.
- Kalau mau ikut sesi presentasi (opsional, ada nilai tambahan), siapkan penjelasan singkat untuk 8 poin yang diminta di soal (overview app, user flow, UI/UX, architecture, state management, API integration, local storage, camera/notification).
