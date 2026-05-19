%% =============================================================================
%% utils.pl
%% Fungsi pembantu: manipulasi list, pengacakan, format teks, navigasi giliran.
%% =============================================================================

:- module(utils, [
    shuffle/2,
    pick_random/3,
    list_length/2,
    list_member/2,
    list_remove_first/3,
    list_subtract/3,
    list_append_elem/3,
    list_nth/3,
    list_last/2,
    list_unique/2,
    next_player/3,
    prev_player/3,
    format_kartu/2,
    format_list_kartu/2,
    format_urutan/2,
    warna_valid/1,
    jenis_valid/1,
    kartu_angka/1,
    kartu_aksi/1,
    kartu_hitam/1,
    nilai_kartu/2
]).

:- use_module(declarations).

