/**
 * Created by kilian on 10/6/15.
 */

/*
	utile pour le prolog
	- couleur d'une case vide : e
	- couleur d'une case occupee par joueur 1 : w
	- couleur d'une case occupee par joueur 2 : b
*/	
var colors = ['e', 'w', 'b'];
var hexaColors = {'w' : 'Bleu', 'b' : 'Rouge'};

// routine pour AJAX ============================================
var xmlhttp = new XMLHttpRequest();
var ajaxRequest = function(url, func){
    var response = "{}";
    console.log(url);
    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            response = xmlhttp.responseText;
            console.log('prolog : ' + response);

            func(response);
        }
    }
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
};
//================================================================


var WinCondition = {

    // Retourne la positions d'un hexagone dans la liste en fonction de ses coord dans la pyramide
    getHexaPosition : function (etage, rang) {
        return etage / 2 * (etage-1) + rang - 1;
    },

    // Retourne la dominance entre trois hexagones
    getDominance : function (hexa1, hexa2, hexa3){
        var dominance = {
            w : 0,
            b : 0,
            e : 0
        };

        dominance[hexa1]++;
        dominance[hexa2]++;
        dominance[hexa3]++;

        if(dominance.w >= 2)
            return 'w';
        else if(dominance.b >= 2)
            return 'b';
        else
            return 'e';
    },

    // Simplifie de facon recursive la pyramide de maniere recursive
    // A chaque iteration, on synthetise les dominances des haxagones par groupe de trois pour former une pyramide avec un etage de moins
    simplify : function(listHexas, nbEtages) {

        var newListHexas = [];

        if (nbEtages == 1)
            return listHexas[0];
        else {
            for (var i = 1; i <= nbEtages - 1; i++) {
                for (var j = 1; j <= i; j++) {
                    hexa1 = listHexas[WinCondition.getHexaPosition(i, j)];
                    hexa2 = listHexas[WinCondition.getHexaPosition(i + 1, j)];
                    hexa3 = listHexas[WinCondition.getHexaPosition(i + 1, j + 1)];
                    newListHexas.push(WinCondition.getDominance(hexa1, hexa2, hexa3));
                }
            }
            return WinCondition.simplify(newListHexas, nbEtages - 1);
        }
    }
}

// mode = "ia" or "humain"
// id > 0
var Player = function (mode, id, color, game, heuristic, depth) {

    // attributes
    var self = this;
    this.mode = mode;
	this.heuristic = heuristic;
	this.depth = depth;
    this.color = color;
    this.id = id;
    this.game = game;

    //methods
    this.select = function (hexa) {
        return hexa.select(self);
    };

    this.playIfIA = function(){

        var winner = self.game.winner();

        if(winner == 'e') {
            if (self.mode == 'ia') {

                //====================
                var prevBoardSerialized = self.game.getSerializedBoard();
                /*var newBoardSerialized = prevBoardSerialized;
                var newBoardSerialized = '';
                var hexaSelected = self.game.getFirstEmptyHexa();
                for(var i = 0; i < prevBoardSerialized.length; i++){
                    if(i != (hexaSelected.id-1))
                        newBoardSerialized += prevBoardSerialized[i];
                    else
                        newBoardSerialized += colors[self.id];
                }*/
                //=====================
				var before = Date.now();
                var response = ajaxRequest('ia?board=' + prevBoardSerialized + '&nextPlayer=' + colors[self.id] + '&heuristic=' + self.heuristic + '&depth=' + self.depth, function(resp){
					console.log('Temps de jeu de ia : ' + (Date.now()-before).toString())
				
                    var newBoardSerialized = JSON.parse(resp).prolog.split(',').join('');

                    hexaSelected = null;
                    for(var i = 0; i < prevBoardSerialized.length; i++) {
                        if(prevBoardSerialized[i] != newBoardSerialized[i]){
                            hexaSelected = i;
                        }
                    }

                    if(hexaSelected == null){
                        self.select(self.game.getFirstEmptyHexa());
			            console.log("serveur renvoi mal")
		            }
                    else
                        self.select(self.game.listHexas[hexaSelected]);
                    self.game.changePlayer();
                });
            }
        } else {
            alert('Le joueur ' + hexaColors[winner] + ' gagne.');
        }
    };

    this.playIfHuman = function(hexa){
        var winner = self.game.winner();

        if(winner == 'e') {
            if (self.mode == 'humain') {
                // si la selection a fonctionne
                if (self.select(hexa))
                    self.game.changePlayer();
            }
        } else {
            alert('Le joueur ' + hexaColors[winner] + ' gagne.');
        }
    };
};

// shape = Path from lib Paper.js
var Hexagon = function (shape, id, game) {

    // attributes
    var self = this;
    this.shape = shape;
    this.id = id;
    this.state = 0;
    this.game = game;

    // on construit le handler de clic
    shape.onClick = function(){
        self.game.currentPlayer.playIfHuman(self);
    };

    this.select = function(player){
        if(self.state == 0){
            shape.fillColor = player.color;
            paper.view.draw();
            self.state = player.id;
            return true;
        } else {
            return false;
        }
    };
};

// player[1-2]Mode = "ia" or "humain"
var YGame = function(canvasWidth, canvasHeight, player1Mode, player2Mode, player1Heuristic, player2Heuristic, player1Depth, player2Depth) {

    //attributes
    var self = this;
    this.nbFloors = parseInt(prompt('Renseigner le nombre d\'étages du plateau de jeu', '5'));
    this.canvasHeight = canvasHeight;
    this.player1 = new Player(player1Mode, 1, "blue", self, player1Heuristic, player1Depth);
    this.player2 = new Player(player2Mode, 2, "red", self, player2Heuristic, player2Depth);
    this.currentPlayer = this.player1;
    this.listHexas = [];

    //methods
    this.launch = function(){
    
    	console.log(self.nbFloors);

        // padding pour eviter les depassements avec les approximations du rayon
        var padding = 50;
        // hauteur totale d'un hexagone
        var hexHeight = (self.canvasHeight - 2 * padding) / self.nbFloors / (1 - 0.24 * ((self.nbFloors - 1) / self.nbFloors));
        var hexRadius = hexHeight / 2;
        // nombre total d'hexagone sur le plan de jeu
        var nbHex = (self.nbFloors + 1) / 2 * self.nbFloors;

        ajaxRequest('init?nbFloors=' + self.nbFloors, function(resp){});

        // algo pour ajouter et placer les hexagones
        var currFloor = 1;
        var currHorizPos = 1;
        var lastHexaInRowId = 1;
        for(var i = 1; i <= nbHex; i++){
            // calcul de positions
            var deltaHexa = hexRadius * 0.86 * (self.nbFloors - currFloor);
            var xPos = currHorizPos * hexHeight * 0.86 + deltaHexa;
            var yPos = currFloor * hexHeight * 0.76;
            //creation de la forme
            var shape = new Path.RegularPolygon(new Point(xPos, yPos), 6, hexRadius);
            shape.strokeColor = 'black';
            shape.fillColor = 'white';

            var hexa = new Hexagon(shape, i, self);

            this.listHexas.push(hexa);

            // si on est a la fin d'une ligne
            if(i == lastHexaInRowId){
                currFloor++;
                currHorizPos = 1;
                lastHexaInRowId += currFloor;
            } else {
                currHorizPos++;
            }
        }

		// dans le cas ou le premier joueur est un IA, il faut le faire jouer
        self.currentPlayer.playIfIA();
    };

    this.changePlayer = function(){
        if(self.currentPlayer == self.player1)
            self.currentPlayer = self.player2;
        else
            self.currentPlayer = self.player1;

		
        self.currentPlayer.playIfIA();
    };

    this.getFirstEmptyHexa = function(){
        for(var i = 0; i < self.listHexas.length; i++){
            if(self.listHexas[i].state == 0)
                return self.listHexas[i];
        }
    };

    this.isBoardFull = function(){
        for(var i = 0; i < self.listHexas.length; i++){
            if(self.listHexas[i].state == 0)
                return false;
        }
        return true;
    };

    this.winner = function(){
        return WinCondition.simplify(self.getBoard(), self.nbFloors);
    };

    this.getSerializedBoard = function(){
        var serializedBoard = '';

        for(var i = 0; i < self.listHexas.length; i++){
            serializedBoard += colors[self.listHexas[i].state];
        }
        return serializedBoard;
    };

    this.getBoard = function(){
        var board = [];

        for(var i = 0; i < self.listHexas.length; i++){
            board.push(colors[self.listHexas[i].state]);
        }
        return board;
    }
};

var modePlayer1 = prompt('Renseigner le mode de jeu du joueur 1', 'humain');
var heuristicPlayer1 = null;
var depthPlayer1 = 0;
if(modePlayer1 == 'ia'){
    heuristicPlayer1 = prompt('Renseigner l\'heuristique d\'ia à utiliser', 'random');
	depthPlayer1 = prompt('Renseigner la profondeur de l\'ia', 1);
}
var modePlayer2 = prompt('Renseigner le mode de jeu du joueur 2', 'ia');
var heuristicPlayer2 = null;
var depthPlayer2 = 0;
if(modePlayer2 == 'ia'){
    heuristicPlayer2 = prompt('Renseigner l\'heuristique d\'ia à utiliser', 'random');
	depthPlayer2 = prompt('Renseigner la profondeur de l\'ia', 1);
} 

var yGame = new YGame(800, 600, modePlayer1, modePlayer2, heuristicPlayer1, heuristicPlayer2, depthPlayer1, depthPlayer2);
yGame.launch();


