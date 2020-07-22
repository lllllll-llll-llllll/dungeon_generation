dungeon gen 6

  the basic approach for this will be same as before, we will generate a randomly sized room,
  then draw a hallway to connect it to the closest room/point, then repeat. however, the
  size/shape/contents of each room will be determined by text bitmap prefabs for this.
  
  prefabs will look like this:
  
  5x4         ; dimensions
  . 1 0 1 .   ; room contents
  0 1 1 1 0   ; ...
  1 1 1 1 1   ; ...
  . 1 0 1 .   ; ...
  <newline>   ; spacing between prefabs
  
  5 being the width, 4 being the height
  so rooms that are generated at 5 by 4 will use this prefab.
  . being nothing
  1 bieng floor space tiles denoting the regions of a room
  0 being floor space tiles that also denote potential connection points between other rooms
  
  these prefabs will be stored in a text file, prefabs.txt
  
  the program will check this prefabs.txt and build up a list of possible rooms by storing
  their line positions in the text file.
  example of how program will work:
  array prefabs = [1, 10, 17, 23, 30, 39, 52]
  this lets us rand(0, ubound(prefab)) to pick a room
  say we get 2.
  prefabs[2] tells us to go to line 17 in prefabs.txt
  we immediately land on the room dimensions.
  we check the world if we have enough space to place the prefab.
  if a collision occurs we fail and try again
  if no collision occurs we once again iterate through world and place tiles according to what
  is in the prefab
  after this, we attempt to draw a hallway connecting our room with another room/point
  if we can't or something, we fail and try again
  we do this until we have placed enough rooms
  
  probably it will be easiest to do simple prefabs first just to figure how this works
