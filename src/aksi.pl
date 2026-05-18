% Helper untuk mendapatkan arah permainan saat ini (default : kanan)
get_direction(Arah) :- 
    arah_permainan(Arah), 
    !.
get_direction(kanan).

find_next_player(Current, Next) :-
    urutan_pemain(Urutan),
    get_direction(Arah),
    (Arah == kanan ->
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
    (Length == 2 ->
        skip_giliran
    ;
        pindah_giliran
    ).

mainkanKartu(NomorUrut) :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    get_element(NomorUrut, ListKartu, KartuPilihan),
    discard_top(Top),
    
    (valid_match(KartuPilihan, Top) ->
        select_element(KartuPilihan, ListKartu, ListBaru),
        retract(kartu_tangan(Pemain, ListKartu)),
        asserta(kartu_tangan(Pemain, ListBaru)),
        
        retract(discard_top(Top)),
        asserta(discard_top(KartuPilihan)),
        
        write(Pemain), write(' memainkan kartu: '), write(KartuPilihan), nl,
        pindah_giliran
    ;
        write('Kartu tidak valid! Silakan pilih kartu lain.'), nl
    ).

valid_match(kartu(Warna, _), kartu(Warna, _)).
valid_match(kartu(_, Jenis), kartu(_, Jenis)).
valid_match(kartu(hitam, _), _).

proses_efek_kartu(kartu(_, skip)) :- !, efek_skip.
proses_efek_kartu(kartu(_, reverse)) :- !, efek_reverse.
proses_efek_kartu(_) :- pindah_giliran.

ambilKartu :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    kartu_acak(KartuBaru),
    append_list(ListKartu, [KartuBaru], ListBaru), 
    retract(kartu_tangan(Pemain, ListKartu)),
    asserta(kartu_tangan(Pemain, ListBaru)),
    write(Pemain), write(' mengambil kartu baru: '), write(KartuBaru), nl,
    pindah_giliran.