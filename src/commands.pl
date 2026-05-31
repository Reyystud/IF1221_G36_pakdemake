:- module(commands, [
    lihat_command/0,
    lihat_kartu/1,
    cek_info/0
]).

:- use_module(declarations).
:- use_module(utils).
:- use_module(library(lists)).

lihat_command :-
    format('Aksi utama yang tersedia:~n', []),
    format('1. mainkanKartu(N).    - Memainkan kartu indeks ke-N.~n', []),
    format('2. ambilKartu.         - Mengambil kartu (sesuai penalti jika ada).~n', []),
    
    format('~nAksi tambahan yang tersedia:~n', []),
    format('1. godsHand.           - Kejadian acak (miracle).~n', []),
    format('2. sembunyikanKartu(N) - Sembunyikan kartu ke-N.~n', []),
    format('3. tampilkanKartu.     - Munculkan kartu tersembunyi.~n', []),
    
    (   declarations:mode(turnamen)
    ->  format('11. swapKartu(N, M).   - [BONUS] Tukar kartu dengan teman tim.~n', [])
    ;   true
    ),
    
    format('1. saveGame.          - Simpan kondisi permainan.~n', []),
    format('2. loadGame.          - Muat kondisi permainan.~n', []),
    
    format('~nAksi pendukung yang tersedia:~n', []),
    format('1. lihatCommand.       - Menampilkan bantuan ini.~n', []),
    format('2. lihatKartu.         - Melihat kartu di tangan.~n', []),
    format('3. cekInfo.            - Melihat status permainan.~n', []).

lihat_kartu(Pemain) :-
    declarations:tangan(Pemain, Tangan),
    format('Berikut kartu yang anda miliki.~n', []),
    print_kartu_list(1, Tangan),
    (   declarations:kartu_tersembunyi(Pemain, K)
    ->  utils:format_kartu(K, Teks),
        format('~n[TERSEMBUNYI] ~w~n', [Teks])
    ;   true
    ),
    
    declarations:mode(Mode),
    (   Mode == turnamen
    ->  (   (declarations:tim(1, T1), member(Pemain, T1)) -> Team = T1 
        ;   (declarations:tim(2, T2), member(Pemain, T2)) -> Team = T2 
        ),
        delete(Team, Pemain, [Partner]),
        declarations:tangan(Partner, PartnerTangan),
        format('~nBerikut kartu yang teman satu tim anda miliki (~w).~n', [Partner]),
        print_kartu_list(1, PartnerTangan)
    ;   true
    ).

print_kartu_list(_, []) :- !.
print_kartu_list(I, [K|Ks]) :-
    utils:format_kartu(K, Teks),
    format('~w. ~w~n', [I, Teks]),
    I1 is I + 1,
    print_kartu_list(I1, Ks).

cek_info :-
    declarations:discard_pile([Top|_]),
    utils:format_kartu(Top, TopTeks),
    format('Kartu discard top: ~w.~n', [TopTeks]),
    
    declarations:mode(Mode),
    (   Mode == turnamen
    ->  declarations:tim(1, Tim1), declarations:tim(2, Tim2),
        format('Tim 1 : ~q~n', [Tim1]),
        format('Tim 2 : ~q~n', [Tim2])
    ;   true
    ),
    
    declarations:urutan_pemain(Urutan),
    utils:format_urutan(Urutan, UrutanTeks),
    format('~nUrutan pemain: ~w.~n', [UrutanTeks]),
    declarations:giliran(Giliran),
    format('Giliran: ~w.~n', [Giliran]),
    print_pemain_info(1, Urutan).

print_pemain_info(_, []) :- !.
print_pemain_info(I, [P|Ps]) :-
    declarations:tangan(P, Tangan),
    length(Tangan, Len),
    format('~nNama pemain ~w: ~w~n', [I, P]),
    format('Jumlah kartu : ~w~n', [Len]),
    I1 is I + 1,
    print_pemain_info(I1, Ps).
