:- module(declarations, [
    game_started/0,
    urutan_pemain/1,
    giliran/1,
    arah/1,
    tangan/2,
    draw_pile/1,
    discard_pile/1,
    warna_aktif/1,
    pending_draw/1,
    last_action_card/1,
    status_uni/1,
    can_challenge/1,
    color_choice_pending/0,
    mode/1,
    tim/2,
    kartu_tersembunyi/2,
    swap_used/0
]).

:- dynamic game_started/0.        
:- dynamic urutan_pemain/1.         
:- dynamic giliran/1.               
:- dynamic arah/1.                  
:- dynamic tangan/2.                
:- dynamic draw_pile/1.             
:- dynamic discard_pile/1.         
:- dynamic warna_aktif/1.           
:- dynamic pending_draw/1.         
:- dynamic last_action_card/1.     
:- dynamic status_uni/1.           
:- dynamic can_challenge/1.        
:- dynamic color_choice_pending/0. 
:- dynamic mode/1.                 
:- dynamic tim/2.                  
:- dynamic kartu_tersembunyi/2.    
:- dynamic swap_used/0.         


