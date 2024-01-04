## ID2209 – Distributed Artificial Intelligence and Intelligent Agents
# Final Project

<p align="center"> Group 16 </p>
<p align="center"> Hong Jiang & Yayan Li </p>
<p align="center"> 4th Jan 2024 </p>

In this assignment, we were tasked with creating a Festival simulation that shows how the interactions between types of guests are affected by their different personalities, as well as how the behaviors of individual agent affected by the personalities. The purpose of this project is not only to help us review the GAMA skills that we have learned through previous assignments, but also help us get more insights into the interactions between multi-agents by implementing a more comprehensive simulation.


## Requirements:

- Create at least 5 different types of guests.
- Each guest type has at least 1 different set of rules on how they interact with other types.
- They also have at least 3 personal traits that affect these rules.
- They have at least 2 different types of places where agents can meet. (Roaming not included.)
- Use at least 50 guests in your simulation.
- Make simulation continuously running.
- Agent communication with FIPA for long distance messaging.
- Have at least 1 global and interesting value to monitor and display on a chart
- At least 1 useful and informative graph.
- Draw out at least 1 interesting conclusion from the created simulation.
    - Example: All agents have some sort of happiness value, ranging from bad (0) to good (1). Show that by adding/removing/changing behaviour of agents how happiness changes over time, to better or worse!


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



## Results




## Challenge 1

- Clearly demonstrate BDI behaviour in agents.


## Challenge 2

- Clearly demonstrate improvement in agents behavior, let agents learn and improve over time. Avoiding other types of agents if they have had bad experience with them before, buying or not buying food from a bar based on past/heard experience.

 
### Discussion / Conclusion

