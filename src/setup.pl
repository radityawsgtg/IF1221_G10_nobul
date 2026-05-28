startGame :-
    retractall(pemain_list(_)),
    retractall(urutan_pemain(_)),
    retractall(giliran_sekarang(_)),
    retractall(kartu_tangan(_, _)),
    retractall(discard_top(_)),
    retractall(tumpukan_dek(_)),
    retractall(arah_permainan(_)),
    retractall(warna_aktif(_)),
    retractall(efek_kartu_pending(_)),
    retractall(status_uni(_)),
    retractall(warna_sebelum_wild(_)),
    asserta(arah_permainan(kanan)),
    asserta(efek_kartu_pending(none)),
    
    prng_init,
    
    write('Masukkan jumlah pemain (2-4): '),
    read(Jumlah),
    (validasi_jumlah(Jumlah) ->
        inisiasi_pemain(Jumlah, [], ListPemain),
        random_permutation(ListPemain, UrutanAcak),
        asserta(urutan_pemain(UrutanAcak)),

        semua_kartu(FullDeck),
        random_permutation(FullDeck, ShuffledDeck),
        asserta(tumpukan_dek(ShuffledDeck)),

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
    ; is_element(Nama, Terdaftar) ->
        write('Nama sudah digunakan. Masukkan nama lain: '), nl,
        inisiasi_pemain(N, Terdaftar, Hasil)
    ;
        N1 is N-1,
        append_list(Terdaftar, [Nama], TerdaftarBaru),
        inisiasi_pemain(N1, TerdaftarBaru, Hasil)
    ).

inisiasi_discard :-
    kartu_acak(TopCard),
    TopCard = kartu(_, Jenis),
    (integer(Jenis) -> asserta(discard_top(TopCard));
        tumpukan_dek(DekLama),
        append_list(DekLama, [TopCard], DekBaru),
        retract(tumpukan_dek(_)),
        asserta(tumpukan_dek(DekBaru)),
        inisiasi_discard
    ).

kartu_acak(Kartu) :-
    tumpukan_dek([H|T]),
    !,
    Kartu = H,
    retract(tumpukan_dek(_)),
    asserta(tumpukan_dek(T)).

kartu_acak(Kartu) :-
    tumpukan_dek([]),
    write('Tumpukan dek habis! Mengocok ulang kartu dari tumpukan discard...'), nl,
    semua_kartu(FullDeck),
    (discard_top(Top) -> TrueTop = [Top] ; TrueTop = []),
    urutan_pemain(Urutan),
    collect_active_hands(Urutan, AllHands),
    append_list(AllHands, TrueTop, KartuAktif),
    exclude_cards(KartuAktif, FullDeck, DekBaru),
    random_permutation(DekBaru, ShuffledDeck),

    (ShuffledDeck == [] ->
        write('Error: Semua kartu sedang dipegang pemain! Dek tidak dapat diisi ulang.'), nl, fail;
        ShuffledDeck = [Kartu|SisaBaru],
        retract(tumpukan_deck(_)),
        asserta(tumpukan_deck(SisaBaru))
    ).

collect_active_hands([], []).
collect_active_hands([Pemain|T], Result) :-
    kartu_tangan(Pemain, ListKartu),
    collect_active_hands(T, Rest),
    append_list(ListKartu, Rest, Result).

exclude_cards([], List, List).
exclude_cards([H|T], List, Result) :-
    (select_element(H, List, Temp) ->
        exclude_cards(T, Temp, Result);
        exclude_cards(T, List, Result)
    ).

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