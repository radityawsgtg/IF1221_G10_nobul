startGame :-
    retractall(pemain_list(_)),
    retractall(urutan_pemain(_)),
    retractall(giliran_sekarang(_)),
    retractall(kartu_tangan(_, _)),
    retractall(discard_top(_)),
    
    write('Masukkan jumlah pemain (2-4): '),
    read(Jumlah),
    (validasi_jumlah(Jumlah) ->
        inisiasi_pemain(Jumlah, [], ListPemain),
        random_permutation(ListPemain, UrutanAcak),
        asserta(urutan_pemain(UrutanAcak)),

        bagi_kartu_awal(UrutanAcak),
        
        inisiasi_discard,
        UrutanAcak = [PemainPertama|_],
        asserta(giliran_sekarang(PemainPertama)),
        
        write('Permainan berhasil diinisiasi!'), nl,
        write('Urutan pemain: '), write(UrutanAcak), nl,
        discard_top(Top), write('Kartu discard top: '), write(Top), nl,
        write('Giliran '), write(PemainPertama), write('.'), nl
    ;
        write('Mohon masukkan angka antara 2-4.'), nl, fail
    ).

validasi_jumlah(N) :- integer(N), N >= 2, N =< 4.

cek_huruf_besar(Nama) :-
    atom(Nama),
    atom_chars(Nama, [HurufPertama|_]),
    char_code(HurufPertama, Code),
    Code >= 65, Code =< 90.

inisiasi_pemain(0, Terdaftar, Terdaftar) :- !.
inisiasi_pemain(N, Terdaftar, Hasil) :-
    N > 0,
    write('Masukkan nama pemain: '),
    read(Nama),
    (\+ cek_huruf_besar(Nama) ->
        write('Nama harus diawali dengan huruf besar! Coba lagi.'), nl,
        inisiasi_pemain(N, Terdaftar, Hasil)
    ; member(Nama, Terdaftar) ->
        write('Nama sudah digunakan. Masukkan nama lain: '), nl,
        inisiasi_pemain(N, Terdaftar, Hasil)
    ;
        N1 is N-1,
        append(Terdaftar, [Nama], TerdaftarBaru),
        inisiasi_pemain(N1, TerdaftarBaru, Hasil)
    ).

inisiasi_discard :-
    asserta(discard_top(kartu(merah, 6))).

kartu_acak(Kartu) :-
    findall(kartu(Warna, Jenis), is_kartu(kartu(Warna, Jenis)), ListSemua),
    random_member(Kartu, ListSemua).

bagi_kartu_awal([]).
bagi_kartu_awal([Pemain|T]) :-
    bagi_n_kartu(7, ListKartu),
    asserta(kartu_tangan(Pemain, ListKartu)),
    bagi_kartu_awal(T).

bagi_n_kartu(0, []).
bagi_n_kartu(N, [Kartu|T]) :-
    N > 0,
    kartu_acak(Kartu),
    N1 is N-1,
    bagi_n_kartu(N1, T).

inisiasi_discard :-
    findall(kartu(W, A), (warna(W), jenis_angka(A)), ListAngka),
    random_member(KartuAwal, ListAngka),
    asserta(discard_top(KartuAwal)).

random_member(X, L) :-
    length(L, Len),
    random(0, Len, Index),
    nth0(Index, L, X).

random_permutation(L, R) :-
    findall(Rand-X, (member(X, L), random(Rand)), Pairs),
    keysort(Pairs, Sorted),
    findall(X, member(_-X, Sorted), R).

nth0(0, [H|_], H) :- !.
nth0(N, [_|T], H) :- N > 0, N1 is N-1, nth0(N1, T, H).