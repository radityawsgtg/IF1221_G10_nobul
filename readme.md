# UNI - IF1221 Logika Komputasional (Kelompok 10 - nobul)

UNI adalah permainan kartu simulasi berbasis logika deklaratif yang ditulis menggunakan **GNU Prolog**. Proyek ini dikembangkan sebagai Tugas Besar Praktikum IF1221 Logika Komputasional Institut Teknologi Bandung. 

Permainan ini mengadaptasi aturan dasar permainan kartu warna-angka populer, namun disesuaikan dengan aturan "khas keluarga" yang mencakup hukuman deklarasi kartu terakhir, sistem tantangan, hingga mode turnamen kooperatif dan keajaiban acak di dalam arena.

## Anggota Kelompok 10 (K1)
* **13525011** - Raihan
* **13525019** - Raditya Wibian Sastaka
* **13525023** - Shaquille Nathan Kalevi
* **13525075** - Bagas Anugrah Putra

## Fitur Utama

### Aksi Utama
* `mainkanKartu(NomorUrut).` - Memainkan kartu yang sesuai dengan warna atau angka pada kartu teratas di tumpukan pembuangan.
* `ambilKartu.` - Mengambil kartu acak dari dek jika tidak ada kartu yang bisa dimainkan atau saat terkena penalti.
* `uni(NomorUrut).` - Memainkan kartu kedua terakhir sekaligus menyerukan deklarasi sisa satu kartu.
* `tangkap('NamaPemain').` - Menghukum pemain lawan yang lupa mendeklarasikan status UNI.
* `tantang.` - Menggugat pemain sebelumnya yang memainkan kartu *Wild Draw Four* secara ilegal.

### Aksi Pendukung
* `lihatCommand.` - Menampilkan daftar perintah yang dapat diakses pemain.
* `lihatKartu.` - Menampilkan seluruh kartu di tangan beserta nomor urutnya.
* `cekInfo.` - Melihat status arena, giliran, warna aktif, kartu teratas, dan jumlah kartu semua pemain.

### Penyimpanan
* `saveGame.` - Menyimpan status dan memori permainan (state) ke dalam file teks eksternal.
* `loadGame.` - Memuat ulang progres permainan dari file teks yang telah disimpan menggunakan *custom parser*.

### Fitur Bonus Terimplementasi
* **Mode Turnamen:** Sistem 2 vs 2 dengan penambahan perintah `swapKartu(NomorUrutku, NomorUrutTeman).` untuk menukar kartu dengan rekan satu tim.
* **God's Hand:** Keajaiban kosmik (probabilitas 15%) di awal giliran yang memindahkan satu kartu acak dari satu pemain ke pemain lain.
* **Mimic Card:** Kartu aksi spesial berwarna hitam yang menyalin dan mengeksekusi efek dari kartu aksi terakhir yang dimainkan.
* **Kartu Tersembunyi:** Fitur `sembunyikanKartu(NomorUrut).` dan `tampilkanKartu.` untuk menyembunyikan eksistensi kartu dari perintah pelacakan lawan.

## Struktur Repository
* `src/` - Memuat seluruh basis kode sumber Prolog (`main.pl`, `setup.pl`, `aksi.pl`, `fungsi.pl`, `fileio.pl`, `state.pl`, `perintah.pl`).
* `docs/` - Memuat berkas laporan dan dokumen pendukung proyek (`Laporan_G10.pdf`, `Milestone1_G10.pdf`, `Milestone2_G10.pdf`).

## Cara Menjalankan Program
Pastikan **GNU Prolog** telah terinstal di dalam sistem operasi Anda.

1. Buka terminal atau *command prompt*, lalu navigasikan ke direktori repositori proyek ini.
2. Jalankan GNU Prolog dengan mengetik perintah:
   ```bash
   gprolog
   ```
3. Lakukan kompilasi dan muat file utama permainan:
   ```prolog
   ['src/main.pl'].
   ```
4. Untuk memulai permainan baru, jalankan perintah:
   ```prolog
   startGame.
   ```
5. Untuk melanjutkan permainan yang telah disimpan sebelumnya, jalankan perintah:
   ```prolog
   loadGame.
   ```