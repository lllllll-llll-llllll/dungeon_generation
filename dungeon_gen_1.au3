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
#cs
   0 1 2 3 4 5 6 7 8 9  - 10
   01 23 45 67 89       - 5
   0123 456789          - 2
   0123456789           - 1
   list_0 : 0 1 2 3 4 5 6 7 8 9	(contains all points)
   round 1
   list_1 : 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
   list_2 : 01
   list_1 : 2, 3, 4, 5, 6, 7, 8, 9
   list_2 : 01, 23
   list_1 : 4, 5, 6, 7, 8, 9
   list_2 : 01, 23, 45
   list_1 : 6, 7, 8, 9
   list_2 : 01, 23, 45, 67
   list_1 : 8, 9
   list_2 : 01, 23, 45, 67, 89
   list_1 : ''
#ce


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


	  #cs









	  #ce

   wend




EndFunc








#cs
   list 1 = random points on map

	  first phase

   iterate through list 1
   find closest point to it
   this pair becomes a new list : list1-1
   remove them from list 1

   continue. making new pair lists, ie list 1-2. 1-3, etc
   until there are no more points left in list 1
   if there is only 1 point left, add it to the closest point-pair


   do this for the next generation until all the point pairs have been connected together





   0 1 2 3 4 5 6 7 8 9  - 10
   01 23 45 67 89       - 5
   0123 456789          - 2
   0123456789           - 1




                            4......
            0.....                .        ..........X
                 .                .        .
                 .                .        .
                 .                5.........
                 .                         .
        .........1                         .
        .                                  .
        .                                  .
        .                                  .
        .                     .............X...................X
        2...........          .                        .
                   .          .                        .
                   3...........                        .
                              .                        .
                              .                        .
                              .                        .
                              X                        X







							  0+5 1+6 2+3 4+7 8+9
							   a   b   c   d   e

							  05+16 23+89 47
							    f     g

							  47+2389
							    h

							  0516+472389
							      i








       fffff1bbbbbbbbb
       f             b              8eeeeeeeeeeeeeeeeeeeeeg
       f             b                           ccccccccc2
       f             b                           c       e
       f             6                           c       e
       f                                         c       e
       0aaaaaaaiiiiiiiiiiiiiiiiii                c       e
              a                 i                c       e
              a                 i                3       e
              a                 7dd              h       e
              5                   d              h       e
                                  d              h       e
                                  d              h       e
                                  4hhhhhhhhhhhhhhh       9


















 points =  x/y of all the room centers
 point =   map of the center points

 	number of connections = $rooms_count * 1.5



   list of center points of our rooms
   iterate though all points, compare to other points
   find the next closest point, the nearest neighbor

   the difference in x is how far we will draw horizontal portion of a hallway.
   the +/- is which direction it will be going.
   the difference in y is how far w ewill draw the verical portion of a hallway
   the +/- is which direction it will be going.

   draw horizontal lines and then draw vertical lines

   if diff_x <> 0 Then



   will this connect everything. i dont think it will.



   local $points_edit = $points
   local $list_pairs[0]
   while $checking ; go through list 1
	  $base = $points_edit
	  local $split1 = stringsplit($base, ",")
	  local $x1 = $split1[2]
	  local $y1 = $split1[1]
	  local $distance_min = 100000
	  local $distance = 0
	  local $x_best = 0
	  local $y_best = 0

	  for $compare in $points
		 local $split2 = stringsplit($compare, ",")
		 local $x2 = $split2[2]
		 local $y2 = $split2[1]

		 $distance = dist($x1, $y1, $x2, $y2)
		 if $distance < $distance_min then
			$distance_min = $distance
			$x_best = $x2
			$y_best = $y2

		 EndIf

	  next ; compare

	  ; we know the shortest point connecting first point of list 1 with some other point
	  ; remove them?
	  $best =
	  _ArrayAdd($list_pairs, $points_edit[0])		;add first xy of pair to pairlist
	  _ArrayDelete($points_edit, 0)





   wend ; base






#ce