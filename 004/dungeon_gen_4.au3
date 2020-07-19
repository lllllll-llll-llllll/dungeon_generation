#include <Array.au3>
const  $world_width = 70		;width of the world
const  $world_height = 70		;height of the world
global $world[$world_height][$world_width]	;the world
global $rooms_x[0] 		;list of all rooms x coords
global $rooms_y[0]		;list of all rooms y coords
const  $rooms_width_min = 5		;min width possible for rooms
const  $rooms_width_max = 10	;max width possible for rooms
const  $rooms_height_min = 5		;min height possible for rooms
const  $rooms_height_max = 10		;max height possible for rooms
const  $rooms_border = 1		;minimumgap between rooms
global $rooms_count = 0				;current amount of rooms
const  $rooms_max = 100				;max amount of rooms that can be placed
global $rooms_fail_count = 0			;current amount of fails at placing a room
const  $rooms_fail_max = 50			;max amount of fails before we stop trying to make new rooms
const  $connection_distance_max = 15	;max distance between a new room and the next closest room
const $tile_empty = "0"
const $tile_wall = "100"
const $tile_hall = "200"
const $tile_wall_trial = "3"
const $tile_hall_trial = "4"

;█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
main()
func main()
   prep()

   while ($rooms_count < $rooms_max) and ($rooms_fail_count < $rooms_fail_max)
	  global $bad = false
	  global $xx = 0
	  global $yy = 0
	  global $x_end = 0
	  global $y_end = 0

	  room_make()
	  room_find()
	  room_connect()
	  room_apply()
	  room_undo()

   wend

   map_print()

endfunc

;█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
func room_make()
   local $room_width = rand($rooms_width_min, $rooms_width_max)
   local $room_height = rand($rooms_height_min, $rooms_height_max)
   local $room_x = rand($rooms_border, ($world_width - $room_width - $rooms_border))
   local $room_y = rand($rooms_border, ($world_height - $room_height - $rooms_border))
   $xx = $room_x + floor($room_height / 2)
   $yy = $room_y + floor($room_height / 2)
   _arrayadd($rooms_x, $xx)
   _arrayadd($rooms_y, $yy)

   for $x1 = $room_x to $room_width + $room_x - 1 step 1
   for $y1 = $room_y to $room_height + $room_y - 1 step 1

	  if $world[$y1][$x1] <> $tile_empty then
		 $bad = true
		 return
	  endif

	  for $x2 = $x1 - $rooms_border to $x1 + $rooms_border step 1
	  for $y2 = $y1 - $rooms_border to $y1 + $rooms_border step 1

		 if ($world[$y2][$x2] = $tile_wall) or ($world[$y2][$x2] = $tile_hall) then
			$bad = true
			return
		 endif

	  next
	  next

	  $world[$y1][$x1] = $tile_wall_trial

   next
   next

endfunc

func room_find()
   if $bad then return
   if $rooms_count < 1 then return

   local $closest = null
   local $distance_best = 999999999
   local $distance = 999999999

   if $rooms_count = 1 then
	  $y_end = $rooms_y[0]
	  $x_end = $rooms_x[0]
	  return
   endif

   for $i = 0 to ubound($rooms_x) - 1 step 1
	  local $x_to_check = $rooms_x[$i]
	  local $y_to_check = $rooms_y[$i]
	  $distance = distance($xx, $x_to_check, $yy, $y_to_check)

	  if ($distance < $distance_best) and ($distance > 0) then
		 $distance_best = $distance
		 $closest = $i
	  endif

   next

   if ($distance_best > $connection_distance_max) then
	  $bad = true
	  return
   endif

	  $y_end = $rooms_y[$closest]
	  $x_end = $rooms_x[$closest]

endfunc

func room_connect()
   if $bad then return
   if $rooms_count < 1 then return

   while true
	  if $xx < $x_end then
		 $xx += 1

	  elseif $xx > $x_end then
		 $xx -= 1

	  elseif $yy < $y_end then
		 $yy += 1

	  elseif $yy > $y_end then
		 $yy -= 1

	  else
		 if $world[$yy][$xx] = $tile_empty then $world[$yy][$xx] = $tile_hall_trial
		 return
	  endif

	  if $world[$yy][$xx] = $tile_empty then $world[$yy][$xx] = $tile_hall_trial

   wend

endfunc

func room_apply()
   if $bad then return

   $rooms_count += 1
   map_fill($tile_wall_trial, $tile_wall)
   map_fill($tile_hall_trial, $tile_hall)

endfunc

func room_undo()
   if not $bad then return

   $rooms_fail_count += 1
   map_fill($tile_wall_trial, $tile_empty)
   map_fill($tile_hall_trial, $tile_empty)

   _arraydelete($rooms_x, ubound($rooms_x) - 1)
   _arraydelete($rooms_y, ubound($rooms_y) - 1)

endfunc

;█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████
func map_fill($what, $with)
   for $x1 = 0 to $world_width - 1 step 1
   for $y1 = 0 to $world_height - 1 step 1
	  $world[$y1][$x1] = ($world[$y1][$x1] = $what) ? $with : $world[$y1][$x1]
   next
   next
endfunc

func map_print()
   map_fill($tile_empty,"░")
   map_fill($tile_hall, "▒")
   map_fill($tile_wall, "▓")
   msgbox(1,"dungeon", _ArrayToString($world, ""))
   map_fill("░", $tile_empty)
   map_fill("▒", $tile_hall)
   map_fill("▓", $tile_wall)
endfunc

func distance($d1, $d2, $d3, $d4)
   $a = Abs($d1 - $d2)
   $b = Abs($d3 - $d4)
   return Sqrt(($a * $a) + ($b * $b))
endfunc

func rand($min, $max)
   return floor(random($min, $max, 1))
endfunc

func prep()
   map_fill("", $tile_empty)
endfunc
