MODULE CmpKeys;

FROM InOut IMPORT Write, WriteLn, WriteString, WriteInt, Read, ReadString;

FROM Files IMPORT File, Access, Open, Close, State;

FROM Binary IMPORT ReadBlock;

FROM Directory IMPORT DirQuery, DirEntry, FileAttrSet;

FROM Strings IMPORT String, Empty, Append, Concat;

VAR n1, n2: String;
    ok: BOOLEAN;
    c: CHAR;
    res: INTEGER;

PROCEDURE checkKey (path: ARRAY OF CHAR; entry: DirEntry): BOOLEAN;

  VAR s: String;
      f: File;
      dat1, dat2: RECORD dummy: CARDINAL; key: LONGCARD END;

  BEGIN
    Concat (path, entry.name, s, ok);
    Open (f, s, readOnly);
    IF State (f) < 0 THEN
      WriteLn;
      WriteString ('Open-Error on first file !');
      RETURN FALSE
    END;
    ReadBlock (f, dat1);
    Close (f);
    
    Concat (n2, entry.name, s, ok);
    Open (f, s, readOnly);
    IF State (f) < 0 THEN
      WriteLn;
      WriteString ('Open-Error on second file !');
      RETURN FALSE
    END;
    ReadBlock (f, dat2);
    Close (f);
    
    IF dat1.key # dat2.key THEN
      WriteLn;
      WriteString ('Different keys: ');
      WriteString (entry.name);
    END;
    
    RETURN TRUE
  END checkKey;

BEGIN
  WriteString ('First folder ? ');
  ReadString (n1);
  IF Empty (n1) THEN RETURN END;
  
  WriteString ('Second folder ? ');
  ReadString (n2);
  IF Empty (n2) THEN RETURN END;
  
  Append ('*.*', n1, ok);
  DirQuery (n1 , FileAttrSet {}, checkKey, res);
  IF res < 0 THEN
    WriteLn;
    WriteString ('Error #');
    WriteInt (res,0)
  END;
  
  WriteLn;
  Read (c)
END CmpKeys.
 
(* $FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$000005BB$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$FFF687CC$00000592T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$00000481$0000023D$0000032A$00000475$0000016F$00000639$000005D9$00000631$0000004A$00000592$0000049C$00000429$0000049C$00000447$0000049C$00000462¨*)
