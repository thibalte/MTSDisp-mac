// MTS-DISP
// by Thibault Brevet
// released under the MIT License
//
// A Processing.org implementation of MTS-Disp for lcd emulation of the Boxdoerfer Powerflex MTS-3SDI.
//
// UP/DOWN arrows to select serial port, then ENTER. ESC to exit.
//

import processing.serial.*;

Serial port;
PFont font;
int maxRow = 2, maxCol = 16;
int row = 0, col = 0;
int grid = 30, select = 0;
boolean printable, connected;
char[][] display;

void setup(){
	
	// set defaults
	size(maxCol*grid+grid, 200);
	fill(255, 0, 0);
	font = createFont("Courier New", 16);
	textFont(font);
	printable = true;
	connected = false;
	display = new char[2][16];
}

void draw(){
	background(0);
	if (connected){
		read();
		display();
	} else {
		select();
	}
}

void select(){
	text(Serial.list()[select], grid, grid);
	println(select);
}

void read(){
	while (port.available() > 0){
		int in = port.read();
		if (in == 255){
			printable = false;
		} else {
			lcd(in);
		}
	}
}

void lcd(int _in){
	if (!printable){
		if (_in >= 128){
			if (_in >= 192){
				row = 1;
				println("");
			} else {
				row = 0;
				println("");
			}
			col = _in & 63;
		} else if (_in >= 2){
			col = 0;
			row = 0;
		} else if (_in >= 1){
			for (int i=0; i<maxRow; i++){
				for (int j=0; j<maxCol; j++){
					display[i][j] = ' ';
				}
			}
		}
		printable = true;
	} else {
		if (col < maxCol && row < maxRow){
			display[row][col] = char(_in);
			col++;
			if (col > maxCol) col = 0;
		}
	}
}

void display(){
	for (int i=0; i<maxRow; i++){
		for (int j=0; j<maxCol; j++){
			text(display[i][j], grid/2+j*grid, grid+i*grid+60);
		}
	}
}

void keyPressed(){
	if (keyCode == ESC){
		port.write(unhex("A1"));
		port.stop();
		exit();
	} else if (keyCode == DOWN){
		println("up");
		if (select>=0 && select<Serial.list().length-1) select++; 
	} else if (keyCode == UP){
		if (select<Serial.list().length && select>0) select--;
	} else if (keyCode == ENTER) {
		port = new Serial(this, Serial.list()[4], 9600);
		port.write(unhex("A0"));
		connected = true;
		textFont(font, 24);
	}
}
