% Fungsi append
% Menggabungkan 2 list
append_list([], List, List).
append_list([Head|Tail], List2, [Head|ResultTail]) :- 
    append_list(Tail, List2, ResultTail).

% Fungsi length
% Menghitung jumlah elemen dalam list
get_length([], 0).
get_length([_|Tail], Length) :- 
    get_length(Tail, TailLength), 
    Length is TailLength + 1.

% Fungsi nth1
% Mencari elemen berdasarkan indeks / mencari indeks berdasarkan elemen
% Dimulai dari indeks 1
get_element(1, [Head|_], Head) :- !.
get_element(Index, [_|Tail], Element) :- 
    Index > 1, 
    NewIndex is Index - 1, 
    get_element(NewIndex, Tail, Element).

% Fungsi member
% Memeriksa apakah elemen ada di dalam list
is_element(Element, [Element|_]).
is_element(Element, [_|Tail]) :- 
    is_element(Element, Tail).

% Fungsi reverse
% Membalik urutan elemen dalam list
reverse_list(List, Reversed) :- 
    reverse_helper(List, [], Reversed).
reverse_helper([], Accumulator, Accumulator).
reverse_helper([Head|Tail], Accumulator, Reversed) :- 
    reverse_helper(Tail, [Head|Accumulator], Reversed).

% Fungsi select
% Mengambil satu elemen dalam list
select_element(Element, [Element|Tail], Tail) :- !.
select_element(Element, [Head|Tail], [Head|ResultTail]) :- 
    select_element(Element, Tail, ResultTail).

% Fungsi between
% Menghasilkan angka secara berurutan dari Min hingga Max
between_manual(Min, Max, Min) :- Min =< Max.
between_manual(Min, Max, X) :-
    Min < Max,
    Next is Min + 1,
    between_manual(Next, Max, X).

% Fungsi findall untuk generate kartu
warna_list([merah, kuning, hijau, biru]).
jenis_list([0,1,2,3,4,5,6,7,8,9,skip,reverse,draw_two]).
wild_list([kartu(hitam, wild), kartu(hitam, wild_draw_four)]).

generate_kartu_warna([], _, []) :- !.
generate_kartu_warna([Warna|TWarna], JenisList, Result) :-
    kombinasi_jenis(Warna, JenisList, KartuWarna),
    generate_kartu_warna(TWarna, JenisList, Rest),
    append_list(KartuWarna, Rest, Result).

kombinasi_jenis(_, [], []) :- !.
kombinasi_jenis(Warna, [Jenis|TJenis], [kartu(Warna, Jenis)|Rest]) :-
    kombinasi_jenis(Warna, TJenis, Rest).

semua_kartu(SemuaDeck) :-
    warna_list(WList),
    jenis_list(JList),
    wild_list(Wilds),
    generate_kartu_warna(WList, JList, KartuWarna),
    append_list(KartuWarna, Wilds, SemuaDeck).