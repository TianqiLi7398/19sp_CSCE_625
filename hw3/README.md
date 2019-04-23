## HW 3, Wumpus simulation
### 2019 spring, Tianqi Li, Texas A&M University 
The solution to the Wumpus world is based on logic and the memory accumluated of the map, with only information of map's size (4 * 4) and the start point (1,1) and orientation 0 degree.

The percept of the player: [Stench, Breez, Glitter, Bump, Scream]
The player has several mode
- exploring (don't sense any dangers information, like Breeze or Stench)
- meet breeze
- meet stench
- go back to start point

#### 1. exploring
When the player is exploring, it will mark the 'visited' cells and make the adjecent cells (left, right, front, back) 'safelocation';
It will avoid repeating visiting same place by recongnizing the visited adjcent cells and turn left/right.

#### 2. meet breeze
When the player meet the breeze, because of there are uncertain number of pits and limited number of actions, the action is the same, turn left twice and go forward so that the player can get ride of breeze area.

#### 3. meet Wumpus
There is always a chance to kill Wumpus (we know we have only one Wumpus), as long as we have enough quantity of actions. 
All possible scenario are listed below

##### 1. you are certain there is only one possible location for Wumpus by using 'safelocastion'

```
|     |  X  |     |
--------------------
|     |  ^  |     |
--------------------
|     |     |     |


|     |     |     |
--------------------
|  X  |  ^  |     |
--------------------
|     |     |     |


|     |     |     |
--------------------
|     |  ^  |  X  |
--------------------
|     |     |     |
```

The following action is just adjust the orientation and shoot the arrow.

##### 2. there are more than Wumpus

```
|     |  X  |     |
--------------------
|  X  |  ^  |     |
--------------------
|  A  |     |     |


|     |     |     |
--------------------
|  X  |  ^  |  X  |
--------------------
|  A  |     |     |


|     |  X  |     |
--------------------
|     |  ^  |  X  |
--------------------
|     |     |  A  |

|     |  X  |     |
--------------------
|  X  |  ^  |  X  |
--------------------
|  A  |     |  B  |


```

We cannot determine the place unless we check cell A first, and for the situation there are 3 cells to check, we also need to go B, then we can determin the location of Wumpus and kill it.

#### 4 Go back to start point

The time point of deciding to go back to start cell are
a. The agent get a gold
b. The agent has used enough actions, I use 

M =  Manhattan distance of the agent's location to start point (1,1) + number of actions used > Maximum num of actions (128)

to determine the point to go back.

When it is going back, the agent will just follow the 'safeloation' marked cells, and try to face toward (1,1) as possible.

When (1,1) is reached, climb out and it's done.

### Sum:

I didn't fully utilize the functions in Prolog, anyway this is an exhaustive method to do the logical inference.....
