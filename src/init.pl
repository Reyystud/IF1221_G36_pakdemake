:- module(init, [
    buat_deck/1,
    shuffle_deck/2,
    input_jumlah_pemain/1,
    input_nama_pemain/2,
    acak_urutan/2,
    bagikan_kartu/3,
    inisiasi_discard/3,
    setup_state/4,
    reset_game/0
]).

:- use_module(declarations).
:- use_module(utils).

reset_game :-
    retractall(declarations:game_started),
    retractall(declarations:urutan_pemain(_)),
    retractall(declarations:giliran(_)),
    retractall(declarations:tangan(_, _)),
    retractall(declarations:draw_pile(_)),
    retractall(declarations:discard_pile(_)),
    retractall(declarations:warna_aktif(_)).

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
    append(Angka40, Skip4,   D1),
    append(D1,  Skip4b,  D2),
    append(D2,  Rev4,    D3),
    append(D3,  Rev4b,   D4),
    append(D4,  DT4,     D5),
    append(D5,  DT4b,    D6),
    append(D6,  Wild4,   D7),
    append(D7,  WD4_4,   Deck).

shuffle_deck(Deck, Shuffled) :-
    utils:shuffle(Deck, Shuffled).

input_jumlah_pemain(N) :-
    format('Masukkan jumlah pemain (2-4, akhiri dengan titik): ', []),
    read(Input),
    (   integer(Input), Input >= 2, Input =< 4
    ->  N = Input
    ;   format('Mohon masukkan angka antara 2 - 4.~n', []),
        input_jumlah_pemain(N)
    ).

input_nama_pemain(N, ListNama) :-
    input_nama_loop(1, N, [], ListNama).

input_nama_loop(I, N, Acc, ListNama) :-
    I =< N, !,
    format('Masukkan nama pemain ~w (akhiri dengan titik, gunakan petik jika kapital, contoh: steven. atau \'Steven\'.): ', [I]),
    read(Nama),
    (   atom(Nama), \+ utils:list_member(Nama, Acc)
    ->  I1 is I + 1,
        input_nama_loop(I1, N, [Nama|Acc], ListNama)
    ;   (   \+ atom(Nama)
        ->  format('Nama tidak valid (gunakan huruf kecil atau tanda petik, akhiri dengan titik).~n', [])
        ;   format('Nama sudah digunakan. Masukkan nama lain.~n', [])
        ),
        input_nama_loop(I, N, Acc, ListNama)
    ).
input_nama_loop(_, _, Acc, ListNama) :-
    reverse(Acc, ListNama).

acak_urutan(ListNama, Shuffled) :-
    utils:shuffle(ListNama, Shuffled).

