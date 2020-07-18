my messy attempts to create an ascii dungeon generation script in autoit.
the idea or intended method will be described, whether or not it was
a success, and what the output (if any) looked like.



▓▓▓▓▓▓▓▓▓dungeon_gen_1▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 
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




▓▓▓▓▓▓▓▓▓dungeon_gen_2▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 
basic idea:  
	1. generate a single room  
	2. search for the nearest other room  
	3. connect both of these rooms  
	4. repeat until you have enough rooms  

confusions:
	- sometimes the rooms aren't connected and 'islands' form,
	  sections of connections that aren't connected as a whole,
	  this should be impossible but i must have made a mistake.
	- having to write array[y][x] is still confusing.

result:
	- it produces interesting looking results

what i learned:
	- separating each logical phase of generation into its own function improves readability.  
	  ie. make_rooms > find_closest_room > draw_hallway. it could be done better.  
	- there should be an adjustable control for hallway length, like a maximum distance.  
	  in the beginning it currently generates massive hallways connecting stuff.  
	  a connection limit can simply skip connecting rooms that are too far apart and try again.  
	- make room >  make connection > repeat - is easier than - make rooms > connect them all  
	- this method works for making connected rooms and it's simple,  
	  it just needs refined and improved somehow.  


▓▓▓▓▓▓▓▓▓dungeon_gen_3▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 
???


