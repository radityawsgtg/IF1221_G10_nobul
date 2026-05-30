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
    retractall(mode_permainan(_)),
    retractall(tim(_, _)),
    retractall(sudah_swap(_)),
    asserta(arah_permainan(kanan)),
    asserta(efek_kartu_pending(none)),
    prng_init,
    write('Tersedia 2 mode permainan.'), nl,
    write('1. Mode klasik'), nl,
    write('2. Mode turnamen'), nl, nl,
    write('Pilih mode permainan: '),
    read(Mode),
    (
        Mode == 1 ->
            asserta(mode_permainan(klasik)),
            jalankan_mode_klasik
        ;
        Mode == 2 ->
            asserta(mode_permainan(turnamen)),
            jalankan_mode_turnamen
        ;
            write('Mode tidak valid!'), nl, fail
    ).

jalankan_mode_klasik :-
    write('Masukkan jumlah pemain (2-4): '),
    read(Jumlah),
    (validasi_jumlah(Jumlah) ->
        inisiasi_pemain_loop(1, Jumlah, [], ListPemain),
        random_permutation(ListPemain, UrutanAcak),
        asserta(urutan_pemain(UrutanAcak)),
        semua_kartu(FullDeck),
        random_permutation(FullDeck, ShuffledDeck),
        asserta(tumpukan_dek(ShuffledDeck)),
        bagi_kartu_awal(UrutanAcak),
        inisiasi_discard,
        UrutanAcak = [PemainPertama|_],
        asserta(giliran_sekarang(PemainPertama)),
        write('Permainan Mode Klasik berhasil diinisiasi!'), nl,
        write('Urutan pemain: '), cetak_urutan(UrutanAcak), write('.'), nl,
        discard_top(Top), Top = kartu(W, J), write('Kartu discard top: '), write(W), write('-'), write(J), write('.'), nl,
        write('Giliran '), write(PemainPertama), write('.'), nl
    ;
        write('Mohon masukkan angka antara 2-4.'), nl, fail
    ).

jalankan_mode_turnamen :-
    write('Permainan dimulai dalam mode turnamen.'), nl, nl,
    inisiasi_pemain_loop(1, 4, [], ListPemain),
    random_permutation(ListPemain, [A, B, C, D]),
    asserta(tim(A, 1)), asserta(tim(C, 1)),
    asserta(tim(B, 2)), asserta(tim(D, 2)),
    UrutanTurnamen = [A, B, C, D],
    asserta(urutan_pemain(UrutanTurnamen)),
    semua_kartu(FullDeck),
    random_permutation(FullDeck, ShuffledDeck),
    asserta(tumpukan_dek(ShuffledDeck)),
    bagi_kartu_awal(UrutanTurnamen),
    inisiasi_discard,
    asserta(giliran_sekarang(A)),
    nl, write('Membentuk tim secara acak...'), nl, nl,
    write('Tim 1 : '), write(A), write(', '), write(C), nl,
    write('Tim 2 : '), write(B), write(', '), write(D), nl, nl,
    write('Urutan pemain: '), cetak_urutan(UrutanTurnamen), write('.'), nl, nl,
    write('Setiap pemain mendapatkan 7 kartu acak.'), nl,
    discard_top(Top), Top = kartu(W, J), write('Kartu discard top: '), write(W), write('-'), write(J), write('.'), nl, nl,
    write('Giliran '), write(A), write('.'), nl.

validasi_jumlah(N) :- integer(N), N >= 2, N =< 4.

cek_huruf_besar(Nama) :-
    atom(Nama),
    atom_chars(Nama, [HurufPertama|_]),
    char_code(HurufPertama, Code),
    Code >= 65, Code =< 90.

inisiasi_pemain_loop(Idx, Max, Terdaftar, Hasil) :-
    Idx > Max, !, Hasil = Terdaftar.
inisiasi_pemain_loop(Idx, Max, Terdaftar, Hasil) :-
    Idx =< Max,
    minta_nama(Idx, Terdaftar, Nama),
    append_list(Terdaftar, [Nama], TerdaftarBaru),
    NextIdx is Idx + 1,
    inisiasi_pemain_loop(NextIdx, Max, TerdaftarBaru, Hasil).

minta_nama(Idx, Terdaftar, NamaFinal) :-
    write('Masukkan nama pemain '), write(Idx), write(': '),
    read(Nama),
    validasi_nama_input(Idx, Nama, Terdaftar, NamaFinal).

validasi_nama_input(Idx, Nama, Terdaftar, NamaFinal) :-
    (\+ cek_huruf_besar(Nama) ->
        write('Nama harus diawali dengan huruf besar! Coba lagi.'), nl,
        minta_nama(Idx, Terdaftar, NamaFinal)
    ; is_element(Nama, Terdaftar) ->
        write('Nama sudah digunakan. Masukkan nama lain: '),
        read(NamaBaru),
        validasi_nama_input(Idx, NamaBaru, Terdaftar, NamaFinal)
    ;
        NamaFinal = Nama
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