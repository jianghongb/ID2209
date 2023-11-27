/**
* Name: Multiple Auction
* Based on the internal empty template. 
* Author: Hong Jiang, Yayan Li
* Tags: 
*/

model MultipleAuction

global {
	int numberOfPeople <- 21;
	int distanceThreshold <- 10;
	int initialGuestMoneyMaxRange <- rnd(2000,4000);
	int initialPrice <- rnd(3000,6000);
	int minimumAuctionPrice <- 2500;
	int auctionDistanceThreshold <- 10;
	
	string CDs <- "CDs";
	rgb CDs_color <- #teal;
	
	string CLOTHING <- "clothing";
	rgb clothing_color <- #orange;

	string Merch <- "signed merch";
	rgb Merch_color <- #purple;
	
		point auctionLocation <- {50, 50};
	
	init {
		create Participant number: numberOfPeople / 3{
			interestedInItemType <- CDs;
			color <- CDs_color;
		}
		create Participant number: numberOfPeople / 3{
			interestedInItemType <- CLOTHING;
			color <- clothing_color;
		}
		create Participant number: numberOfPeople / 3{
			interestedInItemType <- Merch;
			color <- Merch_color;
		}
		
		create DutchAuctioneer{
			location <- {25, 50};
			itemType <- CDs;
			color <- CDs_color;
		}
		create DutchAuctioneer{
			location <- {50, 50};
			itemType <- CLOTHING;
			color <- clothing_color;
		}
		create DutchAuctioneer{
			location <- {75, 50};
			itemType <- Merch;
			color <- Merch_color;
		}
	}
}



species Auctioneer skills: [fipa]
{
	int price <- initialPrice;
	int tmpPrice <- initialPrice;

	list<Participant> buyers <- [];
	list<Participant> allGuests <- list(Participant);
	
	string auctionType; // should be set in sub-species
	string itemType; // should be set in sub-species
	bool sold <- false;
	bool started <- false;
	bool initiated <- false;
	rgb color <- #red;
	
	action proposePrice{
		do start_conversation (to :: buyers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['price', tmpPrice]);
	}
	
	action cancelAuction{
		initiated <- false;
		started <- false;
		sold <- true;
		do endAuction;
	}
	
	action endAuction 
	{
		do start_conversation (to :: buyers, protocol :: 'fipa-request', performative :: 'inform', contents :: ['end_auction', self]);
		buyers <- [];
	}
	
	reflex notifyAuctionStart when: initiated = false and sold = false {
		write '(Time ' + time + '): ' + name + ' the auction is going to start!';
		initiated <- true;
		do start_conversation (to :: allGuests, protocol :: 'fipa-request', performative :: 'inform', contents :: ['start_auction', auctionType, itemType, self]);
	}
	
	
	reflex startNewAuction when: started = false and sold = true {
		// occasionally start a new auction
		if (flip(0.001)) {
			// setting sold to false will trigger our other reflex below,
			// which sends an inform to all agents
			tmpPrice <- initialPrice;
			initiated <- false;
			sold <- false;
		}
	}


	reflex collectParticipants when: initiated = true and started = false and (!(empty(agrees)) or !(empty(refuses)))
	{
		int sizeOfAgrees <- 0;
		int sizeOfRefuses <- 0;
		loop a over: agrees {
			sizeOfAgrees <- sizeOfAgrees + 1;
			add a.sender to: buyers;
			string dummy <- a.contents;
		}
		loop r over: refuses{
			sizeOfRefuses <- sizeOfRefuses + 1;
			string dummy <- r.contents;
		}
		write self.name + ": participants in: " + sizeOfAgrees + "participants refuse: " + sizeOfRefuses;
		if (sizeOfAgrees = 0) {
			// wait until later to start another auction if nobody is interested at this time
			write self.name + ": close auction, no participants interested";
			write "";
			initiated <- false;
			sold <- true;
		}
	}

	reflex startAuction when: initiated = true and started = false and !(empty(buyers))
		and ((buyers where (each.location distance_to self.location < auctionDistanceThreshold)) contains_all (buyers))
	{	
		write self.name + ": all guests arrived - starting auction";
		tmpPrice <- price;
		started <- true;
		do start_conversation (to :: buyers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['price', tmpPrice]);
	}
	
	reflex readProposals when: started = true and !(empty(proposes)) {
		int proposalsSize <- length(proposes);
		bool accepted <- false;
		loop proposeMsg over: proposes {
			if (accepted = false) {
				accepted <- true;
				write self.name + ": accepting proposal from " + proposeMsg.sender + ", price: " + tmpPrice;
				do accept_proposal message: proposeMsg contents: ["Congrts!"];
			} else {
				do reject_proposal message: proposeMsg contents: ["Too slow"];
			}
			
			// we need to do this so that the proposes aren't repeatedly looped through
			string dummy <- proposeMsg.contents;
		}
		write "";
		sold <- true;
		started <- false;
		do endAuction;
	}

	aspect default
	{
		draw circle(9) color: color;
	}
}

species DutchAuctioneer parent: Auctioneer
{
	init {
		auctionType <- "Dutch";
	}
	
	reflex receiveRefuseMessages when: started = true and !(empty(refuses)) {
		int lengthOfRefuses <- 0;
		loop refuseMsg over: refuses {
			lengthOfRefuses <- lengthOfRefuses + 1;
			string dummy <- refuseMsg.contents[0];
		}
		
		// if all buyers refused the price, start another round of negotiations
		if (lengthOfRefuses = length(buyers)) {
			tmpPrice <- tmpPrice - rnd(100);
			write self.name + ": lowering price to: " + tmpPrice;
			if (tmpPrice >= minimumAuctionPrice) {
				do start_conversation (to :: buyers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ['price', tmpPrice]);
			} 
			else {
				write self.name + ": new price (" + tmpPrice + ") is below the minimum (" + minimumAuctionPrice + ") - cancelling auction";
				write "";
				do cancelAuction;
			}
		}
	}
}

species Participant skills:[moving, fipa]
{
	point targetPoint <- nil;
	rgb color <- #blue;
	Auctioneer joinedAuction <- nil;
	string interestedInItemType;
	int money <- rnd(0, initialGuestMoneyMaxRange);
	
	//waiting for auction
	reflex beIdle when: targetPoint = nil{
		do wander;		
	}

	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint)<2
	{
		targetPoint <- nil;

		if self.interestedInItemType = CDs {
			color <- CDs_color;
		} else if self.interestedInItemType = CLOTHING {
			color <- clothing_color;
		} else if self.interestedInItemType = Merch {
			color <- Merch_color;
		} else {
			color <- #blue;
		}
	}
	
	reflex answerInvitation when: (!empty(informs))
	{
		message requestFromAuctioneer <- informs[0];
		string informType <- requestFromAuctioneer.contents[0];
		if (informType = "start_auction") {
			// write self.name + ": auction started";
			string auctionType <- requestFromAuctioneer.contents[1];
			string auctionItemType <- requestFromAuctioneer.contents[2];
			Auctioneer auctioneer <- requestFromAuctioneer.contents[3] as Auctioneer;
			if auctionItemType = interestedInItemType and joinedAuction = nil{
				 write self.name + ": accepting invitation, item type: " + auctionItemType + ", interest: " + interestedInItemType;
				do agree with: (message: requestFromAuctioneer, contents: [self.name + ': I will']);
				joinedAuction <- auctioneer;
			} else {
				 write self.name + ": refusing invitation for: " + auctionItemType + ", money: " + money + ", interest: " + interestedInItemType;
				do refuse with: (message: requestFromAuctioneer, contents: [self.name + ': I won\'t']);
			}
		} else if (informType = "end_auction") {
			// write self.name + ": auction ended"; 
			Auctioneer auctioneer <- requestFromAuctioneer.contents[1] as Auctioneer;
			if (joinedAuction != nil and joinedAuction.name = auctioneer.name) {
				joinedAuction <- nil;
			}
		}
	}
	
	reflex gotoAuction when: joinedAuction != nil and location distance_to joinedAuction > auctionDistanceThreshold - 5
	{
		do goto target: joinedAuction;
	}
	
	reflex respondToCfp when: (!empty(cfps)) {
		message cfp <- cfps at 0;
		list<string> content <- cfp.contents as list<string>;
		int price <- content at 1 as int;
		if price <= money {
			 write self.name + ": propsing purchase"; 
			do propose message: cfp contents: ['buy', price, money];
		} else {
			 write self.name + ": refusing proposal"; 
			do refuse message: cfp contents: ['im poor', price, money];
		}	
	}
	
	reflex receiveAcceptProposals when: !empty(accept_proposals) {
		 write(self.name + ': proposal accepted');		
		loop acceptMsg over: accept_proposals {
			do inform message: acceptMsg contents:["Inform from " + name];
			list<string> content <- acceptMsg.contents[0] as list<string>;
			int price <- content at 1 as int;
			money <- money - price;
		}
		joinedAuction <- nil;
	}

	reflex recieveRejectProposals when: !empty(reject_proposals) {
		 write(self.name + ': proposal rejected');		
		loop rejectMsg over: reject_proposals {
			// Read content to remove the message from reject_proposals variable.
			string dummy <- rejectMsg.contents[0];
		}
		joinedAuction <- nil;
	}
	
	aspect default
	{
		draw pyramid(3) at: location color:color;
		draw sphere(1) at: {location.x,location.y,2.0} color:color;	
	}
}


experiment FIPA type: gui {
	output {
		display map type: opengl {
			species Participant;
			species DutchAuctioneer;
		}
	}
}