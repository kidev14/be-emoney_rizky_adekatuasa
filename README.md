# dompet_kampus_global

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 💸 BE-Emoney AMAN (Aset Masa Depan) (Frontend)
Tugas Ujian Akhir Semester (UAS) Mobile Application


Aplikasi Frontend BE-EMONEY komprehensif untuk pembayaran, transfer saldo, top-up, dan integrasi merchant.

Rizky Adekatuasa • 1123150137

## DESKRIPSI
**DompetKita **merupakan aplikasi E-Money berbasis Flutter yang dikembangkan sebagai proyek Ujian Akhir Semester (UAS) Mata Kuliah Aplikasi Mobile Lanjutan.

Aplikasi ini dirancang sebagai digital wallet yang dapat digunakan untuk melakukan pembayaran pada aplikasi E-Commerce melalui mekanisme App-to-App Integration menggunakan Deep Link.

Selain sebagai dompet digital, aplikasi ini juga mengimplementasikan berbagai teknologi modern seperti:

Firebase Authentication
Firebase Cloud Messaging (FCM)
JWT Authentication
REST API
Deep Link
Two-Factor Authentication (OTP)
Secure Storage

## Alur Integrasi Marketplace dan E-Wallet Menggunakan Deep Link

Project ini terdiri dari dua aplikasi yang saling terintegrasi, yaitu aplikasi Marketplace dan aplikasi E-Wallet Dompet Kampus. Marketplace digunakan untuk membuat pesanan, sedangkan E-Wallet digunakan sebagai metode pembayaran. Integrasi antara kedua aplikasi dilakukan menggunakan Deep Link.

Deep link adalah link khusus yang dapat membuka aplikasi e-wallet secara langsung dari aplikasi marketplace sambil membawa data transaksi seperti order_id, amount, dan callback_url.

## ALUR KERJA SISTEM

1. User Melakukan Checkout di Marketplace
User memilih produk pada aplikasi marketplace, kemudian masuk ke halaman checkout. Setelah itu marketplace membuat data pesanan dengan status awal belum dibayar.

Contoh data pesanan:

Order ID : ORD123
Total    : Rp50.000
Status   : pending
Setelah user memilih metode pembayaran menggunakan E-Wallet Dompet Kampus, marketplace membuat deep link pembayaran.

Contoh:

myewallet://pay?order_id=ORD123&amount=50000&callback_url=https://marketplace.com/callback
Deep link tersebut kemudian dibuka agar aplikasi e-wallet dapat menerima data pembayaran.

2. Aplikasi E-Wallet Terbuka Melalui Deep Link
Pada aplikasi e-wallet, deep link ditangani oleh DeepLinkWrapper. Sistem akan membaca link yang masuk dan memastikan formatnya sesuai.

Format yang valid:

scheme : myewallet
host   : pay
Jika deep link valid, aplikasi mengambil data:

order_id
amount
callback_url
Data tersebut kemudian disimpan sebagai payload pembayaran.

3. E-Wallet Mengecek Status Login User
Setelah deep link diterima, aplikasi e-wallet mengecek apakah user sudah login dan sudah terverifikasi.

Pengecekan dilakukan menggunakan token login dan status autentikasi.

Jika user sudah login, aplikasi langsung mengarahkan user ke halaman merchant checkout.

Jika user belum login, data deep link disimpan sementara agar tidak hilang. Setelah user berhasil login, pembayaran dapat dilanjutkan menggunakan data deep link tersebut.

4. User Masuk ke Halaman Merchant Checkout
User diarahkan ke halaman merchant checkout untuk melihat detail pembayaran.

Data yang ditampilkan antara lain:

Order ID : ORD123
Nominal  : Rp50.000
Pada halaman ini user dapat mengecek detail pembayaran sebelum melanjutkan proses transaksi.

5. User Melakukan Konfirmasi Pembayaran
Setelah user menekan tombol bayar, aplikasi akan meminta user memasukkan PIN atau OTP sebagai validasi keamanan transaksi.

Tujuannya adalah memastikan bahwa transaksi benar-benar dilakukan oleh pemilik akun.

6. E-Wallet Mengirim Request Pembayaran ke Backend
Setelah PIN atau OTP dimasukkan, aplikasi e-wallet mengirim request pembayaran ke backend.

Alur request pada Flutter:

PaymentBloc
→ PaymentRepositoryImpl
→ PaymentRemoteDatasourceImpl
→ ApiClient
→ proses_bayar.php
Data yang dikirim ke backend:

{
  "order_id": "ORD123",
  "amount": 50000,
  "pin": "123456",
  "otp_type": "pin"
}
7. Backend Memvalidasi Token User
Backend e-wallet akan memvalidasi token user menggunakan helper validate_token.

Token dikirim melalui header:

Authorization: Bearer TOKEN_USER
Jika token valid, backend akan mendapatkan user_id dari user yang sedang login.

Jika token tidak valid atau tidak tersedia, backend akan mengembalikan response unauthorized.

8. Backend Mengecek Saldo User
Setelah token valid, backend mengambil saldo user dari database.

Query menggunakan FOR UPDATE agar data saldo terkunci sementara selama transaksi berlangsung. Hal ini bertujuan untuk mencegah konflik jika ada beberapa transaksi yang berjalan bersamaan.

SELECT id, saldo FROM users WHERE id = ? FOR UPDATE
9. Backend Mengecek Status Order
Backend juga mengecek apakah order tersebut sudah pernah dibayar sebelumnya.

Jika order_id sudah memiliki transaksi dengan status success, maka pembayaran akan ditolak agar tidak terjadi pembayaran ganda.

10. Jika Saldo Tidak Mencukupi
Jika saldo user kurang dari nominal pembayaran, backend akan mencatat transaksi dengan status failed.

Contoh status transaksi:

Status     : failed
Keterangan : Saldo tidak mencukupi
Kemudian backend mengirim response gagal ke aplikasi e-wallet.

11. Jika Saldo Mencukupi
Jika saldo mencukupi, backend akan mengurangi saldo user.

Contoh:

Saldo awal : Rp100.000
Pembayaran : Rp50.000
Saldo akhir: Rp50.000
Setelah itu backend mencatat transaksi dengan status success.

Contoh data transaksi:

Order ID   : ORD123
Tipe       : payment
Nominal    : Rp50.000
Status     : success
Keterangan : Pembayaran dari Marketplace
Backend kemudian mengirim response sukses ke aplikasi e-wallet.

Contoh response:

{
  "success": true,
  "message": "Pembayaran berhasil",
  "data": {
    "order_id": "ORD123",
    "sisa_saldo": 50000
  }
}
12. E-Wallet Menampilkan Halaman Sukses
Setelah backend mengirim response sukses, aplikasi e-wallet menampilkan halaman pembayaran berhasil.

Informasi yang ditampilkan dapat berupa:

Pembayaran Berhasil
Order ID    : ORD123
Nominal     : Rp50.000
Sisa Saldo  : Rp50.000
13. Marketplace Menerima Status Pembayaran
Setelah pembayaran berhasil, marketplace dapat menerima status pembayaran melalui callback_url.

Data callback dapat berisi:

{
  "order_id": "ORD123",
  "status": "success",
  "amount": 50000
}
Setelah menerima callback, marketplace mengubah status pesanan menjadi sudah dibayar.

Contoh perubahan status:

pending → paid

## prototype
1.login pasar malam
![alt text](<assets/images/Screenshot 2026-07-03 135516.png>)
2.register pasar malam
![alt text](<assets/images/Screenshot 2026-07-03 135720.png>)
3.home pasar malam
![alt text](<assets/images/Screenshot 2026-07-03 140017.png>)
![alt text](<assets/images/Screenshot 2026-07-03 140053.png>)
4.top up pasar malam
![alt text](<assets/images/Screenshot 2026-07-03 140130.png>)
![alt text](<assets/images/Screenshot 2026-07-03 140147.png>)
5.cekout pasar malam
![alt text](<assets/images/Screenshot 2026-07-03 140147.png>)
![alt text](<assets/images/Screenshot 2026-07-03 140206.png>)
![alt text](<assets/images/Screenshot 2026-07-03 140313.png>)

## prototype dompet kampus global
1.login AMAN 
![alt text](<assets/images/Screenshot 2026-07-03 140541.png>)
2.register AMAN 
![alt text](<assets/images/Screenshot 2026-07-03 140558.png>)
![alt text](<assets/images/Screenshot 2026-07-03 140638.png>)
3.home AMAN 
![alt text](<assets/images/Screenshot 2026-07-03 140928.png>)
4.top up AMAN 
![alt text](<assets/images/Screenshot 2026-07-03 140946.png>)
![alt text](<assets/images/Screenshot 2026-07-03 140958.png>)
![alt text](<assets/images/Screenshot 2026-07-03 141012.png>)
5.akun AMAN
![alt text](<assets/images/Screenshot 2026-07-03 141024.png>)





