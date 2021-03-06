(*$c-*)
module TimeChk;

(*
  Druchsucht ab Startverzeichnis alle Subdirs und sucht nach Files/Dirs,
  die nach einem bestimmbaren Datum liegen.
*)

(*$E mos *)
import moreio;
from inout import OpenOutput, writeln, WriteString, readstring, write, read,
        CloseOutput, writeint;
from directory import dirquery, direntry, fileattr, fileattrset;
from mosglobals import date, time;
from timeconvert import texttotime, texttodate;
from clock import packtime, packdate;
import filenames, strings;

var ch:char;
    res:INTEGER;
    level:CARDINAL;
    d:Date; t:Time;
    pd, pt: CARDINAL;
    b: BOOLEAN;


PROCEDURE showentry (REF path:ARRAY OF CHAR; e:direntry):BOOLEAN;
  var res:integer; i:CARDINAL; p:ARRAY [0..142] of char; b:BOOLEAN; c:char;
  begin
    if (packdate (e.date) > pd)
    or (packdate (e.date) = pd) & (packtime(e.time) >= pt) then
      if e.name[0]#'.' then
        WriteString (path);
        writestring (e.name);
        IF subdirAttr IN e.attr THEN
          write ('\')
        end;
        writeln;
      end;
    end;
    IF subdirAttr IN e.attr THEN
      if e.name[0]#'.' then
        strings.concat (e.name,'\',p,b);
        strings.concat (path,p,p,b);
        strings.concat (p,'*.*',p,b);
        dirquery (p,FileAttrSet{subdirAttr},showentry,res);
        if res<0 then writeint (res,0); writeln; end;
      end
    end;
    return true
  end showentry;

VAR s,p: ARRAY [0..127] of char;

begin
  level:=0;
  WriteString ('Root dir? ');
  ReadString (p);
  filenames.validatepath (p);
  strings.append ('*.*',p,b);
  repeat
    WriteString ('Date? ');
    readString(s);
    if s[0]=0C then return end;
    texttodate (s, 0, d, b);
  until b;
  repeat
    WriteString ('Time? ');
    readString(s);
    if s[0]=0C then return end;
    texttotime (s, t, b);
  until b;
  pd:= packdate(d);
  pt:= packtime(t);
  WriteString ('Ausgabedatei? ');
  OpenOutput ('TXT');
  dirquery (p,FileAttrSet{subdirAttr},showentry,res);
  CloseOutput;
  if res<0 then
    writeint (res,0);
  else
    writestring ('OK.')
  end;
end TimeChk.
 
(* $FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFEAC9B4$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$FFFB32DE$000003D6T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000003B7$FFEAC9A6$0000057E$00000445$0000037B$FFEAC9A6$0000037B$00000413$0000037E$0000038B$FFEAC9A6$00000409$FFEAC9A6$0000043B$000003D6$0000043B*)
