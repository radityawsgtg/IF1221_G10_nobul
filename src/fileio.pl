saveGame :-
    write('Masukkan nama file penyimpanan (contoh: \'permainan1.txt\'.): '),
    read(FileName),
    open(FileName, write, Stream),
    urutan_pemain(Urutan),
    write(Stream, 'urutan_pemain: '), write(Stream, Urutan), nl(Stream),
    giliran_sekarang(Giliran),
    write(Stream, 'giliran: '), write(Stream, Giliran), nl(Stream),
    discard_top(Top),
    write(Stream, 'discard_top: '), cetak_format_kartu_file(Stream, Top), nl(Stream),
    
    cetak_semua_kartu_pemain_file(Stream, Urutan),
    
    arah_permainan(Arah),
    write(Stream, 'arah_permainan: '), write(Stream, Arah), nl(Stream),
    (warna_aktif(Warna) -> write(Stream, 'warna_aktif: '), write(Stream, Warna), nl(Stream); 
        true 
    ),
    findall(P, status_uni(P), ListUNI),
    write(Stream, 'status_UNI: '), write(Stream, ListUNI), nl(Stream),
    close(Stream),
    write('Status permainan berhasil disimpan ke '), write(FileName), nl.

cetak_format_kartu_file(Stream, kartu(W, J)) :-
    write(Stream, W), write(Stream, '-'), write(Stream, J).
    
cetak_list_kartu_file(Stream, []) :- 
    write(Stream, '[]').
cetak_list_kartu_file(Stream, [H|T]) :-
    write(Stream, '['),
    cetak_format_kartu_file(Stream, H),
    cetak_list_kartu_file_tail(Stream, T).

cetak_list_kartu_file_tail(Stream, []) :- 
    write(Stream, ']').
cetak_list_kartu_file_tail(Stream, [H|T]) :-
    write(Stream, ', '),
    cetak_format_kartu_file(Stream, H),
    cetak_list_kartu_file_tail(Stream, T).

cetak_semua_kartu_pemain_file(_, []).
cetak_semua_kartu_pemain_file(Stream, [Pemain|T]) :-
    write(Stream, 'kartu_'), write(Stream, Pemain), write(Stream, ': '),
    kartu_tangan(Pemain, ListKartu),
    cetak_list_kartu_file(Stream, ListKartu), nl(Stream),
    cetak_semua_kartu_pemain_file(Stream, T).