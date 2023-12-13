/**
* Name: Nqueen
* Based on the internal empty template. 
* Author: Hong Jiang, Yayan Li
* Tags: 
*/
model Nqueen

global {
	
	int numberOfQueens <- 12;
	init {
		int index <- 0;
		create Queen number: numberOfQueens;
		// Create all queens and set them up as a doubly linked list.
		loop counter from: 1 to: numberOfQueens {
			Queen queen <- Queen[counter - 1];
			Queen pred <- nil;
			if (counter - 2 >= 0) {
				//set queenId and predecessor
				pred <- Queen[counter - 2];
				// set successor
				pred <- pred.setSucc(queen);
			}
			queen <- queen.setPred(index, pred);
			index <- index + 1;
		}
		// Activate the first queen.
		Queen[0].active <- true;
	}
}


species Queen skills: [fipa] {
	ChessBoard myCell <- nil; 
	int id; 
	bool active <- false;
	Queen pred;
	Queen succ;
	list<ChessBoard> others <- [];
	list<int> memory <- [];
	
	action setPred(int queenId, Queen predecessor) type: Queen {
		id <- queenId;
		pred <- predecessor;
		return self;
	}
	
	action setSucc(Queen successor) type: Queen {
		succ <- successor;	
		return self;
	}
	
	reflex Place when: active and myCell = nil {
		// See where can place the queen.
		list<ChessBoard> locs <- GetPossibleLocations();
		write("[Queen" + id + "] Possible locations have: ");
		loop loc over: locs {
			write( "[" + loc.grid_x + "," + loc.grid_y +"]");
		}
		// If there are NO possible locations, we need to backtrack.
		if (empty(locs)) {
			write("[Queen" + id + "] have no possible place need to backtrack");
			// Wipe our memory so next time we are activated we can go wherever.
			memory <- [];
			others <- [];
			// Deactivate and send backtrack.
			active <- false;
			myCell <- nil;
			do activeSendBacktrack;
			return;
		}
		// Otherwise, we just pick the first one!
		do activeMove(first(locs));
	}

	action GetPossibleLocations type: list<ChessBoard> {
		list<int> possibleY <- [];
		// Go through every possible cell on its own row.
		// We only let them go on its own row to allow backtracking.
		loop i from: 1 to: numberOfQueens {
			// If we've already been here, we skip.
			int y <- i - 1;
			if (memory contains y) {
				continue;
			}
			// If this conflicts with other queens (only last one).
			if (QueenConflict(id, y, others)) {
				continue;
			}
			add y to: possibleY;
		}
		// Optimization: prefer 2-3 away from predecessor.
		int nextOpen;
		if (pred != nil) {
			nextOpen <- (last(others)).grid_y + 2;
		} else {
			nextOpen <- 0;
		}
		// Get the priorities.
		list<int> preferrable <- possibleY where (each >= nextOpen);
		list<int> suboptimal <- possibleY where (not (each in preferrable));
		// Make the final list!
		list<ChessBoard> potential <- (preferrable + suboptimal) accumulate (ChessBoard[id, each]);
		return potential;
	}
	
	action QueenConflict(int x1, int y1, list<ChessBoard> queens) type: bool {
		loop queen over: queens {
			int x2 <- queen.grid_x;
			int y2 <- queen.grid_y;
			int dy <- y2 - y1;
			int dx <- x2 - x1;
			bool condiction1 <- dx = 0;
			bool condiction2 <- dy = 0;
			bool condiction3 <- dx = dy;
			bool condiction4 <- dx = -dy;
			bool Conflict <- condiction1 or condiction2 or condiction3 or condiction4;
			if (Conflict) {
				return true;
			}
		}
		return false;
	}


	action activeSendBacktrack {
		if (pred != nil) {
			do start_conversation to: [pred] protocol: "fipa-propose" performative: "inform" contents: ["backtrack"];
		} else {
			error "Unsolveable problem";
		}
	}

	action activeMove(ChessBoard pos) {
		// Perform the move!
		myCell <- pos;
		add pos.grid_y to: memory;
		write("[Queen" + id + "] Going to: " + "[" + pos.grid_x + "," + pos.grid_y +"]");
		// Let the next one be placed.
		active <- false;
		if (succ != nil) {
			list<ChessBoard> queens <- others + [myCell];
			do start_conversation to: [succ] protocol: "fipa-propose" performative: "inform" contents: ["activate", queens];
		} else {
			write("Finish after " + (int(time) + 1) + " cycles");
		}
		
	}
	
	reflex NextRound when: !active and !empty(informs) {
		loop msg over: informs {
			string act <- msg.contents[0];
			// Activate and backtrack do the same thing, mostly.
			if (act = "activate") {
				list<ChessBoard> queens <- msg.contents[1];
				myCell <- nil;
				active <- true;
				// update other queens list
				others <- queens;				
			} else if (act = "backtrack") {
				write("[Queen" + id + "] Received backtrack signal");
				// Our previous knowledge is still correct, apply it to ourselves.
				myCell <- nil;
				active <- true;
			} else {
				error "Unknown action: " + act;
			}
		}
	}
	
//	action passiveActivate(list<ChessBoard> queens) {
//		myCell <- nil;
//		active <- true;
//		others <- queens;
//	}	
	
	aspect default {
		if (myCell != nil) {
			location <- myCell.location;
			float size <- 30 / numberOfQueens;
			//draw circle(size) color: #magenta;
			draw cone3D(1.3,2.3) at: location color: #brown ;
    		draw sphere(0.7) at: location + {0, 0, 2} color: #brown ;
		}
	}
}
	
	
grid ChessBoard width: numberOfQueens height: numberOfQueens { 
	init{
		if(even(grid_x) and even(grid_y)){
			color <- #black;
		}
		else if (!even(grid_x) and !even(grid_y)){
			color <- #black;
		}
		else {
			color <- #white;
		}
	}		

}

experiment NQueensProblem type: gui {
	output {
		display ChessBoard type: opengl{
			grid ChessBoard border: #black;
			species Queen ;
		}
	}
}