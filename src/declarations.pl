:- module(declarations, [
    game_started/0,
    urutan_pemain/1,
    giliran/1,
    tangan/2,
    draw_pile/1,
    discard_pile/1,
    warna_aktif/1
]).

:- dynamic game_started/0.        
:- dynamic urutan_pemain/1.         
:- dynamic giliran/1.               
:- dynamic tangan/2.                
:- dynamic draw_pile/1.             
:- dynamic discard_pile/1.         
:- dynamic warna_aktif/1.           
