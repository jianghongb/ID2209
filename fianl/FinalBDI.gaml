
model BDI

global {
	
	//all predicates
	string party_at_location <- "party_at_location";
	string chill_at_location<- "chill_at_location";
	string food_at_location<-"food_at_location";
	string meeting_at_location<-"meeting_at_location";
	
	predicate party_desire <- new_predicate("party_desire");
	predicate chill_desire <- new_predicate("chill_desire");
	predicate meeting_desire <- new_predicate("meeting_desire");
	predicate wander_desire <- new_predicate("wander_desire");
	predicate food_desire <- new_predicate("food_desire");
	
	predicate party_location <- new_predicate(party_at_location);
	predicate chill_location <- new_predicate(chill_at_location);
	predicate find_party_loc <- new_predicate("find_party_loc");
	
	predicate set_party_location_as_target <- new_predicate("set_party_location_as_target");
	predicate set_chill_location_as_target<- new_predicate("set_chill_location_as_target");
	predicate set_meeting_location_as_target<- new_predicate("set_meeting_location_as_target");
	predicate set_food_location_as_target<- new_predicate("set_food_location_as_target");
	
	int number_of_people <- 50;
	
	int total_conversations <- 0;
	int total_denies <- 0;
	int partied <- 0;
	int chilled <- 0;
	int ate <- 0;
	int meetingd <- 0;
	map<string, int> happiness_level_map;
	list<int>all_happiness_values;
	
	
	
	
	init{
		create visitor number: number_of_people;
		
		create party_place number: 1
				{
					
		location <- {10,10};
				}
				
		create drinks_chill_place number: 1
				{
					location <- {90,10};
				}
				
		create food_court number: 1
				{
					location <- {10,90};
				}
				
		create meeting_area number: 1
				{
					location <- {90,90};
				}
	}
}

species visitor skills:[moving, fipa] control: simple_bdi{
	
	string get_agent_type {
		switch rnd(0, 99) {
			match_between [0, 40] {return 'normal';}	
			match_between [41, 58] {return 'partylover';}	
			match_between [59, 76] {return 'chillPerson';}	
			match_between [77, 85] {return 'journalist';}	
			match_between [86, 99] {return 'politician';}	
			default {return 'normal';}
		}
	}
	
	
	string agent_type <- get_agent_type();
	list<visitor> allVisitors;
	list<string> allVisitorsNames;
	init{
		allVisitors<-list(visitor);
		allVisitorsNames <- allVisitors collect each.name;
	loop i from: 0 to: length(allVisitorsNames)-1
	{
		add allVisitorsNames[i] :: 0 to: happiness_level_map;
	}
	}
	
	int wealthy <- rnd(0, 9);
	bool talkative <- flip(0.5);
	int generous <- rnd(0, 9);
	
	int food_level <- rnd(150, 200) min: 0 update: food_level - 1;
	
	string status <- 'wandering';
	
	string present_desire <- nil;
	int desire_completion <- 0;
	
	point target <- nil;
	point wander_point <- self.location;
	// updating desires of each visitor
	action update_desire{
		if present_desire= 'party'{
			write name+"I have a desire to party";
			do add_desire(party_desire);
		} 
		
		else if present_desire= 'chill'{
			write name+"I have a desire to chill and have drinks";
			do add_desire(chill_desire);
		}
		
		else if present_desire= 'meeting'{
			write name+"I have a desire for gambling";
			do add_desire(meeting_desire);
		}
		
		else if present_desire='wander'{
			//do wander;
			write name+"I have a desire to wander";
			do add_desire(wander_desire);
		}
		else if present_desire='food'{
			//do wander;
			write name+"I have a desire to have food";
			do add_desire(food_desire);
		}
		}
		
		
	// belief for party..........................................................................
	perceive target: party_place{
		
		focus id: party_at_location var: location;
			
	}
	
	//end------------------------------------------------------------------------------------
	
	// belief for chilling..........................................................................
	perceive target: drinks_chill_place{
		
		focus id: chill_at_location var: location;
		
		
	}
	//end------------------------------------------------------------------------------------
	
	// belief for gambling..........................................................................
	perceive target: meeting_area{
		
		focus id: meeting_at_location var: location;
		
	}
	//end------------------------------------------------------------------------------------
	
	// belief for food..........................................................................
	perceive target: food_court{
		
		focus id: food_at_location var: location;
		
	}
	//end------------------------------------------------------------------------------------
	
	
	
	//plans for party------------------------------------------------------------------------------

	plan party intention: party_desire{
		if (target= nil){
			do add_subintention(get_current_intention(),set_party_location_as_target, true);
            do current_intention_on_hold();
		}
        else{
        	do goto target: target ;
        	write name +"has intention to go towards party location";
        
        	if (target = location)  {
        		
        		desire_completion <- desire_completion + 1;
				do wander;
				
				
				
			if (desire_completion >= 20) {
				
				write name +"partied and thinking of other desire";
				target<-nil;
				desire_completion <- 0;
				present_desire <- nil;
				do remove_intention(party_desire, true);
				
			
			}
        	}
        
        }
   }
   
   plan set_party_location_as_target intention:set_party_location_as_target instantaneous:true
   	{
   		party_place partyPlace;
   		list<point> possible_party_locations <- get_beliefs_with_name(party_at_location) collect (point(get_predicate(mental_state (each)).values["location_value"]));
		
		write name +"has a belief for party location";
		 target <- (possible_party_locations with_min_of (each distance_to self)).location;
		 
		 do remove_intention(set_party_location_as_target, true);
     }
     
    //plans for chill------------------------------------------------------------------------------
	plan chill intention: chill_desire{
		if (target= nil){
			do add_subintention(get_current_intention(),set_chill_location_as_target, true);
            do current_intention_on_hold();
		}
        else{
        	do goto target: target ;
        	write name +"has intention to go towards chill location";
        
        	if (target = location)  {
        		
        		desire_completion <- desire_completion + 1;
				do wander;
				
				
				
			if (desire_completion >= 20) {
				
				write name +"has chilled and thinking of other desire";
				target<-nil;
				desire_completion <- 0;
				present_desire <- nil;
				do remove_intention(chill_desire, true);
				
				
				
			}
        	}
        
        }
   }
   
   plan set_chill_location_as_target intention:set_chill_location_as_target instantaneous:true
   	{
   		
   		list<point> possible_chill_locations <- get_beliefs_with_name(chill_at_location) collect (point(get_predicate(mental_state (each)).values["location_value"]));
		
		write name +"has a belief for chill location";
		 target <- (possible_chill_locations with_min_of (each distance_to self)).location;
		 
		 do remove_intention(set_chill_location_as_target, true);
     }
	
	
	//plans for meeting------------------------------------------------------------------------------
	plan meeting intention: meeting_desire{
		if (target= nil){
			do add_subintention(get_current_intention(),set_meeting_location_as_target, true);
            do current_intention_on_hold();
		}
        else{
        	do goto target: target ;
        	write name +"has intention to go towards meeting location";
        
        	if (target = location)  {
        		
        		desire_completion <- desire_completion + 1;
				do wander;
				
				
				
			if (desire_completion >= 20) {
				write name +"done with meeting and thinking of other desire";
				
				target<-nil;
				desire_completion <- 0;
				present_desire <- nil;
				do remove_intention(meeting_desire, true);
				
				
				
			}
        	}
        
        }
   }
   
   plan set_meeting_location_as_target intention:set_meeting_location_as_target instantaneous:true
   	{
   		
   		list<point> possible_meeting_locations <- get_beliefs_with_name(meeting_at_location) collect (point(get_predicate(mental_state (each)).values["location_value"]));
		
		write name +"has a belief for meeting location";
		 target <- (possible_meeting_locations with_min_of (each distance_to self)).location;
		 
		 do remove_intention(set_meeting_location_as_target, true);
     }
     
     //end---------------------------------------------------------------------------------
	//plan wander desire----------------------------------------------------
	plan wander intention: wander_desire {
		
		float x_wander_min <- (self.location.x - 10) < 0 ? 0 : self.location.x - 10;
		float x_wander_max <- (self.location.x + 10) > 100 ? 100 : self.location.x + 10;
		float y_wander_min <- (self.location.y - 10) < 0 ? 0 : self.location.y - 10;
		float y_wander_max <- (self.location.y + 10) > 100 ? 100 : self.location.y + 10;
		
		write name +"has intention to wander";
		do goto target: point(rnd(x_wander_min, x_wander_max), rnd(y_wander_min, y_wander_max));
		desire_completion <- desire_completion + 1;
		if (desire_completion >= 35) {
				
				target<-nil;
				desire_completion <- 0;
				present_desire <- nil;
				do remove_intention(wander_desire, true);
				
			}
		
		
	}
	
	//end---------------------------------------------------------------------------------
	
	//plans for food------------------------------------------------------------------------------
	plan food intention: food_desire{
		if (target= nil){
			do add_subintention(get_current_intention(),set_food_location_as_target, true);
            do current_intention_on_hold();
		}
        else{
        	do goto target: target ;
        	write name +"has intention to go towards food location";
        
        	if (target = location)  {
        		
        		desire_completion <- desire_completion + 1;
				do wander;
				
				
				
			if (desire_completion >= 20) {
				
				write name +"done having food and thinking of other desire";
				target<-nil;
				desire_completion <- 0;
				present_desire <- nil;
				do remove_intention(food_desire, true);
				
			}
        	}
        
        }
   }
   
   plan set_food_location_as_target intention:set_food_location_as_target instantaneous:true
   	{
   		
   		list<point> possible_food_locations <- get_beliefs_with_name(food_at_location) collect (point(get_predicate(mental_state (each)).values["location_value"]));
		
		write name +"has a belief for food location";
		 target <- (possible_food_locations with_min_of (each distance_to self)).location;
		 
		 do remove_intention(set_food_location_as_target, true);
     }
     
     //end---------------------------------------------------------------------------------
	
	// reflex to get the desire
	reflex get_a_present_desire when: present_desire = nil {
		int roll <- rnd(0, 99);
		
		switch agent_type {
			match 'normal' {
				switch roll {
					match_between [0, 24] {present_desire <- 'party';}		
					match_between [25, 34] {present_desire <- 'chill';}		
					match_between [35, 39] {present_desire <- 'meeting';}		
					match_between [40, 70] {present_desire <- 'food';}		
					default {present_desire <- 'wander';}						
				}
			}
			match 'partylover' {
				switch roll {
					match_between [0, 39] {present_desire <- 'party';}		
					match_between [40, 54] {present_desire <- 'chill';}		
					match_between [35, 39] {present_desire <- 'meeting';}		
					match_between [55, 74] {present_desire <- 'food';}		
					default {present_desire <- 'wander';}						
				}
			}
			match 'chillPerson' {
				switch roll {
					match_between [0, 14] {present_desire <- 'party';}		
					match_between [15, 49] {present_desire <- 'chill';}		
					match_between [50, 59] {present_desire <- 'meeting';}		
					match_between [60, 74] {present_desire <- 'food';}		
					default {present_desire <- 'wander';}						
				}
			}
			match 'journalist' {
				switch roll {
					match_between [0, 9] {present_desire <- 'party';}		
					match_between [10, 19] {present_desire <- 'chill';}		
					match_between [20, 59] {present_desire <- 'meeting';}		
					match_between [60, 74] {present_desire <- 'food';}		
					default {present_desire <- 'wander';}						
				}
			}
			match 'politician' {
				switch roll {
					match_between [0, 4] {present_desire <- 'party';}		
					match_between [5, 9] {present_desire <- 'chill';}		
					match_between [10, 14] {present_desire <- 'meeting';}		
					match_between [15, 19] {present_desire <- 'food';}		
					default {present_desire <- 'wander';}						
				}
			}
			default {}
		}
		do update_desire;
	}


	// describes how every type of visitor reacts at different places while conversing with different types of visitors
	// this reflex has rules of every type of visitor 
	reflex visitor_to_answer when: !empty(informs) {
		point party_place_loc;
		point chill_place_loc;
		point meeting_place_loc;
		point food_place_loc;
		int happinessLevel;
		
		
		
		ask party_place{
			party_place_loc<-location;
			
		}
		ask drinks_chill_place{
			chill_place_loc<-location;
			
		}
		ask meeting_area{
			meeting_place_loc<-location;
			
		}
		ask food_court{
			food_place_loc<-location;
			
		}
		
		switch agent_type {
			match 'normal' {
				// normal person
				message one_inform <- informs[length(informs) - 1];
				//normal person at party-------------------------------------------------------
				
					if (self.location distance_to party_place_loc <=5){
					
						if (int(one_inform.contents[2])>=5 and one_inform.contents[1] != 'weird') {
							write name+"is a"+agent_type+"partying with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							do agree message: one_inform contents: ['Yes lets party'];
							total_conversations <- total_conversations + 1;
							if(one_inform.contents[1]='normal'){
								happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								
								}
							else{
								happinessLevel<- 6;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								}	
							
						} else {
							write name+"is a"+agent_type+"doesnt want to party with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							do cancel message: one_inform contents: ['No I am not interested'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					//normal person at chill place-------------------------------------------------------
					
					else if (self.location distance_to chill_place_loc <=5){
				
						if (int(one_inform.contents[4])<=5 and one_inform.contents[1] != 'weirdo') {
							write name+"is a"+agent_type+"chilling with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							do agree message: one_inform contents: ['Yes lets chill'];
							total_conversations <- total_conversations + 1;
							if(one_inform.contents[1]='normal'){
								happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								
								}
							else{
								happinessLevel<- 6;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								}	
							
						} else {
							write name+"is a"+agent_type+"doesnt want to chill with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							
							do cancel message: one_inform contents: ['No not interested'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//normal person at food place-------------------------------------------------------
					else if (self.location distance_to food_place_loc <=5){
					
						if (one_inform.contents[1] = agent_type) {
							write name+"is a"+agent_type+"having food with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
							happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
							happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
						} else {
							write name+"is a"+agent_type+"doesnt want to have food with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//normal person at meeting place-------------------------------------------------------
					else if (self.location distance_to meeting_place_loc <=5){
					
						if (int(one_inform.contents[3])>= 5 and wealthy >= 5) {
							write name+"is a"+agent_type+"gambling with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
							happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
							happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
						} else {
							write name+"is a"+agent_type+"doesnt want to meeting with "+ one_inform.contents[1]+"whose type is "+one_inform.contents[1];
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				
			}
//normal person end-------------------------------------------------------------------------------------------

			match 'partylover' {
				// party person
				message one_inform <- informs[length(informs) - 1];
				//party person at party place-------------------------------------------------------
				if (self.location distance_to party_place_loc <=5){
				
						if ((int(one_inform.contents[2])>=5 or int(one_inform.contents[4])>=5)) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if(one_inform.contents[1]='partylover'){
								happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								
							}
							else{
								happinessLevel<- 5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								
							}
						}
						
						else {
							write name+"is a"+agent_type+"doesnt want to party with "+ one_inform.contents[1]+"whose is less generous and less talkative" ;
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					//party person at chill place-------------------------------------------------------
					else if (self.location distance_to chill_place_loc <=5){
					
						if (int(one_inform.contents[2])>=5 and (one_inform.contents[1]!='meetingr' and one_inform.contents[1]!='weird')){ 
						
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							if(one_inform.contents[1]='chillPerson'){
								happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								
							}
							else{
								happinessLevel<- 5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
								
							}
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//party person at food place-------------------------------------------------------
					else if (self.location distance_to food_place_loc <=5){
					
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
	
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//party person at meeting place-------------------------------------------------------
					else if (self.location distance_to meeting_place_loc <=5){
				
						if (int(one_inform.contents[3]) >= 5 and wealthy >= 5) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
	
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				
			}
//end-----------------------------------------------------------------------------------------------------------------------			
			match 'chillPerson' {
				// chill person
				message one_inform <- informs[length(informs) - 1];
				//chill person at party place-------------------------------------------------------
				if (self.location distance_to party_place_loc <=5){
				
						do cancel message: one_inform contents: ['No'];
						total_denies <- total_denies + 1;
						
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					//chill person at chill place-------------------------------------------------------
					else if (self.location distance_to chill_place_loc <=5){
					
						do agree message: one_inform contents: ['Yes'];
						total_conversations <- total_conversations + 1;
						happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
	
						
						do end_conversation message: one_inform contents: ['Action'];
					}
					//chill person at food place-------------------------------------------------------
					else if (self.location distance_to food_place_loc <=5){
					
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
	
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//chill person at meeting place-------------------------------------------------------
					else if (self.location distance_to meeting_place_loc <=5){
					
						if (int(one_inform.contents[3]) >= 3 and wealthy >= 6) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				
			}
			match 'journalist' {
				// journalist 
				message one_inform <- informs[length(informs) - 1];
				//journalist at party place-------------------------------------------------------
				if (self.location distance_to party_place_loc <=5){
				
						if (int(one_inform.contents[2])>=5 and one_inform.contents[1] != 'weirdo') {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					//journalist at chill place-------------------------------------------------------
					else if (self.location distance_to chill_place_loc <=5){
					
						if ((int(one_inform.contents[4]) <= 5) and one_inform.contents[1] != 'weirdo' and wealthy = 0) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//journalist at food place-------------------------------------------------------
					else if (self.location distance_to food_place_loc <=5){
					
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//journalist at meeting place-------------------------------------------------------
					else if (self.location distance_to meeting_place_loc <=5){
					
						if (int(one_inform.contents[3]) >= 5 and wealthy >= 5) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				
			}
			
			match 'politician' {
				// politician
				message one_inform <- informs[length(informs) - 1];
				//politician at party place-------------------------------------------------------
				if (self.location distance_to party_place_loc <=5){
				
						do agree message: one_inform contents: ['Yes'];
						total_conversations <- total_conversations + 1;
						happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
						
						
						do end_conversation message: one_inform contents: ['Action'];
						
					}
					//politician at chill place-------------------------------------------------------
					else if (self.location distance_to chill_place_loc <=5){
					
						do agree message: one_inform contents: ['Yes'];
						total_conversations <- total_conversations + 1;
						happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
						
						
						do end_conversation message: one_inform contents: ['Action'];
					}
					//politician at food place-------------------------------------------------------
					else if (self.location distance_to food_place_loc <=5){
					
						if (one_inform.contents[1] = agent_type) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
					//politician at meeting place-------------------------------------------------------
					else if (self.location distance_to meeting_place_loc <=5){
					
						if (int(one_inform.contents[3]) >= 5) {
							do agree message: one_inform contents: ['Yes'];
							total_conversations <- total_conversations + 1;
							happinessLevel<- 9;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						} else {
							do cancel message: one_inform contents: ['No'];
							total_denies <- total_denies + 1;
							happinessLevel<- -5;
								happiness_level_map[name]<- happiness_level_map[name]+happinessLevel;
								happiness_level_map[one_inform.contents[0]]<- happiness_level_map[one_inform.contents[0]]+happinessLevel;
							
							
						}
						do end_conversation message: one_inform contents: ['Action'];
					}
				
			}
		}
		write "####################happiness_Level_map"+happiness_level_map;
		
		
	}
	
	visitor asked_last_time <- nil;
	reflex visitor_to_ask when: food_level != 0 and !(empty(visitor at_distance 5)) {
		switch agent_type {
			match 'normal' {
				bool should_ask <- flip(0.3);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'partylover' {
				bool should_ask <- flip(0.5);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, generous, wealthy, talkative];
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'chillPerson' {
				bool should_ask <- flip(0.15);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'journalist' {
				bool should_ask <- flip(0.1);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;	
				} else {
					asked_last_time <- visitor at_distance 5 at 0;
				}
			}
			match 'politician' {
				bool should_ask <- flip(0.9);
				if (should_ask) {
					list<visitor> nearby_visitors <- visitor at_distance 5;
					visitor selected_visitor <- nearby_visitors[rnd(0, length(nearby_visitors) - 1)];
					if (asked_last_time != selected_visitor) {
						do start_conversation to: [selected_visitor] protocol: 'fipa-contract-net' performative: 'inform' contents: [name, agent_type, generous, wealthy, talkative];	
					}
					asked_last_time <- selected_visitor;	
				}
			}
		}
		
	}
	
	
	
	
	
	rgb get_color {
		if (self.agent_type = 'partylover') {
			return #white;
		} else if (self.agent_type = 'chillPerson') {
			return #yellow;
		} else if (self.agent_type = 'normal') {
			return #green;
		} else if (self.agent_type = 'journalist') {
			return #purple;
		} else {
			// for 'politician'
			return #darkblue;
		}
	}
	
	aspect base {
	//	draw sphere(2) color: get_color() border: get_color() = #white ? #black : #white;
		draw pyramid(3) at: location color: get_color() ;
		draw sphere(1) at: {location.x,location.y,2.0} color: get_color();
	}
}



species party_place{
	aspect base{
		draw circle(15) color:#red;
	}
}

species drinks_chill_place{	
	aspect base{
		
		draw circle(15) color:#green;
	}	
}

species food_court{
	aspect base{
		draw circle(15) color:#yellow;	
	}
}

species meeting_area{
	aspect base{
		draw circle(15) color:#blue;		
	}
}

experiment my_experiment type: gui {

	output {
		display map_3D type: opengl{
			
			species visitor aspect: base;
			species party_place aspect: base;
			species drinks_chill_place aspect: base;
			species food_court aspect: base;
			species meeting_area aspect: base;
		}
		
		display chart {
        	chart "Chart1" type: series style: spline {

        		
        		data "happiness" value:happiness_level_map.values;
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

