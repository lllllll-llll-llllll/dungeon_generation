#cs
declare variables
   everything we need goes here?

world_prep()
   open prefabs.txt
   iterate through it until you find dimensions
   add dimensions line number to an array


room_select()
   room_no = random(0 through ubound(prefabs))
   room_x = leftmost position
   room_y = upmost position


room_check()
   go to line number $room_no of $prefabs
   room_Width = first stringplit string
   room_height = second stringsplit string
   slice_loop:
	  advance a line, set that to room slice
	  stringsplit room_slice using " " empty space
   iterate through y
	  slice_loop?
   iterate through x
	  check the spaces in room_slice array to make sure we have enough room to place the room
	  if any collisions occur, consider it a fail


room_build()
   iterate through it again, placing tiles into the world.
   since we checked and verified there was no collision this should be simple.


connection_find()
   get the connection points of our room stored in an array.
	  we can build this array from the previous step when we are checking.
	  when we encounter chars of "0" or whatever denotes a 'door', we can just add it to an array
   for each of our connection points in this room, find the closest other point in the world
	  best_this?
	  best_other?
		 these show which points we are going to use to build a connection between the two rooms


connection_build()
   we find which direction we need to start building a hallway
   whichever direction is the longest we will do first
   when we reach 50% of that direction, we will switch and do the other direction
   it ends when the current points arent less than the goal points
   perhaps at every corner or turn that we make, we can add these to the list of possible points to build upon
	  this would help contribute visually to making it look more itneresting
	  the dead end hallways would also be easier and cleaner to create if we had more ponts to connect to


room_success()


room_failure()


dead end connection phase here...
#ce

#include <array.au3>

;constants
global const $world_width  = 50
global const $world_height = 50
global const $room_border = 1
global const $room_count_max = 100
global const $room_fail_count_max = 100

;tiles
global const $tile_empty = '0'
global const $tile_floor = '1'
global const $tile_door  = '2'
global const $tile_hall  = '3'
global const $tile_floor_trial = '4'
global const $tile_door_trial  = '5'
global const $tile_hall_trial  = '6'


;variables
global $world[$world_height][$world_width]
global $prefab[0]
global $prefab_positions[0]
global $room_no = null
global $room_width  = null
global $room_height = null
global $room_x = null
global $room_y = null
global $room_x_end = null
global $room_y_end = null
global $room_count = 0
global $room_fail_count = 0
global $bad = false


main()
func main()
   world_prep()

   while ($room_count <= $room_count_max) and ($room_fail_count <= $room_fail_count_max)
	  room_select()
	  room_check()
	  room_build()
	  ;connection_find()
	  ;connection_build()
	  room_success()
	  room_fail()
   wend

   print()

endfunc


func world_prep()
   assert($world_width  > 9)
   assert($world_height > 9)
   assert($room_border >= 0)
   if $bad then return

   local $prefab_file = fileopen(@ScriptDir & "\prefabs.txt")
   $prefab = FileReadToArray($prefab_file)

   for $line = 0 to ubound($prefab) - 1 step 1
	  local $string = $prefab[$line]
	  if StringInStr($string, "x") then
		 _ArrayAdd($prefab_positions, $line)
	  endif
   next ;line

   ;_arraydisplay($prefab_positions)

endfunc


func room_select()
   if $bad then return

   $room_no = rand(0, ubound($prefab_positions) - 1)
   local $dimensions = stringsplit($prefab[$prefab_positions[$room_no]], "x", 2)
   $room_width  = $dimensions[0]
   $room_height = $dimensions[1]
   $room_x = rand($room_border, ($world_width - $room_width - $room_border))
   $room_y = rand($room_border, ($world_height - $room_height - $room_border))
   $room_x_end = $room_x + $room_width
   $room_y_end = $room_y + $room_height

endfunc

;this is failing atm and fucking everything up
func room_check()	;iterate through $world, fail at non-empty
   if $bad then return

   for $y = $room_y to $room_y_end step 1
   for $x = $room_x to $room_x_end step 1
	  if $world[$y][$x] <> $tile_empty then
		 $bad = true
		 msgbox(1,"room_check fail","")
		 return
	  endif
   next
   next

endfunc


func room_build()	;iterate through $prefab, assign tile to $world
   if $bad then return
   local $start = $prefab_positions[$room_no]
   local $tiles = null

   for $y = 0 to $room_height - 1 step 1
	  $tiles = $prefab[$start + $y + 1]
	  msgbox(1,"tiles", $tiles)

	  for $x = 0 to $room_width - 1 step 1
		 local $char = int(StringMid($tiles, $x + 1, 1))
		 if $char > 0 then $world[$room_y + $y][$room_x + $x] = $char + 3
	  next

   next

endfunc


func room_success()
   if $bad then return

   $room_count += 1
endfunc


func room_fail()
   if not $bad then return

   $room_fail_count += 1
   $bad = false
endfunc






func assert($expression)
   if not $expression then $bad = true
endfunc


func rand($min, $max)
   return random($min, $max, 1)
endfunc


func print()
   msgbox(1,"number of rooms", $room_count)
   msgbox(1,"map", _ArrayToString($world, ""))
endfunc














