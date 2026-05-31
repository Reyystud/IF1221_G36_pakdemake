:- module(main, [
    startGame/0,
    mainkanKartu/1,
    ambilKartu/0,
    pilihWarna/1,
    tantang/0,
    uni/1,
    tangkap/1,
    godsHand/0,
    sembunyikanKartu/1,
    tampilkanKartu/0,
    swapKartu/2,
    saveGame/0,
    loadGame/0,
    lihatCommand/0,
    lihatKartu/0,
    cekInfo/0
]).

:- use_module(declarations).
:- use_module(init).
:- use_module(gameplay).
:- use_module(commands).
:- use_module(utils).
:- use_module(library(lists)).

intro_help :-
    commands:lihat_command.

:- initialization(intro_help).

startGame :-
    init:reset_game,
    init:input_mode(Mode),
    init:input_jumlah_pemain(Mode, N),
    init:input_nama_pemain(N, ListNama),
    
    (   Mode == turnamen
    ->  init:setup_teams(ListNama, _),
        UrutanAcak = ListNama
    ;   init:acak_urutan(ListNama, UrutanAcak)
    ),
    
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
    init:setup_state(Mode, UrutanAcak, DrawPile, KartuAwal, WarnaAwal),
    assertz(declarations:game_started),
    
    declarations:giliran(Current),
    format('~nGiliran ~w.~n', [Current]),
    show_turn_notif(Current).

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
        check_win(Pemain)
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
    show_turn_notif(Berikutnya).
pilihWarna(_) :-
    format('Warna tidak valid! Gunakan merah, kuning, hijau, atau biru.~n', []).

ambilKartu :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
ambilKartu :-
    declarations:color_choice_pending, !,
    format('Anda harus memilih warna dahulu!~n', []).
ambilKartu :-
    declarations:giliran(Pemain),
    retractall(declarations:can_challenge(_)),
    gameplay:ambil_kartu(Pemain, 1, 'manual draw'),
    gameplay:next_giliran(Berikutnya),
    format('~nGiliran ~w.~n', [Berikutnya]),
    show_turn_notif(Berikutnya).

godsHand :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
godsHand :-
    declarations:color_choice_pending, !, format('Selesaikan pemilihan warna dahulu.~n', []).
godsHand :-
    gameplay:godsHand_logic(Outcome),
    (   Outcome == triggered(Card, Source, Dest)
    ->  utils:format_kartu(Card, Teks),
        format('~nTuhan telah berkehendak.~n', []),
        format('Kartu ~w milik ~w berpindah ke tangan ~w!~n', [Teks, Source, Dest])
    ;   format('~nTuhan tidak berkehendak gilirannya.~n', [])
    ),
    gameplay:next_giliran(Berikutnya),
    format('~nGiliran ~w.~n', [Berikutnya]),
    show_turn_notif(Berikutnya).

sembunyikanKartu(Index) :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
sembunyikanKartu(Index) :-
    declarations:giliran(Pemain),
    (   gameplay:sembunyikan_kartu(Pemain, Index)
    ->  declarations:kartu_tersembunyi(Pemain, Kartu),
        utils:format_kartu(Kartu, Teks),
        format('Kartu ~w berhasil disembunyikan.~n', [Teks])
    ;   format('Gagal menyembunyikan kartu. (Pastikan kartu > 1 dan belum ada kartu tersembunyi).~n', [])
    ).

tampilkanKartu :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
tampilkanKartu :-
    declarations:giliran(Pemain),
    (   gameplay:tampilkan_kartu(Pemain)
    ->  format('Kartu tersembunyi telah dikembalikan ke tangan.~n', [])
    ;   format('Anda tidak memiliki kartu tersembunyi.~n', [])
    ).

swapKartu(MyIdx, PartIdx) :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
swapKartu(_, _) :-
    declarations:mode(Mode), Mode \= turnamen, !,
    format('Perintah ini hanya tersedia di Mode Turnamen.~n', []).
swapKartu(_, _) :-
    declarations:swap_used, !, format('Anda sudah menggunakan swap kartu giliran ini.~n', []).
swapKartu(MyIdx, PartIdx) :-
    declarations:giliran(Pemain),
    (declarations:tim(1, T1), member(Pemain, T1) -> PartnerList = T1 ; PartnerList = T2, declarations:tim(2, T2)),
    delete(PartnerList, Pemain, [Partner]),
    (   gameplay:swap_kartu(Pemain, MyIdx, Partner, PartIdx)
    ->  format('~w menukar kartu dengan ~w.~n', [Pemain, Partner]),
        format('Pertukaran kartu berhasil.~n', []),
        assertz(declarations:swap_used),
        gameplay:next_giliran(Berikutnya),
        format('~nGiliran ~w.~n', [Berikutnya]),
        show_turn_notif(Berikutnya)
    ;   format('Pertukaran gagal. Pastikan nomor urut valid dan kedua pemain memiliki > 1 kartu.~n', [])
    ).

saveGame :-
    \+ declarations:game_started, !, format('Game belum dimulai.~n', []).
saveGame :-
    (declarations:color_choice_pending ; declarations:can_challenge(_)), !,
    format('Tidak bisa menyimpan saat ada aksi yang harus dipilih.~n', []).
saveGame :-
    format('Masukkan nama file penyimpanan (akhiri dengan titik): ', []),
    read(FileBase),
    atom_concat(FileBase, '.txt', FileName),
    utils:save_to_file(FileName),
    format('Status permainan berhasil disimpan ke ~w.~n', [FileName]).

loadGame :-
    format('Masukkan nama file yang akan dimuat (akhiri dengan titik): ', []),
    read(FileBase),
    atom_concat(FileBase, '.txt', FileName),
    (   exists_file(FileName)
    ->  init:reset_game,
        utils:load_from_file(FileName),
        format('Status permainan berhasil dimuat dari ~w.~n', [FileName]),
        declarations:giliran(G),
        format('Melanjutkan giliran ~w.~n', [G]),
        show_turn_notif(G)
    ;   format('Gagal memuat file ~w. File tidak ditemukan.~n', [FileName])
    ).

tantang :-
    \+ declarations:can_challenge(_), !,
    format('Tidak ada tantangan yang bisa dilakukan saat ini.~n', []).
tantang :-
    declarations:giliran(Challenger),
    declarations:urutan_pemain(Urutan),
    declarations:arah(Arah),
    (   Arah == kanan -> utils:prev_player(Urutan, Challenger, Target) ; utils:next_player(Urutan, Challenger, Target)),
    format('Tantangan dilakukan! Memeriksa kartu ~w...~n', [Target]),
    declarations:discard_pile([_|SisaDiscard]), SisaDiscard = [PrevTop|_],
    utils:get_warna(PrevTop, PrevWarna),
    declarations:tangan(Target, Hand),
    (   (member(kartu(PrevWarna, _), Hand) ; (member(kartu(_, J), Hand), PrevTop = kartu(_, J)))
    ->  format('Tantangan berhasil! ~w memiliki kartu yang cocok.~n', [Target]),
        gameplay:ambil_kartu(Target, 4, 'tantangan berhasil'),
        retractall(declarations:can_challenge(_))
    ;   format('Tantangan gagal. ~w tidak memiliki kartu lain yang cocok.~n', [Target]),
        gameplay:ambil_kartu(Challenger, 6, 'tantangan gagal'),
        retractall(declarations:can_challenge(_)),
        gameplay:skip_player
    ),
    declarations:giliran(Current),
    format('~nGiliran ~w.~n', [Current]),
    show_turn_notif(Current).

uni(Index) :-
    declarations:giliran(Pemain),
    declarations:tangan(Pemain, Tangan),
    length(Tangan, Len),
    (   Len == 2
    ->  assertz(declarations:status_uni(Pemain)),
        format('~w menyerukan UNI!~n', [Pemain]),
        mainkanKartu(Index)
    ;   format('Perintah tidak valid! Anda mendapatkan 1 kartu penalti.~n', []),
        gameplay:ambil_kartu(Pemain, 1, 'penalti salah seru UNI'),
        gameplay:next_giliran(Berikutnya),
        format('~nGiliran ~w.~n', [Berikutnya]),
        show_turn_notif(Berikutnya)
    ).

tangkap(Target) :-
    declarations:giliran(Catcher),
    declarations:tangan(Target, Tangan),
    length(Tangan, Len),
    (   (Len == 1, \+ declarations:status_uni(Target), \+ declarations:kartu_tersembunyi(Target, _))
    ->  format('~w tertangkap tidak menyerukan UNI!~n', [Target]),
        gameplay:ambil_kartu(Target, 2, 'tertangkap tidak UNI'),
        format('~w mendapatkan 2 kartu penalti.~n', [Target])
    ;   (   declarations:kartu_tersembunyi(Target, _)
        ->  format('Terdapat kartu yang disembunyikan oleh ~w.~n', [Target])
        ;   true
        ),
        format('Tuduhan tidak valid! ~w mendapatkan 1 kartu penalti.~n', [Catcher]),
        gameplay:ambil_kartu(Catcher, 1, 'tuduhan tangkap salah')
    ).

show_turn_notif(Pemain) :-
    (   declarations:can_challenge(_)
    ->  format('~w, Anda dapat menggunakan perintah "tantang." atau "ambilKartu."~n', [Pemain])
    ;   true
    ),
    declarations:tangan(Pemain, Hand),
    length(Hand, 2),
    !,
    format('tips: use uni(N) command~n', []).
show_turn_notif(_).

check_win(Pemain) :-
    declarations:tangan(Pemain, Tangan),
    (   Tangan == [], \+ declarations:kartu_tersembunyi(Pemain, _)
    ->  end_game(Pemain)
    ;   (   \+ declarations:color_choice_pending
        ->  gameplay:next_giliran(Berikutnya),
            format('~nGiliran ~w.~n', [Berikutnya]),
            show_turn_notif(Berikutnya)
        ;   format('Silakan pilih warna: ', [])
        )
    ).

end_game(Winner) :-
    format('~n=================================~n', []),
    format('Permainan selesai! ~w menghabiskan semua kartunya!~n', [Winner]),
    format('~nBerikut perhitungan poin sisa kartu:~n', []),
    declarations:urutan_pemain(Urutan),
    maplist(print_poin_pemain, Urutan),
    declarations:mode(Mode),
    (   Mode == turnamen
    ->  declarations:tim(1, Tim1), declarations:tim(2, Tim2),
        poin_tim(Tim1, P1), poin_tim(Tim2, P2),
        format('~nBerikut perhitungan poin untuk masing-masing tim.~n', []),
        format('Tim 1 ~q : ~w poin~n', [Tim1, P1]),
        format('Tim 2 ~q : ~w poin~n', [Tim2, P2]),
        ( P1 < P2 -> format('~nSelamat, Tim 1 menjadi pemenang!~n', []) ; format('~nSelamat, Tim 2 menjadi pemenang!~n', []))
    ;   format('~nSelamat, ~w menjadi pemenang!~n', [Winner])
    ),
    init:reset_game.

poin_tim(PemainList, Total) :-
    maplist(gameplay:hitung_poin, PemainList, PoinList),
    sum_list(PoinList, Total).

print_poin_pemain(P) :-
    gameplay:hitung_poin(P, Poin),
    format('~w: ~w poin~n', [P, Poin]).

lihatCommand :- commands:lihat_command.

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