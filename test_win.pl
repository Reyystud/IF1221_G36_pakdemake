
:- [src/main].

% Helper untuk reset state
reset_all :-
    retractall(declarations:game_started),
    retractall(declarations:mode(_)),
    retractall(declarations:urutan_pemain(_)),
    retractall(declarations:giliran(_)),
    retractall(declarations:arah(_)),
    retractall(declarations:warna_aktif(_)),
    retractall(declarations:tangan(_, _)),
    retractall(declarations:draw_pile(_)),
    retractall(declarations:discard_pile(_)),
    retractall(declarations:pending_draw(_)),
    retractall(declarations:last_action_card(_)),
    retractall(declarations:status_uni(_)),
    retractall(declarations:can_challenge(_)),
    retractall(declarations:color_choice_pending),
    retractall(declarations:kartu_tersembunyi(_, _)).

% Skenario 1: Pemain menang (tangan kosong dan tidak ada kartu tersembunyi)
setup_test_win :-
    reset_all,
    assertz(declarations:game_started),
    assertz(declarations:mode(klasik)),
    assertz(declarations:urutan_pemain([p1, p2])),
    assertz(declarations:giliran(p1)),
    assertz(declarations:arah(kanan)),
    assertz(declarations:warna_aktif(merah)),
    assertz(declarations:tangan(p1, [kartu(merah, 1)])),
    assertz(declarations:tangan(p2, [kartu(biru, 2)])),
    assertz(declarations:draw_pile([kartu(hijau, 3)])),
    assertz(declarations:discard_pile([kartu(merah, 0)])),
    assertz(declarations:pending_draw(0)),
    assertz(declarations:last_action_card(none)).

run_test_win :-
    setup_test_win,
    format('~n>>> MENJALANKAN TEST CASE: PEMAIN MENANG <<<~n', []),
    format('--- Keadaan Awal ---~n', []),
    cekInfo,
    format('~n--- p1 memainkan kartu terakhirnya (merah 1) ---~n', []),
    mainkanKartu(1),
    (   \+ declarations:game_started
    ->  format('~n[RESULT] TEST SUCCESS: Permainan berakhir dan status direset.~n', [])
    ;   format('~n[RESULT] TEST FAILED: Permainan masih berjalan.~n', [])
    ).

% Skenario 2: Tangan kosong tapi ada kartu tersembunyi (belum menang)
setup_test_hidden_card :-
    setup_test_win,
    assertz(declarations:kartu_tersembunyi(p1, kartu(biru, 5))).

run_test_hidden_card :-
    setup_test_hidden_card,
    format('~n>>> MENJALANKAN TEST CASE: TANGAN KOSONG TAPI ADA KARTU TERSEMBUNYI <<<~n', []),
    format('--- Keadaan Awal ---~n', []),
    cekInfo,
    format('~n--- p1 memainkan kartu terakhir di tangan, tapi punya kartu tersembunyi ---~n', []),
    mainkanKartu(1),
    (   declarations:game_started
    ->  format('~n[RESULT] TEST SUCCESS: Permainan berlanjut (p1 belum menang).~n', [])
    ;   format('~n[RESULT] TEST FAILED: Permainan berakhir padahal masih ada kartu tersembunyi.~n', [])
    ).

run_all_tests :-
    run_test_win,
    run_test_hidden_card.

:- format('~nKetik "run_test_win." untuk test menang.~n', []),
   format('Ketik "run_test_hidden_card." untuk test belum menang (ada kartu tersembunyi).~n', []),
   format('Ketik "run_all_tests." untuk menjalankan semua test.~n', []).
