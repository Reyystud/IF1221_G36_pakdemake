:- module(init, [
    buat_deck/1,
    shuffle_deck/2,
    input_mode/1,
    input_jumlah_pemain/2,
    input_nama_pemain/2,
    acak_urutan/2,
    bagikan_kartu/3,
    inisiasi_discard/3,
    setup_state/5,
    reset_game/0,
    setup_teams/2
]).

:- use_module(declarations).
:- use_module(utils). 

reset_game :-
    retractall(declarations:game_started),
    retractall(declarations:urutan_pemain(_)),
    retractall(declarations:giliran(_)),
    retractall(declarations:arah(_)),
    retractall(declarations:tangan(_, _)),
    retractall(declarations:draw_pile(_)),
    retractall(declarations:discard_pile(_)),
    retractall(declarations:warna_aktif(_)),
    retractall(declarations:pending_draw(_)),
    retractall(declarations:last_action_card(_)),
    retractall(declarations:status_uni(_)),
    retractall(declarations:can_challenge(_)),
    retractall(declarations:color_choice_pending),
    retractall(declarations:mode(_)),
    retractall(declarations:tim(_, _)),
    retractall(declarations:kartu_tersembunyi(_, _)),
    retractall(declarations:swap_used).

buat_deck(Deck) :-
    findall(kartu(W, J),
        (utils:warna_valid(W), between(0, 9, J)),
        Angka40),
    findall(kartu(W, skip),    utils:warna_valid(W), Skip4),
    findall(kartu(W, skip),    utils:warna_valid(W), Skip4b),
    findall(kartu(W, reverse), utils:warna_valid(W), Rev4),
    findall(kartu(W, reverse), utils:warna_valid(W), Rev4b),
    findall(kartu(W, draw_two),utils:warna_valid(W), DT4),
    findall(kartu(W, draw_two),utils:warna_valid(W), DT4b),
    Wild4     = [kartu(hitam,wild),kartu(hitam,wild),
                 kartu(hitam,wild),kartu(hitam,wild)],
    WD4_4     = [kartu(hitam,wild_draw_four),kartu(hitam,wild_draw_four),
                 kartu(hitam,wild_draw_four),kartu(hitam,wild_draw_four)],
    Mimic4    = [kartu(hitam,mimic),kartu(hitam,mimic),
                 kartu(hitam,mimic),kartu(hitam,mimic)],
    append(Angka40, Skip4,   D1),
    append(D1,  Skip4b,  D2),
    append(D2,  Rev4,    D3),
    append(D3,  Rev4b,   D4),
    append(D4,  DT4,     D5),
    append(D5,  DT4b,    D6),
    append(D6,  Wild4,   D7),
    append(D7,  WD4_4,   D8),
    append(D8,  Mimic4,  Deck).

shuffle_deck(Deck, Shuffled) :-
    utils:shuffle(Deck, Shuffled).

input_mode(Mode) :-
    format('Tersedia 2 mode permainan.~n', []),
    format('1. Mode klasik~n', []),
    format('2. Mode turnamen~n', []),
    format('~nPilih mode permainan (akhiri dengan titik): ', []),
    read(Input),
    (   Input == 1 -> Mode = klasik, format('~nPermainan dimulai dalam mode klasik.~n', [])
    ;   Input == 2 -> Mode = turnamen, format('~nPermainan dimulai dalam mode turnamen.~n', [])
    ;   format('Pilihan tidak valid. Silakan pilih 1 atau 2.~n', []), input_mode(Mode)
    ).

input_jumlah_pemain(Mode, N) :-
    (   Mode == turnamen
    ->  N = 4, format('Mode turnamen memerlukan 4 pemain.~n', [])
    ;   format('Masukkan jumlah pemain: ', []),
        read(Input),
        (   integer(Input), Input >= 2, Input =< 4
        ->  N = Input
        ;   format('Mohon masukkan angka antara 2 - 4.~n', []),
            input_jumlah_pemain(Mode, N)
        )
    ).

input_nama_pemain(N, ListNama) :-
    input_nama_loop(1, N, [], ListNama).

input_nama_loop(I, N, Acc, ListNama) :-
    I =< N, !,
    format('Masukkan nama pemain ~w.: ', [I]),
    read(Nama),
    (   atom(Nama), \+ utils:list_member(Nama, Acc)
    ->  I1 is I + 1,
        input_nama_loop(I1, N, [Nama|Acc], ListNama)
    ;   (   \+ atom(Nama)
        ->  format('Nama tidak valid.~n', [])
        ;   format('Nama sudah digunakan. Masukkan nama lain.~n', [])
        ),
        input_nama_loop(I, N, Acc, ListNama)
    ).
input_nama_loop(_, _, Acc, ListNama) :-
    reverse(Acc, ListNama).

acak_urutan(ListNama, Shuffled) :-
    utils:shuffle(ListNama, Shuffled).

setup_teams(ListNama, [Tim1, Tim2]) :-
    utils:shuffle(ListNama, Shuffled),
    Tim1 = [P1, P2], Tim2 = [P3, P4],
    append(Tim1, [], Tim1),
    append(Tim2, [], Tim2),
    Shuffled = [P1, P2, P3, P4],
    assertz(declarations:tim(1, Tim1)),
    assertz(declarations:tim(2, Tim2)),
    format('~nMembentuk tim secara acak...~n', []),
    format('~nTim 1 : ~w, ~w~n', [P1, P2]),
    format('Tim 2 : ~w, ~w~n', [P3, P4]).

bagikan_kartu([], Deck, Deck).
bagikan_kartu([P|Ps], Deck, SisaDeck) :-
    ambil_n(7, Deck, Tangan7, DeckSetelah),
    assertz(declarations:tangan(P, Tangan7)),
    bagikan_kartu(Ps, DeckSetelah, SisaDeck).

ambil_n(0, Deck, [], Deck) :- !.
ambil_n(N, [K|Rest], [K|Kartu], Sisa) :-
    N > 0,
    N1 is N - 1,
    ambil_n(N1, Rest, Kartu, Sisa).

inisiasi_discard_loop([K|Rest], K, Rest) :-
    utils:kartu_angka(K), !.
inisiasi_discard_loop([_|Rest], K, DrawPile) :-
    inisiasi_discard_loop(Rest, K, DrawPile).

inisiasi_discard(SisaDeck, KartuAwal, DrawPile) :-
    inisiasi_discard_loop(SisaDeck, KartuAwal, DrawPile).

setup_state(Mode, UrutanAcak, DrawPile, KartuAwal, WarnaAwal) :-
    assertz(declarations:mode(Mode)),
    assertz(declarations:urutan_pemain(UrutanAcak)),
    UrutanAcak = [PemainPertama|_],
    assertz(declarations:giliran(PemainPertama)),
    assertz(declarations:arah(kanan)),
    assertz(declarations:warna_aktif(WarnaAwal)),
    assertz(declarations:draw_pile(DrawPile)),
    assertz(declarations:discard_pile([KartuAwal])),
    assertz(declarations:pending_draw(0)),
    assertz(declarations:last_action_card(none)).