mainkanKartu(NomorUrut) :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    nth1(NomorUrut, ListKartu, KartuPilihan),
    discard_top(Top),
    
    (valid_match(KartuPilihan, Top) ->
        select(KartuPilihan, ListKartu, ListBaru),
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

ambilKartu :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    kartu_acak(KartuBaru),
    append(ListKartu, [KartuBaru], ListBaru),
    retract(kartu_tangan(Pemain, ListKartu)),
    asserta(kartu_tangan(Pemain, ListBaru)),
    write(Pemain), write(' mendapatkan kartu: '), write(KartuBaru), nl,
    pindah_giliran.

pindah_giliran :-
    urutan_pemain(Urutan),
    giliran_sekarang(Sekarang),
    append(_, [Sekarang|Belakang], Urutan),
    (Belakang \= [] -> 
        Belakang = [Berikutnya|_] 
    ; 
        Urutan = [Berikutnya|_] 
    ),
    retract(giliran_sekarang(Sekarang)),
    asserta(giliran_sekarang(Berikutnya)),
    write('Giliran '), write(Berikutnya), write('.'), nl.