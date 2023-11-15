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
		draw triangle(4) at: location color: #purple;
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
	bool isHungry <- false update: flip(0.5);
	bool isThirsty <- false update: flip(0.5);
	int guestId <- rnd(1000, 10000);
	int statementChangeRate <- 4;
	float guestSpeed <- 2.0;
	rgb color <- #green;
	Store targetPoint <- nil;

	reflex statementChange {
		bool getFood <- false;
		if (targetPoint = nil and (isHungry or isThirsty)) {
			string guestStatement <- name;
			if (isHungry and isThirsty) {
				guestStatement <- guestStatement + " feels thirsty and hungry,";
			} else if (isHungry) {
				guestStatement <- guestStatement + " feels hungry,";
				getFood <- true;
			} else if (isThirsty) {
				guestStatement <- guestStatement + " feels thirsty,";
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

	reflex enterStore when: targetPoint != nil and targetPoint.location = {50, 50} and location distance_to (targetPoint.location) < distanceCanGetInfo {
		ask InfoCenter at_distance 2 {
			string destinationString <- name + " getting ";
			if (myself.isThirsty) {
				myself.targetPoint <- drinkLocations[rnd(length(drinkLocations) - 1)];
				destinationString <- destinationString + "drink at ";
			}

			if (myself.isHungry) {
				myself.targetPoint <- foodLocations[rnd(length(foodLocations) - 1)];
				destinationString <- destinationString + "food at ";
			}

			write destinationString + myself.targetPoint;
		}

	}

	reflex isThisAStore when: targetPoint != nil and location distance_to (targetPoint.location) < 2 {
		ask targetPoint {
			string replenishString <- myself.name;
			if (hasFood = true) {
				myself.isHungry <- false;
				replenishString <- replenishString + " ate food at " + name;
			} else if (hasDrink = true) {
				myself.isThirsty <- false;
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