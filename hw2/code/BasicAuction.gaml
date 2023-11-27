/***
* Name: auction
* Author: Hong Jiang, Yayan Li
* Description: 
***/

model auction

/* Insert your model definition here */

global {
	point auct1Location <- {25, 25};
	point auct2Location <- {75, 75};
	point auctLocation <- {50,50};
	
	init {
		create auctioneer number: 1 {location <- auctLocation;}
 		create participant number: 5 ;
	}
}

//Agent actioneers


species auctioneer skills: [fipa] {
	int initPrice <- rnd(5000, 6000) update: rnd(5000, 6000);
	int price;
	int minimumPrice <- rnd(2000, 3000)update:rnd(2000, 3000);
	int step <- 500;
	int updateprice <- 0;
	bool itemSold <- false;
	bool auctionStarted <- false;
	string item <- "signed merch";
	list<participant> participantList;

	
	//Announce participants that the auction is goint to start
	reflex send_announcement_to_participants when: ((time mod 60) = 1) {
		write '(Time ' + time + '): ' + name + ' the auction is going to start!';
		do start_conversation (to: list(participant), protocol: 'no-protocol', performative: 'inform', contents: ['we are going to sell', item]);
	}
	
	//Start the auction and offer the starting price after all the participants joined the auction
	reflex offer_initial_price when: (!empty(informs) and !auctionStarted) and ((time mod 60) = 3) and participant at_distance 0.5 {
		write '(Time' + time + '): ' + name + ' send an cfp message to participants to offer the initial price';
		write 'The Auction is now starting! The price starting from ' + initPrice;
		price <- initPrice;
		do start_conversation (to: list(participant), protocol: 'fipa-contract-net', performative: 'cfp', contents: [item, initPrice]);
		auctionStarted <- true;
	}
	//reduce the price if there is no "buying propose" and not yet reach the minimum price
	reflex reduce_price when: !empty(refuses) and empty(proposes) and auctionStarted {
		updateprice <- (price - step);
		if( updateprice >= minimumPrice) {
			write 'Time ' + time + '): ' + name + ' send a cpf message to participants to offer a lower price';
			price <- updateprice;
			write 'selling at price ' + price;
			loop r over: refuses {
				do cfp (message: r, contents: [item, price]);
			}
		} 
		else if updateprice < minimumPrice {
			write 'Time ' + time + '): ' + name + ' send a failure message to participants to announce the failure of the bid';
			write 'Reach minimum price ' + minimumPrice + ', the auction closed.';
			loop r over: refuses {
				do failure(message: r, contents: ['the auction is failed.']);
			}
			auctionStarted <- false;
		}
	}
	
	//sell the item to the buyer, the auction is successful and ending
	reflex sell_the_item when: !empty(proposes) and auctionStarted {
		write '(Time ' + time + ' ): ' + name + ' receives the buying proposal';
		loop p over: proposes {
			write 'sell the ' + item + ' to ' + agent(p.sender).name + ' at price ' + price;
			do accept_proposal (message: p, contents: ['Congrats, you got the signed merch!']);
		}
		loop r over: refuses {
			do failure(message: r, contents: ['the item is sold, the auction is closed.']);
		}
		auctionStarted <- false;
	}
	
	//draw actioneer
	aspect default {
		draw square(10) color: #blue;
	}
	
}

//Agent participant
species participant skills: [fipa, moving] {
	
	rgb colorParticipant <- #purple;
	bool joinAuction <- false;
	int defaultPrice <- rnd(1000, 3500);
	float distance <- 0.0;
	int counter <- 1000;
	point targetPoint <- {10 + rnd(80), 10 + rnd(80)};
	
	
	// wander while not joining biding 
	reflex moveToTarget when: (!joinAuction) {
		do wander speed:5.0;
		colorParticipant <- #purple;
	}
	
	// set next random target point
//	reflex setNextTarget when: (!joinAuction) and (location distance_to auctioneerLocation < 2) {
//		do wander;
//		colorParticipant <- #violet;
//	}
	
	//join biding after receiving the cpf announcement.
	reflex join_auction when: (!empty(informs) and !joinAuction ) {
		colorParticipant <- #lightblue;
		joinAuction <- true;
		message announce <- informs[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(announce.sender).name + ' with content: ' + announce.contents;
		write name + ' is interested in ' + announce.contents[1] + ', and will join the auction.';
		do inform (message: announce, contents: ['I will join the auction.']);
		joinAuction <- true;
	} 
	
	reflex moveto_auctionner when: self.location distance_to auctLocation > 0.5 {
		do goto target: auctLocation;
	}
	
	reflex biding when: !empty(cfps) and joinAuction and self.location distance_to auctLocation < 0.5{
		message priceOffer <- cfps[0];
		write '(Time ' + time + '): ' + name + ' receives a cfp message from ' + agent(priceOffer.sender).name + ' with content: ' + priceOffer.contents;
		int price_offer <- priceOffer.contents[1];
		write 'willing to buy at price ' + defaultPrice;
		if (price_offer > defaultPrice) {
			do refuse (message: priceOffer, contents: ['The price is too high !']);
			write name + ' rejects ' + price_offer;
			write '----------------------------------';
		}
		else if (price_offer <= defaultPrice) {
			do propose (message: priceOffer, contents: ['I will buy it!']);
			write name + ' buys at price ' + price_offer;
			write '==================================';
		}		
	}			

	
	//receive the failure message for auction, do wander:
	reflex leave_the_auction when: !empty(failures) and joinAuction {
		message f <- failures[0];
		write '(Time ' + time + '): ' + name + ' receives a failure message from ' + agent(f.sender).name + ' with content: ' + f.contents;
		write name + ' leaves the auction.';
		joinAuction <- false;
		defaultPrice <- rnd(1000, 3500);
		colorParticipant <- #purple;
		do goto target:{(rnd(-5,5)+50),(rnd(-5,5)+50)} speed:20.0;
	}
	
	//state6: receive the proposal_accept message, receive the item
	reflex win_the_bid when: !empty(accept_proposals) and joinAuction {
		message a <- accept_proposals[0];
		write '(Time ' + time + '): ' + name + ' receives a accept_proposal message from ' + agent(a.sender).name + ' with content: ' + a.contents;
		write 'Yes! I, ' + name + ', win the bid!' ;
		write name + ' leaves the auction.';
		joinAuction <- false;
		defaultPrice <- rnd(1000, 3500);
		colorParticipant <- #purple;
		do goto target:{(rnd(-10,10)+50),(rnd(-10,10)+50)} speed:20.0;
	}
	
	reflex wait_next_round when:self.location distance_to auctLocation > 0.01 and !joinAuction{
		loop i from: 0 to: counter {
			do goto target: targetPoint;
			do wander;
		}
	}
	
	//draw participant
	aspect default {
		draw pyramid(2) at: location color:colorParticipant;
		draw sphere(1) at: {location.x,location.y,1.5} color:colorParticipant;	}
}


//main
experiment FIPA type: gui {
	output {
		display map type: opengl {
			species auctioneer;
			species participant;
			}
		}
}