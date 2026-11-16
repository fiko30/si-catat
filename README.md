# Si Catat - Aplikasi Pengelolaan Uang

Aplikasi manajemen dan pencatatan keuangan pribadi berbasis Flutter dengan backend Google Apps Script (GAS) dan Google Sheets sebagai database.

---

## 🚀 Fitur Utama
- **Autentikasi Pengguna**: Registrasi, Login, dan Fitur Pemulihan Password via Email.
- **Pencatatan Transaksi**: Catat pemasukan dan pengeluaran beserta kategori, jumlah, dan deskripsi.
- **Riwayat & Filter**: Riwayat transaksi lengkap dengan filter berdasarkan tipe dan tanggal.
- **Dashboard Ringkasan**: Visualisasi total pemasukan, pengeluaran, dan saldo bersih.
- **Serverless Backend**: Menggunakan Google Apps Script terhubung langsung ke Google Sheets.

---

## 🛠️ Tech Stack
- **Frontend**: Flutter (Dart)
- **State Management & Architecture**: Provider & MVC/Service Pattern
- **Storage**: SharedPreferences (local cache)
- **Backend API**: Google Apps Script (Web App)
- **Database**: Google Sheets

---

## ⚙️ Panduan Setup Backend (Google Apps Script)

1. Buat Spreadsheet baru di Google Sheets.
2. Buka menu **Extensions > Apps Script**.
3. Salin seluruh kode dari file `backend_gas/Code.gs` ke editor Apps Script.
4. Jalankan fungsi `setupDatabase()` sekali untuk membuat header tabel `Users` dan `Transactions` otomatis.
5. Jalankan fungsi `aktivasiIzinEmail()` sekali untuk memberikan izin pengiriman email pemulihan password.
6. Klik **Deploy > New deployment**:
   - Pilih jenis: **Web app**
   - Execute as: **Me**
   - Who has access: **Anyone**
7. Salin **Web app URL** yang dihasilkan.
8. Masukkan URL tersebut ke `lib/services/storage_service.dart` pada variabel `defaultGasUrl`:
   ```dart
   static const String defaultGasUrl = 'URL_WEB_APP_ANDA_DISINI';
   ```

---

## 📱 Cara Menjalankan Aplikasi

1. Clone repositori ini:
   ```bash
   git clone https://github.com/fiko30/si-catat.git
   cd si-catat
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Sesuaikan URL Apps Script di `lib/services/storage_service.dart`.
4. Jalankan aplikasi:
   ```bash
   flutter run
   ```
