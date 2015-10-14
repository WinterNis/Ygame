/**
 * Created by kilian on 10/6/15.
 */

var serverRoot = '127.0.0.1:8000/';
var colors = ['e', 'w', 'b'];

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

// mode = "ia" or "human"
// id > 0
var Player = function (mode, id, color, game) {

    // attributes
    var self = this;
    this.mode = mode;
    this.color = color;
    this.id = id;
    this.game = game;

    //methods
    this.select = function (hexa) {
        return hexa.select(self);
    };

    this.playIfIA = function(){
        if(!self.game.isBoardFull()) {
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
                var response = ajaxRequest('ia?board=' + prevBoardSerialized + '&nextPlayer=' + colors[self.id], function(resp){
                    
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
            alert('Le plateau de jeu est rempli.');
        }
    };

    this.playIfHuman = function(hexa){
        if(!self.game.isBoardFull()) {
            if (self.mode == 'human') {
                // si la selection a fonctionne
                if (self.select(hexa))
                    self.game.changePlayer();
            }
        } else {
            alert('Le plateau de jeu est rempli.');
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
            self.state = player.id;
            return true;
        } else {
            return false;
        }
    };
};

// player[1-2]Mode = "ia" or "human"
var YGame = function(canvasWidth, canvasHeight, player1Mode, player2Mode) {

    //attributes
    var self = this;
    this.nbFloors = parseInt(prompt('Renseigner le nombre d\'étages du plateau de jeu', '8'));
    this.canvasHeight = canvasHeight;
    this.player1 = new Player(player1Mode, 1, "blue", self);
    this.player2 = new Player(player2Mode, 2, "red", self);
    this.currentPlayer = this.player1;
    this.listHexas = [];

    //methods
    this.launch = function(){

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

    this.getSerializedBoard = function(){
        var serializedBoard = '';

        for(var i = 0; i < self.listHexas.length; i++){
            serializedBoard += colors[self.listHexas[i].state];
        }
        return serializedBoard;
    }
};

var yGame = new YGame(800, 600, 'human', 'ia');
yGame.launch();

