:- module(commands, [
    lihat_command/0,
    lihat_kartu/1,
    cek_info/0
]).

:- use_module(declarations).
:- use_module(utils).

lihat_command :-
    format('Aksi utama yang tersedia:~n', []),
    format('1. ambilKartu~n', []),
    format('2. mainkanKartu(NomorUrutKartuDiTangan)~n', []),
    format('~nAksi pendukung yang tersedia:~n', []),
    format('1. lihatCommand~n', []),
    format('2. lihatKartu~n', []),
    format('3. cekInfo~n', []).

lihat_kartu(Pemain) :-
    tangan(Pemain, Tangan),
    format('Berikut kartu yang anda miliki.~n', []),
    print_kartu_list(1, Tangan).

print_kartu_list(_, []) :- !.
print_kartu_list(I, [K|Ks]) :-
    utils:format_kartu(K, Teks),
    format('~w. ~w~n', [I, Teks]),
    I1 is I + 1,
    print_kartu_list(I1, Ks).

cek_info :-
    discard_pile([Top|_]),
    utils:format_kartu(Top, TopTeks),
    format('Kartu discard top: ~w.~n', [TopTeks]),
    urutan_pemain(Urutan),
    utils:format_urutan(Urutan, UrutanTeks),
    format('~nUrutan pemain: ~w.~n', [UrutanTeks]),
    print_pemain_info(1, Urutan).

print_pemain_info(_, []) :- !.
print_pemain_info(I, [P|Ps]) :-
    tangan(P, Tangan),
    length(Tangan, Len),
    format('~nNama pemain ~w: ~w~n', [I, P]),
    format('Jumlah kartu : ~w~n', [Len]),
    I1 is I + 1,
    print_pemain_info(I1, Ps).