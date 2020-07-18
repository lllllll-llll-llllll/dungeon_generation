dungeon_gen_1

basic idea:  
	1. generate a bunch of rooms  
	2. connect them all somehow  

ideas that were implemented:
	- generate 2d array of the world  
	- generate rectangular rooms  
	- rooms have random height and width  
	- if a room overlaps with another room, it fails and tries again. 
	- after so many fails, the script ends  
	- you can specify a limit to how many rooms to make  
	- if a room is successfully placed, add its coordinates to an array  
	- rooms can have an adjustable gap between them  

ideas that i couldn't implement: 
	- the hallway generation algorithm i came up, i couldn't translate it from paper.
	  you have a list of points of the rooms which get successively paired/connected.
	  phase 1 connects 1 room to its closest room, they form a pair. you do this for
	  all unpaired rooms. phase 2 connects the pairs formed from phase 1 to form a
	  pair-pair. etc... until everything is a pair of pairs of pairs all connected.
	  doing this on paper produces what looks like a minimum spanning tree. this was
	  interesting to me because other guides seem to use delaunay triangulation to
	  arrive at a minimum spanning tree.  

mistakes:  
	- storing xy coordinates for the rooms as a string in an array  

confusions:  
	- i think of x as horizontal, and y as vertical, like on a graph, but in a 2d array
	  it is the other way around. maybe there is a way to just do everything as array[x][y]
	  and simply rotate the end result? having to write array[y][x] is confusing.  

result:  
	- it can output rooms and their center points, but they aren't connected in any way.  

what i learned:  
	- connecting everything together is probably the hardest part of generating a dungeon.  
