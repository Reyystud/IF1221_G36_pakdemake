:- module(gameplay, [
    kartu_bisa_dimainkan/2,
    mainkan_kartu_index/3,
    ambil_kartu/3,
    recycle_deck/0,
    next_giliran/1,
    skip_player/0,
    reverse_direction/0,
    apply_card_effect/2,
    process_mimic/2,
    hitung_poin/2,
    find_last_non_mimic_action/2,
    godsHand_logic/1,
    sembunyikan_kartu/2,
    tampilkan_kartu/1,
    swap_kartu/4
]).

:- use_module(declarations).
:- use_module(utils).
:- use_module(library(lists)).

kartu_bisa_dimainkan(Kartu, _) :-
    (   Kartu = kartu(hitam, _)
    ->  declarations:discard_pile([Top|_]),
        (   utils:kartu_hitam(Top)
        ->  format('~nKesalahan: Tidak bisa mengeluarkan kartu hitam di atas kartu hitam!~n', []), fail
        ;   true
        )
    ;   Kartu = kartu(W, J),
        (   declarations:warna_aktif(W)
        ->  true
        ;   declarations:discard_pile([Top|_]),
            Top = kartu(_, J)
        ->  true
        ;   format('Kartu tidak valid! Silakan masukkan pilihan kartu kembali.~n', []),
            fail
        )
    ), !.

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
    retractall(declarations:status_uni(Berikutnya)),
    retractall(declarations:swap_used).

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
    ambil_kartu(Target, 2, 'efek Draw Two'),
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

process_mimic(Pemain, copied) :-
    declarations:discard_pile([_|History]),
    find_last_non_mimic_action(History, LastAction),
    !,
    utils:format_kartu(LastAction, Teks),
    format('Menelusuri riwayat permainan...~n', []),
    format('Kartu aksi terakhir yang dimainkan: ~w.~n', [Teks]),
    format('Kartu mimic menyalin efek ~w!~n', [Teks]),
    apply_card_effect(LastAction, Pemain).

process_mimic(_, none) :-
    format('Menelusuri riwayat permainan...~n', []),
    format('Tidak ditemukan kartu aksi sebelumnya. Mimic berlaku sebagai Wild.~n', []).

find_last_non_mimic_action([K|_], K) :-
    K \= kartu(hitam, mimic),
    (utils:kartu_aksi(K) ; utils:kartu_hitam(K)), !.
find_last_non_mimic_action([_|T], K) :-
    find_last_non_mimic_action(T, K).

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

ambil_kartu(Pemain, N, Alasan) :-
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

hitung_poin(Pemain, Poin) :-
    declarations:tangan(Pemain, Tangan),
    (   declarations:kartu_tersembunyi(Pemain, K)
    ->  append(Tangan, [K], FullHand)
    ;   FullHand = Tangan
    ),
    poin_list(FullHand, Poin).

poin_list([], 0).
poin_list([K|Ks], P) :-
    utils:nilai_kartu(K, Nk),
    poin_list(Ks, Rest),
    P is Nk + Rest.

godsHand_logic(triggered(Card, Source, Dest)) :-
    random(0, 100, R),
    R < 20,
    declarations:urutan_pemain(Urutan),
    member(P, Urutan),
    declarations:tangan(P, T), length(T, L), (L > 1 ; declarations:kartu_tersembunyi(P, _)),
    !,
    findall(S, (member(S, Urutan), (declarations:tangan(S, Ts), length(Ts, Ls), Ls > 0)), Sources),
    random_member(Source, Sources),
    declarations:tangan(Source, HandS),
    random_member(Card, HandS),
    delete(Urutan, Source, PotentialDests),
    random_member(Dest, PotentialDests),
    delete(HandS, Card, NewHandS),
    retract(declarations:tangan(Source, HandS)),
    assertz(declarations:tangan(Source, NewHandS)),
    declarations:tangan(Dest, HandD),
    append(HandD, [Card], NewHandD),
    retract(declarations:tangan(Dest, HandD)),
    assertz(declarations:tangan(Dest, NewHandD)).

godsHand_logic(failed).

sembunyikan_kartu(Pemain, Index) :-
    declarations:tangan(Pemain, Tangan),
    length(Tangan, L), L > 1,
    \+ declarations:kartu_tersembunyi(Pemain, _),
    nth1(Index, Tangan, Kartu),
    !,
    delete_nth1(Index, Tangan, TanganBaru),
    retract(declarations:tangan(Pemain, Tangan)),
    assertz(declarations:tangan(Pemain, TanganBaru)),
    assertz(declarations:kartu_tersembunyi(Pemain, Kartu)).

tampilkan_kartu(Pemain) :-
    declarations:kartu_tersembunyi(Pemain, Kartu),
    !,
    retract(declarations:kartu_tersembunyi(Pemain, Kartu)),
    declarations:tangan(Pemain, Tangan),
    append(Tangan, [Kartu], TanganBaru),
    retract(declarations:tangan(Pemain, Tangan)),
    assertz(declarations:tangan(Pemain, TanganBaru)).

swap_kartu(P1, Idx1, P2, Idx2) :-
    declarations:tangan(P1, T1), length(T1, L1), L1 > 1,
    declarations:tangan(P2, T2), length(T2, L2), L2 > 1,
    nth1(Idx1, T1, K1),
    nth1(Idx2, T2, K2),
    !,
    delete_nth1(Idx1, T1, T1R), append(T1R, [K2], T1Final),
    delete_nth1(Idx2, T2, T2R), append(T2R, [K1], T2Final),
    retract(declarations:tangan(P1, T1)), assertz(declarations:tangan(P1, T1Final)),
    retract(declarations:tangan(P2, T2)), assertz(declarations:tangan(P2, T2Final)).
