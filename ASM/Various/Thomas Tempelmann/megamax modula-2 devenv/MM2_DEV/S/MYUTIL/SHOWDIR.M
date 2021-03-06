(*$c-*)
module ShowDir;

from inout import OpenOutput, writeln, WriteString, readstring, write, read,
        CloseOutput, writeint;
from directory import dirquery, direntry, fileattr, fileattrset;
import strings;

var ch:char;
    res:INTEGER;
    level:CARDINAL;
    b: BOOLEAN;


PROCEDURE showentry (path:ARRAY OF CHAR; e:direntry):BOOLEAN;
  var res:integer; i:CARDINAL; p:ARRAY [0..142] of char; b:BOOLEAN; c:char;
  begin
    with e do
      IF subdirAttr IN attr THEN
        if name[0]#'.' then
          for i:=1 to level do WriteString ('  ') end;
          WriteString ('sub: ');
          WriteString (path);
          writestring (name); writeln;
          inc (level);
          strings.concat (name,'\',p,b);
          strings.concat (path,p,p,b);
          strings.concat (p,'*.*',p,b);
          dirquery (p,FileAttrSet{subdirAttr},showentry,res);
          if res<0 then writeint (res,0); writeln; read (c) end;
          dec (level)
        end
      else
        for i:=1 to level do WriteString ('  ') end;
        writestring (name); writeln;
      end
    end;
    return true
  end showentry;

VAR p: ARRAY [0..127] of char;

begin
  level:=0;
  WriteString ('Root dir ? ');
  ReadString (p);
  OpenOutput ('TXT');
  strings.append ('*.*',p,b);
  dirquery (p,FileAttrSet{subdirAttr},showentry,res);
  CloseOutput;
  if res<0 then
    writeint (res,0);
  else
    writestring ('OK.')
  end;
end ShowDir.
 
(* $FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFF6A486$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE�$00000597T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFF6A486$FFF6A486$00000118$000004BF$00000509$000002B7$00000453$000005BE$00000597$000005BB$FFF9CF2A$000005B2$00000597$0000056B$0000055F$0000007F���*)
