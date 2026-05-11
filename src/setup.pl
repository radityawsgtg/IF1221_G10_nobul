startGame :-
    % Reset state jika sebelumnya ada permainan yang berjalan
    retractall(pemain_list(_)),
    retractall(urutan_pemain(_)),
    retractall(giliran_sekarang(_)),
    retractall(kartu_tangan(_, _)),
    retractall(discard_top(_)),
    
    write('Masukkan jumlah pemain (2-4): '),
    read(Jumlah),
    ( validasi_jumlah(Jumlah) ->
        inisiasi_pemain(Jumlah, [], ListPemain),
        random_permutation(ListPemain, UrutanAcak),
        asserta(urutan_pemain(UrutanAcak)),
        
        % (Fungsi bagi_kartu_awal/1 perlu Anda kembangkan untuk me-loop pembagian 7 kartu)
        % bagi_kartu_awal(UrutanAcak),
        
        inisiasi_discard,
        UrutanAcak = [PemainPertama|_],
        asserta(giliran_sekarang(PemainPertama)),
        
        write('Permainan berhasil diinisiasi!'), nl,
        write('Urutan pemain: '), write(UrutanAcak), nl,
        discard_top(Top), write('Kartu discard top: '), write(Top), nl,
        write('Giliran '), write(PemainPertama), write('.'), nl
    ;
        write('Mohon masukkan angka antara 2 - 4.'), nl, fail
    ).

validasi_jumlah(N) :- integer(N), N >= 2, N =< 4.

% Rekursi meminta input nama pemain yang unik
inisiasi_pemain(0, Terdaftar, Terdaftar) :- !.
inisiasi_pemain(N, Terdaftar, Hasil) :-
    N > 0,
    write('Masukkan nama pemain: '),
    read(Nama),
    ( member(Nama, Terdaftar) ->
        write('Nama sudah digunakan. Masukkan nama lain: '), nl,
        inisiasi_pemain(N, Terdaftar, Hasil)
    ;
        N1 is N - 1,
        append(Terdaftar, [Nama], ListBaru),
        inisiasi_pemain(N1, ListBaru, Hasil)
    ).

% Inisiasi kartu awal di meja (harus kartu angka, bukan aksi)
inisiasi_discard :-
    % (Fungsi pembangkit kartu acak angka ditaruh di sini)
    % Sebagai fondasi M1, kita set manual terlebih dahulu:
    asserta(discard_top(kartu(merah, 6))).