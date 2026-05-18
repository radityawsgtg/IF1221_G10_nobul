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
select_element(Element, [Head|Tail], [Head|Result]) :- 
    select_element(Element, Tail, Result).