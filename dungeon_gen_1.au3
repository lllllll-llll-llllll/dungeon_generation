#region ROOM GEN
#include <Array.au3>

func rand($min, $max)
   return floor(random($min, $max, 1))
endfunc

func fill($what, $with)
   for $x = 0 to $world_x - 1 step 1
	  for $y = 0 to $world_y - 1 step 1
		 $world[$y][$x] = ($world[$y][$x] = $what) ? $with : $world[$y][$x]
	  next ;y
   next ;x
endfunc

Func dist($d1, $d2, $d3, $d4)
   $a = Abs($d1 - $d3)	; y dif
   $b = Abs($d2 - $d4)	; x dif
   return Sqrt(($a * $a) + ($b * $b))
EndFunc


const $world_x = 30			; width of the world
const $world_y = 25			; height of the world
global $world[$world_y][$world_x]	;2d array of the world
fill("","░")
global $point = $world
global $points[0]
const $room_border = 1		; min gap between rooms and edge of the world
const $room_min_x = 4		; min width for rooms
const $room_max_x = 8		; max width for rooms

const $room_min_y = 3		; min height for rooms
const $room_max_y = 4		; max height for rooms

const $room_max = 0		; max number of rooms, (0 = no limit)
const $room_fails_max = 150	; max number of failed attempts to place a room before we give up
	  $room_count = 0		; num of successfully placed rooms
	  $room_fails_count = 0	; num of failed attempts to place a room

func make_room(); 	1.2
   local $flag_overlap = false
   local $test_room_x = rand($room_min_x, $room_max_x)
   local $test_room_y = rand($room_min_y, $room_max_y)
   local $test_room_x_pos = rand($room_border, ($world_x - $test_room_x - $room_border))
   local $test_room_y_pos = rand($room_border, ($world_y - $test_room_y - $room_border))

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

   if $flag_overlap then	; room failed to be placed
	  fill("?", "░")
	  $room_fails_count += 1

   else						; room successfully placed
	  fill("?", "▓")
	  $room_fails_count = 0
	  $room_count += 1

	  local $temp_x = $test_room_x_pos + floor($test_room_x / 2)
	  local $temp_y = $test_room_y_pos + floor($test_room_y / 2)
	  _arrayadd($points, string($test_room_x_pos & "," & $test_room_y_pos))
	  $point[$temp_y][$temp_x] = "▒"
	  $world[$temp_y][$temp_x] = "▒"

   endif

endfunc
#EndRegion /ROOM GEN

main()
func main()
   while $room_fails_count < $room_fails_max
	  if ($room_count < $room_max) or ($room_max = 0) then
		 make_room()
	  else
		 exitloop
	  endif
   wend

   print()
   ;hallway()
endfunc

func print()
   ;fill(".", "▓")
   ;fill("X", "░")
   local $string = _ArrayToString($world, "")
   msgbox(1,"map", $string)

   local $string = _ArrayToString($point, "")
   msgbox(1,"map", $string)
endfunc







func hallway()
  ; build list 0
   local $list_0x[0]
   local $list_0y[0]
   _arraydisplay($points)
   for $i in $points
	  local $split = stringsplit($i, ",")
	  msgbox(1,"",$split[1])
	  _arrayadd($list_0x, $split[1])
	  _arrayadd($list_0y, $split[2])
   next



   ; populate list 1
   local $list_1x = $list_0x
   local $list_1y = $list_0y

_arraydisplay($list_1x)

   ; init list 2
   local $list_2x[0]
   local $list_2y[0]

   ; keep iterating through list 1 until everything is gone
   while ubound($list_1x) > 0
	  ;these all might need to be placed before this while block
	  $base_x = $list_1x[0]
	  $base_y = $list_1y[0]
	  $distance = 999999
	  $closest = 0

	  ; find closest pair for [0][0] : [c][c]
	  for $a = 0 to ubound($list_1x) - 1 step 1
		 ;msgbox(1, "a", "")
		 local $comp_x = $list_1x[$a]
		 local $comp_y = $list_1y[$a]
		 local $this_distance = dist($base_x, $base_y, $comp_x, $comp_y)
		 if ($this_distance < $distance) and ($this_distance <> 0) then
			$distance = $this_distance
			$closest = $a
		 endif
	  next ;a

	  ; where is it stored?

	  ; store [c][c] values
	  $comp_x = $list_1x[$closest]
	  $comp_y = $list_1y[$closest]

	  ;remove [0][0] and [c][c] from lists
	  _arraydelete($list_1x, $closest)
	  _arraydelete($list_1y, $closest)
	  _arraydelete($base_x, 0)
	  _arraydelete($base_y, 0)

	  ;form pair of [0][0] and [c][c]
	  $pair_x = $base_x & "." & $comp_x
	  $pair_y = $base_y & "." & $comp_y

	  ;add pair to list 2
	  _arrayadd($list_2x, $pair_x)
	  _arrayadd($list_2y, $pair_y)

	  ;repeat for all the other things?
	  ; need to check that there isn't 1 left over or something

	  msgbox(1,"list 2:", "")
	  _arraydisplay($list_2x)
   wend

EndFunc
