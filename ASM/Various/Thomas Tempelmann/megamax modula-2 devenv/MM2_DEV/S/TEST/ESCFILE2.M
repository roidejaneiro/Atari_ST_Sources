(*$c-*)
module t; (*$E MOS *)
(*
 * test f�r ctrl-codes in text-files
 *)

import tosio;
from inout import WriteString,write,read, writecard,writeln,readstring;
import text,files;

const   dateiname = 'g:\dat';
        esc=33C;
        ron='p';
        roff='q';

var ch:char; f:files.file;

begin
  (* Datei erzeugen, dabei ESC-Codes einf�gen *)
  files.create (f, dateiname, files.writeseqtxt,files.replaceold);
  text.WriteString (f,'normal');
  text.write (f,esc);
  text.write (f,ron);
  text.WriteString (f,'reverse');
  text.write (f,esc);
  text.write (f,roff);
  text.WriteString (f,'normal');
  text.writeln(f);
  files.close (f);

  (* Datei wieder lesen *)
  files.open (f, dateiname, files.readseqtxt);
  loop
    text.read (f,ch);
    if text.eol (f) then
      if files.eof (f) then exit end;
      writeln
    else
      write (ch)
    end
  end;
  files.close (f);

  read(ch)
end t.
 
(* $FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$00000317$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A$FFF0688A�$000002BAT.......T.......T.......T.......T.......T...............T...T...T.......T.......$0000037E$0000009C$0000031A$000002F2$00000352$FFF0688A$0000038A$000002BA$0000016C$000002BA$FFF0688A$0000036B$FFF0688A$00000363$00000317$00000363���*)
