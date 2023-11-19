## ID2209 – Distributed Artificial Intelligence and Intelligent Agents
# Assignment 1 – Agents & stuff

<p align="center"> Group 16 </p>
<p align="center"> Hong Jiang & Yayan Li </p>
<p align="center"> 16th Nov 2023 </p>

In this assignment, we were tasked with creating a Basic Festival in GAMA. And implement communication between Guests agents and InformationCenter agent when guests get hungry or thirsty. 

## How to Run
Run GAMA V1.9.2 and import myFestival.gaml as a new project. Press main to run the simulation. 

## Species
### Agent FoodStore & DrinkStore
FoodStore and DrinkStore agents offer food and drink whenever what behavior guests conduct. When the guests get to the FoodStore or DrinkStore, their value of hungry and thirsty would be replenished.

### Agent InfomationCenter
The Information Center acts as a central hub for information about the locations of Stores. It provides directions to the nearest Store based on the guest's current needs. And it also reports the bad-apple to the guard.

### Agent Guard
This agent was responsible with removing bad guests when InformationCenter report it.

### Agent Guest
This agent was designed to simulate festival guests' behavior, including wandering, go to information center ask for the location of stores when they feel hungry or thirsty and go to stores. The important variables, reflexes and actions used to do are the value of hunger and thirst, ask location of stores from informationcenter agent.

## Implementation

<Explain a little bit how you went on with your assignment>
We began by developing the FoodStore and DrinkStore agents, focusing on simple behaviors such as seeking food and water. Then we introduced the InformationCenter agent to store the location of Stores to facilitate guest-store interactions. A Guard agent was also designed to ensure the safety of the festival by following and killing the bad-apple guests. In Guest agent we implement going to the information center to get the target location, or to use the SmallBrain component to locate stores without always relying on the Information Center.

## Results
As you can see in the following log, Agent Guest successfully complete getting to stores. Agent InformationCenter successfully found a bad guest.
Guest4 is hungry, heading to InfoCenter0
Guest4 getting food at (added to brain) FoodStore1
InfoCenter found a bad guest (Guest7), sending RoboCop after it
This can also be demonstrated from this screenshot right here.



## Challenge 1
To complete the first challenge, we added a List variable SmallBrain to Agent Guest. Small Brain will store two location guests had been to.

## Challenge 2
To complete the second challenge, we added an agent Guard. Information Center will add bad-apple agent to target list and report to agent Guard. Agent Guard will trace and kill the bad agent according to the location.

### Discussion / Conclusion
Creating Agent Stores was no problem, because its attributes are simple and no actions. But Agent InformationCenter and Agent Guest concerned more complex setting, such as recording the distance to agent Stores. Overall, we got familiar with GAMA platform and learnt the basic usage of GAMA.
