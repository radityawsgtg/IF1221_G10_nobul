get_direction(Arah) :- 
    arah_permainan(Arah), 
    !.
get_direction(kanan).

find_next_player(Current, Next) :-
    urutan_pemain(Urutan),
    get_direction(Arah),
    (Arah == kanan ->
        find_next_circular(Current, Urutan, Urutan, Next) ;
        reverse_list(Urutan, UrutanReversed),
        find_next_circular(Current, UrutanReversed, UrutanReversed, Next)
    ).

find_next_circular(Current, [Current, Next|_], _, Next) :- !.
find_next_circular(Current, [Current], FullList, Next) :- FullList = [Next|_], !.
find_next_circular(Current, [_|Tail], FullList, Next) :- find_next_circular(Current, Tail, FullList, Next).

pindah_giliran :-
    giliran_sekarang(Current),
    find_next_player(Current, Next),
    retract(giliran_sekarang(Current)),
    asserta(giliran_sekarang(Next)),
    write('Giliran berikutnya: '), write(Next), nl,
    godsHand. % <--- Sisipkan ini

skip_giliran :-
    giliran_sekarang(Current),
    find_next_player(Current, TargetSkip),
    find_next_player(TargetSkip, Next),
    retract(giliran_sekarang(Current)),
    asserta(giliran_sekarang(Next)),
    write('Giliran '), write(TargetSkip), write(' dilewati!'), nl,
    write('Giliran berikutnya: '), write(Next), nl,
    godsHand. % <--- Sisipkan ini
    
efek_skip :-
    write('Kartu SKIP dimainkan! '), nl,
    skip_giliran.

efek_reverse :-
    write('Kartu REVERSE dimainkan! Arah permainan dibalik.'), nl,
    get_direction(ArahLama),
    (ArahLama == kanan -> ArahBaru = kiri ; ArahBaru = kanan),
    retractall(arah_permainan(_)),
    asserta(arah_permainan(ArahBaru)),
    write('Arah permainan sekarang ke '), write(ArahBaru), write('.'), nl,
    
    urutan_pemain(Urutan),
    get_length(Urutan, Length),
    (Length == 2 -> skip_giliran ; pindah_giliran).

efek_draw_two :-
    write('Kartu DRAW TWO dimainkan! Pemain berikutnya akan mengambil 2 kartu.'), nl,
    retractall(efek_kartu_pending(_)),
    asserta(efek_kartu_pending(draw_two)),
    pindah_giliran.

efek_wild :-
    write('Kartu WILD dimainkan!'), nl,
    write('Pilih warna aktif baru (merah/kuning/hijau/biru): '),
    read(WarnaBaru),
    retractall(warna_aktif(_)),
    asserta(warna_aktif(WarnaBaru)),
    write('Warna aktif sekarang adalah: '), write(WarnaBaru), nl,
    pindah_giliran.

efek_wild_draw_four :-
    write('Kartu WILD DRAW FOUR dimainkan!'), nl,
    write('Pilih warna aktif baru (merah/kuning/hijau/biru): '),
    read(WarnaBaru),
    retractall(warna_aktif(_)),
    asserta(warna_aktif(WarnaBaru)),
    retractall(efek_kartu_pending(_)),
    asserta(efek_kartu_pending(wild_draw_four)),
    write('Warna aktif sekarang: '), write(WarnaBaru), nl,
    pindah_giliran.

proses_efek_kartu(kartu(_, skip)) :- !, efek_skip.
proses_efek_kartu(kartu(_, reverse)) :- !, efek_reverse.
proses_efek_kartu(kartu(_, draw_two)) :- !, efek_draw_two.
proses_efek_kartu(kartu(hitam, wild)) :- !, efek_wild.
proses_efek_kartu(kartu(hitam, wild_draw_four)) :- !, efek_wild_draw_four.
proses_efek_kartu(_) :- pindah_giliran.

mainkanKartu(NomorUrut) :-
    (efek_kartu_pending(Efek), Efek \= none ->
        write('Aksi ditolak! Anda sedang terkena penalti '), write(Efek), write('. Wajib gunakan ambilKartu atau tantang.'), nl ;
        giliran_sekarang(Pemain),
        kartu_tangan(Pemain, ListKartu),
        get_element(NomorUrut, ListKartu, KartuPilihan),
        discard_top(Top),
        (valid_match(KartuPilihan, Top) ->
            Top = kartu(WarnaAktif, _),
            (KartuPilihan = kartu(hitam, wild_draw_four) -> retractall(warna_sebelum_wild(_)),asserta(warna_sebelum_wild(WarnaAktif)) ; true),
            select_element(KartuPilihan, ListKartu, ListBaru),
            retract(kartu_tangan(Pemain, ListKartu)),
            asserta(kartu_tangan(Pemain, ListBaru)),
            retract(discard_top(Top)),
            asserta(discard_top(KartuPilihan)),
            write(Pemain), write(' memainkan kartu: '), write(KartuPilihan), nl,
            (ListBaru == [] -> endGame; proses_efek_kartu(KartuPilihan))
        ;
            write('Kartu tidak valid! Silakan pilih kartu lain.'), nl
        )
    ).

valid_match(kartu(hitam, wild), kartu(_, TopJenis)) :-
    !, TopJenis \= wild.

valid_match(kartu(hitam, wild_draw_four), kartu(_, TopJenis)) :-
    !,
    TopJenis \= wild_draw_four.

valid_match(kartu(Warna, _), kartu(TopWarna, TopJenis)) :-
    ((TopJenis == wild ; TopJenis == wild_draw_four) -> (warna_aktif(WarnaAktif) -> Warna == WarnaAktif ; true) ;
        Warna == TopWarna).
valid_match(kartu(_, Jenis), kartu(_, Jenis)).

punya_kartu_alternatif([kartu(Warna, _) | _], Warna, _) :- Warna \= hitam.
punya_kartu_alternatif([kartu(_, Jenis) | _], _, Jenis).
punya_kartu_alternatif([_ | Tail], WarnaCek, TopJenis) :- 
    punya_kartu_alternatif(Tail, WarnaCek, TopJenis).

ambilKartu :-
    giliran_sekarang(Pemain),
    (efek_kartu_pending(EfekAktif), EfekAktif \= none -> proses_ambil_efek(Pemain, EfekAktif) ;
        kartu_tangan(Pemain, ListKartu),
        kartu_acak(KartuBaru),
        append_list(ListKartu, [KartuBaru], ListBaru), 
        retract(kartu_tangan(Pemain, ListKartu)),
        asserta(kartu_tangan(Pemain, ListBaru)),
        write(Pemain), write(' mengambil kartu acak: '), write(KartuBaru), nl,
        hapus_status_UNI(Pemain),
        pindah_giliran
    ).

proses_ambil_efek(Pemain, draw_two) :-
    write(Pemain), write(' terkena efek DRAW TWO dan harus mengambil 2 kartu!'), nl,
    penalti_ambil(Pemain, 2),
    retractall(efek_kartu_pending(_)),
    asserta(efek_kartu_pending(none)),
    hapus_status_UNI(Pemain),
    pindah_giliran.

proses_ambil_efek(Pemain, wild_draw_four) :-
    write(Pemain), write(' terkena efek WILD DRAW FOUR dan harus mengambil 4 kartu!'), nl,
    penalti_ambil(Pemain, 4),
    retractall(efek_kartu_pending(_)),
    asserta(efek_kartu_pending(none)),
    hapus_status_UNI(Pemain),
    pindah_giliran.

uni(NomorUrut) :-
    (efek_kartu_pending(Efek), Efek \= none ->
        write('Aksi ditolak! Anda sedang terkena penalti '), write(Efek), write('. Wajib gunakan ambilKartu atau tantang.'), nl ;
        giliran_sekarang(Pemain),
        kartu_tangan(Pemain, ListKartu),
        get_length(ListKartu, Jumlah),
        (Jumlah == 2 ->
            get_element(NomorUrut, ListKartu, KartuPilihan),
            discard_top(Top),
            (valid_match(KartuPilihan, Top) ->
                select_element(KartuPilihan, ListKartu, ListBaru),
                retract(kartu_tangan(Pemain, ListKartu)),
                asserta(kartu_tangan(Pemain, ListBaru)),
                retract(discard_top(Top)),
                asserta(discard_top(KartuPilihan)),
                write(Pemain), write(' memainkan kartu: '), write(KartuPilihan), nl,
                write(Pemain), write(' UNI!!!'), nl,
                asserta(status_uni(Pemain)),
                (ListBaru == [] -> endGame; proses_efek_kartu(KartuPilihan))
            ;
                write('Kartu tidak valid! Anda terkena penalti ambil 1 kartu.'), nl,
                penalti_ambil(Pemain, 1),
                pindah_giliran)
        ;
            write('Gagal! Kartu Anda tidak bersisa 1 setelah ini. Anda terkena penalti.'), nl,
            penalti_ambil(Pemain, 1),
            pindah_giliran
        )
    ).

hapus_status_UNI(Pemain) :-
    (status_uni(Pemain) ->
        retract(status_uni(Pemain)),
        write('Status UNI milik '), write(Pemain), write(' telah hangus karena mengambil kartu.'), nl ;
        true
    ).

tantang :-
    giliran_sekarang(Penantang),
    discard_top(kartu(hitam, wild_draw_four)),
    get_direction(ArahSekarang),
    (ArahSekarang == kanan -> ArahMundur = kiri ; ArahMundur = kanan ),
    retractall(arah_permainan(_)), asserta(arah_permainan(ArahMundur)),
    find_next_player(Penantang, PemainWD4),
    retractall(arah_permainan(_)), asserta(arah_permainan(ArahSekarang)),
    
    kartu_tangan(PemainWD4, TanganWD4),
    warna_sebelum_wild(WarnaLama),
    
    write('Tantangan diajukan! Memeriksa kartu milik '), write(PemainWD4), write('...'), nl,
    
    (cek_punya_warna(TanganWD4, WarnaLama) ->
        write('Tantangan BERHASIL! '), write(PemainWD4), write(' curang (punya warna '), write(WarnaLama), write(')!'), nl,
        write(PemainWD4), write(' dihukum mengambil 4 kartu.'), nl,
        penalti_ambil(PemainWD4, 4),
        retractall(efek_kartu_pending(_)),
        asserta(efek_kartu_pending(none)),
        pindah_giliran
    ;
        write('Tantangan GAGAL! '), write(PemainWD4), write(' bermain jujur.'), nl,
        write(Penantang), write(' yang menuduh menerima hukuman mengambil 6 kartu.'), nl,
        penalti_ambil(Penantang, 6),
        retractall(efek_kartu_pending(_)),
        asserta(efek_kartu_pending(none)),
        pindah_giliran
    ).

cek_punya_warna([kartu(Warna, _) | _], Warna) :- !.
cek_punya_warna([_ | T], Warna) :- cek_punya_warna(T, Warna).

penalti_ambil(_, 0) :- !.
penalti_ambil(PemainTarget, N) :-
    N > 0,
    kartu_tangan(PemainTarget, ListKartu),
    kartu_acak(KartuBaru),
    append_list(ListKartu, [KartuBaru], ListBaru),
    retract(kartu_tangan(PemainTarget, ListKartu)),
    asserta(kartu_tangan(PemainTarget, ListBaru)),
    N1 is N-1,
    penalti_ambil(PemainTarget, N1).

tangkap(TargetPemain) :-
    giliran_sekarang(Penangkap),
    kartu_tangan(TargetPemain, ListKartuTarget),
    get_length(ListKartuTarget, JumlahKartu),
    (JumlahKartu == 1, \+ status_uni(TargetPemain) ->
        write(TargetPemain), write(' tertangkap tidak menyerukan UNI.'), nl,
        write(TargetPemain), write(' mendapatkan 2 kartu penalti.'), nl,
        penalti_ambil(TargetPemain, 2),
        pindah_giliran
    ;
        write('Perintah tangkap tidak valid. '), write(Penangkap), write(' mendapatkan 1 kartu penalti.'), nl,
        penalti_ambil(Penangkap, 1),
        pindah_giliran).

hitung_poin_kartu(kartu(_, Jenis), Poin) :-
    integer(Jenis), !, Poin = Jenis.
hitung_poin_kartu(kartu(_, Jenis), 10) :-
    is_element(Jenis, [skip, reverse, draw_two]), !.
hitung_poin_kartu(kartu(_, Jenis), 20) :-
    is_element(Jenis, [wild, wild_draw_four, mimic]), !.

hitung_total_poin([], 0).
hitung_total_poin([Kartu|T], Total) :-
    hitung_poin_kartu(Kartu, Poin),
    hitung_total_poin(T, SisaPoin),
    Total is Poin + SisaPoin.

ambil_data_pemain([], _, []).
ambil_data_pemain([Pemain|T], Index, [v(Poin, Jumlah, Index, Pemain)|SisaData]) :-
    kartu_tangan(Pemain, ListKartu),
    get_length(ListKartu, Jumlah),
    hitung_total_poin(ListKartu, Poin),
    NextIndex is Index + 1,
    ambil_data_pemain(T, NextIndex, SisaData).

cetak_semua_breakdown([]).
cetak_semua_breakdown([Pemain|T]) :-
    write(Pemain), write(': '),
    kartu_tangan(Pemain, ListKartu),
    cetak_breakdown_kartu(ListKartu),
    cetak_semua_breakdown(T).

cetak_breakdown_kartu([]) :- 
    write('kartu habis = 0 poin'), nl, !.
cetak_breakdown_kartu(ListKartu) :-
    cetak_nama_kartu(ListKartu),
    write(' = '),
    cetak_poin_kartu(ListKartu),
    hitung_total_poin(ListKartu, Total),
    write(' = '), write(Total), write(' poin'), nl.

cetak_nama_kartu([kartu(W, J)]) :- !, write(W), write('-'), write(J).
cetak_nama_kartu([kartu(W, J)|T]) :- 
    write(W), write('-'), write(J), write(' + '), cetak_nama_kartu(T).

cetak_poin_kartu([Kartu]) :- !, hitung_poin_kartu(Kartu, Poin), write(Poin).
cetak_poin_kartu([Kartu|T]) :- 
    hitung_poin_kartu(Kartu, Poin), write(Poin), write(' + '), cetak_poin_kartu(T).

cetak_leaderboard([], _).
cetak_leaderboard([v(Poin, _, _, Pemain)|T], Rank) :-
    write(Rank), write('. '), write(Pemain), write(' ('), write(Poin), write(' poin)'), nl,
    NextRank is Rank + 1,
    cetak_leaderboard(T, NextRank).

cari_pemenang([Pemain|_], Pemain) :-
    kartu_tangan(Pemain, []).
cari_pemenang([_|T], Pemenang) :-
    cari_pemenang(T, Pemenang).

endGame :-
    urutan_pemain(Urutan),
    cari_pemenang(Urutan, Pemenang),
    write('Permainan selesai! '), write(Pemenang), write(' menghabiskan semua kartunya!'), nl, nl,
    write('Berikut perhitungan poin sisa kartu.'), nl,
    cetak_semua_breakdown(Urutan), nl,
    ambil_data_pemain(Urutan, 1, DataPemain),
    sort(DataPemain, DataUrut),
    write('Urutan pemenang:'), nl,
    cetak_leaderboard(DataUrut, 1), nl,
    write('Selamat, '), write(Pemenang), write(' menjadi pemenang!'), nl.

% ==========================================
% BONUS: GOD'S HAND (Orang 2)
% ==========================================
godsHand :-
    urutan_pemain(Urutan),
    % Validasi: Jangan trigger kalau semua pemain hanya punya 1 kartu
    ( cek_semua_satu_kartu(Urutan) ->
        true 
    ;
        % Menggunakan PRNG dari fungsi.pl
        prng_next(Rand),
        Chance is Rand mod 100,
        (Chance < 15 -> % Peluang trigger: 15% (Syarat tugas: 10-20%)
            jalankan_gods_hand(Urutan)
        ;
            true
        )
    ).

cek_semua_satu_kartu([]).
cek_semua_satu_kartu([P|T]) :-
    kartu_tangan(P, Kartu),
    get_length(Kartu, Len),
    Len =< 1,
    cek_semua_satu_kartu(T).

jalankan_gods_hand(Urutan) :-
    % Mengacak urutan pemain untuk memilih Source dan Target yang berbeda
    tambah_bobot_acak(Urutan, UrutanAcak),
    keysort(UrutanAcak, UrutanSorted),
    hapus_bobot(UrutanSorted, ListAcak),
    ListAcak = [Source, Target | _],
    
    kartu_tangan(Source, TanganSource),
    get_length(TanganSource, LenSource),
    
    (LenSource > 0 ->
        prng_next(RandCard),
        Index is (RandCard mod LenSource) + 1,
        
        get_element(Index, TanganSource, KartuPindah),
        select_element(KartuPindah, TanganSource, TanganSourceBaru),
        
        kartu_tangan(Target, TanganTarget),
        append_list(TanganTarget, [KartuPindah], TanganTargetBaru),
        
        retract(kartu_tangan(Source, TanganSource)),
        asserta(kartu_tangan(Source, TanganSourceBaru)),
        retract(kartu_tangan(Target, TanganTarget)),
        asserta(kartu_tangan(Target, TanganTargetBaru)),
        
        write('=========================================='), nl,
        write('✨ GOD''S HAND TERPICU! ✨'), nl,
        write('Sebuah keajaiban kosmik mengambil kartu dari '), write(Source), 
        write(' dan memindahkannya ke tangan '), write(Target), write('!'), nl,
        write('=========================================='), nl
    ;
        true
    ).