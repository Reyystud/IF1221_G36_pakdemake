:- module(gameplay, [
    kartu_bisa_dimainkan/2,
    mainkan_kartu_index/3,
    ambil_kartu/3,
    recycle_deck/0,
    next_giliran/1
]).

:- use_module(declarations).
:- use_module(utils).

kartu_bisa_dimainkan(kartu(hitam, _), wild_always) :- !.
kartu_bisa_dimainkan(kartu(W, _), cocok_warna) :-
    declarations:warna_aktif(W), !.
kartu_bisa_dimainkan(kartu(_, J), cocok_jenis) :-
    declarations:discard_pile([kartu(_, J)|_]), !.

next_giliran(Berikutnya) :-
    declarations:giliran(Current),
    declarations:urutan_pemain(Urutan),
    utils:next_player(Urutan, Current, Berikutnya),
    retract(declarations:giliran(Current)),
    assertz(declarations:giliran(Berikutnya)).

mainkan_kartu_index(Pemain, Index, Kartu) :-
    declarations:tangan(Pemain, Tangan),
    (   nth1(Index, Tangan, Kartu)
    ->  (   kartu_bisa_dimainkan(Kartu, _)
        ->  delete_nth1(Index, Tangan, TanganBaru),
            retract(declarations:tangan(Pemain, Tangan)),
            assertz(declarations:tangan(Pemain, TanganBaru)),
            declarations:discard_pile(Discard),
            retract(declarations:discard_pile(Discard)),
            assertz(declarations:discard_pile([Kartu|Discard])),
            update_warna_aktif(Kartu)
        ;   format('Kartu tidak valid untuk dimainkan.~n', []), fail
        )
    ;   format('Nomor urut kartu tidak valid.~n', []), fail
    ).

delete_nth1(1, [_|T], T) :- !.
delete_nth1(N, [H|T], [H|R]) :-
    N > 1,
    N1 is N - 1,
    delete_nth1(N1, T, R).

update_warna_aktif(kartu(hitam, _)) :- !. 
update_warna_aktif(kartu(W, _)) :-
    retract(declarations:warna_aktif(_)),
    assertz(declarations:warna_aktif(W)).

ambil_kartu(Pemain, N, KartuDiambil) :-
    declarations:draw_pile(Pile),
    length(Pile, Len),
    (   Len < N
    ->  recycle_deck,
        declarations:draw_pile(Pile2),
        ambil_n_kartu(N, Pile2, KartuDiambil, SisaPile)
    ;   ambil_n_kartu(N, Pile, KartuDiambil, SisaPile)
    ),
    retract(declarations:draw_pile(_)),
    assertz(declarations:draw_pile(SisaPile)),
    declarations:tangan(Pemain, TanganLama),
    append(TanganLama, KartuDiambil, TanganBaru),
    retract(declarations:tangan(Pemain, TanganLama)),
    assertz(declarations:tangan(Pemain, TanganBaru)).

ambil_n_kartu(0, Pile, [], Pile) :- !.
ambil_n_kartu(N, [K|Rest], [K|Ambil], Sisa) :-
    N > 0, N1 is N - 1,
    ambil_n_kartu(N1, Rest, Ambil, Sisa).

recycle_deck :-
    declarations:discard_pile([Top|Bekas]),
    utils:shuffle(Bekas, Shuffled),
    retract(declarations:discard_pile(_)),
    assertz(declarations:discard_pile([Top])),
    retract(declarations:draw_pile(_)),
    assertz(declarations:draw_pile(Shuffled)).


