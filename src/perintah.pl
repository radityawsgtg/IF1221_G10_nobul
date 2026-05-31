lihatCommand :-
    write('Aksi utama yang tersedia:'), nl,
    write('1. mainkanKartu(NomorUrut)'), nl,
    write('2. ambilKartu'), nl,
    (mode_permainan(turnamen) -> write('3. swapKartu(NoUrutku, NoUrutTeman)'), nl ; true ),
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl,
    write('4. saveGame'), nl,
    write('5. loadGame'), nl.

lihatKartu :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    write('Berikut kartu yang anda miliki.'), nl,
    cetak_kartu_berurut_pribadi(ListKartu, 1, Pemain), nl,
    (mode_permainan(turnamen) ->
        tim(Pemain, TeamNum),
        tim(Teman, TeamNum),
        Pemain \= Teman, !,
        kartu_tangan(Teman, ListKartuTeman),
        write('Berikut kartu yang teman satu tim anda miliki ('), write(Teman), write(').'), nl,
        cetak_kartu_berurut(ListKartuTeman, 1)
    ;
        true
    ).

cetak_kartu_berurut_pribadi([], Index, Pemain) :-
    (kartu_tersembunyi(Pemain, kartu(W, J)) ->
        write(Index), write('. '), write(W), write('-'), write(J), write(' (disembunyikan)'), nl
    ; true).
cetak_kartu_berurut_pribadi([kartu(W, J)|T], Index, Pemain) :-
    write(Index), write('. '), write(W), write('-'), write(J), nl,
    NextIndex is Index+1,
    cetak_kartu_berurut_pribadi(T, NextIndex, Pemain).

cetak_kartu_berurut([], _).
cetak_kartu_berurut([kartu(W, J)|T], Index) :-
    write(Index), write('. '), write(W), write('-'), write(J), nl,
    NextIndex is Index+1,
    cetak_kartu_berurut(T, NextIndex).

cekInfo :-
    discard_top(Top), Top = kartu(W, J),
    urutan_pemain(Urutan),
    write('Kartu discard top: '), write(W), write('-'), write(J), write('.'), nl, nl,
    (mode_permainan(turnamen) ->
        findall(P1, tim(P1, 1), [T1A, T1B]),
        findall(P2, tim(P2, 2), [T2A, T2B]),
        write('Tim 1 : '), write(T1A), write(', '), write(T1B), nl,
        write('Tim 2 : '), write(T2A), write(', '), write(T2B), nl, nl
    ;
        true
    ),
    write('Urutan pemain: '), cetak_urutan(Urutan), write('.'), nl, nl,
    cetak_info_pemain(Urutan, 1),
    write('yes'), nl.

cetak_urutan([H]) :- write(H).
cetak_urutan([H|T]) :- write(H), write(' - '), cetak_urutan(T).

cetak_info_pemain([], _).
cetak_info_pemain([Pemain|T], Index) :-
    kartu_tangan(Pemain, ListKartu),
    get_length(ListKartu, Jumlah),
    write('Nama pemain '), write(Index), write(': '), write(Pemain), nl,
    write('Jumlah kartu : '), write(Jumlah), nl, nl,
    NextIndex is Index+1,
    cetak_info_pemain(T, NextIndex).