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

