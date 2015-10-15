:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).
:- use_module(library(http/http_files)).

% ======================== Includes

:-consult(generateBoard).
:-consult(move).
:-consult(randomHeuristic).
:-consult(minmax).

% ======================== Utilitaires

% Operation de deserialisation "elqsjdfml" => [e,l,q,s,j,d,f,m,l]
string_to_list_of_characters(String, Characters) :-
    name(String, Xs),
    maplist( number_to_character,
       Xs, Characters ).

number_to_character(Number, Character) :-
    name(Character, [Number]).
    
% Start Server on port "Port"
server(Port) :-
        http_server(http_dispatch, [port(Port)]).

% Halt Server on port "Port"
halt_server(Port) :- 
	http_stop_server(Port,[]).

% ======================== To serve html, css, json files

:- multifile http:location/3.
:- dynamic   http:location/3.
http:location(files, '/f', []).
:- json_object response(prolog:any).
:- http_handler(files(.), http_reply_from_files('web', []), [prefix]).

% ======================== Routes

% Route pour demander un prochain coup a l IA
% 	ex : localhost:8000/ia?board=webwebbeww&nexPlayer=b
:- http_handler('/ia', ia, []).

% Route pour initialiser la base de faits
% 	ex : localhost:8000/init?nbFloors=8
:- http_handler('/init', init, []).

% Route pour servir le jeu en js
% 	demander simplement localhost:8000/ygame
:- http_handler('/ygame', ygame, [prefix]).

% ======================== Handlers

% Handler pour les fichiers

serve_files(Request) :-
	 http_reply_from_files('web', [], Request).
serve_files(Request) :-
	  http_404([], Request).

% Handler pour servir le jeu par navigateur
ygame(Request) :-
	 http_reply_from_files('web', [], Request).
ygame(Request) :-
	  http_404([], Request).

% Handler pour demander un prochain coup de l IA
ia(Request) :- 
	cors_enable,
	getTurnInfo(Request, Board, NextPlayer),
	play(Board,NextPlayer,NextBoard),	
	atomic_list_concat(NextBoard, ',', NextBoardSerialized),
	prolog_to_json(response(NextBoardSerialized), ResponseSerialized),
	reply_json(ResponseSerialized).
	
getTurnInfo(Request,Board, NextPlayer) :- 
	http_parameters(Request, [board(BoardString, [default(7)])]), string_to_list_of_characters(BoardString, Board),
	http_parameters(Request, [nextPlayer(NextPlayer, [default(7)])]).
	
% Handler pour demander une initialisation de la base de faits
init(Request) :- 
	cors_enable,
	getNbFloors(Request, NbFloors),
	generateGraph(NbFloors),
	prolog_to_json(response('200 OK'), ResponseSerialized),
	reply_json(ResponseSerialized).

getNbFloors(Request,NbFloors) :- http_parameters(Request, [nbFloors(NbFloorsString, [default(7)])]), atom_number(NbFloorsString, NbFloors), !.

% ======================== Auto Launch

:- server(8000).


