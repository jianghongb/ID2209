/***
* Name: Final_Project
* Author: HongJiang & Yayan Li
* Description: final project
***/


model Final_Project

global {
	
	int nb_people <- 50;
	
	int total_conversations <- 0;
	int total_denies <- 0;
	int partied <- 0;
	int chilled <- 0;
	int gambled <- 0;
	map<string, int> happiness_level_map;
	list<int>all_happiness_values;
	
		
	init{
		create visitor number: nb_people;
		
		create Bar number: 1
				{location <- {10,10};}
				
		create NewsCenter number: 1
				{location <- {90,10};}
				
		create food_court number: 1
				{location <- {10,90};}
				
		create Home number: 1
				{location <- {90,90};}
	}
}

species visitor skills:[moving, fipa] {
	
	string get_agent_type {
		switch rnd(0, 99) {
			match_between [0, 20] {return 'normal';}	
			match_between [21, 40] {return 'partylover';}	
			match_between [41, 60] {return 'chillPerson';}	
			match_between [61, 80] {return 'journalist';}	
			match_between [81, 99] {return 'politician';}	
			default {return 'normal';}
		}
	}
	
	string agent_type <- get_agent_type();
	string event_type <- nil;
	list<visitor> allVisitors;
	list<string> allVisitorsNames;
	
	init{
		allVisitors<-list(visitor);
		allVisitorsNames <- allVisitors collect each.name;
		loop i from: 0 to: length(allVisitorsNames)-1
		{add allVisitorsNames[i] :: 0 to: happiness_level_map;}
	}
	
	// Attributes (at least 3):
	int wealthy <- rnd(0, 9)update:rnd(0,9);
	bool talkative <- flip(0.5)update:flip(0.5);
	int generous <- rnd(0, 9)update:rnd(0,9);
	
	int food_level <- rnd(150, 200) ;

	
	string status <- 'wandering';
	
	string present_desire <- nil;
	int desire_completion <- 0;
	
	point target <- nil;
	point wander_point <- self.location;

	reflex dowander when: target = nil and present_desire = 'wander' {
		// to keep it within the grid limits:
		float x_wander_min <- (self.location.x - 10) < 0 ? 0 : self.location.x - 10;
		float x_wander_max <- (self.location.x + 10) > 100 ? 100 : self.location.x + 10;
		float y_wander_min <- (self.location.y - 10) < 0 ? 0 : self.location.y - 10;
		float y_wander_max <- (self.location.y + 10) > 100 ? 100 : self.location.y + 10;		
		
		desire_completion <- desire_completion + 1;
		if (desire_completion = 4 and self.location = wander_point) {
			present_desire <- nil;
			wander_point <- self.location;
			desire_completion <- 0;
		}
		
		if (self.location = wander_point) {
			wander_point <- point(rnd(x_wander_min, x_wander_max), rnd(y_wander_min, y_wander_max));
//			do wander;
		}
		do goto target: wander_point;
	}
	
	reflex moveToTarget when: target != nil {
		if(target = location) {
			target <- nil;
		}
		do goto target: target;
	}
	
	
//	reflex eat when: food_level = 0 {
//		point food_place_loc;
//		ask food_court{
//			food_place_loc<-location;
//		}
//		
//		if (status != 'walking to eat') {
//			target <- food_place_loc;	
//		}
//		status <- 'walking to eat';
//		if (self.location = target) {
//			target <- nil;
//			food_level <- rnd(150, 200);
//			status <-'wandering';
//			wander_point <- self.location;
//		}
//	}
	
	reflex get_a_present_desire when: present_desire = nil {
		
		int roll <- rnd(0, 24);
		
		switch agent_type {
			match 'normal' {
				switch roll {
					match_between [0, 5] {present_desire <- 'party';}		// 5% to party
					match_between [6, 8] {present_desire <- 'rest';}		// 5% to chill
					match_between [9, 21] {present_desire <- 'meeting';}		// 5% to gamble
					default {present_desire <- 'wander';}						// 85% to wander
				}
			}
			match 'partylover' {
				switch roll {
					match_between [0, 5] {present_desire <- 'party';}		// 5% to party
					match_between [6, 8] {present_desire <- 'rest';}		// 5% to chill
//					match_between [9, 21] {present_desire <- 'meeting';}		// 5% to gamble
					default {present_desire <- 'wander';}						// 85% to wander
				}
			}
			match 'chillPerson' {
				switch roll {
					match_between [0, 5] {present_desire <- 'party';}		// 5% to party
					match_between [6, 8] {present_desire <- 'rest';}		// 5% to chill
					match_between [13, 21] {present_desire <- 'meeting';}		// 5% to gamble
					default {present_desire <- 'wander';}						// 85% to wander
				}
			}
			match 'journalist' {
				switch roll {
					match_between [0, 5] {present_desire <- 'party';}		// 5% to party
					match_between [6, 8] {present_desire <- 'rest';}		// 5% to chill
					match_between [13, 21] {present_desire <- 'meeting';}		// 5% to gamble
					default {present_desire <- 'wander';}						// 85% to wander
				}
			}
			match 'politician' {
				switch roll {
					match_between [0, 5] {present_desire <- 'party';}		// 5% to party
					match_between [6, 8] {present_desire <- 'rest';}		// 5% to chill
					match_between [13, 21] {present_desire <- 'meeting';}		// 5% to gamble
					default {present_desire <- 'wander';}						// 85% to wander
				}
			}
			default {}
		}
	}
	
	reflex party when: present_desire = 'party' and food_level != 0 {
		point bar_loc;
		ask Bar{
			bar_loc<-location;
		}
		
		if (status != 'walking to bar' and status != 'partying') {
			target <- bar_loc;	
		}
		
		if (status != 'partying') {
			status <- 'walking to party';	
		}
		
		if (self.location = target) {
			target <- nil;
			status <-'partying';
		}
		
		if (status = 'partying') {
			desire_completion <- desire_completion + 1;
			do wander;
			
			if (desire_completion = 4) {
				desire_completion <- 0;
				present_desire <- nil;
				status <- 'wandering';
				wander_point <- self.location;
			}
		}
		
	}
	
	reflex newscenter when: present_desire = 'chill' and food_level != 0 {
		point meeting_place_loc;
		ask NewsCenter{
			meeting_place_loc<-location;
		}
		if (status != 'walking to newscenter' and status != 'thinking') {
			target <- {75, 25};	
		}
		
		if (status != 'thinking') {
			status <- 'walking to newscenter';	
		}
		
		if (self.location = target) {
			target <- nil;
			status <-'thinking';
		}
		
		if (status = 'thinking') {
			desire_completion <- desire_completion + 1;
			do wander;
			
			if (desire_completion = 4) {
				desire_completion <- 0;
				present_desire <- nil;
				status <- 'wandering';
				wander_point <- self.location;
			}
		}
	}
	
	reflex rest when: present_desire = 'rest' and food_level != 0 {
		point rest_place_loc;
		ask Home{
			rest_place_loc<-location;
			
		}
		if (status != 'walking to home' and status != 'tired') {
			target <- rest_place_loc;	
		}
		
		if (status != 'tired') {
			status <- 'walking to gamble';	
		}
		
		if (self.location = target) {
			target <- nil;
			status <-'tired';
		}
		
		if (status = 'tired') {
			desire_completion <- desire_completion + 1;
			do wander;
			
			if (desire_completion = 4) {
				desire_completion <- 0;
				present_desire <- nil;
				status <- 'wandering';
				wander_point <- self.location;
			}
		}
	}
	

	reflex answer_visitor when: !empty(informs) {
		point bar_loc;
		point meeting_place_loc;
		point rest_place_loc;
		point food_place_loc;
		int happinessLevel;
		
		
		
		ask Bar{
			bar_loc<-location;
		}
		ask NewsCenter{
			meeting_place_loc<-location;
			
		}
		ask Home{
			rest_place_loc<-location;
			
		}
		ask food_court{
			food_place_loc<-location;
			
		}
		
		switch agent_type {
			match 'normal' {
				// normal person
				
				//normal person at bar
				if (self.location distance_to bar_loc <=5){
					if self.wealthy >5{
						write name +":I am a "+ agent_type + " I am wealthy to buy drinks.";
						happiness_level_map[name]<- 0;
						happinessLevel<- rnd(5,10);
						happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;													
					}
					else{
						write name +":I am a "+ agent_type + " I am enjoying music.";
						happiness_level_map[name]<- 0;
						happiness_level_map[name]<- happiness_level_map[name]+rnd(0,3);							
					}
					
				}
					
				//normal person at newscenter					
				else if (self.location distance_to meeting_place_loc <=5){
					write name +":I am a "+ agent_type + " I am listening to a news meeting";
					happiness_level_map[name]<- 0;
				}

				//normal person at foodshop
				else if (self.location distance_to food_place_loc <=5){
					write name +":I am a "+ agent_type +" I am eating";
					happiness_level_map[name]<- 0;
					happiness_level_map[name]<- happiness_level_map[name]+rnd(3,5);							

				}

				//normal person at home
				else if (self.location distance_to rest_place_loc <=5){
					write name +":I am a "+ agent_type +" I am taking a rest";
					happiness_level_map[name]<- 0;					
				}
				
			}
//normal person end-------------------------------------------------------------------------------------------

			match 'partylover' {
				// partylover at bar
				message one_inform <- informs[length(informs) - 1];
				if (self.location distance_to bar_loc <=5){
					write name +":I am a "+ agent_type +" I am having fun at bar";
					happiness_level_map[name]<- 0;
					happiness_level_map[name]<- happiness_level_map[name]+rnd(7,10);
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];					
					}
				
				// partylover at foodshop
				else if (self.location distance_to food_place_loc <=5){
					write name +":I am a "+ agent_type +" I am at a foodshop";
					happiness_level_map[name]<- 0;
					happiness_level_map[name]<- happiness_level_map[name]+rnd(3,6);	
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];											
					}
				
				//partylover at home
				else if (self.location distance_to rest_place_loc <=5){
					write name +":I am a "+ agent_type +" I am taking a rest";
					happiness_level_map[name]<- 0;		
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];				
				}
				
			}
//party person end-------------------------------------------------------------------------------------------
			
			match 'chillPerson' {
				// chill person at bar
				message one_inform <- informs[length(informs) - 1];
				if (self.location distance_to bar_loc <=5){
					happiness_level_map[name]<- -5;
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];
						write name +":I am a "+ agent_type +" I am at a bar. I have a free drink, I am happy now.";					
						happiness_level_map[name]<- happiness_level_map[name]+rnd(5,10);
						if desire_completion =4 {
							total_conversations <- 0;}
						else{
							total_conversations <- total_conversations + 1;
						}											
					}
					else{
						write name +":I am a "+ agent_type +" I am at a bar. It is too noisy, I am unhappy.";					
						do cancel message: one_inform contents: ['No'];
						if desire_completion =4 {
							total_denies <- 0;}
						else{
							total_denies <- total_denies + 1;
						}
					}
					do end_conversation message: one_inform contents: ['Action'];
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];		
						
				}
				
				// chill person at newsletter				
				else if (self.location distance_to meeting_place_loc <=5){
					write name +":I am a "+ agent_type +" I am at a newscenter";					
					happiness_level_map[name]<- 2;
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];							
				}
					
					
				else if (self.location distance_to food_place_loc <=5){
					write name +":I am a "+ agent_type +" I am at a foodshop";					
					happiness_level_map[name]<- rnd(3,5);
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];		
				}
			
				else if (self.location distance_to rest_place_loc <=5){
					write name +":I am a "+ agent_type +" I am taking a rest";					
					happiness_level_map[name]<- 0;
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];		
				}
				
			}
			
			match 'journalist' {
				// journalist at bar
				message one_inform <- informs[length(informs) - 1];
				if (self.location distance_to bar_loc <=5){
					write name +":I am a "+ agent_type +" I am having fun at bar";
					happiness_level_map[name]<- 0;
					happiness_level_map[name]<- happiness_level_map[name]+rnd(7,10);
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];			
				}
				
				// journalist at foodshop
				else if (self.location distance_to food_place_loc <=5){
					write name +":I am a "+ agent_type +" I am at a foodshop";
					happiness_level_map[name]<- 0;
					happiness_level_map[name]<- happiness_level_map[name]+rnd(3,6);	
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];									
				}

				// journalist person at newsletter				
				else if (self.location distance_to meeting_place_loc <=5){
					write name +":I am a "+ agent_type +" I am at a newscenter. I am unhappy with the answer";					
					happiness_level_map[name]<- rnd(-5,-1);	
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];				
				}
				
				//journalist at home
				else if (self.location distance_to rest_place_loc <=5){
					write name +":I am a "+ agent_type +" I am taking a rest";
					happiness_level_map[name]<- 0;
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];	
			
				}
			}
			
			match 'politician' {
				// politician person
				message one_inform <- informs[length(informs) - 1];
				if (self.location distance_to meeting_place_loc <=5 ){					
					happiness_level_map[name]<- rnd(-10,-5);
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];
						write name +":I am a "+ agent_type +" I am at a newscenter. I will answer your question";
						happiness_level_map[name]<- happiness_level_map[name]+rnd(5,10);
						if desire_completion =4 {
							total_conversations <- 0;}
						else{
							total_conversations <- total_conversations + 1;
						}											
					}
					else{
						do cancel message: one_inform contents: ['No'];
						write name +":I am a "+ agent_type +" I am at a newscenter. I refuse to answer your question";						
						if desire_completion =4 {
							total_denies <- 0;}
						else{
							total_denies <- total_denies + 1;
						}
					}
					do end_conversation message: one_inform contents: ['Action'];
						
				}
				
				// politician person at bar				
				else if (self.location distance_to bar_loc <=5){
					write name +":I am a "+ agent_type +" I am at a bar";					
					happiness_level_map[name]<- rnd(2,5);
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];
										
				}
					
					
				else if (self.location distance_to food_place_loc <=5){
					write name +":I am a "+ agent_type +" I am at a foodshop";					
					happiness_level_map[name]<- rnd(3,5);
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];

				}
			
				else if (self.location distance_to rest_place_loc <=5){
					write name +":I am a "+ agent_type +" I am taking a rest";					
					happiness_level_map[name]<- 0;
					if self.talkative {
						do agree message: one_inform contents: ['Yes'];											
					}
					else{
						do cancel message: one_inform contents: ['No'];
					}
					do end_conversation message: one_inform contents: ['Action'];

				}
			}
		}		
		
	}
	
	visitor asked_last_time <- nil;
	
	reflex ask_visitor when: food_level != 0 and !(empty(visitor at_distance 5)) {
		switch agent_type {
			match 'normal' {
				bool should_ask <- 1;
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, event_type, generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'partyEnthisiast' {
				bool should_ask <- 1;
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, event_type,generous, wealthy, talkative];
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'chillPerson' {
				bool should_ask <- 1;
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, event_type,generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'journalist' {
				bool should_ask <- 1;
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type,event_type, generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'politician' {
				bool should_ask <- 1;
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type,event_type, generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;	
				}
			}
		}
		
	}
	
	
	
//	Rendering the visitor:
	rgb get_color {
		if (self.agent_type = 'partylover') {
			return #red;
		} else if (self.agent_type = 'chillPerson') {
			return #darkgray;
		} else if (self.agent_type = 'normal') {
			return #green;
		} else if (self.agent_type = 'journalist') {
			return #purple;
		} else {
			// for 'politician'
			return #darkblue;
		}
	}
	
	aspect default {
		draw pyramid(3) at: location color: get_color() ;
		draw sphere(1) at: {location.x,location.y,2.0} color: get_color();
	}
}



species Bar{
	aspect default{
		draw circle(15) color:#red;
		draw geometry: self.name rotate:-90::{1,0,0}  at: self.location+ {0,0,6} color: #blue font: font('Default', 12, #bold) ;
	}
}

species NewsCenter{	
	aspect default{
		draw circle(15) color:#green;
		draw geometry: self.name rotate:-90::{1,0,0}  at: self.location+ {0,0,6} color: #blue font: font('Default', 12, #bold) ;
	}	
}

species food_court{
	aspect default{
		draw circle(15) color:#yellow;
		draw geometry: self.name rotate:-90::{1,0,0}  at: self.location+ {0,0,6} color: #blue font: font('Default', 12, #bold) ;	
	}
}

species Home{
	aspect default{
		draw circle(15) color:#blue;	
		draw geometry: self.name rotate:-90::{1,0,0}  at: self.location+ {0,0,6} color: #blue font: font('Default', 12, #bold) ;	
	}
}

experiment my_experiment type: gui {

	output {
		display map_3D type: opengl{
			//grid festival_map lines: #black;
			species visitor ;
			species Bar ;
			species NewsCenter  ;
//			species food_court  ;
			species Home  ;
		}
		
		display chart1 {
        	chart "Guest Mood" type: series style: spline {
        		data "mood" value:happiness_level_map.values color:#black;
        	}
        	
        	}
        display chart2 {
			chart "Conflict and Peace" type: pie { 
     		   	data "Peace" value: total_conversations color: #darkgreen;
        		data "Conflict" value: total_denies color: #darkred;
				
			}
			}

	}
}