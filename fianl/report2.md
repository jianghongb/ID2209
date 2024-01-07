## ID2209 – Distributed Artificial Intelligence and Intelligent Agents
# Final Project

<p align="center"> Group 16 </p>
<p align="center"> Hong Jiang & Yayan Li </p>
<p align="center"> 7th Jan 2024 </p>

In this assignment, we were tasked with creating a environment simulation that shows different behaviour and interactions between different types of agents. The place where agents meet and the individual agent's attributes affect their interactions. The purpose of this project is not only to help us review the GAMA skills that we have learned through previous assignments, but also help us get more insights into the interactions between multi-agents by  implementinga more comprehensive simulation.

## Requirements:

- Create at least 5 different types of guests.
- Each guest type has at least 1 different set of rules on how they interact with other types.
- They also have at least 3 personal traits that affect these rules.
- They have at least 2 different types of places where agents can meet. (Roaming not included.)

## How to Run
Run GAMA V1.9.2 and import Final.gaml as a new project. Press my_experiment to run the simulation. 

## Species
### Visitors
We create 5 different types of visitors, including normal, partylover, chillPerson, journalist and politician. All visitors have three attributes, including wealthy, talkative and generous. We also use mood numbers to represent the happiness of all visitors. A Mood number greater than 0 means they are happy. A Mood number equal to 0 means they are taking a rest or having no feeling. A Mood number lower than 0 means they are unhappy. Partylover and Chillperson are rivals but the relationship may change due to two factors. The same goes for journalist and politician. 
Visitors have the following features:
1. Normal people interact with no one.
2. Partylover only influence the mood of chillPerson when they are interacted. But partlover is immune to chillperson.
3. ChillPerson gets annoyed with partylover only when they meet at a bar. Attitude towards partylover may change based on the behavior of partylover.
4. Journalist gets annoyed with politician only when they meet at NewsCenter. Attitude towards politician change based on different places.
5. Journalist gets annoyed with Journalist when they are unwilling to answer Journalist's question.



### Bar
Visitors come here become happy except for chillperson. 

### NewsCenter
Partylover has no interest in attending news meeting. Normal people and ChillPerson come here to listen but no mood would change.  Journalists asks politicians questions and is never feel satisfied. Politicians get angry when they are unwilling to answer. 

### Home
Sometimes, visitors want to take a rest and stay in a calm mood at 0.

## Interaction Rules
### How places influence the rules 
1. Partylover and ChillPerson get well along when they are taking rest(at home). But chillperson get annoyed with partylover when they meet at bar, because partylover make too much noise.
2. Journalist get well along with politician when they meet at bar, because they are enjoying music and drinking. But they get angry when they meet in NewsCenter.

### How visitors' attributes influence the rules 
1. If partylover and chillperson are both talkative, and partylover is generous to buy chillperson a drink, they can get well along with.
2. If politicians are talkative, it means they are satisfied to the answer, politicians' mood would turn to 0 from minus number. Journalists also get better but still not satisfied with politicians. 

## Implementation
We set Agent Visitors three different attributes and five different types. Visitors communicate with others with FIPA protocol and send messages with their attributes and types. By identifying different places, different types of visitors and different places, visitors change their moods and behaviors which is show by two charts. A serial chart shows the moods number of every visitor each time. A pie chart counts the sum of conflict and peace. When politician refuses to answer questions, conflict counts for one. The same goes for peace counting when politician is willing to answer questions.s

## Results
![](result.png)

According to the log information, it tells us "visitor2:I am a chillPerson I am at a bar. It is too noisy, I am unhappy." Then we can view the serial chart on x=2 axis, the moods number equals to -5 representing visitor2 is unhappy now. And others moods numbers are presenting visitors' moods accordingly. The pie chart below shows the sum of the conflict and peace between politicians and journalists.

 
### Discussion / Conclusion

All agents have some sort of moods value, ranging from bad (negative number) to good (positive number) and 0 represents peaceful mood. By changing behaviour of agents and moving agents to different places, the moods change accroding to the rules we set for them.


