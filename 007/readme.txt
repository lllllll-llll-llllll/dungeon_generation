dungeon_gen_7
  prefab file data structure changed to accomate more things down the line
  prefab rooms have a percent chance of placement, letting their frequency be tweaked
  max distance between rooms now configurable, uses a different method than before too
  the 0,0 black pixel bug for outputs is somehow fixed
  
  there isn't much of a difference between 6 and 7
  
  the lack of a max distance really made 6's outputs look strange though, the hallways were way too long. this is way better i think.
  and the changes to how data in the prefab.txt is stored will make it easier to do things in the future
  
  there is a serious problem for worlds above 300x300 taking forever to finish. the chances of a room being randomly placed within
  range of another room, when the world is huge, make the output very barren. the majority of time seems to be spent producing the
  bitmap, because it creates the blank output file within a few seconds and then starts iterating through the world array. i think
  setting the array to itself + some chars becomes costly as the array grows large. maybe it cheaper to just build each line, then
  print that, instead of building one massive string


other things i've noticed
  border_limit when set high slows it down a lot
  max_fails doesn't really increase the time, while producing much denser rooms
  max_fails produces denser rooms but you need to keep raising it exponentially it feels like for the effects to matter
  max_distance doesnt really slow it down, but it produces sparse output when too low and requires a large max_fails to become dense
