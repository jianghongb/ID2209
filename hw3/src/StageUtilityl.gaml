/**
* Name: Assignment3 Task2
* Author: Hong Jiang, Yayan Li
* Description: Group 16, Guest agents choose stages to attend based on attributes and preference matching
*/
 
model Task2 
 
global
{
    list<point> stagePositions <- [{15, 15}, {85, 15}, {15, 85},{85, 85}];
    list<rgb> stageColors <- [#black, #red, #purple, #blue];
   	int NumVaraibles <- 6;
    
   
    init {
        create Guest number: 10 {
           location <- {rnd(100), rnd(100)};
        }
        int counter <- 0;
        create Stage number: 4 {
            location <- stagePositions[counter];
            color <- stageColors[counter];
            counter <- counter + 1;
        }
       
    }
   
}
 
species Stage skills:[fipa]  {
	
	list<float> StageValues <- [];
	rgb color;
	bool acting <- false; 
	
	init {
		loop times: NumVaraibles {
			StageValues << rnd(100.0)/10.0;
		}
	}
	
	
	reflex reAssignValues when: time mod 30 = 0 {
		StageValues <- [];
		loop times: 6 {
			StageValues << rnd(100.0)/10.0;
		}
	}
	
	reflex sendValues when: !empty(informs) {
		write name + ": concert here is going to start ";
		write "Attributes:"+"[lightshow:"+StageValues[0]+']'+" [speakers:"+StageValues[1]+']'+" [band:"+StageValues[2]+']';
		write " [size:"+StageValues[3]+']'+" [costume:"+StageValues[4]+']'+" [food:"+StageValues[5]+']';
		Guest sender;
		loop msg over: informs {
			sender <- msg.sender;
			do inform with:(message: msg, contents: [StageValues]);
		}
		informs <- [];
	}

    aspect default
    {
        draw square(15) at: location color: color;
		draw geometry: self.name rotate:-90::{1,0,0}  at: self.location+ {0,0,8} color: #blue font: font('Default', 12, #bold) ;
    }

 
}
 
species Guest skills:[moving, fipa] {
    list<float> GuestValues <- [];
    float mySpeed <- rnd(3.0, 6.0) update:rnd(3.0, 6.0);
    point target <- nil;
    bool valuesChanged <- false;
    list<list<float>> stageValues <- [];
    list<float> utilityPerStage <- [0.0, 0.0, 0.0, 0.0];
    list<rgb> stageColors <- [];
    rgb color <- #grey;
    int concertRuntime <- 40;

    
    
    init {
		loop times: NumVaraibles {
			GuestValues << rnd(100.0)/10.0;
		}
    }
        
    
    //request stage values every interval
    reflex getStageInformation when: time mod 60 = 0 {
    	stageValues <- [];
        do start_conversation with:(to: list(Stage), protocol: 'fipa-request', performative: 'inform', contents: ['Send Values']);
     }
     
     reflex recieveValues when: (!empty(informs)) {
     	loop msg over: informs {
            stageValues << msg.contents[0];
        }
        valuesChanged <- true;
        informs <- [];
     }
     
     reflex findTheMostAppropriateStage when: valuesChanged {
        valuesChanged <- false;
        utilityPerStage <- [0.0, 0.0, 0.0, 0.0];
        loop stageIndex from: 0 to: length(Stage) - 1 {
            loop valueIndex from: 0 to: length(stageValues) - 1 {
                list<float> currentStageValues <- stageValues[stageIndex];
                utilityPerStage[stageIndex] <- utilityPerStage[stageIndex] + (currentStageValues[valueIndex] * GuestValues[valueIndex]);
            }
            stageColors << Stage[stageIndex].color;
        }
       
       	// choose max utility
        float maxValue <- max(utilityPerStage);
        write 'The Utilities of'+self.name +' in all Stages is:';
        write '[Stage 0:'+utilityPerStage[0]+ '], [Stage 1:'+utilityPerStage[1]+']';
        write '[Stage 2:'+utilityPerStage[2]+ '], [Stage 3:'+utilityPerStage[3]+']';
        int maxIndex <- 0;       
        loop currentUtilityIndex from:0 to: length(utilityPerStage) - 1 {
        	if(maxValue = utilityPerStage[currentUtilityIndex]) {
        		maxIndex <- currentUtilityIndex;
        	}
        }
        write 'The Max Utility is:['+maxValue +'] in Stage '+maxIndex;
        target <- stagePositions[maxIndex];
        color <- stageColors[maxIndex];
        write name + " go to stage " + maxIndex;
        
     }

    reflex moveToTarget when: target != nil {
        do goto target:target speed: mySpeed;
//        if self.location distance_to target < 0.5{
//        	target <- nil;
        if self.location distance_to target<0.5 and concertRuntime<=0 {
        	target <- nil;
        	concertRuntime <-40;
        }
    }
    
	reflex concert_delay when: (concertRuntime > 0) {
		concertRuntime <- concertRuntime - 1;
	}

   

	reflex dowander when:(target = nil and (self.location distance_to {50,50} > 0.5) ) {
		color <- #grey;
		do goto target:{50,50} speed: 5.0;
		do wander speed: mySpeed;	
	}
     
     
     aspect default {
		draw pyramid(3) at: location color:color;
		draw sphere(1) at: {location.x,location.y,2.0} color:color;	
    }
   
}
 
experiment StageUtility type: gui
{
   
    output
    {
        display map type: opengl
        {
            species Guest;
            species Stage;
        }
    }
}