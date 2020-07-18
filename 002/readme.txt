dungeon_gen_2

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
