/**
* Name: Festival Challenge
* Based on the internal empty template. 
* Author: Hong Jiang, Yayan Li
* Tags: 
*/


model FestivalChallenge


global {
    int numberOfGuests <- 20;
	int numberOfStores <- 3;
	int numberOfInfo <- 1;
	int numberOfSecurityGuards <- 1;
	
	
	init {
		create Guest number:numberOfGuests;
		create DrinkStore number:numberOfStores;
		create FoodStore number:numberOfStores;
		create DrinkNFoodStore number:numberOfStores;
		create InformationCenter number:numberOfInfo {location <- {50,50};}
		create SecurityGuard number:numberOfSecurityGuards;
		
		loop counter from: 1 to: numberOfGuests {
			Guest my_agent <- Guest[counter - 1];
			my_agent <- my_agent.setName(counter);
		}	
		
		loop counter from: 1 to: numberOfStores {
			DrinkStore my_agent <- DrinkStore[counter - 1];
			my_agent <- my_agent.setName(counter);
    	}
    	
		loop counter from: 1 to: numberOfStores {
			FoodStore my_agent <- FoodStore[counter - 1];
			my_agent <- my_agent.setName(counter);
    	}
    	
		loop counter from: 1 to: numberOfStores {
			DrinkNFoodStore my_agent <- DrinkNFoodStore[counter - 1];
			my_agent <- my_agent.setName(counter);
    	}
		
	}

}



species Location {}

species Store parent: Location {
    bool hasFood <- false;
    bool hasDrinks <- false;
}

species DrinkStore parent: Store { 
    bool hasDrinks <- true;
    
	string storeName <- "Undefined";
	
	action setName(int num) {
		storeName <- "Drink Store " + num;
	}
	
	aspect default {
		draw cube(5) color: #blue;
	}
}

species FoodStore parent: Store { 
    bool hasFood <- true;
    bool hasDrinks <- false;
    
	string storeName <- "Undefined";
	
	action setName(int num) {
		storeName <- "Food Store " + num;
	}
	
	aspect default {
		draw cube(5) color: #purple;
	}
}

species DrinkNFoodStore parent: Store { 
    bool hasFood <- true;
    bool hasDrinks <- true;
    
	string storeName <- "Undefined";
	
	action setName(int num) {
		storeName <- "Drink and Food Store " + num;
	}
	
	aspect default {
		draw cube(5) color: #orange;
	}
}

species InformationCenter parent: Location {
 	list<Store> foodstore <- (FoodStore at_distance 1000);
	list<Store> drinkstore <- (DrinkStore at_distance 1000);
	list<Store> drinknfoodstore <- (DrinkNFoodStore at_distance 1000);

	aspect default{
		draw pyramid(5) at: location color: #lightblue;
	}
	
	reflex whenGuestVisit when: Guest at_distance (4) {
		Guest badapple <- nil;
		string guestname <- nil;
		
		ask Guest at_distance (4){
			if (self.badApple) {
				guestname <- self.guestName;
				badapple <- self;
			}
		}
		
		if (badapple != nil) {
			ask one_of(SecurityGuard) {
				if (!(badlist contains badapple)) {
					write "security trace "+ guestname;
					badlist <+ badapple;
				}				
			}
		}
	}	
}

species SecurityGuard skills:[moving] {
	list<Guest> badlist <- [];
	Guest target <- nil;
	float killSpeed <- 2.5;
	
	reflex TraceTarget when: length(badlist) > 0 and target = nil {
		target <- badlist[0];
	}
	
	reflex trace
	{
		if (target != nil) {
			do goto target:target.location  speed:killSpeed;
		}
		else {
			do wander;
		}
	}
	
 	reflex killTheGuest when: target != nil and location distance_to (target.location) < 0.1 {
		write "kill" + target.guestName;
		ask target {
			do die;
		}
		target <- nil;
		remove item:badlist[0] from:badlist;
	}
	 
	aspect default{
	draw circle(2) at: location color: #red;
	}
}

species Guest skills:[moving] {
	bool isHungry <- false;
	bool isThirsty <- false;
	float hunger <- rnd(70.0,100.0); 
	float thirst <- rnd(80.0,100.0);	
	Location target <- nil;
	list<Store> smallbrian <- [];
	bool badApple <- flip(0.3);
	string guestName <- "Undefined";
	bool memory <- flip(0.5);
	
	
	rgb color <- #green;
	
	aspect default{
		if(badApple) {
			color <- #darkred;
		}		
		draw sphere(3) at: location color:color;
	}
	
	action setName(int num) {
		guestName <- "Person " + num;
	}
	
	reflex ConsumeFood when:!isHungry{
		hunger <- hunger - 1;
		if hunger < 50{
			isHungry <- true;
			write guestName + " is hungry ";
		}
		else{
			do wander;
		}
	}
	
	reflex ConsumeWater when:!isThirsty{
		thirst <- thirst - 1;
		if thirst < 50{
			isThirsty <- true;
			write guestName + " is thirsty ";			
		}
		else{
			do wander;
		}
	}
	
	reflex whereToGo when: (isThirsty or isHungry) and (target = nil) {
		if (length(smallbrian) > 0 and memory) {
			loop i from: 0 to: length(smallbrian)-1 {
				Store store <- smallbrian[i];
				if ((isHungry and isThirsty) and (store.hasFood and store.hasDrinks)) {
					target <- store;
					color <- #orange;
					break;
				} else if (isThirsty and store.hasDrinks) {
					target <- store;
					color <- #blue;
					break;
				} else if (isHungry and store.hasFood) {
					target <- store;
					color <- #purple;
					break;
				}				
			}	
			write "Brain memory is used";
		}
		 else {
			target <- one_of(InformationCenter);
			color <- #lightblue;
		}
	}
	
	reflex move
	{
		if (target != nil) {
			do goto target:target.location;
		}
		else {
			do wander;
		}
	}
	
	reflex whenAtInfo when: target != nil and location distance_to (target) < 4{
				ask InformationCenter at_distance 4 {
					Store store;
					if (myself.isHungry and myself.isThirsty) {
						store <- drinknfoodstore closest_to myself.location;
						myself.color <- #orange;
					} else if (myself.isHungry and myself.isThirsty = false) {
						store <- foodstore closest_to myself.location;
						myself.color <- #purple;
					} else {
						store <- drinkstore closest_to myself.location;
						myself.color <- #blue;
					}

					myself.target <- store;
					write myself.guestName + " is told to go to " + myself.target.name;
				}
	}
    
    //replenish
	reflex whenAtStore when: target != nil and location distance_to (target) < 2{
		if (isHungry and isThirsty) {
			isHungry <- false;
			isThirsty <- false;
			hunger <- 100.0;
			thirst <- 100.0;
		} else if (isHungry and isThirsty = false) {
			isHungry <- false;
			hunger <- 100.0;
		} else {
			isThirsty <- false;
			thirst <- 100.0;
		}	
		
		write guestName + " has replenished at " + target.name;

		if (memory) {
			if(length(smallbrian) < 3) {
				smallbrian <+ target;
			} else {
				remove item:smallbrian[0] from:smallbrian;
				smallbrian <+ target;
			}
			write target.name + " has been added to " +guestName+ " memory";
		}
		
		color <- #green;
		target <- nil;
		
		do wander;
	}

}

experiment my_experiment type:gui
{
    output {
		display map type: opengl
		{
			species Guest;
			species DrinkStore;
			species FoodStore;
			species DrinkNFoodStore;
			species InformationCenter;
			species SecurityGuard;
		}
    }
}