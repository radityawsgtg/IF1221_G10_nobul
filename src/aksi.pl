mainkanKartu(NomorUrut) :-
    giliran_sekarang(Pemain),
    kartu_tangan(Pemain, ListKartu),
    nth1(NomorUrut, ListKartu, KartuPilihan),
    discard_top(Top),
    
    ( valid_match(KartuPilihan, Top) ->
        % Hapus kartu dari tangan pemain dan update discard top
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

% Aturan pencocokan kartu
valid_match(kartu(Warna, _), kartu(Warna, _)).
valid_match(kartu(_, Jenis), kartu(_, Jenis)).
valid_match(kartu(hitam, _), _).

ambilKartu :-
    giliran_sekarang(Pemain),
    % (Logika mengambil 1 kartu acak ditambahkan di sini)
    write(Pemain), write(' mengambil kartu.'), nl,
    pindah_giliran.

pindah_giliran :-
    urutan_pemain(Urutan),
    giliran_sekarang(Sekarang),
    % Logika mencari pemain selanjutnya di dalam list
    append(_, [Sekarang, Berikutnya|_], Urutan) ->
        retract(giliran_sekarang(Sekarang)),
        asserta(giliran_sekarang(Berikutnya)),
        write('Giliran berpindah ke '), write(Berikutnya), nl
    ; % Jika pemain terakhir, kembali ke awal list
        Urutan = [Pertama|_],
        retract(giliran_sekarang(Sekarang)),
        asserta(giliran_sekarang(Pertama)),
        write('Giliran berpindah ke '), write(Pertama), nl.