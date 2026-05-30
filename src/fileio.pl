saveGame :-
    write('Masukkan nama file penyimpanan (contoh: \'permainan1.txt\'.): '),
    read(FileName),
    open(FileName, write, Stream),
    ( mode_permainan(turnamen) ->
        write(Stream, 'mode:turnamen.'), nl(Stream),
        findall(P1, tim(P1, 1), [T1A, T1B]),
        findall(P2, tim(P2, 2), [T2A, T2B]),
        write(Stream, 'tim1:[\''), write(Stream, T1A), write(Stream, '\',\''), write(Stream, T1B), write(Stream, '\'].'), nl(Stream),
        write(Stream, 'tim2:[\''), write(Stream, T2A), write(Stream, '\',\''), write(Stream, T2B), write(Stream, '\'].'), nl(Stream)
    ;
        write(Stream, 'mode:klasik.'), nl(Stream)
    ),
    urutan_pemain(Urutan),
    write(Stream, 'urutan_pemain:'), cetak_list_reguler_file(Stream, Urutan), write(Stream, '.'), nl(Stream),
    giliran_sekarang(Giliran),
    write(Stream, 'giliran:\''), write(Stream, Giliran), write(Stream, '\'.'), nl(Stream),
    discard_top(Top),
    write(Stream, 'discard_top:'), cetak_format_kartu_file(Stream, Top), write(Stream, '.'), nl(Stream),
    arah_permainan(Arah),
    write(Stream, 'arah_permainan:'), write(Stream, Arah), write(Stream, '.'), nl(Stream),
    (warna_aktif(Warna) -> write(Stream, 'warna_aktif:'), write(Stream, Warna), write(Stream, '.'), nl(Stream); true),
    cetak_semua_kartu_pemain_file(Stream, Urutan),
    findall(P, status_uni(P), ListUNI),
    write(Stream, 'status_UNI:'), cetak_list_reguler_file(Stream, ListUNI), write(Stream, '.'), nl(Stream),
    
    (kartu_aksi_terakhir(AksiTerakhir) ->
        write(Stream, 'kartu_aksi_terakhir:'), write(Stream, AksiTerakhir), write(Stream, '.'), nl(Stream)
    ;
        write(Stream, 'kartu_aksi_terakhir:none.'), nl(Stream)
    ),
    findall(kartu_tersembunyi(P,K), kartu_tersembunyi(P,K), ListSembunyi),
    write(Stream, 'kartu_tersembunyi:'), cetak_list_sembunyi_file(Stream, ListSembunyi), write(Stream, '.'), nl(Stream),
    
    close(Stream),
    write('Status permainan berhasil disimpan ke '), write(FileName), nl.

cetak_list_reguler_file(Stream, []) :- write(Stream, '[]').
cetak_list_reguler_file(Stream, [H|T]) :-
    write(Stream, '[\''), write(Stream, H), write(Stream, '\''),
    cetak_list_reguler_tail(Stream, T).
cetak_list_reguler_tail(Stream, []) :- write(Stream, ']').
cetak_list_reguler_tail(Stream, [H|T]) :-
    write(Stream, ',\''), write(Stream, H), write(Stream, '\''),
    cetak_list_reguler_tail(Stream, T).

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
    write(Stream, ','),
    cetak_format_kartu_file(Stream, H),
    cetak_list_kartu_file_tail(Stream, T).

cetak_list_sembunyi_file(Stream, []) :- write(Stream, '[]').
cetak_list_sembunyi_file(Stream, [H|T]) :-
    write(Stream, '['),
    cetak_format_sembunyi(Stream, H),
    cetak_list_sembunyi_tail(Stream, T).

cetak_list_sembunyi_tail(Stream, []) :- write(Stream, ']').
cetak_list_sembunyi_tail(Stream, [H|T]) :-
    write(Stream, ','),
    cetak_format_sembunyi(Stream, H),
    cetak_list_sembunyi_tail(Stream, T).

cetak_format_sembunyi(Stream, kartu_tersembunyi(P, K)) :-
    write(Stream, 'kartu_tersembunyi(\''), write(Stream, P), write(Stream, '\','), write(Stream, K), write(Stream, ')').

cetak_semua_kartu_pemain_file(_, []).
cetak_semua_kartu_pemain_file(Stream, [Pemain|T]) :-
    write(Stream, 'kartu(\''), write(Stream, Pemain), write(Stream, '\'):'),
    kartu_tangan(Pemain, ListKartu),
    cetak_list_kartu_file(Stream, ListKartu), write(Stream, '.'), nl(Stream),
    cetak_semua_kartu_pemain_file(Stream, T).

loadGame :-
    write('Masukkan nama file penyimpanan (contoh: \'permainan1.txt\'.): '),
    read(FileName),
    (file_exists(FileName) ->
        open(FileName, read, Stream),
        retractall(urutan_pemain(_)),
        retractall(giliran_sekarang(_)),
        retractall(discard_top(_)),
        retractall(kartu_tangan(_, _)),
        retractall(arah_permainan(_)),
        retractall(warna_aktif(_)),
        retractall(status_uni(_)),
        retractall(mode_permainan(_)),
        retractall(tim(_, _)),
        retractall(sudah_swap(_)),
        retractall(kartu_aksi_terakhir(_)),
        retractall(kartu_tersembunyi(_, _)),
        baca_baris_chars(Stream),
        close(Stream),
        write('Status permainan berhasil dimuat!'), nl,
        (giliran_sekarang(Giliran) ->
            write('Sekarang adalah giliran: '), write(Giliran), nl
        ;
            true
        )
    ;
        write('Error: File tidak ditemukan! Pastikan nama file dan ekstensinya benar.'), nl
    ).

baca_baris_chars(Stream) :-
    at_end_of_stream(Stream), !.
baca_baris_chars(Stream) :-
    read_line_chars(Stream, Chars),
    (Chars \= [] -> parse_line_chars(Chars) ; true),
    baca_baris_chars(Stream).

read_line_chars(Stream, Chars) :-
    get_char(Stream, C),
    read_line_chars_helper(Stream, C, Chars).
read_line_chars_helper(_, end_of_file, []) :- !.
read_line_chars_helper(_, '\n', []) :- !.
read_line_chars_helper(Stream, '\r', Chars) :-
    !, get_char(Stream, NextC), read_line_chars_helper(Stream, NextC, Chars).
read_line_chars_helper(Stream, Char, [Char|Rest]) :-
    get_char(Stream, NextC),
    read_line_chars_helper(Stream, NextC, Rest).

parse_line_chars(Chars) :-
    split_key_value(Chars, KeyChars, ValueCharsRaw),
    trim_space(ValueCharsRaw, ValueCharsTrimmed),
    append_list(ValueCharsTrimmed, ['.'], ValueCharsFinal),
    atom_chars(Key, KeyChars),
    read_term_from_chars(ValueCharsFinal, Term, [variable_names(Vars)]),
    bind_vars(Vars),
    parse_key_value(Key, Term).

bind_vars([]).
bind_vars([_=Var|T]) :-
    bind_vars(T).
    
split_key_value([], [], []).
split_key_value([':'|T], [], T) :- !.
split_key_value([H|T], [H|KeyRest], Value) :-
    split_key_value(T, KeyRest, Value).

trim_space([], []).
trim_space([' '|T], T) :- !.
trim_space(T, T).

parse_key_value(mode, Mode) :- asserta(mode_permainan(Mode)).
parse_key_value(tim1, [A, B]) :- asserta(tim(A, 1)), asserta(tim(B, 1)).
parse_key_value(tim2, [A, B]) :- asserta(tim(A, 2)), asserta(tim(B, 2)).
parse_key_value(urutan_pemain, Urutan) :- asserta(urutan_pemain(Urutan)).
parse_key_value(giliran, Giliran) :- asserta(giliran_sekarang(Giliran)).
parse_key_value(discard_top, Warna - Jenis) :- asserta(discard_top(kartu(Warna, Jenis))).
parse_key_value(arah_permainan, Arah) :- asserta(arah_permainan(Arah)).
parse_key_value(warna_aktif, Warna) :- asserta(warna_aktif(Warna)).
parse_key_value(status_UNI, ListUNI) :- assert_status_uni(ListUNI).

parse_key_value(kartu_aksi_terakhir, none) :- !.
parse_key_value(kartu_aksi_terakhir, Aksi) :- asserta(kartu_aksi_terakhir(Aksi)).

parse_key_value(kartu_tersembunyi, ListSembunyi) :- assert_tersembunyi(ListSembunyi).

parse_key_value(Key, ListKartuMinus) :-
    atom_chars(Key, Chars),
    Chars = ['k','a','r','t','u','(','\'' | Rest],
    ekstrak_nama_pemain_file(Rest, PemChars),
    atom_chars(Pemain, PemChars),
    ubah_format_kartu(ListKartuMinus, ListKartuProlog),
    asserta(kartu_tangan(Pemain, ListKartuProlog)).

ekstrak_nama_pemain_file(['\'',')'], []) :- !.
ekstrak_nama_pemain_file([H|T], [H|R]) :- ekstrak_nama_pemain_file(T, R).

ubah_format_kartu([], []).
ubah_format_kartu([Warna - Jenis | T], [kartu(Warna, Jenis) | TRes]) :-
    ubah_format_kartu(T, TRes).

assert_status_uni([]).
assert_status_uni([H|T]) :-
    asserta(status_uni(H)),
    assert_status_uni(T).

assert_tersembunyi([]).
assert_tersembunyi([kartu_tersembunyi(P, K)|T]) :-
    asserta(kartu_tersembunyi(P, K)),
    assert_tersembunyi(T).