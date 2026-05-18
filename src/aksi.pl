% ==========================================
% HELPER ARAH & GILIRAN (Kerjaan Tim)
% ==========================================
get_direction(Arah) :- 
    arah_permainan(Arah), 
    !.
get_direction(kanan).

find_next_player(Current, Next) :-
    urutan_pemain(Urutan),
    get_direction(Arah),
    ( Arah == kanan ->
        find_next_circular(Current, Urutan, Urutan, Next)
    ;
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
    write('Giliran berikutnya: '), write(Next), nl.

skip_giliran :-
    giliran_sekarang(Current),
    find_next_player(Current, TargetSkip),
    find_next_player(TargetSkip, Next),
    retract(giliran_sekarang(Current)),
    asserta(giliran_sekarang(Next)),
    write('Giliran '), write(TargetSkip), write(' dilewati!'), nl,
    write('Giliran berikutnya: '), write(Next), nl.


% ==========================================
% LOGIKA EFEK KARTU
% ==========================================
efek_skip :-
    write('Kartu SKIP dimainkan! '), nl,
    skip_giliran.

efek_reverse :-
    write('Kartu REVERSE dimainkan! Arah permainan dibalik.'), nl,
    get_direction(ArahLama),
    ( ArahLama == kanan -> ArahBaru = kiri ; ArahBaru = kanan ),
    retractall(arah_permainan(_)),
    asserta(arah_permainan(ArahBaru)),
    write('Arah permainan sekarang ke '), write(ArahBaru), write('.'), nl,
    
    urutan_pemain(Urutan),
    get_length(Urutan, Length),
    ( Length == 2 -> skip_giliran ; pindah_giliran ).

efek_draw_two :-
    write('Kartu DRAW TWO dimainkan! Pemain berikutnya akan mengambil 2 kartu.'), nl,
    retractall(efek_kartu_pending(_)),
    asserta(efek_kartu_pending(draw_two)),
    skip_giliran.

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
    skip_giliran.

proses_efek_kartu(kartu(_, skip)) :- !, efek_skip.
proses_efek_kartu(kartu(_, reverse)) :- !, efek_reverse.
proses_efek_kartu(kartu(_, draw_two)) :- !, efek_draw_two.
proses_efek_kartu(kartu(hitam, wild)) :- !, efek_wild.
proses_efek_kartu(kartu(hitam, wild_draw_four)) :- !, efek_wild_draw_four.
proses_efek_kartu(_) :- pindah_giliran.

mainkanKartu(NomorUrut) :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    get_element(NomorUrut, ListKartu, KartuPilihan),
    discard_top(Top),
    
    ( valid_match(KartuPilihan, Top) ->
        
        % HOOK TANTANG 
        Top = kartu(WarnaAktif, _),
        ( KartuPilihan = kartu(hitam, wild_draw_four) ->
            retractall(warna_sebelum_wild(_)),
            asserta(warna_sebelum_wild(WarnaAktif))
        ; true ),
        
        select_element(KartuPilihan, ListKartu, ListBaru),
        retract(kartu_tangan(Pemain, ListKartu)),
        asserta(kartu_tangan(Pemain, ListBaru)),
        
        retract(discard_top(Top)),
        asserta(discard_top(KartuPilihan)),
        
        write(Pemain), write(' memainkan kartu: '), write(KartuPilihan), nl,
        
        % BUG FIX: Ganti pindah_giliran jadi proses_efek_kartu agar efek kartu jalan
        proses_efek_kartu(KartuPilihan)
    ;
        write('Kartu tidak valid! Silakan pilih kartu lain.'), nl
    ).

% --- FIX VALID MATCH (Mengecek warna_aktif jika kartu teratas adalah kartu hitam) ---
valid_match(kartu(hitam, wild), kartu(_, TopJenis)) :-
    !, TopJenis \= wild.

valid_match(kartu(hitam, wild_draw_four), kartu(TopWarna, TopJenis)) :-
    !,
    TopJenis \= wild_draw_four,
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    ( warna_aktif(WarnaSedangAktif) -> 
        WarnaCek = WarnaSedangAktif 
    ; 
        WarnaCek = TopWarna 
    ),
    \+ punya_kartu_alternatif(ListKartu, WarnaCek, TopJenis).

valid_match(kartu(Warna, _), kartu(TopWarna, TopJenis)) :-
    ( (TopJenis == wild ; TopJenis == wild_draw_four) ->
        ( warna_aktif(WarnaAktif) -> Warna == WarnaAktif ; true )
    ;
        Warna == TopWarna
    ).

valid_match(kartu(_, Jenis), kartu(_, Jenis)).

punya_kartu_alternatif([kartu(Warna, _) | _], Warna, _) :- 
    Warna \= hitam.
punya_kartu_alternatif([kartu(_, Jenis) | _], _, Jenis).
punya_kartu_alternatif([_ | Tail], WarnaCek, TopJenis) :- 
    punya_kartu_alternatif(Tail, WarnaCek, TopJenis).

ambilKartu :-
    giliran_sekarang(Pemain),
    ( efek_kartu_pending(EfekAktif), EfekAktif \= none ->
        proses_ambil_efek(Pemain, EfekAktif)
    ;
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


% ==========================================
% FITUR TUGAS UTAMA (UNI, TANTANG, PENALTI)
% ==========================================
uni(NomorUrut) :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    get_length(ListKartu, Jumlah),
    
    ( Jumlah == 2 ->
        get_element(NomorUrut, ListKartu, KartuPilihan),
        discard_top(Top),
        
        ( valid_match(KartuPilihan, Top) ->
            select_element(KartuPilihan, ListKartu, ListBaru),
            retract(kartu_tangan(Pemain, ListKartu)),
            asserta(kartu_tangan(Pemain, ListBaru)),
            
            retract(discard_top(Top)),
            asserta(discard_top(KartuPilihan)),
            
            write(Pemain), write(' memainkan kartu: '), write(KartuPilihan), nl,
            write(Pemain), write(' UNI!!!'), nl,
            
            asserta(status_uni(Pemain)),
            proses_efek_kartu(KartuPilihan)
        ;
            write('Kartu tidak valid! Anda terkena penalti ambil 1 kartu.'), nl,
            penalti_ambil(Pemain, 1),
            pindah_giliran
        )
    ;
        write('Gagal! Kartu Anda tidak bersisa 1 setelah ini. Anda terkena penalti.'), nl,
        penalti_ambil(Pemain, 1),
        pindah_giliran
    ).

hapus_status_UNI(Pemain) :-
    ( status_uni(Pemain) ->
        retract(status_uni(Pemain)),
        write('Status UNI milik '), write(Pemain), write(' telah hangus karena mengambil kartu.'), nl
    ;
        true
    ).

tantang :-
    giliran_sekarang(Penantang),
    discard_top(kartu(hitam, wild_draw_four)),
    
    % Trik cerdas mencari pemain sebelumnya: Balikkan arah sementara, cari next player, lalu normalkan arahnya lagi
    get_direction(ArahSekarang),
    ( ArahSekarang == kanan -> ArahMundur = kiri ; ArahMundur = kanan ),
    retractall(arah_permainan(_)), asserta(arah_permainan(ArahMundur)),
    find_next_player(Penantang, PemainWD4),
    retractall(arah_permainan(_)), asserta(arah_permainan(ArahSekarang)),
    
    kartu_tangan(PemainWD4, TanganWD4),
    warna_sebelum_wild(WarnaLama),
    
    write('Tantangan diajukan! Memeriksa kartu milik '), write(PemainWD4), write('...'), nl,
    
    ( cek_punya_warna(TanganWD4, WarnaLama) ->
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

% Helper buat uni dan wildcard
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
    N1 is N - 1,
    penalti_ambil(PemainTarget, N1).