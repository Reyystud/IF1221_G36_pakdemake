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

mainkanKartu(Index) :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
mainkanKartu(_) :-
    declarations:color_choice_pending, !,
    format('Anda harus memilih warna dahulu! Gunakan pilihWarna(Warna).~n', []).
mainkanKartu(Index) :-
    declarations:giliran(Pemain),
    (   gameplay:mainkan_kartu_index(Pemain, Index, Kartu)
    ->  utils:format_kartu(Kartu, Teks),
        format('~n~w memainkan kartu: ~w.~n', [Pemain, Teks]),
        
        declarations:tangan(Pemain, Tangan),
        (   Tangan == []
        ->  end_game(Pemain)
        ;  
            (   \+ declarations:color_choice_pending
            ->  gameplay:next_giliran(Berikutnya),
                format('~nGiliran ~w.~n', [Berikutnya]),
                check_tantang_notif(Berikutnya)
            ;   format('Silakan pilih warna: ', [])
            )
        )
    ;   true
    ).

pilihWarna(Warna) :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
pilihWarna(_) :-
    \+ declarations:color_choice_pending, !,
    format('Tidak ada pemilihan warna yang tertunda.~n', []).
pilihWarna(Warna) :-
    utils:warna_valid(Warna), !,
    retract(declarations:warna_aktif(_)),
    assertz(declarations:warna_aktif(Warna)),
    retractall(declarations:color_choice_pending),
    format('Warna aktif sekarang: ~w.~n', [Warna]),
    gameplay:next_giliran(Berikutnya),
    format('~nGiliran ~w.~n', [Berikutnya]),
    check_tantang_notif(Berikutnya).
pilihWarna(_) :-
    format('Warna tidak valid! Gunakan merah, kuning, hijau, atau biru.~n', []).

tantang :-
    \+ declarations:can_challenge(_), !,
    format('Tidak ada tantangan yang bisa dilakukan saat ini.~n', []).
tantang :-
    declarations:giliran(Challenger),
    declarations:urutan_pemain(Urutan),
    declarations:arah(Arah),
    (   Arah == kanan
    ->  utils:prev_player(Urutan, Challenger, Target)
    ;   utils:next_player(Urutan, Challenger, Target)
    ),
    format('Tantangan dilakukan! Memeriksa kartu ~w...~n', [Target]),
    declarations:discard_pile([_|SisaDiscard]),
    SisaDiscard = [PrevTop|_],
    utils:get_warna(PrevTop, PrevWarna),
    declarations:tangan(Target, Hand),
    (   (member(kartu(PrevWarna, _), Hand) ; member(kartu(_, J), Hand), PrevTop = kartu(_, J))
    ->  format('Tantangan berhasil! ~w memiliki kartu yang cocok.~n', [Target]),
        gameplay:ambil_kartu(Target, 4, 'tantangan berhasil', _),
        retractall(declarations:can_challenge(_))
    ;   format('Tantangan gagal. ~w tidak memiliki kartu lain yang cocok.~n', [Target]),
        gameplay:ambil_kartu(Challenger, 6, 'tantangan gagal', _),
        retractall(declarations:can_challenge(_)),
        gameplay:skip_player
    ),
    declarations:giliran(Current),
    format('~nGiliran ~w.~n', [Current]).

uni(Index) :-
    declarations:giliran(Pemain),
    declarations:tangan(Pemain, Tangan),
    length(Tangan, Len),
    (   Len == 2
    ->  assertz(declarations:status_uni(Pemain)),
        format('~w menyerukan UNI!~n', [Pemain]),
        mainkanKartu(Index)
    ;   format('Perintah tidak valid! Anda mendapatkan 1 kartu penalti.~n', []),
        gameplay:ambil_kartu(Pemain, 1, 'penalti salah seru UNI', _),
        gameplay:next_giliran(Berikutnya),
        format('~nGiliran ~w.~n', [Berikutnya])
    ).

tangkap(Target) :-
    declarations:giliran(Catcher),
    declarations:tangan(Target, Tangan),
    length(Tangan, Len),
    (   Len == 1, \+ declarations:status_uni(Target)
    ->  format('~w tertangkap tidak menyerukan UNI!~n', [Target]),
        gameplay:ambil_kartu(Target, 2, 'tertangkap tidak UNI', _),
        format('~w mendapatkan 2 kartu penalti.~n', [Target])
    ;   format('Tuduhan tidak valid! ~w mendapatkan 1 kartu penalti.~n', [Catcher]),
        gameplay:ambil_kartu(Catcher, 1, 'tuduhan tangkap salah', _)
    ).

check_tantang_notif(Pemain) :-
    (   declarations:can_challenge(_)
    ->  format('~w, Anda dapat menggunakan perintah "tantang." atau "ambilKartu."~n', [Pemain])
    ;   true
    ).

end_game(Winner) :-
    format('~n=================================~n', []),
    format('Permainan selesai! ~w menghabiskan semua kartunya!~n', [Winner]),
    format('~nBerikut perhitungan poin sisa kartu:~n', []),
    declarations:urutan_pemain(Urutan),
    maplist(print_poin_pemain, Urutan),
    format('~nSelamat, ~w menjadi pemenang!~n', [Winner]),
    init:reset_game.

print_poin_pemain(P) :-
    gameplay:hitung_poin(P, Poin),
    format('~w: ~w poin~n', [P, Poin]).

lihatCommand :- intro_help.

ambilKartu :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
ambilKartu :-
    declarations:color_choice_pending, !,
    format('Anda harus memilih warna dahulu!~n', []).
ambilKartu :-
    declarations:giliran(Pemain),
    retractall(declarations:can_challenge(_)),
    gameplay:ambil_kartu(Pemain, 1, 'manual draw', _),
    gameplay:next_giliran(Berikutnya),
    format('~nGiliran ~w.~n', [Berikutnya]).

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
