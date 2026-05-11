lihatCommand :-
    write('Aksi utama yang tersedia:'), nl,
    write('1. mainkanKartu(NomorUrut)'), nl,
    write('2. ambilKartu'), nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.

lihatKartu :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    write('Berikut kartu yang Anda miliki:'), nl,
    cetak_kartu_berurut(ListKartu, 1).

cetak_kartu_berurut([], _).
cetak_kartu_berurut([H|T], Index) :-
    write(Index), write('. '), write(H), nl,
    NextIndex is Index + 1,
    cetak_kartu_berurut(T, NextIndex).

cekInfo :-
    discard_top(Top),
    urutan_pemain(Urutan),
    write('Kartu discard top: '), write(Top), nl,
    write('Urutan pemain: '), write(Urutan), nl,
    % Tambahkan iterasi (loop) untuk mencetak nama pemain beserta jumlah kartunya di sini
    write('Status pemain berhasil ditampilkan.'), nl.