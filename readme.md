This is an implementation of [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life) that uses a metaphor of a living world where "Pods" and "Embryos" live and die in cycles. It is the test implementation of an idea that started during the [Global Day of Code Retreat](http://coderetreat.org/) 2011 (Tampa Bay).  The time to complete the initial working game was limited to an afternoon.

This isn't a super polished final implementation, but maybe I'll make some improvements over time.

## Motivation

This is probably **not** the most straightforward implementation of the game, but is a study that tries to address some questions / limitations:

* How can the game be implemented in a way that is truly infinite?
* The organisms should not need the world to tell them their environment.
* The implementation should use a very strong metaphor.
* Arrays can not be used. (One of the code retreat challenges).
* Bonus Challenge: Short Methods (8 lines or less)
    * *Close, but not quite there. I think my longest are 11 lines long.*

See "Background" for more info on the above.

## The Pod Story

Somewhere there is a World of infinite size. In that world live stationary life forms called Pods. Once per cycle all pods release seeds in all directions and all in unison.  If a seed falls on the ground, it becomes an embryo which hangs out for a while, waiting for other seeds to fall in the same location to fertilize it further.  Exactly three seeds combine to birth a new Pod.  If a seed falls on a Pod, the Pod eats it.  In fact, Pods have no other means of obtaining food beyond eating the seeds of other pods.* Pods are greedy little things and will keep eating seeds even if it kills them, which it eventually will.

**The fact that the material used for reproduction and the material used for food are identical is the reason we keep the Pods in their own sick little world and don't let them become part of ours.*

When seeds are released, some interesting things happen:

1. Any live Pod that eats less than two seeds dies of undernourishment.
1. Any live Pod that eats two or three seeds lives on, fat and happy, to the next generation.
1. Any live Pod that eats more than three seeds will die of overdose.
1. Any empty area on which exactly three seeds fall will fertilize into a new Pod.

## Background

There are some specific questions that I wanted to address with this exercise and some artificial constraints that I imposed as a result of the Code Retreat sessions.

### Truly Infinite

The Game of Life is supposed to be an infinite grid. Many implementations used a fixed size grid and track the states in each cell. "Infinite" is implemented by wrapping around so that any movement off one edge will appear back on the opposite side of the grid. I wanted something that would be truly infinite, even if you could only "peek" into a fixed sized window.

To solve this I wanted to use a coordinate system with a position that could have any x,y value.  In theory two organisms could be trillions of units away from each other and it shouldn't matter.  An organism has a position somewhere and it is not limited by arbitrary bounds set by the size of the world.

### The Organisms Should Not Need the World to Tell Them About Their Environment

Many implementations I've seen, and many implementations that were worked on in the Code Retreat sessions use the world to control the state of each position of the grid.  The World is responsible for stepping through each location in the grid, and determining what is there, and whether or not that location has any neighbors.  I kept thinking there should be some way to just make the organisms aware of what was around them or making them know that they were "touching" a neighbor.  On the other hand, maybe they just didn't need to know if they had neighbors or not.  Maybe they could just do their own thing and results could just happen.

I decided to remove the need for any organism to know if it had neighbors.  As a consequence, the world does not need to tell the organism anything at all.  The organism simply acts (casts seeds) and responds (gets fed).  The only thing the world needs to do is provide "addresses" for things to be (seed, Embryo, Pod).  When an organism is born, it is born into an address.  When a seed falls, it falls onto an address.  Based on what does or does not already exist at that address, different things happen. As a result, any need to calculate and count neighbors is removed.  An organism simply reaches out in all directions and if a neighbor is present in some direction, so be it.

### The Implementation Should Use a Strong Metaphor

The Code Retreat sessions imposed a few restrictions at times, ranging from, "Naming should be as descriptive as possible" to "Mute session, the only communication is through code".  With this implementation I wanted to practice making the code as clear and understandable as I could by using a very strong metaphor. Interesting to note, the metaphor actually helped tremendously in determining how the application should work.  As the metaphor evolved and became more clear, the code naturally followed suit and became simpler, more concise, and solutions to problems were readily apparent.

There is still some improvement that can be done here.  Shortly into writing I refactored almost everything and the names I settled on maybe weren't the best.

### Arrays Can Not Be Used

This limitation was imposed in the last Code Retreat session (half way through).  I loved the limitation because I couldn't help thinking the whole day that arrays were somehow an unnatural way to address the problem.

Rather than storing a grid in arrays as my collection, I opt to use hashes to store the addresses of Pods and the addresses of Embryos.  Currently, I use two hashes, @pods and @embryos, but this can possibly be done in one hash while just checking to see whether the item at a given location is a Pod or Embryo.

To create the output for display I iterate over a given number for width and height checking the corresponding coordinates in the @pods hash.  No arrays needed.

### Bonus Challenge: Use Short Methods of 8 Lines or Less

This was another Code Retreat restriction in one of the sessions. I actually wasn't trying to implement it this time around, but I found that in the process of trying to keep things clean all of my methods were super short anyway.  I went back to shorten some up.  I think I have two methods left that are 11 lines long.