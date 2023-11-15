/**
* Name: BasicFestival
* Based on the internal empty template. 
* Author: hongjiang
* Tags: 
*/
model BasicFestival

global {
	int distanceCanGetInfo <- 5;

	init {
		create FestivalGuest number: 10;
		create FoodStore number: 1 {
			location <- {20, 20};
		}

		create FoodStore number: 1 {
			location <- {80, 80};
		}

		create DrinkStore number: 1 {
			location <- {20, 80};
		}

		create DrinkStore number: 1 {
			location <- {80, 20};
		}

		create InfoCenter number: 1 {
			location <- {50, 50};
		}

	}

}

/* Insert your model definition here */
species Store {
	bool hasFood <- false;
	bool hasDrink <- false;
}

species FoodStore parent: Store {
	bool hasFood <- true;

	aspect default {
		draw triangle(4) at: location color: #brown;
	}

}

species DrinkStore parent: Store {
	bool hasDrink <- true;

	aspect default {
		draw triangle(4) at: location color: #blue;
	}

}

species InfoCenter parent: Store {
	list<DrinkStore> drinkLocations <- list<DrinkStore>(DrinkStore);
	list<FoodStore> foodLocations <- list<FoodStore>(FoodStore);
	bool hasLocationList <- false;

	reflex listStoreLocations when: hasLocationList = false {
		ask foodLocations {
			write "InfoCenter knows that food stores are at:" + location;
		}

		ask drinkLocations {
			write "InfoCenter knows that drink stores are at:" + location;
		}

		hasLocationList <- true;
	}

	aspect default {
		draw square(8) at: location color: #gold;
	}

}

species FestivalGuest skills: [moving] {
	float thirst <- rnd(50, 100) * 1.0;
	float hunger <- rnd(50, 100) * 1.0;
	int guestId <- rnd(1000, 10000);
	int statementChangeRate <- 4;
	float guestSpeed <- 1.0;
	rgb color <- #green;
	Store targetPoint <- nil;


	reflex statementChange {
		thirst <- thirst - rnd(statementChangeRate) * 0.1;
		hunger <- hunger - rnd(statementChangeRate) * 0.1;
		if (targetPoint = nil and (thirst < 50 or hunger < 50)) {
			string guestStatement <- name;
			if (thirst < 50 and hunger < 50) {
				guestStatement <- guestStatement + " feels thirsty and hungry,";
			} else if (thirst < 50) {
				guestStatement <- guestStatement + " feels thirsty,";
			} else if (hunger < 50) {
				guestStatement <- guestStatement + " feels hungry,";
			}

			if (targetPoint = nil) {
				targetPoint <- one_of(InfoCenter);
			}

			guestStatement <- guestStatement + " going to " + targetPoint.name;
			write guestStatement;
		} }

	aspect default {
		draw circle(1) at: location color: color;
	}

	reflex beIdle when: targetPoint = nil {
		color <- #green;
		do wander;
	}

	reflex moveToTarget when: targetPoint != nil {
		color <- #red;
		do goto target: targetPoint.location speed: guestSpeed;
	}

	reflex infoCenterReached when: targetPoint != nil and targetPoint.location = {50, 50} and location distance_to (targetPoint.location) < distanceCanGetInfo {
		string destinationString <- name + " getting ";
		ask InfoCenter at_distance distanceCanGetInfo {
			if (myself.thirst <= myself.hunger) {
				myself.targetPoint <- drinkLocations[rnd(length(drinkLocations) - 1)];
				destinationString <- destinationString + "drink at ";
			} else {
				myself.targetPoint <- foodLocations[rnd(length(foodLocations) - 1)];
				destinationString <- destinationString + "food at ";
			}

			write destinationString + myself.targetPoint.name;
		}

	}

	reflex isThisAStore when: targetPoint != nil and location distance_to (targetPoint.location) < 2 {
		ask targetPoint {
			string replenishString <- myself.name;
			if (hasFood = true) {
				myself.hunger <- 100.0;
				replenishString <- replenishString + " ate food at " + name;
			} else if (hasDrink = true) {
				myself.thirst <- 100.0;
				replenishString <- replenishString + " had a drink at " + name;
			}

			write replenishString;
		}

		targetPoint <- nil;
	} }

experiment myExperiment type: gui {
	output {
		display myDisplay {
		// Display the species with the created aspects
			species FestivalGuest;
			species FoodStore;
			species DrinkStore;
			species InfoCenter;
		}

	}

}