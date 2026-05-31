:- module(gameplay, [
    kartu_bisa_dimainkan/2,
    mainkan_kartu_index/3,
    ambil_kartu/4,
    recycle_deck/0,
    next_giliran/1,
    skip_player/0,
    reverse_direction/0,
    apply_card_effect/2,
    process_mimic/2,
    hitung_poin/2
]).

:- use_module(declarations).
:- use_module(utils).

kartu_bisa_dimainkan(kartu(hitam, Jenis), wild_special) :-
    declarations:discard_pile([Top|_]),
    (   Top = kartu(hitam, _)
    ->  format('Kesalahan: Tidak bisa mengeluarkan kartu hitam di atas kartu hitam!~n', []), fail
    ;   true
    ), !.
kartu_bisa_dimainkan(kartu(W, _), cocok_warna) :-
    declarations:warna_aktif(W), !.
kartu_bisa_dimainkan(kartu(_, J), cocok_jenis) :-
    declarations:discard_pile([kartu(_, J)|_]), !.

next_giliran(Berikutnya) :-
    declarations:giliran(Current),
    declarations:urutan_pemain(Urutan),
    declarations:arah(Arah),
    (   Arah == kanan
    ->  utils:next_player(Urutan, Current, Berikutnya)
    ;   utils:prev_player(Urutan, Current, Berikutnya)
    ),
    retract(declarations:giliran(Current)),
    assertz(declarations:giliran(Berikutnya)),
    retractall(declarations:status_uni(Berikutnya)).

skip_player :-
    next_giliran(_).

reverse_direction :-
    declarations:arah(Arah),
    retract(declarations:arah(Arah)),
    (   Arah == kanan
    ->  assertz(declarations:arah(kiri))
    ;   assertz(declarations:arah(kanan))
    ).

apply_card_effect(kartu(_, skip), _) :-
    format('Pemain berikutnya kehilangan giliran.~n', []),
    skip_player.

apply_card_effect(kartu(_, reverse), _) :-
    format('Arah permainan dibalik!~n', []),
    reverse_direction.

apply_card_effect(kartu(_, draw_two), _) :-
    declarations:giliran(Current),
    declarations:urutan_pemain(Urutan),
    declarations:arah(Arah),
    (   Arah == kanan
    ->  utils:next_player(Urutan, Current, Target)
    ;   utils:prev_player(Urutan, Current, Target)
    ),
    ambil_kartu(Target, 2, 'efek Draw Two', _),
    format('~w terkena penalti Draw Two dan kehilangan giliran.~n', [Target]),
    skip_player.

apply_card_effect(kartu(hitam, wild), _) :-
    assertz(declarations:color_choice_pending).

apply_card_effect(kartu(hitam, wild_draw_four), _) :-
    assertz(declarations:color_choice_pending),
    assertz(declarations:can_challenge(true)).

apply_card_effect(kartu(hitam, mimic), Pemain) :-
    process_mimic(Pemain, Efek),
    (   Efek == none
    ->  assertz(declarations:color_choice_pending)
    ;   true 
    ),
    (   \+ declarations:color_choice_pending
    ->  assertz(declarations:color_choice_pending)
    ;   true
    ).

apply_card_effect(kartu(_, _), _) :- !. 

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
            update_warna_aktif(Kartu),
            (   (utils:kartu_aksi(Kartu) ; utils:kartu_hitam(Kartu))
            ->  retractall(declarations:last_action_card(_)),
                assertz(declarations:last_action_card(Kartu))
            ;   true
            ),
            apply_card_effect(Kartu, Pemain)
        ;  
            fail
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

ambil_kartu(Pemain, N, Alasan, KartuDiambil) :-
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
    assertz(declarations:tangan(Pemain, TanganBaru)),
    format('~w mengambil ~w kartu karena ~w.~n', [Pemain, N, Alasan]).

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




