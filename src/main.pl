:- module(main, [
    startGame/0,
    mainkanKartu/1,
    ambilKartu/0,
    pilihWarna/1,
    tantang/0,
    uni/1,
    tangkap/1,
    lihatCommand/0,
    lihatKartu/0,
    cekInfo/0
]).

:- use_module(declarations).
:- use_module(init).
:- use_module(gameplay).
:- use_module(commands).
:- use_module(utils).

intro_help :-
    format('~n=================================~n', []),
    format('  UNI Card Game - Prolog Edition ~n', []),
    format('  IF1221 Logika Komputasional    ~n', []),
    format('=================================~n', []),
    format('Selamat datang! Perintah tersedia:~n', []),
    format('1. startGame.          - Memulai permainan baru.~n', []),
    format('2. mainkanKartu(N).    - Memainkan kartu indeks ke-N.~n', []),
    format('3. ambilKartu.         - Mengambil kartu (sesuai penalti jika ada).~n', []),
    format('4. pilihWarna(W).      - Memilih warna (merah,kuning,hijau,biru).~n', []),
    format('5. tantang.            - Menantang Wild Draw Four lawan.~n', []),
    format('6. uni(N).             - Mainkan kartu ke-N dan serukan UNI!~n', []),
    format('7. tangkap(P).         - Tangkap pemain P yang lupa UNI.~n', []),
    format('8. lihatKartu.         - Melihat kartu di tangan.~n', []),
    format('9. cekInfo.            - Melihat status permainan.~n', []),
    format('10. lihatCommand.      - Menampilkan bantuan ini.~n', []),
    format('~nKetik "startGame." untuk memulai.~n~n', []).

:- initialization(intro_help).

startGame :-
    init:reset_game,
    init:input_jumlah_pemain(N),
    init:input_nama_pemain(N, ListNama),
    init:acak_urutan(ListNama, UrutanAcak),
    utils:format_urutan(UrutanAcak, UrutanTeks),
    format('~nUrutan pemain: ~w.~n', [UrutanTeks]),
    
    init:buat_deck(Deck),
    init:shuffle_deck(Deck, ShuffledDeck),
    init:bagikan_kartu(UrutanAcak, ShuffledDeck, SisaDeck),
    format('~nSetiap pemain mendapatkan 7 kartu acak.~n', []),
    
    init:inisiasi_discard(SisaDeck, KartuAwal, DrawPile),
    utils:format_kartu(KartuAwal, TopTeks),
    format('~nKartu discard top: ~w.~n', [TopTeks]),
    
    utils:get_warna(KartuAwal, WarnaAwal),
    init:setup_state(UrutanAcak, DrawPile, KartuAwal, WarnaAwal),
    assertz(declarations:game_started),
    
    declarations:giliran(Current),
    format('~nGiliran ~w.~n', [Current]).

lihatCommand :- intro_help.

lihatKartu :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
lihatKartu :-
    declarations:giliran(Pemain),
    commands:lihat_kartu(Pemain).

cekInfo :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
cekInfo :-
    commands:cek_info,
    declarations:draw_pile(Pile),
    length(Pile, Len),
    format('Jumlah kartu di deck: ~w~n', [Len]).
