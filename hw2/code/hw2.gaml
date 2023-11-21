/**
* Name: hw2
* Based on the internal empty template. 
* Author: hongjiang
* Tags: 
*/


model hw2

/* Insert your model definition here */
global {

	Consumer1 C1;
	Consumer0 C0;
	init
	{
		create Merchant number: 1
		{
			startofauction <- true;
			notsold <- true;
			whom <- 0;
			baseprice <- 500.0;
			startprice <- 599.0;
			location <- {45,20};
		}
		create Consumer0 number: 1 returns: c0
		{
			offeredprice <- '';
			startofauction <- true;
			begin <- false;
			buyprice <- 699.0;
			dist <- 1;
			location <- {rnd(48,54),rnd(16,24)};
		}
		create Consumer1 number: 1 returns: c1
		{
			offeredprice <- '';
			startofauction <- true;
			begin <- false;
			buyprice <- 799.0;
			dist <- 1;
			location <- {rnd(48,54),rnd(16,24)};
		}
		C0 <- c0 at 0;
		C1 <- c1 at 0;
	}
}
species Merchant skills: [fipa]{
	float baseprice;
	float startprice;
	int whom;
	bool notsold;
	bool startofauction;
	reflex start_of_auction when: startofauction = true {
		write self.name + ': INFORM';
		do start_conversation with: [ to :: [C0], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['Auction is starting now.'] ];
		startofauction <- false;
	}
	reflex call_for_proposals when: notsold = true {
		write self.name + ': CALL FOR PROPOSAL';
		write self.name + ': Selling for the price: '+ startprice + ' Kr.';
 		if whom = 0{
			do start_conversation with: [ to :: [C0], protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['Selling for the price: '+ startprice + ' Kr.'] ];
			notsold <- false;
		}
		else if whom = 1{
			do start_conversation with: [ to :: [C1], protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['Selling for the price: '+ startprice + ' Kr.'] ];
			notsold <- false;
		}
		
	}
	reflex read_proposal when: !(empty(proposes)) {
		loop p over: proposes {
			write self.name + ': Proposal recieved: ' + string(p.contents);
			if string(p.contents) = string(startprice){
				write self.name + ': Its a deal';
				do accept_proposal with: [message :: p, contents :: ['Its a deal.']];
			}
			else{
				write self.name + ': No deal';
				do reject_proposal with: [message :: p, contents :: ['No deal.']];
				if whom < 2{
					whom <- whom + 1;
				}
				else{
					if startprice >= baseprice{
						startprice <- startprice - 100.0;
						whom <- 0;
						notsold <- true;
					}
					else{
						do end_conversation with: [message :: cfps at 0, contents :: ['Auction cancelled.']];
					}
				}
				notsold <- true;
			}
		}
	}
	aspect default{ 
    	draw cone3D(1.5,2.5) at: location color: #black ;
    	draw sphere(1) at: location + {0, 0, 2} color: #white ;
    }
}

species Consumer0 skills: [fipa, moving]{
	int dist;
	float buyprice;
	string offeredprice;
	bool begin;
	bool startofauction;
	reflex read_inform_message when: !(empty(informs)) and startofauction = true {
		loop i over: informs {
			write self.name + ': Information recieved: ' + string(i.contents);
		}
		startofauction <- false;
	}
	reflex read_cfp_message when: !(empty(cfps)) {
		loop c over: cfps {
			if offeredprice != string(c.contents){
				write self.name + ': Cfp recieved: ' + string(c.contents);
				write self.name + ': I am willing to buy for ' + buyprice + ' Kr.';
				do propose with: [message :: c, contents :: [string(buyprice)]];
				offeredprice <- string(c.contents);
			}
		}
	}
	reflex proposal_accepted when: !(empty(accept_proposals)) {
		loop ap over: accept_proposals {
			write self.name + ': Acceptance recieved: ' + string(ap.contents);
			write self.name + ': OK.';
			do end_conversation with: [message :: ap, contents :: ['OK.']];
		}
	}
	reflex proposal_rejected when: !(empty(reject_proposals)) {
		loop rp over: reject_proposals {
			write self.name + ': Rejection recieved: ' + string(rp.contents);
			write self.name + ': OK.';
			do end_conversation with: [message :: rp, contents :: ['OK.']];
		}
	}
	reflex dance
	{
		dist <- -dist;
		do goto target:location + dist speed: 1.0;
	}
	aspect default{ 
    	draw cone3D(1.5,2.5) at: location color: #white ;
    	draw sphere(1) at: location + {0, 0, 2} color: #black ;
    }
}

species Consumer1 skills: [fipa, moving]{
	int dist;
	float buyprice;
	string offeredprice;
	bool begin;
	bool startofauction;
	reflex read_inform_message when: !(empty(informs)) and startofauction = true {
		loop i over: informs {
			write self.name + ': Information recieved: ' + string(i.contents);
		}
		startofauction <- false;
	}
	reflex read_cfp_message when: !(empty(cfps)) {
		loop c over: cfps {
			if offeredprice != string(c.contents){
				write self.name + ': Cfp recieved: ' + string(c.contents);
				write self.name + ': I am willing to buy for ' + buyprice + ' Kr.';
				do propose with: [message :: c, contents :: [string(buyprice)]];
				offeredprice <- string(c.contents);
			}
		}
	}
	reflex proposal_accepted when: !(empty(accept_proposals)) {
		loop ap over: accept_proposals {
			write self.name + ': Acceptance recieved: ' + string(ap.contents);
			write self.name + ': OK.';
			do end_conversation with: [message :: ap, contents :: ['OK.']];
		}
	}
	reflex proposal_rejected when: !(empty(reject_proposals)) {
		loop rp over: reject_proposals {
			write self.name + ': Rejection recieved: ' + string(rp.contents);
			write self.name + ': OK.';
			do end_conversation with: [message :: rp, contents :: ['OK.']];
		}
	}
	reflex dance
	{
		dist <- -dist;
		do goto target:location + dist speed: 1.0;
	}
	aspect default{ 
    	draw cone3D(1.5,2.5) at: location color: #white ;
    	draw sphere(1) at: location + {0, 0, 2} color: #black ;
    }
}

experiment main type: gui {
	output {
		display map type: opengl
		{
			species Merchant;
			species Consumer1;
			species Consumer0;
		}
		display chart
		{
			chart "Agent displacements"
			{
				//data "Agents with memory" value: displacement_WM color: #green;
				//data "Agents without memory" value: displacement_WoM color: #red;
			}
		}
	}
}