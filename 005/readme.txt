dungeon_gen_5

basic idea:
  - add in dead end hallways to 4 to make it kind of like a maze, increase variety
  - save the output to a bitmap. currently it's outputting to .xbm,
    but above the data section you can see a human-readable text version
    which lets you look at the bitmap in any text editor or from github

problems:
  - line 167 causes program to fail sometimes
  - also some rooms aren't connecting now. something broke betwen 4 and 5
  - takes forever. can start optimizing it
  
result: 
  - output looks cool i like it
