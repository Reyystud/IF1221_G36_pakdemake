# Pakde Make - Game UNO Berbasis Prolog

Selamat datang di repository proyek **Pakde Make**, sebuah permainan kartu strategi yang terinspirasi dari UNO, dikembangkan menggunakan bahasa pemrograman Prolog.

## Gambaran Singkat Proyek
**Pakde Make** adalah permainan kartu multiplayer (2-4 pemain) di mana pemain berlomba untuk menghabiskan kartu di tangan mereka. Permainan ini mengimplementasikan logika permainan UNO klasik dengan tambahan beberapa fitur unik seperti *God's Hand*, mekanisme menyembunyikan kartu, serta mode turnamen dengan sistem tim.

## Fitur Utama
- **Dua Mode Permainan:** 
  - **Mode Klasik:** Permainan individual standar.
  - **Mode Turnamen:** Permainan berbasis tim (2 vs 2) dengan fitur tambahan seperti *swap kartu* antar rekan tim.
- **Kartu Spesial:** Mengimplementasikan kartu *Skip*, *Reverse*, *Draw Two*, *Wild Card*, dan *Wild Draw Four*.
- **Fitur Unik:**
  - **Mimic Card:** Kartu yang dapat meniru efek dari kartu aksi sebelumnya.
  - **God's Hand:** Kejadian acak yang dapat mengubah jalannya permainan secara drastis.
  - **Mekanisme Sembunyikan/Tampilkan Kartu:** Pemain dapat menyimpan satu kartu untuk kejutan di akhir.
- **Sistem Tantangan (Challenge):** Menantang pemain yang mengeluarkan *Wild Draw Four* jika diduga memiliki kartu warna lain.
- **Sistem UNI:** Mekanisme menyerukan "UNI" saat sisa 1 kartu dan menangkap lawan yang lupa menyerukannya.
- **Save & Load Game:** Menyimpan status permainan ke dalam file teks dan melanjutkannya kapan saja.

## Struktur Repository
```text
IF1221_G36_pakdemake/
├── docs/                   # Dokumentasi proyek (Laporan & Milestone)
├── src/                    # Source code program utama
│   ├── main.pl             # Entry point dan logika kontrol utama
│   ├── init.pl             # Inisialisasi game, deck, dan pemain
│   ├── gameplay.pl         # Logika permainan dan aksi kartu
│   ├── declarations.pl     # Deklarasi fakta dinamis (state game)
│   ├── commands.pl         # Perintah bantuan dan display informasi
│   └── utils.pl            # Fungsi pembantu (shuffle, list ops, I/O)
├── README.md               # Dokumentasi utama repository
└── .gitignore              # Daftar file yang diabaikan oleh git
```

## Cara Menjalankan Program
1. Clone repository ini atau unduh semua file di folder `src/`.
2. Buka terminal atau *command prompt* di direktori `src/`.
3. Jalankan SWI-Prolog dengan perintah:
   ```bash
   swipl main.pl
   ```
4. Setelah masuk ke *prompt* Prolog, jalankan perintah:
   ```prolog
   startGame.
   ```
5. Ikuti instruksi di layar untuk memilih mode, jumlah pemain, dan nama pemain.
6. Gunakan perintah `lihatCommand.` selama permainan untuk melihat daftar aksi yang tersedia.

## Anggota Kelompok (G36 - Pakde Make)
| Steven Vanako | 13525044 | Membuat fitur-fitur awal seperti declarations dynamic state, startGame, pemain, dan kartu-kartu |
| Muhammad Rafiandhi Suryadinata | 13525006 | Menambah fitur-fitur bonus, seperti God's hands, Mimic card, Hidden cards, dan Tournament mode, dan fitur-fitur lainnya, seperti load game and save game |

---
