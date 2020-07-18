#include <Array.au3>
#region of helper functions
func rand($min, $max)
   return floor(random($min, $max, 1))
endfunc

func fill($what, $with)
   for $x = 0 to $width - 1 step 1
	  for $y = 0 to $height - 1 step 1
		 $world[$y][$x] = ($world[$y][$x] = $what) ? $with : $world[$y][$x]
	  next ;y
   next ;x
endfunc

Func dist($d1, $d2, $d3, $d4)
   $a = Abs($d1 - $d3)	; y dif
   $b = Abs($d2 - $d4)	; x dif
   return Sqrt(($a * $a) + ($b * $b))
EndFunc

func say($what)
   msgbox(1,"", $what)
endfunc

func main()
   while $room_fails_count < $room_fails_max
	  if ($room_count < $room_max) or ($room_max = 0) then
		 make_room()
	  else
		 exitloop
	  endif
   wend

   print()
endfunc

func print()
   local $string = _ArrayToString($world, "")
   msgbox(1,"map", $string)
endfunc
#EndRegion of helper functions

const $blank = "░"
global $xx[0]				; x points of placed rooms
global $yy[0]				; y points of placed rooms
const $width = 70			; width of the world
const $height = 70			; height of the world
global $world[$height][$width]	;2d array of the world
const $room_border = 1		; min gap between rooms and edge of the world
const $room_min_x = 3		; min width for rooms
const $room_max_x = 3		; max width for rooms
const $room_min_y = 3		; min height for rooms
const $room_max_y = 3		; max height for rooms
const $room_max = 50			; max number of rooms, (0 = no limit)
const $room_fails_max = 150	; max number of failed attempts to place a room before we give up
global $room_count = 0		; num of successfully placed rooms
global $room_fails_count = 0; num of failed attempts to place a room

fill("","░")
main()
print()

func make_room(); 	1.2
   local $flag_overlap = false																;to check if room overlaps so we can undo
   local $test_room_x = rand($room_min_x, $room_max_x)										;room width
   local $test_room_y = rand($room_min_y, $room_max_y)										;room height
   local $test_room_x_pos = rand($room_border, ($width - $test_room_x - $room_border))		;room spawn x pos (leftmost)
   local $test_room_y_pos = rand($room_border, ($height - $test_room_y - $room_border))		;room spawn y pos (upmost)

   #Region of place_room
   for $x = $test_room_x_pos to $test_room_x + $test_room_x_pos - 1 step 1
	  for $y = $test_room_y_pos to $test_room_y + $test_room_y_pos - 1 step 1

		 ; check cell
		 if $world[$y][$x] = "░" then
			local $flag_border_touch = false

			;check border cells
			for $xi = $x - $room_border to $x + $room_border step 1
			   for $yi = $y - $room_border to $y + $room_border step 1

				  if $world[$yi][$xi] = "▓" then 	; overlap with something, fail
					 $flag_border_touch = true
					 $flag_overlap = true
					 exitloop 4
				  endif
			   next ;yi
			next ;xi

			if ($flag_border_touch = false) then	; no overlaps
			   $world[$y][$x] = "?"
			endif

		 else
			$flag_overlap = true
		 endif

	  next ;y
   next ;x
   #EndRegion of place_room

   if $flag_overlap then	; room failed to be placed
	  fill("?", "░")
	  $room_fails_count += 1

   else						; room successfully placed
	  $room_fails_count = 0
	  $room_count += 1
	  local $x_center = $test_room_x_pos + floor($test_room_x / 2)
	  local $y_center = $test_room_y_pos + floor($test_room_y / 2)
	  ;say($x_center)
	  _arrayadd($xx, $x_center)
	  _arrayadd($yy, $y_center)
	  $world[$y_center][$x_center] = "░"

	  ;print()

	  if $room_count > 1 then									;ok
		 local $goal[2]
		 $goal = find_closest_room($x_center, $y_center)

		 draw_hallway($x_center, $y_center, $goal[1], $goal[0])	; y x

	  endif



   endif

endfunc


;this outputs correctly
func find_closest_room($x_this, $y_this)
   local $result[2]	; y x
   local $closest = null
   local $distance_best = 99999999
   local $distance = 99999999

   for $checking = 0 to ubound($xx) - 1 step 1	; <--- GOOD			(properly iterates through our newly built list)
	  local $x_to_check = $xx[$checking]
	  local $y_to_check = $yy[$checking]
	  $distance = dist($x_this, $x_to_check, $y_this, $y_to_check)
	  ;say($distance)
	  if ($distance < $distance_best) and ($distance > 0) then
		 $distance_best = $distance
		 $closest = $checking						;array index of the closest other room
	  endif

   next

   ;say($closest & "/" & ubound($xx))
   $result[0] = $yy[$closest]
   $result[1] = $xx[$closest]

   return $result	; y x
endfunc




func draw_hallway($x_from, $y_from, $x_to, $y_to)
   local $x1 = $x_from
   local $y1 = $y_from
   local $x2 = $x_to
   local $y2 = $y_to
   local $connected = false

   local $ok = "▓"
   local $hallway = "▒"

   while $connected = false
	  ;print()

	  ;horizontal
	  if $x_from < $x_to then
		 ;move right?
		 $x_from += 1

	  elseif $x_from > $x_to then
		 ;move left?
		 $x_from -= 1

	  ;vertical
	  elseif $y_from < $y_to then
		 ;move down?
		 $y_from += 1

	  elseif $y_from > $y_to then
		 ;move up?
		 $y_from -= 1

	  ;finished
	  else
		 ;say("connected")
		 $world[$y_from][$x_from] = "▒"
		 $connected = true
		 fill("▒", "▓")
		 fill("?", "▓")

	  endif


	  ;check for a connection
	  if ($world[$y_from - 1][$x_from] = $ok) or ($world[$y_from + 1][$x_from] = $ok) or ($world[$y_from][$x_from - 1] = $ok) or ($world[$y_from][$x_from + 1] = $ok) then
		 ;say("connected 2")
		 $world[$y_from][$x_from] = "▒"
		 $connected = true
		 fill("▒", "▓")
		 fill("?", "▓")

	  else ;no connection yet
		 $world[$y_from][$x_from] = "▒"

	  endif



   wend
endfunc










#cs

   2-step dungeon generator loop


   0. make a rectangular room (to start with)

   1. make another rectangular room
	  a. does it collide with another room?
		 (if so erase it, try again, add a fail.)
	  b. does it have another room within range hallway_dist_max?
		 (if so erase it, try again, add a fail.)
	  c. connect the rooms together.
		 draw loop
		 cancel the loop when we touch a hallway or room

   2. repeat until you have enough rooms, or you failed enough


	  ;check that this isn't the first room to be placed, and we still have room to place stuff
	  if $room_count > 1 then

		 ;find the closest room to this room
		 ;iterate through list of points placed so far
		 local $closest = null
		 local $distance_best = 99999999
		 local $distance = 99999999

		 for $checking = 0 to ubound($points) - 1 step 1	; <--- GOOD			(properly iterates through our newly built list)
			;if distance between cc and 00 is less than distance_best then save
			;say($points[$checking])
			local $cc = stringsplit($points[$checking], ",")
			$distance = dist($test_room_x_pos, $cc[2], $test_room_y_pos, $cc[1])
			if ($distance < $distance_best) and ($distance > 0) then
			   $distance_best = $distance
			   $closest = $checking		;array index of the closest other room
			   say("closest :" & $closest _
			   &@CRLF& "distance:" & $distance _
			   &@CRLF& "distbest:" & $distance_best)

			endif

		 next ; closest

		 _arraydisplay($points)	;		<--- GOOD
		 ;	$test_room_x_pos = $cc[2]	<--- BAD
		 ;	$test_room_y_pos = $cc[1]	<--- BAD

		 local $x1 = $test_room_x_pos
		 local $y1 = $test_room_y_pos
		 local $x2 = $cc[2]
		 local $y2 = $cc[1]



		 local $disty = dist($x1, $x2, $y1, $y2)
		 say("distance is " & $disty)
		 say("closest is room #" & $closest + 1)

		 print()


		 ;$points[$closest] is the closest room to 00
		 local $connected = false
		 local $placed[2]
		 local $cc = stringsplit($points[$closest], ",")
		 local $diff_x = 0
		 local $diff_y = 0
		 while $connected = false ;begin drawing hallway to connect 00 and cc
			;find the distances we need to go
			$diff_x = $cc[1] - $test_room_x_pos
			$diff_y = $cc[2] - $test_room_y_pos
			msgbox(1, "differences", _
						"X: " & $diff_x & " = " & $cc[2] & " - " & $test_room_x_pos _
			  & @crlf & "Y: " & $diff_y & " = " &  $cc[1] & " - " & $test_room_y_pos _
			  & @crlf & "00: " & $test_room_x_pos & ", " & $test_room_y_pos _
			  & @crlf & "cc: " & $cc[2] & ", " & $cc[1])

			;LEFT OR RIGHT
			if $diff_x < 0 then
			   msgbox(1,"horizontal 1",$diff_x)
			   $cc[1] += 1


			elseif $diff_x > 0 then 	; go left
			   msgbox(1,"horizontal 2",$diff_x)
			   $cc[1] -= 1


			;UP OR DOWN
			elseif $diff_y < 0 then
			   msgbox(1,"vertical 1",$diff_y)
			   $cc[2] += 1

			elseif $diff_y > 0 then 	; go up?
			   msgbox(1,"vertical 2",$diff_y)
			   $cc[2] -= 1

			else
			   msgbox(1,"connected","")
			   $connected = true

			endif

			;▒░▓
			;if $world[$cc[2]][$cc[1]] = "░" then
			   $world[$cc[2]][$cc[1]] = "▒"
			   ;_arraydisplay($cc)
			   msgbox(1,"00:", "x: " & $test_room_x_pos & @crlf & "y: " & $test_room_y_pos)
			   print()
			;endif

			; by this point we should have reached cc







#ce
