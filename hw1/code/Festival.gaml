/**
* Name: Festival
* Based on the internal empty template. 
* Author: Xinlong Han, Tianyu Deng
* Tags: 
*/

model Festival
global {
	int distanceCanGetInfo <- 5;
	
	init {
		create FestivalGuest number: 20;
		
		create FoodShop number: 1 {location <- {20,20};}
		create FoodShop number: 1 {location <- {80,80};}
		create DrinkShop number: 1 {location <- {20,80};}
		create DrinkShop number: 1 {location <- {80,20};}	
		
		create InfoCenter number: 1 {location <- {50,50};}
		
		create Guard number: 1;
	}
}

species Shop {
	bool servesFood <- false;
	bool servesDrink <- false;
}

species FoodShop parent: Shop {
	bool servesFood <- true;
	
	aspect default {
		draw triangle(4) at: location color: #brown;
	}
}

species DrinkShop parent: Shop {
	bool servesDrink <- true;
	
	aspect default {
		draw triangle(4) at: location color: #blue;
	}
}

species InfoCenter parent: Shop {
	list<FoodShop> foodLocations <- list<FoodShop>(FoodShop);
	list<DrinkShop> drinkLocations <- list<DrinkShop>(DrinkShop);
	
	bool hasLocationList <- false;
	
	reflex listStoreLocations when: hasLocationList = false {
		ask foodLocations {
			write "InfoCenter knows that foodshops are at:" + location; 
		}	
		ask drinkLocations {
			write "InfoCenter knows that drinkshops are at:" + location; 
		}
		
		hasLocationList <- true;
	}
	
	aspect default {
		draw square(8) at: location color: #gold;
	}

	reflex checkForBadGuest
	{
		ask FestivalGuest at_distance distanceCanGetInfo
		{
			if(self.isBad)
			{
				FestivalGuest badGuest <- self;
				ask Guard
				{
					if(!(self.targets contains badGuest))
					{
						self.targets <+ badGuest;
						write 'InfoCenter found a bad guest (' + badGuest.name + ') and informed guard';	
					}
				}
			}
		}
	}
}

species FestivalGuest skills:[moving]
{
	float thirst <- rnd(50, 100)* 1.0;
	float hunger <- rnd(50, 100)* 1.0;
	int guestId <- rnd(1000,10000);
	float guestSpeed <- 2.0;
	int statementChangeRate <- 4;	
	rgb color <- #green;

	bool isBad <- flip(0.2);
	bool isAlive <- true;
	
	list<Shop> guestBrain;
	
	Shop targetPoint <- nil;
	
	aspect default {
		if(isBad) {
			color <- #purple;
		}
		draw circle(1) at: location color: color;
	}
	
	reflex statementChange {
		thirst <- thirst - rnd(statementChangeRate)* 0.1;
		hunger <- hunger - rnd(statementChangeRate)* 0.1;
		
		bool getFood <- false;
		
		if(targetPoint = nil and (thirst < 50 or hunger < 50) and isAlive) {	
			string guestStatement <- name; 

			if(thirst < 50 and hunger < 50) {
				guestStatement <- guestStatement + " feels thirsty and hungry,";
			}
			else if(thirst < 50) {
				guestStatement <- guestStatement + " feels thirsty,";
			}
			else if(hunger < 50) {
				guestStatement <- guestStatement + " feels hungry,";
				getFood <- true;
			}

			bool useBrain <- flip(0.5);
			
			if(length(guestBrain) > 0 and useBrain = true) {

				loop i from: 0 to: length(guestBrain)-1 {
					if(getFood = true and guestBrain[i].servesFood = true) {
						targetPoint <- guestBrain[i];
						guestStatement <- guestStatement + " (brain used)";
						getFood <- false;
						break;
					}
					else if(getFood = false and guestBrain[i].servesDrink = true) {
						targetPoint <- guestBrain[i];
						guestStatement <- guestStatement + " (brain used)";
						break;
					}
				}
			}

			if(targetPoint = nil){
				targetPoint <- one_of(InfoCenter);	
			}
			
			guestStatement <- guestStatement + " going to " + targetPoint.name;
			write guestStatement;
		}
	}

	reflex beIdle when: targetPoint = nil and isAlive {
		color <- #green;
		do wander;
	}

	reflex moveToTarget when: targetPoint != nil {
		color <- #red;
		do goto target:targetPoint.location speed: guestSpeed;
	}
	
	reflex infoCenterReached when: targetPoint != nil and targetPoint.location = {50,50} and location distance_to(targetPoint.location) < distanceCanGetInfo {
		string destinationString <- name  + " getting "; 
		ask InfoCenter at_distance distanceCanGetInfo {
			if(myself.thirst <= myself.hunger) {
				myself.targetPoint <- drinkLocations[rnd(length(drinkLocations)-1)];
				destinationString <- destinationString + "drink at ";
			}
			else {
				myself.targetPoint <- foodLocations[rnd(length(foodLocations)-1)];
				destinationString <- destinationString + "food at ";
			}
			
			if(length(myself.guestBrain) < 2) {
				myself.guestBrain <+ myself.targetPoint;
				destinationString <- destinationString + "(added to brain) ";
			}
			
			write destinationString + myself.targetPoint.name;
		}
	}
	
	reflex isThisAStore when: targetPoint != nil and location distance_to(targetPoint.location) < 2 {
		ask targetPoint {
			string replenishString <- myself.name;	
			if(servesFood = true) {
				myself.hunger <- 100.0;
				replenishString <- replenishString + " ate food at " + name;
			}
			else if(servesDrink = true) {
				myself.thirst <- 100.0;
				replenishString <- replenishString + " had a drink at " + name;
			}
			
			write replenishString;
		}
		
		targetPoint <- nil;
	}
	
}

species Guard skills:[moving] {
	float GuardSpeed <- 3.0;
	list<FestivalGuest> targets;
	
	aspect default {
		draw circle(2) at: location color: #gray;
	}
	
	reflex catchBadGuest when: length(targets) > 0 {
		
		if(dead(targets[0])) {
			targets >- first(targets);
		}
		else {
			do goto target:(targets[0].location) speed: GuardSpeed;
		}
	}
	
	reflex badGuestCaught when: length(targets) > 0 and !dead(targets[0]) and location distance_to(targets[0].location) < 0.2 {
		ask targets[0] {
			write name + ': exterminated by Guard!';
			do die;
		}
		targets >- first(targets);
	}
}

experiment myExperiment type:gui {
	output {
		display myDisplay {
			species FestivalGuest;
			species FoodShop;
			species DrinkShop;
			species InfoCenter;
			species Guard;
		}
	}
}