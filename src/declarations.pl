% DEKLARASI STATE DINAMIS

:- dynamic pemain_list/1.        % pemain_list([p1, p2, ...])
:- dynamic tangan/2.             % tangan(Nama, [kartu(...), ...])
:- dynamic discard_pile/1.       % discard_pile([KartuTop | ...])
:- dynamic draw_pile/1.          % draw_pile([Kartu | ...])
:- dynamic giliran/1.            % giliran(NamaPemain)
:- dynamic arah/1.               % arah(clockwise | counter)
:- dynamic warna_aktif/1.        % warna_aktif(Warna)
:- dynamic game_started/0.
:- dynamic aksi_utama_dilakukan/0.
:- dynamic uni_declared/1.       % uni_declared(NamaPemain)
:- dynamic kartu_tersembunyi/2.  % kartu_tersembunyi(Nama, [Kartu,...])