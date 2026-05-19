%% =============================================================================
%% utils.pl
%% Fungsi pembantu: manipulasi list, pengacakan, format teks, navigasi giliran.
%% =============================================================================

:- module(utils, [
    shuffle/2,
    pick_random/3,
    list_length/2,
    list_member/2,
    list_remove_first/3,
    list_subtract/3,
    list_append_elem/3,
    list_nth/3,
    list_last/2,
    list_unique/2,
    next_player/3,
    prev_player/3,
    format_kartu/2,
    format_list_kartu/2,
    format_urutan/2,
    warna_valid/1,
    jenis_valid/1,
    kartu_angka/1,
    kartu_aksi/1,
    kartu_hitam/1,
    nilai_kartu/2
]).

:- use_module(declarations).

%% =============================================================================
%% Manipulasi List
%% =============================================================================

list_length([], 0).
list_length([_|T], N) :-
    list_length(T, N1),
    N is N1 + 1.

list_member(X, [X|_]).
list_member(X, [_|T]) :- list_member(X, T).

%% Hapus elemen pertama yang cocok
list_remove_first(_, [], []).
list_remove_first(X, [X|T], T) :- !.
list_remove_first(X, [H|T], [H|R]) :-
    list_remove_first(X, T, R).

list_subtract([], _, []).
list_subtract([H|T], L2, R) :-
    list_member(H, L2), !,
    list_remove_first(H, L2, L2Rest),
    list_subtract(T, L2Rest, R).
list_subtract([H|T], L2, [H|R]) :-
    list_subtract(T, L2, R).

list_append_elem(List, Elem, Result) :-
    append(List, [Elem], Result).

list_nth(1, [H|_], H) :- !.
list_nth(N, [_|T], X) :-
    N > 1,
    N1 is N - 1,
    list_nth(N1, T, X).

list_last([X], X) :- !.
list_last([_|T], X) :- list_last(T, X).

%% Hilangkan duplikat, pertahankan urutan
list_unique([], []).
list_unique([H|T], [H|R]) :-
    \+ list_member(H, T), !,
    list_unique(T, R).
list_unique([H|T], R) :-
    list_member(H, T),
    list_unique(T, R).

shuffle(List, Shuffled) :-
    random_permutation(List, Shuffled).

pick_random(List, Elem, Rest) :-
    length(List, Len),
    Len > 0,
    random(0, Len, Idx),
    nth0(Idx, List, Elem),
    list_remove_first(Elem, List, Rest).

%% =============================================================================
%% Navigasi Giliran
%% =============================================================================

%% next_player(+UrutanList, +Current, -Next)
next_player(List, Current, Next) :-
    append(Before, [Current|After], List), !,
    (   After = [Next|_]
    ->  true
    ;   List = [Next|_]
    ).

%% prev_player(+UrutanList, +Current, -Prev)
prev_player(List, Current, Prev) :-
    next_player(List, Prev, Current), !.

%% format_kartu(+Kartu, -Teks)
format_kartu(kartu(Warna, Jenis), Teks) :-
    term_to_atom(Jenis, JenisAtom),
    term_to_atom(Warna, WarnaAtom),
    atomic_list_concat([WarnaAtom, ' ', JenisAtom], Teks).

%% format_list_kartu(+ListKartu, -ListTeks)
format_list_kartu([], []).
format_list_kartu([K|Ks], [T|Ts]) :-
    format_kartu(K, T),
    format_list_kartu(Ks, Ts).

%% format_urutan(+ListNama, -Teks)  contoh: "P1 - P2 - P3"
format_urutan([N], N) :- !.
format_urutan([N|Ns], Teks) :-
    format_urutan(Ns, Rest),
    atomic_list_concat([N, ' - ', Rest], Teks).

