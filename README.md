# Live Notes

## Deskripsi singkat
- Aplikasi Flutter sederhana untuk membuat, mengedit, dan menghapus catatan yang tersinkronisasi secara real-time menggunakan Firebase Cloud Firestore.
- Fitur utama: tambah catatan, edit (update) catatan, hapus, dan sinkronisasi realtime antar perangkat lewat StreamBuilder.

## Fitur
- Tambah catatan dengan judul dan isi.
- Edit catatan: ketuk ListTile untuk membuka form yang sudah terisi data lama lalu simpan perubahan menggunakan `.update()`.
- Hapus catatan.
- Real-time sync: perubahan langsung muncul di semua device yang terhubung.

## Struktur proyek (relevan)
- lib/main.dart — Inisialisasi Firebase dan entry point.
- lib/homepage.dart — UI utama, StreamBuilder, form tambah/edit, operasi Firestore.
- lib/firebase_options.dart — File konfigurasi Firebase yang di-generate oleh `flutterfire configure`.

## Persiapan & Instalasi
1. Pastikan Flutter dan Dart sudah terpasang:
   - flutter --version
2. Pasang Firebase CLI untuk Flutter:
   - flutter pub global activate flutterfire_cli
   - (atau) dart pub global activate flutterfire_cli
3. Tambahkan Pub Cache ke PATH (PowerShell):
   - $env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
   - setx PATH "$env:Path;$env:USERPROFILE\AppData\Local\Pub\Cache\bin"  (opsional permanen)
4. Konfigurasi Firebase untuk project:
   - Buka terminal di folder project (d:\Mobile Dev\livenotes)
   - jalankan: flutterfire configure
   - File `firebase_options.dart` akan dihasilkan dan digunakan di main.dart

## Menjalankan aplikasi
- flutter pub get
- flutter run

## Penjelasan fitur Edit (Update)
- Pada homepage, setiap ListTile mewakili dokumen Firestore.
- Ketuk ListTile memanggil _showForm(context, document) yang:
  - Mengisi TextEditingController dengan nilai lama (title, content).
  - Menampilkan bottom sheet berisi form.
  - Saat disimpan, memanggil `_notes.doc(document.id).update({...})` untuk memperbarui dokumen di Firestore.
- StreamBuilder yang mendengarkan `collection('notes').orderBy('timestamp', descending: true).snapshots()` akan mengupdate UI otomatis setelah perubahan.

## Testing sinkronisasi realtime (2 device)
1. Jalankan aplikasi di dua emulator / satu emulator + perangkat fisik.
2. Buat catatan di Device A → seharusnya muncul segera di Device B.
3. Ketuk catatan di Device B → ubah konten lalu simpan → perubahan muncul segera di Device A.

## Troubleshooting 
- Error "flutterfire : The term 'flutterfire' is not recognized":
  - Pastikan `flutterfire_cli` terinstall dan Pub Cache bin ada di PATH (lihat langkah instalasi).
- Error orderBy('timestamp') jika beberapa dokumen tanpa field timestamp:
  - Pastikan setiap dokumen memiliki field `timestamp` atau hilangkan `orderBy` saat debugging.
- Jika Firebase initialize error: periksa `firebase_options.dart` dan pastikan package name / bundle id cocok dengan konfigurasi di Firebase Console.

## Dependencies utama
- flutter
- firebase_core
- cloud_firestore
- flutterfire_cli (pengaturan)

## Lisensi
- Sesuaikan lisensi proyek sesuai kebutuhan (mis. MIT).

## Catatan
- Pastikan aturan Firestore (security rules) mengizinkan akses yang diperlukan selama development.

## CApture Hasil

![g2](https://github.com/user-attachments/assets/97df735b-5a66-47d6-9133-b0fc0dc00bfb)
![g1](https://github.com/user-attachments/assets/fc7ead54-5f9a-47ed-b27a-92937f8e9c62)
![g3](https://github.com/user-attachments/assets/15e816cb-7f7e-4988-91fa-9f3da0225c36)

dari hasil tersebut saya melakukan edit, tambah dalam 2 hp secara realtime dan masuk ke firebase secara langsung
