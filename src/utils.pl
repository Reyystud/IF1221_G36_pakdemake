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
    nilai_kartu/2,
    save_to_file/1,
    load_from_file/1
]).

:- use_module(declarations).

save_to_file(File) :-
    tell(File),
    (declarations:mode(M) -> format('mode(~q).~n', [M]) ; true),
    (declarations:urutan_pemain(U) -> format('urutan_pemain(~q).~n', [U]) ; true),
    (declarations:giliran(G) -> format('giliran(~q).~n', [G]) ; true),
    (declarations:arah(A) -> format('arah(~q).~n', [A]) ; true),
    (declarations:warna_aktif(W) -> format('warna_aktif(~q).~n', [W]) ; true),
    (declarations:discard_pile(D) -> format('discard_pile(~q).~n', [D]) ; true),
    (declarations:draw_pile(P) -> format('draw_pile(~q).~n', [P]) ; true),
    (declarations:last_action_card(La) -> format('last_action_card(~q).~n', [La]) ; true),
    
    % Hands
    forall(declarations:tangan(P, T), format('tangan(~q, ~q).~n', [P, T])),
    
    % Bonus
    forall(declarations:tim(Id, Tp), format('tim(~q, ~q).~n', [Id, Tp])),
    forall(declarations:status_uni(Pu), format('status_uni(~q).~n', [Pu])),
    forall(declarations:kartu_tersembunyi(Pt, Kt), format('kartu_tersembunyi(~q, ~q).~n', [Pt, Kt])),
    
    format('game_started.~n', []),
    told.

load_from_file(File) :-
    open(File, read, Stream),
    load_loop(Stream),
    close(Stream).

load_loop(Stream) :-
    read(Stream, Term),
    (   Term == end_of_file -> true
    ;   assert_term(Term),
        load_loop(Stream)
    ).

assert_term(mode(X)) :- assertz(declarations:mode(X)).
assert_term(urutan_pemain(X)) :- assertz(declarations:urutan_pemain(X)).
assert_term(giliran(X)) :- assertz(declarations:giliran(X)).
assert_term(arah(X)) :- assertz(declarations:arah(X)).
assert_term(warna_aktif(X)) :- assertz(declarations:warna_aktif(X)).
assert_term(discard_pile(X)) :- assertz(declarations:discard_pile(X)).
assert_term(draw_pile(X)) :- assertz(declarations:draw_pile(X)).
assert_term(last_action_card(X)) :- assertz(declarations:last_action_card(X)).
assert_term(tangan(P, T)) :- assertz(declarations:tangan(P, T)).
assert_term(tim(I, L)) :- assertz(declarations:tim(I, L)).
assert_term(status_uni(P)) :- assertz(declarations:status_uni(P)).
assert_term(kartu_tersembunyi(P, K)) :- assertz(declarations:kartu_tersembunyi(P, K)).
assert_term(game_started) :- assertz(declarations:game_started).
assert_term(_) :- true. 

list_length([], 0).
list_length([_|T], N) :-
    list_length(T, N1),
    N is N1 + 1.

list_member(X, [X|_]).
list_member(X, [_|T]) :- list_member(X, T).

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

%% next_player(+UrutanList, +Current, -Next)
next_player(List, Current, Next) :-
    append(_, [Current|After], List), !,
    (   After = [Next|_]
    ->  true
    ;   List = [Next|_]
    ).

%% prev_player(+UrutanList, +Current, -Prev)
prev_player(List, Current, Prev) :-
    next_player(List, Prev, Current), !.
 
%% format_kartu(+Kartu, -Teks)
format_kartu(kartu(hitam, Jenis), Teks) :-
    term_to_atom(Jenis, JenisAtom),
    atomic_list_concat(['hitam-', JenisAtom], Teks), !.
format_kartu(kartu(Warna, Jenis), Teks) :-
    term_to_atom(Jenis, JenisAtom),
    term_to_atom(Warna, WarnaAtom),
    atomic_list_concat([WarnaAtom, '-', JenisAtom], Teks).

%% format_list_kartu(+ListKartu, -ListTeks)
format_list_kartu([], []).
format_list_kartu([K|Ks], [T|Ts]) :-
    format_kartu(K, T),
    format_list_kartu(Ks, Ts).

%% get_warna(+Kartu, -Warna)
get_warna(kartu(W, _), W).
 
%% format_urutan(+ListNama, -Teks)  contoh: "P1 - P2 - P3"
format_urutan([N], N) :- !.
format_urutan([N|Ns], Teks) :-
    format_urutan(Ns, Rest),
    atomic_list_concat([N, ' - ', Rest], Teks).
 
warna_valid(merah).
warna_valid(kuning).
warna_valid(hijau).
warna_valid(biru).

jenis_valid(J) :- integer(J), J >= 0, J =< 9.
jenis_valid(skip).
jenis_valid(reverse).
jenis_valid(draw_two).
jenis_valid(wild).
jenis_valid(wild_draw_four).

kartu_angka(kartu(W, J)) :-
    warna_valid(W),
    integer(J),
    J >= 0, J =< 9.
 
kartu_aksi(kartu(W, skip))     :- warna_valid(W).
kartu_aksi(kartu(W, reverse))  :- warna_valid(W).
kartu_aksi(kartu(W, draw_two)) :- warna_valid(W).
 
kartu_hitam(kartu(hitam, wild)).
kartu_hitam(kartu(hitam, wild_draw_four)).
 
%% nilai_kartu(+Kartu, -Nilai) — untuk perhitungan skor
nilai_kartu(kartu(_, J), J)       :- integer(J), !.
nilai_kartu(kartu(_, skip),     20).
nilai_kartu(kartu(_, reverse),  20).
nilai_kartu(kartu(_, draw_two), 20).
nilai_kartu(kartu(hitam, wild),           50).
nilai_kartu(kartu(hitam, wild_draw_four), 50).