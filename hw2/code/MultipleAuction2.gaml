/**
* Name: MultipleAuction2
* Based on the internal empty template. 
* Author: Hong Jiang, Yayan Li
* Tags: 
*/

model MultipleAuction2

global {
	int numberOfPeople <- 21;
	int distanceThreshold <- 10;
	
	int initialGuestMoneyMaxRange <- rnd(2000,3000);
	int initialDutchAuctionPrice <- rnd(3000,6000);
	int minimumDutchAuctionPrice <- 5000;
	int auctionDistanceThreshold <- 10;
	
	int initialEnglishAuctionPrice <- 3000;
	
	string AUCTION_TYPE_ENGLISH <- "ENGLISH_AUCTION";
	string AUCTION_TYPE_DUTCH <- "DUTCH_AUCTION";
	string AUCTION_TYPE_SEALED_LETTER <- "SEALED_AUCTION";
	
	string CD_ITEM_TYPE <- "CD_ITEM_TYPE";
	int CD_ITEM_LIMIT_MAX <- 10000;
	rgb CD_ITEM_COLOR <- #teal;
	
	string CLOTHING_ITEM_TYPE <- "CLOTHING_ITEM_TYPE";
	int CLOTHING_ITEM_LIMIT_MAX <- 10000;
	rgb CLOTHING_ITEM_COLOR <- #orange;

	string VIP_TICKET_ITEM_TYPE <- "VIP_TICKET_ITEM_TYPE";
	int VIP_TICKET_ITEM_LIMIT_MAX <- 10000;
	rgb VIP_ITEM_COLOR <- #purple;
	
	point informationCenterLocation <- {50,75};
	point auctionLocation <- {50, 50};
	
	init {
		create FestivalGuest number: numberOfPeople / 3
		{
			interestedInItemType <- CD_ITEM_TYPE;
			priceLimit <- rnd(0, CD_ITEM_LIMIT_MAX);
			color <- CD_ITEM_COLOR;
		}
		create FestivalGuest number: numberOfPeople / 3
		{
			interestedInItemType <- CLOTHING_ITEM_TYPE;
			priceLimit <- rnd(0, CLOTHING_ITEM_LIMIT_MAX);
			color <- CLOTHING_ITEM_COLOR;
		}
		create FestivalGuest number: numberOfPeople / 3
		{
			interestedInItemType <- VIP_TICKET_ITEM_TYPE;
			priceLimit <- rnd(0, VIP_TICKET_ITEM_LIMIT_MAX);
			color <- VIP_ITEM_COLOR;
		}
		create SealedBidAuctioneer
		{
			location <- {25, 50};
			itemType <- CD_ITEM_TYPE;
			color <- CD_ITEM_COLOR;
		}

		create EnglishAuctioneer
		{
			location <- {50, 50};
			itemType <- VIP_TICKET_ITEM_TYPE;
			color <- VIP_ITEM_COLOR;
		}
		create DutchAuctioneer
		{
			location <- {75, 50};
			itemType <- CLOTHING_ITEM_TYPE;
			color <- CLOTHING_ITEM_COLOR;
		}
	}
}

species FestivalGuest skills:[moving, fipa]{
	point targetPoint <- nil;
	
	float size <- 1.0;
	rgb color <- #blue;
	Auctioneer joinedAuction <- nil;
	int priceLimit; // set in initializer (global species)
	string interestedInItemType;
	int	money <- rnd(0, initialGuestMoneyMaxRange);
	
	action respondToDutchCfp(message cfpMsg) {
		list<string> content <- cfpMsg.contents as list<string>;
		int proposedPrice <- content at 1 as int;
		if proposedPrice <= money {
			// write self.name + ": propsing purchase"; 
			do propose message: cfpMsg contents: ['buy', proposedPrice];
		} else {
			// write self.name + ": refusing proposal"; 
			do refuse message: cfpMsg contents: ['im poor', proposedPrice];
		}	
	}
	
	action receiveDutchAcceptProposal(message proposalMsg) {
		do inform message: proposalMsg contents:["Inform from " + name];
		list<string> content <- proposalMsg.contents[0] as list<string>;
		int price <- content at 1 as int;
		money <- money - price;
		// write self.name + ": dutch accept proposal!";
		joinedAuction <- nil;
	}
	
	action receiveDutchRejectProposal(message rejectMsg) {
		// someone else won the auction, unfortunate
		string dummy <- rejectMsg.contents[0];
		// write self.name + ": dutch reject proposal!";
		joinedAuction <- nil;
	}
	
	action respondToEnglishCfp(message cfpMsg) {
		list<string> content <- cfpMsg.contents as list<string>;
		int proposedPrice <- content[1] as int;
		agent proposerAgent <- content[2] as agent;
		if proposerAgent != nil and self.name = proposerAgent.name {
			// if we currently hold the highest bid, we can just wait
			// and see if someone else performs another bid
			// write self.name + ": refusing bid, since currently holding max price: " + content;
			do refuse message: cfpMsg contents: ['i already hold the highest bid! i\'ll wait..', proposedPrice];	
		} else if proposedPrice + 100 <= priceLimit {
			// don't increase price to the price limit right away,
			// perform small increments
			int offset <- rnd(0, 100);
			int mySuggestedPrice <- proposedPrice + offset;
			// write self.name + ": proposing new price: " + mySuggestedPrice;
			do propose message: cfpMsg contents: ['im willing to pay this price', mySuggestedPrice];
		} else {
			// write self.name + ": refusing price, too low on money";
			do refuse message: cfpMsg contents: ['this is above my paygrade', proposedPrice];	
		}
		string dummy <- cfpMsg.contents[0];
	}
	
	action receiveEnglishAcceptProposal(message proposalMsg) {
		// for english auctions, receiving an approval just means that
		// we got approved as the highest bid. we don't have to do
		// anything special here, perhaps register that we're the current
		// highest bidder - but no need, since it's visibile
		// in the message received from the auctioneer anyway
		string dummy <- proposalMsg.contents[0];
	}
	
	action receiveEnglishRejectProposal(message rejectMsg) {
		// this just means that someone else holds the highest bid -
		// we can participate in the next round by increasing the bid,
		// if it falls within our budget..
		string dummy <- rejectMsg.contents[0];
	}
	
	action respondToSealedBidCfp(message cfpMsg) {
		list<string> content <- cfpMsg.contents as list<string>;
		if money > 0 {
			// write self.name + ": propsing purchase"; 
			int proposedPrice <- rnd(money);
			do propose message: cfpMsg contents: ['buy', proposedPrice];
		} else {
		 	// write self.name + ": refusing proposal"; 
			do refuse message: cfpMsg contents: ['im poor', 0];
		}	
	}
	
	action receiveSealedAcceptProposal(message proposalMsg) {
		do inform message: proposalMsg contents:["Inform from " + name];
		// write proposalMsg;
		int price <- proposalMsg.contents[1] as int;
		money <- money - price;
		// write self.name +  ": Bought for " + price + ", new money = " + money;
		joinedAuction <- nil;
	}
	
	action receiveSealedRejectProposal(message rejectMsg) {
		// someone else won the auction, unfortunate
		string dummy <- rejectMsg.contents[0];
		// write self.name + ": sealed reject proposal";
		joinedAuction <- nil;
	}
	
	reflex beIdle when: targetPoint = nil
	{
		do wander;
		
		if (money < initialGuestMoneyMaxRange) {
			money <- money + (rnd(initialGuestMoneyMaxRange - money));	
		}
		
	}

	reflex moveToTarget when: targetPoint != nil
	{
		do goto target:targetPoint;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint)<2
	{


		targetPoint <- nil;
		if self.interestedInItemType = CD_ITEM_TYPE {
			color <- CD_ITEM_COLOR;
		} else if self.interestedInItemType = CLOTHING_ITEM_TYPE {
			color <- CLOTHING_ITEM_COLOR;
		} else if self.interestedInItemType = VIP_TICKET_ITEM_TYPE {
			color <- VIP_ITEM_COLOR;
		} else {
			color <- #blue;
		}
	}

	reflex receiveInforms when: (!empty(informs))
	{
		message requestFromAuctioneer <- informs[0];
		string informType <- requestFromAuctioneer.contents[0];
		if (informType = "start_auction") {
			 write self.name + ": auction started";
			string auctionType <- requestFromAuctioneer.contents[1];
			string auctionItemType <- requestFromAuctioneer.contents[2];
			Auctioneer auctioneer <- requestFromAuctioneer.contents[3] as Auctioneer;
			if auctionItemType = interestedInItemType and joinedAuction = nil  {
				 write self.name + ": accepting invitation, item type: " + auctionItemType + ", interest: " + interestedInItemType;
				do agree with: (message: requestFromAuctioneer, contents: [self.name + ': I will']);
				joinedAuction <- auctioneer;
			} else {
				// write self.name + ": refusing invitation for item type: " + auctionItemType + ", money: " + money + ", interest: " + interestedInItemType;
				do refuse with: (message: requestFromAuctioneer, contents: [self.name + ': I won\'t']);
			}
		} else if (informType = "won_auction") {
			int wonPrice <- requestFromAuctioneer.contents[3] as int;
			money <- money - wonPrice;
			joinedAuction <- nil;
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
	
	reflex respondToCfp when: joinedAuction != nil and (!empty(cfps)) {
		message cfp <- cfps at 0;
		if (joinedAuction.auctionType = AUCTION_TYPE_DUTCH) {
			do respondToDutchCfp(cfp);
		} else if (joinedAuction.auctionType = AUCTION_TYPE_ENGLISH) {
			do respondToEnglishCfp(cfp);
		} else if (joinedAuction.auctionType = AUCTION_TYPE_SEALED_LETTER){
			do respondToSealedBidCfp(cfp);
		} else {
			// throw an error if we encounter an unexpected auction type
			int crash <- 100 / 0;
		}
	}
	
	reflex receiveAcceptProposals when: joinedAuction != nil and !empty(accept_proposals) {
		 write(self.name + ': proposal accepted');		
		loop acceptMsg over: accept_proposals {
			if (joinedAuction.auctionType = AUCTION_TYPE_DUTCH) {
				do receiveDutchAcceptProposal(acceptMsg);
			} else if (joinedAuction.auctionType = AUCTION_TYPE_ENGLISH) {
				do receiveEnglishAcceptProposal(acceptMsg);
			} else if (joinedAuction.auctionType = AUCTION_TYPE_SEALED_LETTER){
				do receiveSealedAcceptProposal(acceptMsg);
			} else {
				int crash <- 100/0;
			}
		}
	}

	reflex receiveRejectProposals when: joinedAuction != nil and !empty(reject_proposals) {
		 write(self.name + ': proposal rejected');		
		loop rejectMsg over: reject_proposals {
			if (joinedAuction.auctionType = AUCTION_TYPE_DUTCH) {
				do receiveDutchRejectProposal(rejectMsg);
			} else if (joinedAuction.auctionType = AUCTION_TYPE_ENGLISH) {
				do receiveEnglishRejectProposal(rejectMsg);
			} else if (joinedAuction.auctionType = AUCTION_TYPE_SEALED_LETTER){
				do receiveSealedRejectProposal(rejectMsg);
			} else {
				int crash <- 100/0;
			}
		}
	}
	
	aspect base
	{
		draw pyramid(2) at: location color:color;
		draw sphere(1) at: {location.x,location.y,2.0} color:color;
	}
}


species Auctioneer skills: [fipa]{
	int price <- 0;
	int tmpPrice;

	list<FestivalGuest> buyers <- [];
	list<FestivalGuest> allGuests <- agents of_species FestivalGuest;
	
	string auctionType; // should be set in sub-species
	string itemType; // should be set in sub-species
	bool sold <- false;
	bool started <- false;
	bool initiated <- false;
	rgb color <- #red;
	
	float avg <- 0.0;
	int nSold <- 0;
	
	action proposePrice(list content)
	{
		list<string> defaultContent <- ['price', tmpPrice];
		do start_conversation (to :: buyers, protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: defaultContent + content);
	}
	
	action announceAuction
	{		
		do start_conversation (to :: allGuests, protocol :: 'fipa-request', performative :: 'inform', contents :: ['start_auction', auctionType, itemType, self]);
	}
	
	action cancelAuction
	{
		initiated <- false;
		started <- false;
		sold <- true;
		do endAuction;
	}
	
	action resetValues
	{
		buyers <- [];
		started <- false;
		sold <- true;
	}
	
	action endAuction
	{
		if length(buyers) > 0 {
			do start_conversation (to :: buyers, protocol :: 'fipa-request', performative :: 'inform', contents :: ['end_auction', self]);	
		}
		do resetValues;
	}
	
	reflex startNewAuction when: started = false and sold = true {
		// occasionally start a new auction
		if (flip(0.001)) {
			// setting sold to false will trigger our other reflex below,
			// which sends an inform to all agents
			tmpPrice <- price;
			initiated <- false;
			sold <- false;
		}
	}

	reflex notifyAuctionStart when: initiated = false and sold = false {
		write self.name + ': informing guests of new auction, item type: ' + itemType;
		initiated <- true;
		do announceAuction;
	}

	reflex collectParticipants when: initiated = true and started = false and (!(empty(agrees)) or !(empty(refuses)))
	{
		int sizeOfAgrees <- 0;
		int sizeOfRefuses <- 0;
		loop a over: agrees 
		{
			sizeOfAgrees <- sizeOfAgrees + 1;
			add a.sender to: buyers;
			string dummy <- a.contents;
		}
		loop r over: refuses
		{
			sizeOfRefuses <- sizeOfRefuses + 1;
			string dummy <- r.contents;
		}
		write self.name + ": size of agrees = " + sizeOfAgrees + "; size of refuses: " + sizeOfRefuses;
		if (sizeOfAgrees = 0) {
			// wait until later to start another auction if nobody is interested at this time
			write self.name + ": cancelling auction, no participants interested";
			write "";
			initiated <- false;
			sold <- true;
		}
	}

	aspect base
	{
		draw square(10) color: color;
	}
}

species DutchAuctioneer parent: Auctioneer
{
	init {
		auctionType <- AUCTION_TYPE_DUTCH;
		price <- initialDutchAuctionPrice;
		tmpPrice <- initialDutchAuctionPrice;
	}

	reflex readProposals when: started = true and !(empty(proposes)) {
		int proposalsSize <- length(proposes);
		bool accepted <- false;

		write self.name + ": reading proposals: " + proposalsSize + " buyers: " + length(buyers);
		
		loop proposeMsg over: proposes {
			buyers <- buyers - proposeMsg.sender;
			if (accepted = false) {
				accepted <- true;
				write self.name + ": accepting proposal from " + proposeMsg.sender + ", price: " + tmpPrice;
				do accept_proposal message: proposeMsg contents: ["Congratulations!"];
				avg <- (avg * nSold + tmpPrice) / (nSold + 1);
				nSold <- nSold + 1;
				write name + " Average selling price: " + avg + "; Sold " + nSold + " items.";
				
			} else {
				write self.name + ": rejecting proposal";
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
	
	reflex receiveRefuseMessages when: started = true and !(empty(refuses)) {
		int lengthOfRefuses <- 0;
		loop refuseMsg over: refuses {
			lengthOfRefuses <- lengthOfRefuses + 1;
			// Read content to remove the message from refuses variable.
			string dummy <- refuseMsg.contents[0];
		}
		
		// if all buyers refused the price, start another round of negotiations
		if (lengthOfRefuses = length(buyers)) {
			tmpPrice <- tmpPrice - rnd(100);
			 write self.name + ": lowering price to: " + tmpPrice;
			if (tmpPrice >= minimumDutchAuctionPrice) {
				do proposePrice([]);
			} else {
				write self.name + ": new price (" + tmpPrice + ") is below the minimum (" + minimumDutchAuctionPrice + ") - cancelling auction";
				write "";
				do cancelAuction;
			}
		}
	}

	reflex startAuction when: initiated = true and started = false and !(empty(buyers))
		and ((buyers where (each.location distance_to self.location < auctionDistanceThreshold)) contains_all (buyers))
	{	
		write self.name + ": all guests arrived - starting new auction";
		tmpPrice <- price;
		started <- true;
		do proposePrice([]);
	}
}

species EnglishAuctioneer parent: Auctioneer
{
	FestivalGuest highestBidder <- nil;
	int highestBidAmt <- 0;
	
	init {
		auctionType <- AUCTION_TYPE_ENGLISH;
		price <- initialEnglishAuctionPrice;
		tmpPrice <- initialEnglishAuctionPrice;
	}
	
	action informWinner
	{
		do start_conversation (to :: [highestBidder], protocol :: 'fipa-request', performative :: 'inform', contents :: ['won_auction', auctionType, itemType, highestBidAmt] );
		highestBidder <- nil;
		highestBidAmt <- 0;
		do endAuction;
	}
	
	action cancelEnglishAuction
	{
		highestBidder <- nil;
		highestBidAmt <- 0;
		do cancelAuction;
	}

	reflex readProposals when: started = true and (!(empty(proposes)) or !(empty(refuses))) {
		int proposalsSize <- length(proposes);
		bool accepted <- false;

		int lengthOfRefuses <- length(refuses);
		loop refuseMsg over: refuses {
			// Read content to remove the message from refuses variable.
			string dummy <- refuseMsg.contents[0];
		}
		
		 write self.name + ": reading proposals (proposed/rejected): " + proposalsSize + "/" + lengthOfRefuses + " buyers: " + length(buyers);
		
		// this means that nobody submitted a new bid,
		// so the previously highest bidder has won
		if (lengthOfRefuses = length(buyers)) {
			if (highestBidder != nil) {
//				 write self.name + ": winner found - " + highestBidder.sender + "; price: " + highestBidder.contents[1];
				write self.name + ": winner found - " + highestBidder + " for price: " + highestBidAmt;
				avg <- (avg * nSold + highestBidAmt) / (nSold + 1);
				nSold <- nSold + 1;
				write name + " Average selling price: " + avg + "; Sold " + nSold + " items.";
				do informWinner;
			} else {
				write self.name + ": no bids received, cancelling auction. initial price: " + tmpPrice;
				do cancelEnglishAuction;
			}
			write "";
			return;
		}
		
		// see who proposed the highest price so far, and
		// reject other proposals. the ones who get rejected
		// will have to submit new bids if they're still interested
		list<message> rejectedMessages <- [];
		message highestBid <- nil; // this will initialize to a message from self
		loop proposeMsg over: proposes {
			list<string> proposeContent <- proposeMsg.contents as list<string>;
			int proposedPrice <- proposeContent[1] as int;
			 write self.name + ": proposal received from: " + proposeMsg.sender + "; price: " + proposeMsg.contents[1];
			if ((highestBid.sender as agent).name = self.name or (highestBid.contents[1] as int) < proposedPrice) {
				if ((highestBid.sender as agent).name != self.name) {
					rejectedMessages <- rejectedMessages + highestBid;
				}
				highestBid <- proposeMsg;
			} else {
				rejectedMessages <- rejectedMessages + proposeMsg;
			}
			
			string dummy <- proposeMsg.contents[0];
		}
		
		agent highestBidSender <- (highestBid.sender as agent);
		
		loop rejectedMsg over: rejectedMessages {
			do reject_proposal message: rejectedMsg contents: ["your bid was too low!"];
		}
		
		if highestBidSender.name != self.name {
			int bidAmt <- highestBid.contents[1] as int;
			 write self.name + ": highest bid so far: " + highestBidSender + "; price: " + bidAmt + " - initiating another round of bidding.";
			 write "";
			do accept_proposal message: highestBid contents: ["you're the highest bid so far!"];
			highestBidder <- highestBid.sender;
			highestBidAmt <- bidAmt;

			tmpPrice <- tmpPrice + rnd(100);
			do proposePrice([highestBidder]);
		} else {
			write self.name + ": cancelling auction, no bids received";
			do cancelEnglishAuction;
		}
	}

	reflex startAuction when: initiated = true and started = false and !(empty(buyers))
		and ((buyers where (each.location distance_to self.location < auctionDistanceThreshold)) contains_all (buyers))
	{	
		write self.name + ": all guests arrived - starting new auction";
		tmpPrice <- price;
		started <- true;
		do proposePrice([nil]);
	}
}

species SealedBidAuctioneer parent: Auctioneer{
	FestivalGuest highestBidder <- nil;
	int highestBidAmt <- 0;
	int tmpPrice <- -1;
	
	init {
		auctionType <- AUCTION_TYPE_SEALED_LETTER;
	}
	
	action informWinner
	{
		do start_conversation (to :: [highestBidder], protocol :: 'fipa-request', performative :: 'inform', contents :: ['won_auction', auctionType, itemType, highestBidAmt] );
		highestBidder <- nil;
		highestBidAmt <- 0;
		do endAuction;
	}
	
	action cancelSealedBid
	{
		highestBidder <- nil;
		highestBidAmt <- 0;
		do cancelAuction;
	}
	
	reflex startAuction when: initiated = true and started = false and !(empty(buyers))
		and ((buyers where (each.location distance_to self.location < auctionDistanceThreshold)) contains_all (buyers))
	{	
		write self.name + ": all guests arrived - starting new auction";
		started <- true;
		do proposePrice([nil]);
	} 
	
	reflex readProposals when: started = true and !(empty(proposes)) {
		int proposalsSize <- length(proposes);
		message currHighest <- nil;
		list<message> messages <- [];
		
		
		loop proposeMsg over: proposes {
			messages <- messages + proposeMsg;
			if currHighest.contents = nil {
				currHighest <- proposeMsg;
			}
			if (proposeMsg.contents[1] as int) > (currHighest.contents[1] as int) {
				currHighest <- proposeMsg;
			}
			string dummy <- proposeMsg.contents;
		}
		
		if (currHighest.sender as agent).name != self.name {
			loop proposeMsg over: messages {
				if proposeMsg = currHighest {
					highestBidder <- proposeMsg.sender;
					highestBidAmt <- proposeMsg.contents[1] as int;
					write self.name + ": accepting proposal from " + proposeMsg.sender + ", price: " + proposeMsg.contents[1];
					do accept_proposal message: proposeMsg contents: ["Congratulations!", proposeMsg.contents[1]];
					avg <- (avg * nSold + highestBidAmt) / (nSold + 1);
					nSold <- nSold + 1;
					write name + " Average selling price: " + avg + "; Sold " + nSold + " items.";
				} else {
					do reject_proposal message: proposeMsg contents: ["Too slow"];
				}
				
			}
		
			write "";
			do resetValues;
		} else {
			do cancelSealedBid;
		}
	}
	
}


experiment festival type: gui {
	output {
		display map type: opengl {
			species FestivalGuest aspect: base;
			species DutchAuctioneer aspect: base;
			species EnglishAuctioneer aspect: base;
			species SealedBidAuctioneer aspect: base;
		}
	}
}