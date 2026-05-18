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

ambilKartu :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    kartu_acak(KartuBaru),
    append_list(ListKartu, [KartuBaru], ListBaru), 
    retract(kartu_tangan(Pemain, ListKartu)),
    asserta(kartu_tangan(Pemain, ListBaru)),
    write(Pemain), write(' mengambil kartu.'), nl,
    pindah_giliran.