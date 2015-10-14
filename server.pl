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

:-consult(generateBoard).
:-consult(move).
:-consult(randomHeuristic).
:-consult(minmax).

:- multifile http:location/3.
:- dynamic   http:location/3.

http:location(files, '/f', []).

:- http_handler('/ia', ygame, []).
:- http_handler('/init', init, []).
:- http_handler('/ok', test, []).
:- http_handler('/ygame', indexGame, [prefix]).

:- http_handler(files(.), http_reply_from_files('web', []), [prefix]).

:- json_object
	response(prolog:any).


% Start Server on port "Port"
server(Port) :-
        http_server(http_dispatch, [port(Port)]).

% Halt Server on port "Port"
halt_server(Port) :- 
	http_stop_server(Port,[]).

test(_) :- cors_enable, reply_json('ok').

indexGame(Request) :-
	 http_reply_from_files('web', [], Request).
indexGame(Request) :-
	  http_404([], Request).

serve_files(Request) :-
	 http_reply_from_files('web', [], Request).
serve_files(Request) :-
	  http_404([], Request).

% To be upgraded
ygame(Request) :- 
	cors_enable,
	getTurnInfo(Request, Board, NextPlayer),
	play(Board,NextPlayer,NextBoard),	
	atomic_list_concat(NextBoard, ',', NextBoardSerialized),
	prolog_to_json(response(NextBoardSerialized), ResponseSerialized),
	reply_json(ResponseSerialized).
	%reply_json('ok').
	%reply_json(BoxPlayed).
	
	
init(Request) :- 
	cors_enable,
	getNbFloors(Request, NbFloors),
	generateGraph(NbFloors),
	reply_json('{status="200 OK"}').


% To be upgraded
getTurnInfo(Request,Board, NextPlayer) :- 
	http_parameters(Request, [board(BoardString, [default(7)])]), string_to_list_of_characters(BoardString, Board),
	http_parameters(Request, [nextPlayer(NextPlayer, [default(7)])]).
	

getNbFloors(Request,NbFloors) :- http_parameters(Request, [nbFloors(NbFloorsString, [default(7)])]), atom_number(NbFloorsString, NbFloors), !.

%atomic_list_concat([d,z,f,s,g,hhj,ddf,d,s,ss,f],'-',Atom), atom_string(Atom, String).

string_to_list_of_characters(String, Characters) :-
    name(String, Xs),
    maplist( number_to_character,
       Xs, Characters ).

number_to_character(Number, Character) :-
    name(Character, [Number]).
