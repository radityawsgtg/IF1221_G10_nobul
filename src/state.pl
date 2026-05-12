warna(merah).
warna(kuning).
warna(hijau).
warna(biru).

jenis_angka(X) :- between(0, 9, X).
jenis_aksi(skip).
jenis_aksi(reverse).
jenis_aksi(draw_two).

is_kartu(kartu(Warna, Jenis)) :- 
    warna(Warna), 
    (jenis_angka(Jenis) ; jenis_aksi(Jenis)).

is_kartu(kartu(hitam, wild)).
is_kartu(kartu(hitam, wild_draw_four)).