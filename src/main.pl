% Deklarasi dynamic state global
:- dynamic pemain_list/1.
:- dynamic urutan_pemain/1.
:- dynamic giliran_sekarang/1.
:- dynamic kartu_tangan/2.
:- dynamic discard_top/1.
:- dynamic arah_permainan/1.
:- dynamic warna_aktif/1.
:- dynamic efek_kartu_pending/1.
:- dynamic status_UNI/1.

% Include modul
:- include ('state.pl').
:- include ('setup.pl').
:- include ('aksi.pl').
:- include ('perintah.pl').

% Start game
:- initialization(main).