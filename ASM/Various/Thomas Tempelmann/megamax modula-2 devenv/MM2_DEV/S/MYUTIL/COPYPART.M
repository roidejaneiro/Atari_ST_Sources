MODULE CopyPart;
(*$E MOS *)

(*
 * Kopiert gesamte Partition von einem auf ein anderes Laufwerk.
 * Dabei wird rigiros auch der Bootsektor mit den Gr��eninformationen
 * ohne �nderung kopiert.
 *)

FROM SYSTEM IMPORT ADR;

FROM SysUtil0 IMPORT VarEqual;

FROM BIOS IMPORT DriveMap, DriveSet, RWAbs, BPB, BPBPtr, RW, GetBPB;

IMPORT TOSIO;
FROM InOut IMPORT WriteString, WriteCard, WriteLn, GotoXY, WritePg;
IMPORT InOut;


PROCEDURE drvno (c:CHAR): CARDINAL;
  BEGIN
    RETURN ORD (CAP (c)) - ORD ('A')
  END drvno;

TYPE CharSet = SET OF CHAR;

VAR sd, dd: CHAR;
    sn, dn: CARDINAL;
    drives: DriveSet;
    p: BPBPtr;
    inf: ARRAY [0..31] OF BPB;
    ch: CHAR;
    l: LONGINT;
    bufbls, blno, restbls, bls: CARDINAL;
    verify: BOOLEAN;


    buf2, buf: ARRAY [1..32768] OF CARDINAL; (* 2 * 64KB *)


PROCEDURE info (n: CARDINAL);
  BEGIN
    WriteString ('  Drive ');
    WriteString (CHR (n + ORD ('A')));
    WriteString (':');
    WriteLn;
    WriteString ('  Size: ');
    IF inf[n].clsizb <> 1024 THEN HALT END;
    WriteCard (inf [n].numcl,0);
    WriteString (' KB');
    WriteLn;
  END info;


BEGIN
  drives:= DriveMap ();
  WriteLn;
  WriteString ('Copy whole partition');
  WriteLn;
  WriteLn;
  
  WriteString ('Source drive      (C-P) ? ');
  InOut.Read (sd); sd:= CAP (sd);
  IF NOT ( sd IN CharSet {'C'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (sd) IN drives ) THEN RETURN END;
  WriteLn;
  
  WriteString ('Destination drive (C-P) ? ');
  InOut.Read (dd); dd:= CAP (dd);
  IF NOT ( dd IN CharSet {'C'..'P'} ) THEN RETURN END;
  IF NOT ( drvno (dd) IN drives ) THEN RETURN END;
  WriteLn;
  
  IF sd = dd THEN RETURN END;
  sn:= drvno (sd);
  dn:= drvno (dd);
  
  p:= GetBPB (sn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf[sn]:= p^;

  p:= GetBPB (dn);
  IF p = NIL THEN WriteString ('Not online'); InOut.Read (ch); RETURN END;
  inf[dn]:= p^;

  WriteLn;
  WriteString ('Source drive: ');
  WriteLn;
  info (sn);

  WriteLn;
  WriteString ('Dest drive: ');
  WriteLn;
  info (dn);

  WriteLn;
  WriteString ('Copy (Y/N) ? ');
  InOut.Read (ch);
  IF CAP (ch) <> 'Y' THEN RETURN END;

  WriteLn;
  WriteString ('With verify (Y/N) ? ');
  InOut.Read (ch);
  verify:= CAP (ch) = 'Y';

  blno:= 0;
  restbls:= inf[sn].numcl * inf[sn].clsiz;
  bufbls:= SHORT (SIZE (buf) DIV 1024L) * inf[sn].clsiz; (* =128 *)
  REPEAT
    GotoXY (0, 17);
    WriteString ('Block no. ');
    WriteCard (blno,0);
    WriteLn;
    WriteString ('Copied: ');
    WriteCard (blno DIV inf[sn].clsiz,4);
    WriteString (' KB');
    WriteLn;
    WriteString ('Left  : ');
    WriteCard (restbls DIV inf[sn].clsiz,4);
    WriteString (' KB');
    bls:= bufbls;
    IF bls > restbls THEN bls:= restbls END;
    l:= RWAbs (Read, ADR (buf), bls, blno, sn);
    IF l # 0L THEN
      WriteLn; WriteString ('Read error on source!'); InOut.Read (ch);
      RETURN
    END;
    LOOP
      l:= RWAbs (Write, ADR (buf), bls, blno, dn);
      IF l # 0L THEN
        WriteLn; WriteString ('Write error!'); InOut.Read (ch);
        RETURN
      END;
      IF NOT verify THEN EXIT END;
      l:= RWAbs (Read, ADR (buf2), bls, blno, dn);
      IF l # 0L THEN
        WriteLn; WriteString ('Read error on destination!'); InOut.Read (ch);
        RETURN
      END;
      IF VarEqual (buf, buf2) THEN
        EXIT
      ELSE
        WriteLn; WriteString ('Verify error! Press ESC to stop, other to retry');
        InOut.Read (ch);
        IF ch = 33C THEN RETURN END;
      END;
    END;
    INC (blno, bls);
    DEC (restbls, bls)
  UNTIL restbls = 0;
  WriteLn;
  WriteString ('Copy completed');
  InOut.Read (ch)
END CopyPart.
 
(* $FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE$FFF394BE�$00000311T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000B39$00000CB5$00000D6D$00000DA0$00000E3B$00000DF0$00000DCD$00000E33$00000ECF$00000DFD$00000ECF$000008CD$000008F6$00000923$0000092D$00000311���*)
