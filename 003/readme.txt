dungeon_gen_3

basic idea:
	- quickly add a connection_distance_max check into dungeon_gen_2 when placing rooms
	- this was supposed to make the map more dense and have less hallways 
	
result:
	- the map isn't any denser and the hallways are more or less the same.
	- in addition, the rooms generate in a "\" diagonal orientation which is strange.	
	- output is still pretty interesting
	
what i learned:
	- i need to redo this and start over for dungeon_gen_4, but try to implement everything
	  i've learned from 1/2/3 into 4.


...


dungeon_gen_3.1

correction:
	- it seems the distance formula being used this entire time wasn't right
	- either that or i was originally giving it x1, y1, x2, y2 arguments
	- this:
		$a = Abs($d1 - $d3)	; y dif
		$b = Abs($d2 - $d4)	; x dif
	- was changed to:
		$a = Abs($d1 - $d2)	; y dif
		$b = Abs($d3 - $d4)	; x dif	
		
result:
	- the "\" diagonal distribution of rooms has disappeared.
	- rooms are still not connecting
	- i believe the rooms arrays aren't getting cleansed upon a failure,
	  which leads to future rooms pairing up with these ghsot rooms,
	  rooms that don't exist on the map, but exist within the point arrays
	- output is interesting
	  
what i learned:
	- well the distance formula for gen4 is now fixed, so that's nice
