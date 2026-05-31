:- module(gameplay, [
    kartu_bisa_dimainkan/2,
    mainkan_kartu_index/3,
    ambil_kartu/3,
    recycle_deck/0,
    next_giliran/1
]).

:- use_module(declarations).
:- use_module(utils).

%% kartu_bisa_dimainkan(+Kartu, -Alasan)
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




