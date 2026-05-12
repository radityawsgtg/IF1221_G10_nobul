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
    NextIndex is Index+1,
    cetak_kartu_berurut(T, NextIndex).

cekInfo :-
    discard_top(Top),
    urutan_pemain(Urutan),
    write('Kartu discard top: '), write(Top), nl,
    write('Urutan pemain: '), cetak_urutan(Urutan), nl, nl,
    cetak_info_pemain(Urutan, 1),
    write('yes'), nl.

cetak_urutan([H]) :- write(H).
cetak_urutan([H|T]) :- write(H), write(' - '), cetak_urutan(T).

cetak_info_pemain([], _).
cetak_info_pemain([Pemain|T], Index) :-
    kartu_tangan(Pemain, ListKartu),
    length(ListKartu, Jumlah),
    write('Nama pemain '), write(Index), write(': '), write(Pemain), nl,
    write('Jumlah kartu: '), write(Jumlah), nl, nl,
    NextIndex is Index+1,
    cetak_info_pemain(T, NextIndex).