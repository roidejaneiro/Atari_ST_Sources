MODULE CmpMods;
(*$A+*)

(*
IMPORT Debug;
*)

(*
Vergleicht die L�nge der Prozeduren zweier �bersetzteer Module.

Wenigstens eins der Module sollte $M+ verwenden, damit
die unterschiedlichen Procs benannt werden k�nnen.

Funktioniert z.Zt. nur, wenn gleiche Anzahl Procs in beiden Modulen!
*)

IMPORT GEMIO;
FROM EasyGEM1 IMPORT SelectFile;
FROM MOSGlobals IMPORT fNoMatchingFiles, PathStr, FileStr;
FROM BinOps IMPORT LowerLCard;
IMPORT Files, Binary;
FROM Directory IMPORT Delete, DirQuery, DirQueryProc, DirEntry, FileAttrSet,
        SetFileAttr;
FROM FileNames IMPORT SplitPath, PathConc;
FROM InOut IMPORT Write, WriteString, WriteCard, WriteLn, Read, WritePg,
        BusyRead, ReadString, GotoXY;
FROM Strings IMPORT Space, Length, Empty, Append, String, Compare, Relation;
FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
IMPORT Loader, ShellMsg, ModBase, ModCtrl;
FROM ModBase IMPORT PtrModHeader, ModHeader, ModRef;

TYPE PL = POINTER TO LONGCARD;
     PC = POINTER TO CHAR;
     PS = POINTER TO ARRAY [0..39] OF CHAR;

PROCEDURE wait;
  VAR ch: CHAR;
  BEGIN
    WriteLn;
    WriteString ('Press a key...');
    Read (ch)
  END wait;

PROCEDURE skip (VAR pl: ADDRESS);
  BEGIN
    REPEAT INC (pl) UNTIL (PC(pl)^ = 0C);
    IF ODD (pl) THEN INC (pl) END;
    INC (pl, 4)
  END skip;

PROCEDURE back (ad: ADDRESS; VAR pl: LONGCARD);
  BEGIN
    DEC (pl, 6);
    REPEAT DEC (pl, 2) UNTIL (PC(ad+pl)^ = 0C);
  END back;

PROCEDURE size (header: PtrModHeader; start, end: LONGCARD): LONGCARD;
  (* alle Proc-Namen im Bereich finden und L�nge addieren *)
  VAR n: LONGCARD; pn: LONGCARD; p, pa: ADDRESS;
  BEGIN
    n:= 0;
    pn:= header^.body; (* Beim Body f�ngt die Kette r�ckw. an *)
    LOOP
      IF pn <= start THEN EXIT END;
      p:= ADDRESS(header) + pn; (* Proc-Adr. absolut *)
      DEC (p, 4); (* zum Ptr vor Name *)
      IF (pn < end) THEN
        pa:= p;
        INC (n, 6);
        DEC (pa,2);
        REPEAT INC (n, 2); DEC (pa,2) UNTIL PC(pa)^ = 0C;
      END;
      pn:= PL(p)^;
    END;
    IF n = 0 THEN HALT END;
    RETURN n
  END size;

VAR mn1, mn2: FileStr; dummy: ARRAY [0..11] OF CHAR;
    ad1, ad2: ADDRESS;
    hd1, hd2: PtrModHeader;
    f: Files.File;
    ref1, ref2: ModBase.ModRef;
    s: String;
    syms1, syms2, ok: BOOLEAN;
    co1, co2, len1, len2, clen1, clen2: LONGCARD;
    end1, end2, n1,n2: LONGCARD;
    pa1, pa2, p, pa: ADDRESS;
    pc: PC;

VAR pl1, pl2: PL;

PROCEDURE find (proc: LONGCARD; VAR pl: PL; VAR len: LONGCARD);
  BEGIN
    ASSEMBLER
        MOVE.L  proc(A6),D0
        MOVE.L  pl(A6),A0
        MOVE.L  (A0),A1
       l:
        MOVE.L  (A1),D1
        BEQ     err
        CMP.L   D1,D0
        BEQ     ende
        ADDQ.L  #8,A1
        BRA     l
      err:
        BREAK
      ende:
        MOVE.L  A1,(A0)
        MOVE.L  len(A6),A0
        MOVE.L  4(A1),(A0)
    END
  END find;
  

BEGIN
  mn1:= '';
  SelectFile ('1. Modul?', mn1, ok);
  IF NOT ok THEN RETURN END;
  mn2:= '';
  SelectFile ('2. Modul?', mn2, ok);
  IF NOT ok THEN RETURN END;
  
  Files.Open (f, mn1, Files.readOnly);
  len1:= Binary.FileSize (f);
  ALLOCATE (ad1, len1);
  Binary.ReadBytes (f, ad1, len1, len1);
  Files.Close (f);
  
  Files.Open (f, mn2, Files.readOnly);
  len2:= Binary.FileSize (f);
  ALLOCATE (ad2, len2);
  Binary.ReadBytes (f, ad2, len2, len2);
  Files.Close (f);
  
  INC(ad1, 8);
  INC(ad2, 8);
  hd1:= ad1;
  hd2:= ad2;
  
  syms1:= 4 IN hd1^.id;
  syms2:= 4 IN hd2^.id;
  WriteString (mn1); IF syms1 THEN WriteString (' has symbols') END; WriteLn;
  WriteString (mn2); IF syms2 THEN WriteString (' has symbols') END; WriteLn;
  WriteLn;
  
  co1:= hd1^.codeStart;
  co2:= hd2^.codeStart;
  end1:= hd1^.body;
  end2:= hd2^.body;
  IF syms1 THEN back (ad1, end1) END;
  IF syms2 THEN back (ad2, end2) END;
  
  pl1:= ad1+hd1^.procSize;
  pl2:= ad2+hd2^.procSize;
  
  n1:= 0;
  WHILE pl1^ # 0 DO INC (n1); INC (pl1, 8) END;
  n2:= 0;
  WHILE pl2^ # 0 DO INC (n2); INC (pl2, 8) END;
  WriteString (mn1); WriteString (' has '); WriteCard (n1,0); WriteString (' procs'); WriteLn;
  WriteString (mn2); WriteString (' has '); WriteCard (n2,0); WriteString (' procs'); WriteLn;
  WriteLn;
  
  (*$D-*)
  n1:= 0;
  n2:= 0;
  WHILE (co1 < end1) & (co2 < end2) DO
    pl1:= ad1+hd1^.procSize;
    pl2:= ad2+hd2^.procSize;
    find (co1, pl1, len1);
    find (co2, pl2, len2);
    clen1:= len1;
    clen2:= len2;
    IF syms1 THEN DEC (clen1, size(ad1,co1,co1+len1)) END;
    IF syms2 THEN DEC (clen2, size(ad2,co2,co2+len2)) END;
    IF clen1 # clen2 THEN
      INC (n2);
      IF syms1 THEN
        pc:= ad1+co1+1;
        WHILE pc^#0C DO Write (pc^); INC (pc) END;
        Write (' ')
      ELSIF syms2 THEN
        pc:= ad2+co2+1;
        WHILE pc^#0C DO Write (pc^); INC (pc) END;
        Write (' ')
      END;
    END;
    INC (co1, len1);
    INC (co2, len2);
    INC (n1)
  END;
  WriteLn;
  WriteCard (n1, 4); WriteString (' procs compared');
  WriteLn;
  WriteCard (n2, 4); WriteString (' mismatches found');
  WriteLn;
  (*$D-*)
  
  wait
END CmpMods.
 
(* $FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$00001235$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E$FFE45D3E�$00000130T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000804$0000058F$000005CC$000005DB$FFED710E$000005D4$00000033$00001126$00000130$00000828$00000837$0000002F$00000033$00001126$000007ED$00000821���*)
