/**
 * Created by kilian on 10/6/15.
 */

// mode = "ia" or "human"
// id > 0
var Player = function (mode, id, color) {

    // attributes
    var self = this;
    this.mode = mode;
    this.color = color;
    this.id = id;

    //methods
    this.select = function (hexa) {
        return hexa.select(self);
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
        if(self.game.currentPlayer.select(self))
            self.game.changePlayer();
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
var YGame = function(nbFloors, canvasWidth, canvasHeight, player1Mode, player2Mode) {

    //attributes
    var self = this;
    this.nbFloors = parseInt(prompt("Renseigner le nombre d'étages du plateau de jeu", "8"));
    this.canvasHeight = canvasHeight;
    this.player1 = new Player(player1Mode, 1, "blue");
    this.player2 = new Player(player2Mode, 2, "red");
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
    };

    this.changePlayer = function(){
        if(self.currentPlayer == self.player1)
            self.currentPlayer = self.player2;
        else
            self.currentPlayer = self.player1;
    };
};

var yGame = new YGame(8, 800, 600, "human", "human");
yGame.launch();