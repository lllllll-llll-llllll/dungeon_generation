#include <array.au3>
;constants
global const $world_width  = 100
global const $world_height = 100
global const $room_border = 1
global const $room_border_max = 10
global const $room_count_max = 1000
global const $room_fail_count_max = 1000
global const $name = rand(0,99999)


;debugging
;global const $logpath = @ScriptDir & "\" & $name & ".txt"
;global const $logfile = fileopen($logpath, 10)


;tiles
global const $tile_empty = '0'
global const $tile_floor = '1'
global const $tile_door  = '2'
global const $tile_hall  = '3'


;variables
global $world[$world_height][$world_width]
global $prefab[0]
global $prefab_positions[0]
global $room_no = null
global $room_width  = null
global $room_height = null
global $room_chance = null
global $room_distance_max = null
global $room_x = null
global $room_y = null
global $room_x_end = null
global $room_y_end = null
global $room_x_center = null
global $room_y_center = null
global $room_count = 0
global $room_fail_count = 0
global $bad = false

global $door_x = null
global $door_y = null
global $door_x_end = null
global $door_y_end = null
global $doors_x[0]
global $doors_y[0]
global $doors_x_end[0]
global $doors_y_end[0]



main()
func main()
   world_prep()

   while ($room_count <= $room_count_max) and ($room_fail_count <= $room_fail_count_max)
	  room_select()
	  room_chance()
	  room_check()
	  room_closest()
	  room_build()
	  door_closest()
	  hall_build()
	  room_success()
	  room_fail()
   wend

   image()
   ;print()

endfunc


func world_prep()
   assert($world_width  > 9)
   assert($world_height > 9)
   assert($room_border >= 0)
   if $bad then return

   local $prefab_file = fileopen(@ScriptDir & "\prefabs.txt")
   $prefab = FileReadToArray($prefab_file)

   for $line = 0 to (ubound($prefab) - 1) step 1
	  local $string = $prefab[$line]
	  if StringInStr($string, ",") then
		 _ArrayAdd($prefab_positions, $line)
	  endif
   next

   fill("", $tile_empty)

endfunc


func room_select()
   if $bad then return
   global $doors_x[0]
   global $doors_y[0]
   $room_no = rand(0, ubound($prefab_positions) - 1)
   local $data = StringStripws($prefab[$prefab_positions[$room_no]], 8)
   $data = StringSplit($data, ",")
   $room_width  = $data[1]
   $room_height = $data[2]
   ;$room_limit = $data[3]		not sure how to implement this yet but it will still be here. maybe a map, and we assign a count to keys named after room plan numbers?
   $room_chance = $data[4]
   $room_distance_max = int((($room_width + $room_height) / 2) + $room_border_max)
   $room_x = rand($room_border, ($world_width - $room_width - $room_border))
   $room_y = rand($room_border, ($world_height - $room_height - $room_border))
   $room_x_end = $room_x + $room_width
   $room_y_end = $room_y + $room_height
   $room_x_center = $room_x + floor($room_width / 2)
   $room_y_center = $room_y + floor($room_height / 2)

endfunc

func room_chance()
   if $bad then return
   if $room_chance = 0 then ; dont ever place
	  $bad = true
	  return
   endif

   if rand(1,100) <= $room_chance then
	  ;good
   else
	  ;fail
	  $bad = true
	  return
   endif

endfunc

func room_check()
   if $bad then return

   for $y = ($room_y - $room_border) to ($room_y_end + $room_border - 1)
   for $x = ($room_x - $room_border) to ($room_x_end + $room_border - 1)
	  if $world[$y][$x] <> $tile_empty then
		 $bad = true
		 return
	  endif

   next
   next

endfunc


func room_closest()
   if $bad then return
   if $room_count < 1 then return
   if $room_count = 1 then
	  ;print()
	  ;_arraydisplay($doors_x)
	  $door_x_end = $doors_x_end[0]
	  $door_y_end = $doors_y_end[0]
	  ;door_y/x need to be here too?
	  return
   endif

   local $best_index = null
   local $best = 999999999
   local $dist = 999999999
   for $i = 0 to (ubound($doors_x_end) - 1)		;	find the closest door to the center of this room
	  $dist = distance($room_x_center, $doors_x_end[$i], $room_y_center, $doors_y_end[$i])
	  if ($dist < $best) and ($dist > 0) then
		 $best = $dist
		 $best_index = $i
	  endif
   next

   if ($best < $room_distance_max) then	; room is within range, good
	  $door_y_end = $doors_y_end[$best_index]
	  $door_x_end = $doors_x_end[$best_index]
   else ; room is too far away, fail
	  $bad = true
	  return
   endif

endfunc


func room_build()
   if $bad then return
   local $start = $prefab_positions[$room_no]
   local $tiles = null
   local $doors_count = 0

   for $y = 0 to ($room_height - 1)
	  $tiles = $prefab[$start + $y + 1]

	  for $x = 0 to ($room_width - 1)
		 local $char = int(StringMid($tiles, $x + 1, 1))
		 if $char > 0 then $world[$room_y + $y][$room_x + $x] = $char

		 if ($char = $tile_door) then ;add doors from this room being built
			$doors_count += 1
			_ArrayAdd($doors_x, $room_x + $x)
			_ArrayAdd($doors_y, $room_y + $y)
		 endif

	  next

   next

   if $doors_count < 1 then $bad = true

endfunc


func door_closest()
   if $bad then return
   if $room_count < 1 then return

   local $best_index = null
   local $best = 999999999
   local $dist = 999999999
   for $i = 0 to (ubound($doors_x) - 1)		;	find the closest door in this room to the door outside
	  $dist = distance($door_x_end, $doors_x[$i], $door_y_end, $doors_y[$i])
	  if ($dist < $best) and ($dist > 0) then
		 $best = $dist
		 $best_index = $i
	  endif
   next
   $door_y = $doors_y[$best_index]
   $door_x = $doors_x[$best_index]

endfunc


func hall_build()
   if $bad then return
   if $room_count < 1 then return
   local $this_x = $door_x
   local $this_y = $door_y

   ;say($door_x)
   ;say($this_x & @crlf & $door_x_end & @crlf & @crlf & $this_y & @crlf & $door_y_end)


   while true
	  if ($this_x < $door_x_end) then
		 $this_x += 1

	  elseif ($this_x > $door_x_end) then
		 $this_x -= 1

	  elseif ($this_y < $door_y_end) then
		 $this_y += 1

	  elseif ($this_y > $door_y_end) then
		 $this_y -= 1

	  else
		 ;if ($this_y > 0) and ($this_x > 0) and ($this_y < $world_height - 1) and ($this_x < $world_width - 1) then
			if ($world[$this_y][$this_x] = $tile_empty) then $world[$this_y][$this_x] = $tile_hall
		 ;endif
		 return
	  endif

	  ;if ($this_y > 0) and ($this_x > 0) and ($this_y < $world_height - 1) and ($this_x < $world_width - 1) then
		 if ($world[$this_y][$this_x] = $tile_empty) then $world[$this_y][$this_x] = $tile_hall
		 ;say("here")
	  ;endif
	  ;these checks caused a problem so they are commented out for now

   wend

endfunc


func room_success()
   if $bad then return

   for $x in $doors_x
	  _ArrayAdd($doors_x_end, $x)
   next

   for $y in $doors_y
	  _ArrayAdd($doors_y_end, $y)
   next

   $room_count += 1
endfunc


func room_fail()
   if not $bad then return

   $room_fail_count += 1
   $bad = false
endfunc





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




func distance($d1, $d2, $d3, $d4)
   $a = Abs($d1 - $d2)
   $b = Abs($d3 - $d4)
   return Sqrt(($a * $a) + ($b * $b))
endfunc


func assert($expression)
   if not $expression then
	  $bad = true
	  say("assert failed")
   endif
endfunc


func rand($min, $max)
   return random($min, $max, 1)
endfunc


func print()
   msgbox(1,"number of rooms", $room_count)
   msgbox(1,"map", _ArrayToString($world, ""))
endfunc


func fill($what, $with)
   for $y = 0 to ($world_height - 1)
   for $x = 0 to ($world_width  - 1)
	  $world[$y][$x] = ($world[$y][$x] = $what) ? $with : $world[$y][$x]
   next
   next
endfunc


func image()
   local $path = @ScriptDir & "\" & $name & ".bpm"
   local $file = fileopen($path, 10)
   local $header  = "P1" & @CRLF & $world_width & " " & $world_height & @CRLF
   local $body = ""
   local $human_readable = "#"

   for $y = 0 to ($world_height - 1)
	  $human_readable = $human_readable & @CRLF & "#"
	  $body = $body & @CRLF
   for $x = 0 to ($world_width  - 1)
	  ;$body = $body & $world[$y][$x] & " "
	  if $world[$y][$x] = $tile_floor then $human_readable = $human_readable & "  "
	  if $world[$y][$x] = $tile_door then $human_readable = $human_readable  & "▒▒"
	  if $world[$y][$x] = $tile_empty then $human_readable = $human_readable  & "▓▓"
	  if $world[$y][$x] = $tile_hall then $human_readable = $human_readable  & "▓▓"

	  if $world[$y][$x] = $tile_floor then $body = $body  & "1 "
	  if $world[$y][$x] = $tile_door then $body = $body  & "1 "
	  if $world[$y][$x] = $tile_empty then $body = $body  & "0 "
	  if $world[$y][$x] = $tile_hall then $body = $body  & "1 "
   next
   next

   FileWrite($file, $header & $human_readable & $body)
   FileClose($file)

endfunc


func logger($data)
   FileWriteLine($logfile, $data)
endfunc


func say($message)
   msgbox(1, "", $message)
endfunc

























