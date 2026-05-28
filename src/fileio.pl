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

loadGame :-
    write('Masukkan nama file penyimpanan (contoh: \'permainan1.txt\'.): '),
    read(FileName),
    (file_exists(FileName) ->
        open(FileName, read, Stream),
        
        % Menghapus semua state lama sebelum menimpa yang baru
        retractall(urutan_pemain(_)),
        retractall(giliran_sekarang(_)),
        retractall(discard_top(_)),
        retractall(kartu_tangan(_, _)),
        retractall(arah_permainan(_)),
        retractall(warna_aktif(_)),
        retractall(status_uni(_)),
        
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

% Membaca baris secara karakter per karakter
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
read_line_chars_helper(Stream, '\r', Chars) :- % Handle Carriage Return (Windows/Mac)
    !, get_char(Stream, NextC), read_line_chars_helper(Stream, NextC, Chars).
read_line_chars_helper(Stream, Char, [Char|Rest]) :-
    get_char(Stream, NextC),
    read_line_chars_helper(Stream, NextC, Rest).

parse_line_chars(Chars) :-
    split_key_value(Chars, KeyChars, ValueCharsRaw),
    trim_space(ValueCharsRaw, ValueCharsTrimmed),
    % GNU Prolog butuh tanda titik di akhir untuk bisa membaca term
    append_list(ValueCharsTrimmed, ['.'], ValueCharsFinal),
    atom_chars(Key, KeyChars),
    % Tambahkan trik variable_names di sini
    read_term_from_chars(ValueCharsFinal, Term, [variable_names(Vars)]),
    bind_vars(Vars),
    parse_key_value(Key, Term).

% Fungsi pembantu untuk mengubah Variabel menjadi Teks (Atom)
bind_vars([]).
bind_vars([Name=Var|T]) :-
    Var = Name,
    bind_vars(T).
    
% Memisah Key dan Value pada tanda titik dua (:)
split_key_value([], [], []).
split_key_value([':'|T], [], T) :- !.
split_key_value([H|T], [H|KeyRest], Value) :-
    split_key_value(T, KeyRest, Value).

% Menghapus spasi di awal value
trim_space([], []).
trim_space([' '|T], T) :- !.
trim_space(T, T).

% Mencocokkan data yang sudah di-parse ke state Prolog
parse_key_value(urutan_pemain, Urutan) :- asserta(urutan_pemain(Urutan)).
parse_key_value(giliran, Giliran) :- asserta(giliran_sekarang(Giliran)).
parse_key_value(discard_top, Warna - Jenis) :- asserta(discard_top(kartu(Warna, Jenis))).
parse_key_value(arah_permainan, Arah) :- asserta(arah_permainan(Arah)).
parse_key_value(warna_aktif, Warna) :- asserta(warna_aktif(Warna)).
parse_key_value(status_UNI, ListUNI) :- assert_status_uni(ListUNI).

% Menangkap format dinamis seperti "kartu_Pemain1"
parse_key_value(Key, ListKartuMinus) :-
    atom_chars(Key, ['k','a','r','t','u','_' | PemChars]),
    atom_chars(Pemain, PemChars),
    ubah_format_kartu(ListKartuMinus, ListKartuProlog),
    asserta(kartu_tangan(Pemain, ListKartuProlog)).

% Mengubah format text (merah-5) kembali menjadi struktur (kartu(merah, 5))
ubah_format_kartu([], []).
ubah_format_kartu([Warna - Jenis | T], [kartu(Warna, Jenis) | TRes]) :-
    ubah_format_kartu(T, TRes).

assert_status_uni([]).
assert_status_uni([H|T]) :-
    asserta(status_uni(H)),
    assert_status_uni(T).