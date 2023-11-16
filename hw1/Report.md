## ID2209 – Distributed Artificial Intelligence and Intelligent Agents
# Assignment 1 – Agents & stuff

<p align="center"> Group 16 </p>
<p align="center"> Hong Jiang & Yayan Li </p>
<p align="center"> 16th Nov 2023 </p>

In this assignment, we were tasked with creating a Basic Festival in GAMA. And implement communication between Guests agents and InformationCenter agent to get the location of Store agents when guests get hungry or thirsty. 
We also incorporated a SmallBrain component to store the locations of Store agents, allowing Guest agents to sometimes reach Stores directly without needing to communicate with the Information Center agent.

## How to Run
-Install Gama V1.9.2
-Import Festival as a new file
-Run the myExperiment

## Species
### Agent FestivalGuest
This agent was designed to simulate festival guests' behavior, focusing on locating and finding Store agents when they get hungry and thirsty. The important variables, reflexes and actions used to do are the value of hunger and thirst, . 

### Agent FoodStore & DrinkStore
FoodStore and DrinkStore offer different services. When the guests get to the FoodStore or DrinkStore, their value of hungry and thirsty would be replenished to default. 

### Agent InfomationCenter
The Information Center acts as a central hub for information about the locations of FoodStores and DrinkStores. It processes requests from FestivalGuests and provides directions to the nearest Store based on the guest's current needs.

### Agent Guard
This agent was responsible with removing bad guests when InformationCenter report it.

## Implementation

<Explain a little bit how you went on with your assignment>
We began by developing the FestivalGuest agent, focusing on simple behaviors such as seeking food and water. Once we established basic interactions between FestivalGuest and Store agents, we introduced the InformationCenter agent to facilitate more complex guest-store interactions. Implementing the SmallBrain component was pivotal in enabling guests to locate stores without always relying on the Information Center.

## Results
As you can see in the following log, Agent successfully completes the tasks.
AgentA: I‘m doing this
AgentB: Ok I‘m doing that
....
AgentB: Task2 completed at time xx.yy.zzzz
This can also be demonstrated from this fancy screenshot right here.
Figure 1: A screenshot of the final solution.


## Challenge 1
To complete the first challenge, we introduced List structures in FestivalGuest and InformationCenter agents, respectively. These structures efficiently handled the storage and retrieval of coordinates, streamlining the agent's decision-making processes.

## Challenge 2
In the second challenge, Guard agents wandering in the festival, waiting for certain triggers and maintaining a safe environment. 


### Discussion / Conclusion
Creating Agent Stores was no problem, because its attribute is simple and no actions. But Agent InformationCenter concerned more complex setting, such as recording the distance to agent Stores. Overall, we got familiar with GAMA platform and learnt the basic usage of GAMA.
