(*$c-*)
module show_mem; (*$E mos *)

from storage import memavail, allavail;
from strconv import cardtostr;
from terminal import writepg, writeString, writeln, read;

var ch: char;

begin
  writepg;
  WriteString ('All    : '); WriteString (cardtostr (allavail(),0));
  writeln;
  WriteString ('Largest: '); WriteString (cardtostr (memavail(),0));
  writeln;
  read (ch)
end show_mem.
 
(* $FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$00000108$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4$FFEFB5B4�$00000052T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000066$000000FD$00000106$00000158$00000052$0000010B$00000167$00000142$00000127$FFEFB5B4$00000184$00000127$00000184$000000BE$000000B6$00000025���*)
