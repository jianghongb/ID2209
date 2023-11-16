/**
* Name: Assignment 1
* Author: 
* Description: Festival scene with hungry guests, bad guests and a security guard
*/

model NewModel
global 
{

	int GuestNumber <- 20;
	int FoodStoreNumber <- 2;
	int DrinkStoreNumber <- 2;
	int infoCenterSize <- 5;
	point infoCenterLocation <- {50,50};
	float guestSpeed <- 0.05; 	              // guest move speed
	int ConsumeRate <- 1;				      // the rate at which guests grow hungry / thirsty
	float GuardSpeed <- guestSpeed * 1.2;     //Guard should be faster than bad guest

	
	init
	{
		create Guest number: GuestNumber;
		create FoodStore number: FoodStoreNumber;
		create DrinkStore number: DrinkStoreNumber;
		create InfoCenter number: 1 {location <- infoCenterLocation;}
		create Guard number: 1;
	}
}

/*
 * Parent Building
 * Guests might have a possibility to find a new place,
 * reserved for further developing
 */
species Building
{
	bool sellsFood <- false;
	bool sellsDrink <- false;
	
}

species FoodStore parent: Building
{
	bool sellsFood <- true;
	
	aspect default{
		draw pyramid(5) at: location color: #brown;}
}


species DrinkStore parent: Building
{
	bool sellsDrink <- true;
	
	aspect default{
		draw pyramid(5) at: location color: #yellow;}
}

/* InfoCenter serves info with the ask function */
species InfoCenter parent: Building
{
	// Get every store within 1000, should be enough	
	list<FoodStore> foodStoreLocs <- (FoodStore at_distance 1000);
	list<DrinkStore> drinkStoreLocs <- (DrinkStore at_distance 1000);
	
	// We only want to querry locations once
	bool hasLocations <- false;
	
	reflex listStoreLocations when: hasLocations = false
	{
		ask foodStoreLocs
		{
			write "Food store at:" + location; 
		}	
		ask drinkStoreLocs
		{
			write "Drink store at:" + location; 
		}
		
		hasLocations <- true;
	}
	
	aspect default
	{
		draw cube(5) at: location color: #blue;
	}

	reflex checkForBadGuest
	{
		ask Guest at_distance infoCenterSize
		{
			if(self.isBad)
			{
				Guest badGuest <- self;
				ask Guard
				{
					if(!(self.targets contains badGuest))
					{
						self.targets <+ badGuest;
						write 'InfoCenter found a bad guest (' + badGuest.name + '), sending RoboCop after it';	
					}
				}
			}
		}
	}
}// InfoCenter end


/*
 * Guests wander until they feel either thirsty or hungry
 * they have a possibility to use brain or go towards info center 
 */
species Guest skills:[moving]
{
	float thirst <- rnd(50)+50.0;
	float hunger <- rnd(50)+50.0;
	int guestId <- rnd(1000,10000);

	// Bad apples are removed by robocop and are darker in color
	bool isBad <- flip(0.2);
	rgb color <- #red;

		
	bool isConscious <- true;
	
	list<Building> guestBrain;
	
	/* Default target to move towards */
	Building target <- nil;
	
	/* Bad apples are colored differently */
	aspect default
	{
		if(isBad) {
			color <- #darkred;
		}
		draw sphere(2) at: location color: color;
	}
	
	/* 
	 * Reduce thirst and hunger with a random value between 0 and 0.5
	 * Once agent's thirst or hunger reaches below 50, they will head towards info/Store
	 */
	reflex alwaysThirstyAlwaysHungry
	{
		/* Reduce thirst and hunger */
		thirst <- thirst - rnd(ConsumeRate)*0.1;
		hunger <- hunger - rnd(ConsumeRate)*0.1;
		
		// This is used to decide which store to prefer in case of draw. Default is drink.
		bool getFood <- false;
		
		/* 
		 * If agent has no target and either thirst or hunger is less than 50
		 * then either head to info center, or directly to store
		 * 
		 * Once agent visits info center,
		 * the store they're given will be added to guestBrain,
		 * which is a list of stores.
		 * 
		 * The next time the agent is thirsty / hungry,
		 * agent then has 50% chance of either drawing an appropriate store from memory,
		 * or heading to info center as usual.
		 * 
		 * Agents can hold two stores in memory
		 * (typically these will be 1 drink and 1 food due to how the agents' grow thirsty/hungry),
		 * and will check if the stores in their memory hace the thing they want (food/drink)
		 * 
		 * Only conscious agents will react to their thirst/hunger 
		 */
		if(target = nil and (thirst < 50 or hunger < 50) and isConscious)
		{	
			string destinationMessage <- name; 

			/*
			 * Is agent thirsty, hungry or both.
			 * If hungry, getFood will be set to true,
			 * otherwise the agent will prefer drink.
			 */
			if(thirst < 50 and hunger < 50)
			{
				destinationMessage <- destinationMessage + " is thirsty and hungry,";
			}
			else if(thirst < 50)
			{
				destinationMessage <- destinationMessage + " is thirsty,";
			}
			else if(hunger < 50)
			{
				destinationMessage <- destinationMessage + " is hungry,";
				getFood <- true;
			}
			
			// Guest has 50% chance of using brain or asking from infocenter
			bool useBrain <- flip(0.5);
			
			// Only use brain if the guest has locations saved in brain
			if(length(guestBrain) > 0 and useBrain = true)
			{

				loop i from: 0 to: length(guestBrain)-1
				{
					// If user is hungry, ask guestBrain for food stores,
					// in the case of draw and otherwise ask for drink stores
					if(getFood = true and guestBrain[i].sellsFood = true)
					{
						target <- guestBrain[i];
						destinationMessage <- destinationMessage + " (brain used)";
						
						// Set getFood back to false, so we'll continue to prefer drink in the future too
						getFood <- false;
						break;
					}
					else if(getFood = false and guestBrain[i].sellsDrink = true)
					{
						target <- guestBrain[i];
						destinationMessage <- destinationMessage + " (brain used)";
						break;
					}
				}
			}

			// If no valid store was found in the brain, head to info center
			if(target = nil)
			{
				target <- one_of(InfoCenter);	
			}
			
			destinationMessage <- destinationMessage + " heading to " + target.name;
			write destinationMessage;
		}
	}

	/* 
	 * Agent's default behavior when target not set and they are conscious
	 * TODO: Do something more exciting here maybe
	 */
	reflex beIdle when: target = nil and isConscious
	{
		do wander;
	}
	
	/* 
	 * When agent has target, move towards target
	 * note: unconscious guests can still move, just to enable them moving to the hospital
	 */
	reflex moveToTarget when: target != nil
	{
		do goto target:target.location speed: guestSpeed;
	}
	
	/* 
	 * Guest arrives to info center
	 * It is assumed the guests will only head to the info center when either thirsty or hungry
	 * 
	 * The guests will prioritize the attribute that is lower for them,
	 * if tied then thirst goes first.
	 * This might be different than the reason they decided to head to the info center originally.
	 * 
	 * If the guest's brain has space, it will add the store's information to its brain
	 * This could be the same store it already knows, but the guests are not very smart
	 */
	reflex infoCenterReached when: target != nil and target.location = infoCenterLocation and location distance_to(target.location) < infoCenterSize
	{
		string destinationString <- name  + " getting "; 
		ask InfoCenter at_distance infoCenterSize
		{
			if(myself.thirst <= myself.hunger)
			{
				myself.target <- drinkStoreLocs[rnd(length(drinkStoreLocs)-1)];
				destinationString <- destinationString + "drink at ";
			}
			else
			{
				myself.target <- foodStoreLocs[rnd(length(foodStoreLocs)-1)];
				destinationString <- destinationString + "food at ";
			}
			
			if(length(myself.guestBrain) < 2)
			{
				myself.guestBrain <+ myself.target;
				destinationString <- destinationString + "(added to brain) ";
			}
			
			write destinationString + myself.target.name;
		}
	}
	
	/*
	 * When the agent reaches a building, it asks what does the store replenish
	 * Guests are foxy, opportunistic beasts and will attempt to refill their parameters at every destination
	 * Yes, guests will even try to eat at the info center
	 * Such ravenous guests
	 */
	reflex isThisAStore when: target != nil and location distance_to(target.location) < 2
	{
		ask target
		{
			string replenishString <- myself.name;	
			if(sellsFood = true)
			{
				myself.hunger <- 100.0;
				replenishString <- replenishString + " ate food at " + name;
			}
			else if(sellsDrink = true)
			{
				myself.thirst <- 100.0;
				replenishString <- replenishString + " had a drink at " + name;
			}
			
			write replenishString;
		}
		
		target <- nil;
	}
	
}// Guest end


species Guard skills:[moving]
{
	list<Guest> targets;
	aspect default{
		draw cube(5) at: location color: #black;
	}
	
	reflex catchBadGuest when: length(targets) > 0
	{
		if(dead(targets[0])){
			targets >- first(targets);
		}
		else{
			do goto target:(targets[0].location) speed: GuardSpeed;
		}
	}
	
	reflex badGuestCaught when: length(targets) > 0 and !dead(targets[0]) and location distance_to(targets[0].location) < 0.2
	{
		ask targets[0]
		{
			write name + ': exterminated by Robocop!';
			do die;
		}
		targets >- first(targets);
	}
}

experiment main type: gui
{
	
	output
	{
		display map type: opengl
		{
			species Guest;
			species FoodStore;
			species DrinkStore;
			species InfoCenter;
			
			species Guard;
		}
	}
}
