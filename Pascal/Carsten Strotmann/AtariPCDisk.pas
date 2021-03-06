(**********************************************************************)
(*                                                                    *)
(* Ph�niX SoftCrew  Turbo Pascal Programme                            *)
(* most (c) by PSC Software Development Lippstadt/Warendorf           *)
(*                                                                    *)
(* Ph�niX SoftCrew          ####   ####  ####                         *)
(* c/o Carsten Strotmann    #   # ##    ##                            *)
(*                          ####   ###  ##     Software Development   *)
(*                          #        ## ##                            *)
(*                          #     ####   ####                         *)
(*                                                                    *)
(**********************************************************************)

(*

  Programmname   :ATARI Kompatibilit�ts Unit
  Filename       :A_UNIT.PAS
  von            :Carsten Strotmann
  letzte �nderung:06.02.91
  Bemerkung      :

*)

UNIT A_UNIT;

INTERFACE

USES DOS, CRT;

TYPE
  a_sector = RECORD
             CASE INTEGER OF
              1 : ( secdata  : ARRAY [0..252] OF BYTE; { Sektordaten }
                    seclink  : WORD;                   { Link Word }
                    secsize  : BYTE;                   { Anzahl Bytes }
                    dummy    : WORD;
                  );
              2 : ( sectordat: ARRAY [0..$FF] OF BYTE );
             END;

  drivetab = RECORD
              steptime : BYTE; { Schrittzeit }
              dmamode  : BYTE; { DMA Modus }
              motorwait: BYTE; { Motor Nachlaufzeit }
              secbyte  : BYTE; { Bytes pro Sektor }
              sectrack : BYTE; { Max. Anzahl Sek. pro Track }
              secspace1: BYTE; { Zeit zwischen Sektoren }
              notused  : BYTE; { unbenutzt }
              secspace2: BYTE; { Freiraum zwischen Sektoren }
              fillcode : BYTE; { ASCII Code zum f�llen }
              endtime  : BYTE; { Ruhezeit zum Ausschwingen }
              starttime: BYTE; { Anlaufzeit des Motors }
            END;

  filename = RECORD
               name    : ARRAY [0..7] OF CHAR; { Bezeichnung }
               ext     : ARRAY [0..2] OF CHAR; { Extender }
             END;

  direntry = RECORD
               flag    : BYTE;                 { Statusflag }
               length  : WORD;                 { L�nge des Files }
               startsec: WORD;                 { Startsector }
               name    : ARRAY [0..7] OF CHAR; { Bezeichner }
               ext     : ARRAY [0..2] OF CHAR; { Extender }
             END;

  vtoc     = RECORD
               version : BYTE;                   { Dos Version kompat. }
               maxfree : WORD;                   { Max. Sektoren der Disk }
               freesec : WORD;                   { Freie Sektoren }
               table   : ARRAY [0..$FF] OF BYTE; { Sektorenbelegungstabelle }
             END;

VAR
  olddrivetab : POINTER;
  { Zeiger auf alte Tabelle }

  a_drivetab  : drivetab;
  { Neue Laufwerkstabelle }

  a_vtoc      : vtoc;
  { VOLUME TABLE OF CONTENTS }

  a_dir       : ARRAY [1..64] OF direntry;
  { DIRECTORY ARRAY }

  dir_read,
  { Flag f�r Directory schon gelesen }

  vtoc_read   : BOOLEAN;
  { Flag f�r VTOC schon gelesen }

  secprotrk,
  { Sektoren pro Track }
  secsize,
  { Sektorengr��e }
  diskside,
  { Diskettenseite }
  drivenum,
  { Laufwerksnummer }
  entrycount,
  { Eintragsnummer }
  a_error     : BYTE;
  { Fehlernummer }

FUNCTION DiskStatus : BYTE;
{ Ermittelt den Diskstatus }

PROCEDURE DiskReset;
{ F�hrt einen Diskreset aus }

PROCEDURE SetDrive (drive, value : BYTE);
{ Setzt Formatangaben f�r Diskettenlaufwerk }

PROCEDURE SetNewDriveTab (strack, sbyte : BYTE);
{ Installiert neue Laufwerkstabelle }

PROCEDURE SetOldDriveTab;
{ Restauriert alte Laufwerkstabelle }

FUNCTION  Read_A_Sector (drive, side : BYTE; num : WORD; VAR buffer : a_sector): BYTE;
{ Liest einen ATARI Sektor }

FUNCTION  Write_A_Sector (drive, side : BYTE; num : WORD; VAR buffer : a_sector): BYTE;
{ Schreibt einen ATARI Sektor }

PROCEDURE Read_Dir (drive : BYTE);
{ Liest Directory ein }

PROCEDURE Read_VTOC (drive : BYTE);
{ Liest VTOC ein }

FUNCTION A_FindFirst (filen : STRING) : BYTE;
{ Findet ersten Filenamen in Directory und liefert Eintragsnummer zur�ck }

FUNCTION A_FindNext (filen : STRING): BYTE;
{ Findet n�chsten Filenamen in Directory und gibt Eintragsnummer zur�ck }

IMPLEMENTATION

FUNCTION DiskStatus : BYTE;
VAR
  reg : REGISTERS;
BEGIN
  reg.ah := 1;
  Intr ($13,reg);
  DiskStatus := reg.ah;
END;

PROCEDURE DiskReset;
VAR
  reg : REGISTERS;
BEGIN
  reg.ah := 0;
  Intr ($13,reg);
END;

PROCEDURE SetDrive (drive, value : BYTE);
VAR
  reg : REGISTERS;
BEGIN
  reg.ah := $17;
  reg.dl := drive;
  reg.al := value;
  Intr($13,reg);
END;

PROCEDURE SetNewDriveTab (strack, sbyte : BYTE);
BEGIN
  WITH a_drivetab DO
  BEGIN
    steptime := $DF;
    dmamode  := 2;
    motorwait:= $24;
    secbyte  := sbyte;
    sectrack := strack;
    secspace1:= $1B;
    notused  := $FF;
    secspace2:= $10;
    fillcode := $FF;
    endtime  := $F;
    starttime:= 8;
  END;

  GetIntVec ($1E, olddrivetab);
  SetIntVec ($1E, @a_drivetab);

END;

PROCEDURE SetOldDriveTab;
BEGIN
  SetIntVec ($1E, olddrivetab);
END;

FUNCTION Read_A_Sector (drive, side : BYTE; num : WORD; VAR buffer : a_sector): BYTE;
VAR
  reg : REGISTERS;
  track,
  sec,
  bb  : WORD;
  buf : ARRAY [0..$110] OF BYTE;

BEGIN
  IF (num > 0) AND (num < 720) THEN
  BEGIN
    bb := DiskStatus;

    IF bb > 0 THEN
      DiskReset;

    track := num DIV secprotrk;
    sec:= num - (track * secprotrk);
    IF sec = 0 THEN
    BEGIN
      sec := secprotrk;
      Dec (track);
    END;
    reg.ah := 2;        {Sektor lesen}
    reg.al := 1;        {Anzahl der Sektoren}
    reg.dh := side;     {Diskettenseite}
    reg.dl := drive;    {Laufwerk}
    reg.cl := sec;      {erster Sektor}
    reg.ch := track;    {Track des Sektors}
    reg.es := Seg(buf[0]);
    reg.bx := Ofs(buf[0]);
    Intr ($13,reg);

    Read_A_Sector := reg.ah;

    Move (buf,buffer,$100);

    FOR bb := 0 TO $100 DO
      buffer.sectordat[bb] := buffer.sectordat[bb] XOR $FF;
  END;
END;

FUNCTION Write_A_Sector (drive, side : BYTE; num : WORD; VAR buffer : a_sector): BYTE;
VAR
  reg : REGISTERS;
  track,
  sec,
  bb  : WORD;
  buf : ARRAY [0..$110] OF BYTE;

BEGIN
  FOR bb := 0 TO $100 DO
    buffer.sectordat[bb] := buffer.sectordat[bb] XOR $FF;

  Move (buffer,buf,$100);

  IF (num > 0) AND (num < 720) THEN
  BEGIN
    bb := DiskStatus;

    IF bb > 0 THEN
      DiskReset;

    track := num DIV secprotrk;
    sec:= num - (track * secprotrk);
    IF sec = 0 THEN
    BEGIN
      sec := secprotrk;
      Dec (track);
    END;
    reg.ah := 3;        {Sektor schreiben}
    reg.al := 1;        {Anzahl der Sektoren}
    reg.dh := side;     {Diskettenseite}
    reg.dl := drive;    {Laufwerk}
    reg.cl := sec;      {erster Sektor}
    reg.ch := track;    {Track des Sektors}
    reg.es := Seg(buf[0]);
    reg.bx := Ofs(buf[0]);
    Intr ($13,reg);

    Write_A_Sector := reg.ah;

  END;
END;

PROCEDURE Read_Dir (drive : BYTE);
VAR
 u : WORD;
 s : a_sector;

BEGIN
 a_error := 0;
 FOR u := 1 TO 8 DO
 BEGIN
   a_error := Read_A_Sector (drive,diskside,u+360,s);
   Move (s,a_dir[(u-1)*8+1],128);
   IF a_error > 0 THEN
     EXIT;
 END;
 dir_read := TRUE;
 entrycount := 0;
END;

PROCEDURE Read_VTOC (drive : BYTE);
VAR
  s : a_sector;
BEGIN
  a_error := 0;
  a_error := Read_A_Sector (drive,diskside,360,s);
  Move (s,a_vtoc,$80);
  vtoc_read := TRUE;
END;

FUNCTION A_FindNext (filen : STRING): BYTE;
VAR
  u,p : BYTE;
  f : BOOLEAN;
  fn,
  fs : filename;

BEGIN
  FillChar (fn,11,0);

  p := Pos('.',filen);

  FOR u := 1 TO p-1 DO
    fn.name[u-1] := filen[u];

  FOR u := p+1 TO Length(filen) DO
    fn.ext[u-p-1] := filen[u];

  f := FALSE;
 
  FOR u := 0 TO 7 DO
  BEGIN
    IF fn.name[u] = '*' THEN
      f := TRUE;
    IF f THEN
      fn.name[u] := '?';
  END;

  f := FALSE;

  FOR u := 0 TO 2 DO
  BEGIN
    IF fn.ext[u] = '*' THEN
      f := TRUE;
    IF f THEN
      fn.ext[u] := '?';
  END;

  FOR u := 0 TO 7 DO
    IF fn.name[u] = #0 THEN
      fn.name[u] := #32;

  FOR u := 0 TO 7 DO
    IF fn.ext[u] = #0 THEN
      fn.ext[u] := #32;

  REPEAT
    Inc (entrycount);

    FOR u := 0 TO 7 DO
      fs.name[u] := a_dir[entrycount].name[u];

    FOR u := 0 TO 2 DO
      fs.ext[u] := a_dir[entrycount].ext[u];

     FOR u := 0 TO 7 DO
       IF fn.name[u] = '?' THEN
         fs.name[u] := '?';

     FOR u := 0 TO 2 DO
       IF fn.ext[u] = '?' THEN
         fs.ext[u] := '?';

     IF a_dir[entrycount].flag = 0 THEN
       entrycount := $41;

  UNTIL (fs.name = fn.name) AND (fs.ext = fn.ext) AND (a_dir[entrycount].flag AND $80 = 0) OR (entrycount > $40);

  IF NOT (entrycount > $40) THEN
    A_FindNext := entrycount
  ELSE
    A_FindNext := 0;

END;

FUNCTION A_FindFirst (filen : STRING) : BYTE;

BEGIN
  entrycount := 0;
  A_FindFirst := A_FindNext (filen);
END;

BEGIN
  dir_read := FALSE;
  vtoc_read := FALSE;
  secprotrk := 18;
  secsize := 1;
  diskside := 0;
  drivenum := 0;
  entrycount := 0;
  a_error := 0;
END.

Copy ATARI DD Disk Files to MS-DOS Files 


(**********************************************************************)
(*                                                                    *)
(* Ph�niX SoftCrew  Turbo Pascal Programme                            *)
(* most (c) by PSC Software Development Lippstadt/Warendorf           *)
(*                                                                    *)
(* Ph�niX SoftCrew          ####   ####  ####                         *)
(* c/o Carsten Strotmann    #   # ##    ##                            *)
(*                          ####   ###  ##     Software Development   *)
(*                          #        ## ##                            *)
(*                          #     ####   ####                         *)
(*                                                                    *)
(**********************************************************************)

(*

  Programmname   :ATARI DOS 2.5 --> MS-DOS Copy
  Filename       :ACOPY2.PAS
  von            :CARSTEN STROTMANN
  letzte �nderung:
  Bemerkung      :

*)


PROGRAM ACopy2;

USES CRT, DOS, PSCCRT, PSCDOS, A_UNIT;

CONST
  q : STRING = '1';

VAR
  filea,
  fileb : STRING;
  driva,
  drivb : CHAR;

PROCEDURE CopyAM (filea, fileb : STRING);

VAR
  drivenuma,
  entry,
  checkentry,
  bytes,
  cy, count,
  u, error    : BYTE;
  startsec,
  nextsec     : WORD;
  msdosfile   : FILE OF BYTE;
  buffer      : a_sector;

BEGIN
  drivenuma := Ord(filea[2]) - 49;

  Read_Dir (drivenuma);

  Delete (filea,1,3);
  entry := A_FindFirst (filea);

  IF entry > 0 THEN
  BEGIN
    startsec := a_dir[entry].startsec;

    fileb := FExpand (fileb);

    WriteLn ('Kopiere ATARI DOS 2.x File ',filea,' nach MS-DOS File ',fileb);
    WriteLn;
    WriteLn;

    cy := WhereY;

    IF cy = 25 THEN
    BEGIN
      Dec(cy);
      GotoXY (1,1);
      DelLine;
    END;

    Assign (msdosfile,fileb);
    ReWrite (msdosfile);

    nextsec := startsec;
    error := 0;
    count := 0;

    WHILE (nextsec > 0) AND (error = 0) AND (nextsec < 720) DO
    BEGIN
      GotoXY (5,cy);
      WriteLn ('Lese ',filea,' Sektor #',nextsec,'  ');

      REPEAT
        Read_A_Sector (drivenuma,0,nextsec,buffer);

        error := DiskStatus;

        IF error > 0 THEN
        BEGIN
          Inc (count);
          DiskReset;
        END;

        bytes := buffer.secsize;

        checkentry := (buffer.sectordat[253] AND $FC) SHR 2;

        nextsec := (buffer.sectordat[253] AND $03) * $100 + buffer.sectordat[254];

      UNTIL (error = 0) AND (nextsec > 0) AND (nextsec < 720) OR (count > 10);

      FOR u := 0 TO bytes-1 DO
        Write (msdosfile, buffer.sectordat[u]);

      count := 0;

    END;

    IF error > 0 THEN
    BEGIN
      WriteLn;
      WriteLn (' Diskettenfehler Code ',error);
    END;

    IF (nextsec > 719) OR (entry-1 <> checkentry) THEN
    BEGIN
      WriteLn;
      WriteLn (' Linkfehler ');
    END;

    Close (msdosfile);
  END
  ELSE
  BEGIN
    WriteLn;
    WriteLn ('File ',filea,' nicht gefunden !!');
    WriteLn;
  END;

END;

BEGIN

  C_Off;

  Writeln;
  Writeln;

  IF Paramcount <> 2 THEN
  BEGIN
    Writeln ('Fehlerhafte Parameter�bergabe !');
    Writeln;
    Writeln ('Aufruf : ');
    Writeln;
    Writeln ('ACOPY drive:filename.ext drive:filename.ext');
    Writeln;
    Writeln ('DRIVE: D1:,D2:  --> ATARI Formate');
    Writeln ('DRIVE: A:,B:,C: --> MS-DOS Formate');
    Writeln;
    HALT;
  END;

  filea := UpString(ParamStr(1));
  fileb := UpString(ParamStr(2));

  IF (filea[1] = 'D') AND (filea[2] = ':') THEN
    Insert (q,filea,2);

  IF (filea[1] = 'D') AND (filea[3] = ':') THEN
    driva := 'A'
  ELSE
    drivb := 'M';

  IF (fileb[1] = 'D') AND (fileb[3] = ':') THEN
    driva := 'A'
  ELSE
    drivb := 'M';

  IF driva = drivb  THEN
  BEGIN
    Writeln ('FEHLER: Zwei gleiche Formate !');
    HALT;
  END;

  IF DiskStatus > 0 THEN
    Diskreset;

  SetNewDriveTab (secprotrk,secsize);

  IF (driva = 'A') AND (drivb = 'M') THEN
    CopyAM (filea,fileb);


  SetOldDriveTab;

  C_On;

END.

Print ATARI DD Disk DOS 2.5 Directory on PC 


(**********************************************************************)
(*                                                                    *)
(* Ph�niX SoftCrew  Turbo Pascal Programme                            *)
(* most (c) by PSC Software Development Lippstadt/Warendorf           *)
(*                                                                    *)
(* Ph�niX SoftCrew          ####   ####  ####                         *)
(* c/o Carsten Strotmann    #   # ##    ##                            *)
(*                          ####   ###  ##     Software Development   *)
(*                          #        ## ##                            *)
(*                          #     ####   ####                         *)
(*                                                                    *)
(**********************************************************************)

(*

  Programmname   :ATARI Dir Version 2
  Filename       :ADIR.PAS
  von            :CARSTEN STROTMANN
  letzte �nderung:06.02.90
  Bemerkung      :

*)

PROGRAM ADIR;

USES CRT, PSCCRT, A_UNIT;

VAR
  u, p : BYTE;
  s : STRING;
  drive,
  drivetype : BYTE;
  search,
  drivestr  : STRING;

BEGIN
  drivestr := '';
  search := '*.*';
  WriteLn;
  s := UpString(ParamStr(1));

  p := Pos (':',s);
  IF p > 0 THEN
  BEGIN
    drivestr := Copy(s,1,p);
    search   := Copy(s,p+1,Length(s)-p);
  END;

  IF drivestr = '' THEN
    search := s;

  IF search = '' THEN
    search := '*.*';

  IF Paramcount > 0 THEN
    WriteLn ('Directory Disk ',s);
  WriteLn;

  IF drivestr = 'D2:' THEN
  BEGIN
    drive := 1;
    drivetype := 1;
  END
  ELSE
  BEGIN
    drive := 0;
    drivetype := 2;
  END;

  IF DiskStatus > 0 THEN
    DiskReset;
  SetDrive (drive,drivetype);
  SetNewDriveTab (secprotrk, secsize);

  Read_Dir (drive);
  Read_VTOC (drive);

  SetOldDriveTab;

  REPEAT
    u := A_FindNext (search);

    IF u > 0 THEN

    BEGIN
      IF (a_dir[u].flag AND $20 > 0)  THEN
        Write ('* ')
      ELSE
        Write ('  ');

      WriteLn (a_dir[u].name, a_dir[u].ext,' ',a_dir[u].length :3);
    END;
  UNTIL u = 0;

  WriteLn;
  WriteLn (a_vtoc.freesec,' Freie Sektoren. ');

  WriteLn;
  WriteLn;

END.

Read ATARI DD Disks by Sector 


(**********************************************************************)
(*                                                                    *)
(* Ph�niX SoftCrew  Turbo Pascal Programme                            *)
(* most (c) by PSC Software Development Lippstadt/Warendorf           *)
(*                                                                    *)
(* Ph�niX SoftCrew          ####   ####  ####                         *)
(* c/o Carsten Strotmann    #   # ##    ##                            *)
(*                          ####   ###  ##     Software Development   *)
(*                          #        ## ##                            *)
(*                          #     ####   ####                         *)
(*                                                                    *)
(**********************************************************************)

(*

  Programmname   : ATARI - Sektoren lesen
  Filename       : AREAD.PAS
  von            : Carsten Strotmann
  letzte �nderung: 15.12.90
  Bemerkung      :

*)


PROGRAM AtariSektorReader;

USES DOS,CRT,PSCCrt;

TYPE
  sector = ARRAY [0..$FF] OF BYTE;

VAR
  track,side,drive,drivetype,error,sekprotrk,seksize,
  secnum,x                : WORD;
  drvstr                  : STRING[3];
  newtab                  : ARRAY [1..11] OF BYTE;
  oldtab                  : POINTER;
  secbuf                  : sector;

PROCEDURE ReadSector (drive,side : BYTE; secnum : WORD; VAR buffer : sector);

VAR
  reg : REGISTERS;
  track, sec, bb : BYTE;

BEGIN
  track := secnum DIV sekprotrk;
  sec := secnum - (track*sekprotrk);
  IF sec = 0 THEN
  BEGIN
    sec := sekprotrk;
    Dec(track);
  END;
  reg.ah := 2;        {Sektor lesen}
  reg.al := 1;        {Anzahl der Sektoren}
  reg.dh := side;     {Diskettenseite}
  reg.dl := drive;    {Disklaufwerk (1/2)}
  reg.cl := sec;      {erster Sektor}
  reg.ch := track;    {Track des Sektors}
  reg.es := Seg(buffer[0]); {Segment des Buffers}
  reg.bx := Ofs(buffer[0]); {Offset des Buffers}
  Intr ($13,reg);
  FOR bb:=0 TO $FF DO
    buffer[bb]:=buffer[bb] XOR $FF;
END;

FUNCTION DiskError :BYTE;

VAR
  reg : REGISTERS;

BEGIN
  reg.ah := 1;
  Intr ($13,reg);
  DiskError := reg.ah;
END;

PROCEDURE DiskReset;

VAR
  reg : REGISTERS;

BEGIN
  reg.ah := 0;
  Intr ($13,reg);
END;

PROCEDURE SetDrive (drive,value : BYTE);
VAR
  reg : REGISTERS;

BEGIN
  reg.ah := $17;
  reg.dl := drive;
  reg.al := value;
  Intr ($13,reg);
END;

PROCEDURE NewDriveTab (sektrack,sekbyte,phy :BYTE);
BEGIN
  newtab[1] := $DF;                   {Schrittzeit}
  newtab[2] := 2;                     {DMA Modus}
  newtab[3] := $2;                    {Motor nachlauf $24}
  newtab[4] := sekbyte;               {Bytes pro Sektor}
  newtab[5] := sektrack;              {Max. Anzahl Sek./Track}
  newtab[6] := $1B;                   {Freiraum zwischen Sektoren ZEIT $1B}
  newtab[7] := $FF;                   {nicht belegt}
  newtab[8] := $10;                   {Freiraum zwischen Sektoren}
  newtab[9] := $FF;                   {ASCII Code zum f�llen}
  newtab[10]:= 15;                    {Ruhezeit zum Ausschwingen}
  newtab[11]:= 8;                     {Anlaufzeit des Motors}
  Getintvec ($1E,oldtab);
  Setintvec ($1E,@newtab);
END;

PROCEDURE OldDriveTab;
BEGIN
  Setintvec ($1E,oldtab);
END;

FUNCTION GetFreeSectors (drive : BYTE): WORD;

VAR
  secbuf : sector;

BEGIN
  ReadSector (drive,0,360,secbuf);
  GetFreeSectors := secbuf[3]+secbuf[4]*$100;
END;

PROCEDURE ErrorMsg (error : BYTE);

BEGIN
  Writeln;
  Writeln;
  Writeln ('Fehler #',error,', Programm gestoppt !');
  Writeln;
  HALT;
END;

PROCEDURE GetDir (drive : BYTE);

VAR
  entry,flg,u,err,itm,errz : BYTE;
  count,startsecnum,sec : WORD;
  name      : STRING[8];
  ext       : STRING[3];
  secbuf    : sector;
  buffer    : ARRAY [0..$F] OF BYTE;

BEGIN

  entry := 0;
  errz := 0;
  REPEAT
    itm := entry MOD 8;
    IF (entry MOD 8) = 0 THEN
      REPEAT
        sec := 361+(entry DIV 8);
        ReadSector (drive,0,sec,secbuf);
        err := Diskerror;
        IF err > 0 THEN
        BEGIN
          Diskreset;
          Inc (errz);
          IF errz > 10 THEN
            ErrorMsg (err);
        END;
      UNTIL err = 0;

    FOR u := 0 TO 15 DO
      buffer[u] := secbuf[itm*$10+u];

    flg := buffer [0];
    count := buffer [1] + buffer[2]*$100;
    startsecnum := buffer[3] +  buffer[4]*$100;

    FOR u := 1 TO 8 DO
      name[u] := Chr(buffer[4+u]);
    name[0] := Chr(8);

    FOR u := 1 TO 3 DO
      ext[u] := Chr(buffer[12+u]);
    ext[0] := Chr(3);

    Writeln;

    IF (flg AND $80 = 0) AND (flg > 0) THEN
    BEGIN
      IF flg AND $20 = 0 THEN
        Write ('* ')
      ELSE
        Write ('  ');

      Write (name,ext,' ',count);
    END;
    IF (flg = 0) OR (entry = 63) THEN
    BEGIN
      Writeln;
      Writeln (GetFreeSectors(drive),' Freie Sektoren.');
    END;

    Inc (entry);

  UNTIL (flg = 0) OR (entry = 64);
END;

BEGIN

  drive := 0;
  drivetype := 2;
  sekprotrk := 18;
  seksize := 1;
  side := 0;

  ClrScr;

  IF Diskerror>0 THEN
    DiskReset;

  SetDrive(drive,drivetype);
  NewDriveTab (sekprotrk,seksize,$54);

  secnum := 360;

  REPEAT
    GetDir (0);

    error := Diskerror;
    IF error > 0 THEN
    BEGIN
      Writeln;
      Writeln ('Fehler :',error,' beim Lesen von Sektor ',secnum,' aufgetreten !');
      DiskReset;
      OldDriveTab;
    END;
  UNTIL error = 0;

  OldDriveTab;
  Writeln;
  Writeln;

END.


Copy MS-DOS File into ATARI DD Disk 


(**********************************************************************)
(*                                                                    *)
(* Ph�niX SoftCrew  Turbo Pascal Programme                            *)
(* most (c) by PSC Software Development Lippstadt/Warendorf           *)
(*                                                                    *)
(* Ph�niX SoftCrew          ####   ####  ####                         *)
(* c/o Carsten Strotmann    #   # ##    ##                            *)
(*                          ####   ###  ##     Software Development   *)
(*                          #        ## ##                            *)
(*                          #     ####   ####                         *)
(*                                                                    *)
(**********************************************************************)

(*

  Programmname   :MS-DOS-File to ATARI Sector Copy
  Filename       :ASECCOPY.PAS
  von            :Carsten Strotmann
  letzte �nderung:18.02.91
  Bemerkung      :

*)

{$A-,B-,E-,F-,I-,L-,N-,R-,V-,G+}

PROGRAM ASecCopy;

USES DOS, PSCDOS, CRT, PSCCRT, A_UNIT;

VAR
  ok         : BOOLEAN;
  cy, p      : BYTE;
  sec, bytes : WORD;
  filelength,
  bytsum     : LONGINT;
  s1         : STRING;
  buffer     : ARRAY [1..$100] OF BYTE;
  msdosfile  : FILE;
  secbuf     : a_sector;

BEGIN

  IF ParamCount < 1 THEN
  BEGIN
    TextColor (RED);
    WriteLn ('Wrong Parameters :');
    WriteLn;
    WriteLn ('SYNTAX : ASECCOPY <msdosfile>');
    Halt ($FF);
  END;

  s1 := FExpand (ParamStr (1));

  IF NOT Exist (s1) THEN
  BEGIN
    TextColor (RED);
    WriteLn ('File ',s1,' not found ');
    Halt ($FF);
  END;

  C_Off;

  TextColor (YELLOW);
  WriteLn;
  WriteLn;
  WriteLn ('Kopiere MS-Dos File ',s1);
  WriteLn;
  WriteLn;
  Writeln;
  Writeln ('Percent   1....:....:....:....:....50...:....:....:....:....100 %');

  cy := WhereY;

  IF cy = 25 THEN
  BEGIN
    Dec(cy);
    GotoXY (1,1);
    DelLine;
  END;

  Assign (msdosfile,s1);
  Reset (msdosfile,1);
  filelength := FileSize (msdosfile);

  IF filelength = 0 THEN
  BEGIN
    TextColor (RED);
    WriteLn;
    WriteLn ('File without data');
    Halt ($FF);
  END;

  SetNewDriveTab (secprotrk, secsize);

  sec := 10;
  bytsum := 0;
  bytes := $100;
  ok := TRUE;

  WHILE NOT EOF(msdosfile) AND (ok = TRUE) AND (sec < 720) DO
  BEGIN
    FillChar (buffer,SizeOf (buffer), 0);
    BlockRead (msdosfile,buffer,SizeOf(buffer),bytes);
    Inc (bytsum,bytes);

    GotoXY (1,cy-3);
    WriteLn ('Writing to Sector ',sec, '; Bytes total :',bytsum,' of ',filelength);
    p := (bytsum * 100 DIV filelength) DIV 2;
    GotoXY (11 + p,cy);
    Write (#127);

    Move (buffer,secbuf,SizeOf(buffer));
    ok := (Write_A_Sector (drivenum,diskside,sec,secbuf) = 0);
    Inc (sec);
  END;

  WriteLn;
  WriteLn;

  IF ok THEN
  BEGIN
    WriteLn ('Copy complete, ',bytsum,' Bytes copied in ',sec-10,' Sectors');

    secbuf.seclink := sec-10;
    secbuf.secsize := bytes;
    Write_A_Sector (drivenum,diskside,9,secbuf);
  END
  ELSE
  BEGIN
    TextColor (RED);
    WriteLn ('Copy failure, Error in Sector ',sec);
  END;

  SetOldDriveTab;
  C_On;

  TextColor (WHITE);
  NormVideo;

END.

Lock Files on ATARI DD Disks 


(**********************************************************************)
(*                                                                    *)
(* Ph�niX SoftCrew  Turbo Pascal Programme                            *)
(* most (c) by PSC Software Development Lippstadt/Warendorf           *)
(*                                                                    *)
(* Ph�niX SoftCrew          ####   ####  ####                         *)
(* c/o Carsten Strotmann    #   # ##    ##                            *)
(*                          ####   ###  ##     Software Development   *)
(*                          #        ## ##                            *)
(*                          #     ####   ####                         *)
(*                                                                    *)
(**********************************************************************)

(*

  Programmname   :ATARI File Lock
  Filename       :ALOCK.PAS
  von            :Carsten Strotmann
  letzte �nderung:11.02.91
  Bemerkung      :

*)

PROGRAM ALock;

USES CRT, A_UNIT, DOS, PSCCRT;

VAR
  files,
  search : STRING;
  entry  : BYTE;

FUNCTION Write_A_Sector (drive, side : BYTE; num : WORD; VAR buffer : a_sector): BYTE;
VAR
  reg : REGISTERS;
  track,
  sec,
  bb  : WORD;
  buf : ARRAY [0..$110] OF BYTE;

BEGIN
  FOR bb := 0 TO $100 DO
    buffer.sectordat[bb] := buffer.sectordat[bb] XOR $FF;

  Move (buffer,buf,$100);

  IF (num > 0) AND (num < 720) THEN
  BEGIN
    bb := DiskStatus;

    IF bb > 0 THEN
      DiskReset;

    track := num DIV secprotrk;
    sec:= num - (track * secprotrk);
    IF sec = 0 THEN
    BEGIN
      sec := secprotrk;
      Dec (track);
    END;
    reg.ah := 3;        {Sektor schreiben}
    reg.al := 1;        {Anzahl der Sektoren}
    reg.dh := side;     {Diskettenseite}
    reg.dl := drive;    {Laufwerk}
    reg.cl := sec;      {erster Sektor}
    reg.ch := track;    {Track des Sektors}
    reg.es := Seg(buf[0]);
    reg.bx := Ofs(buf[0]);
    Intr ($13,reg);

    Write_A_Sector := reg.ah;

  END;
END;

PROCEDURE Write_Dir (drive : BYTE);
VAR
 u : WORD;
 s : a_sector;

BEGIN
 FOR u := 1 TO 8 DO
 BEGIN
   Move (a_dir[(u-1)*8+1],s,128);
   Write_A_Sector (drive,diskside,u+360,s);
 END;
END;

BEGIN

  C_Off;

  WriteLn;
  WriteLn;

  IF ParamCount > 0 THEN
  BEGIN
    files := UpString(ParamStr(1));
    IF (files[1] = 'D') AND (files[2] = ':') THEN
      Insert ('1',files,2);

    drivenum := Ord(files[2]) - 49;
    search := Copy(files,4,Length(files) - 3);
  END
  ELSE
  BEGIN
    search := '*.*';
    drivenum := 0;
  END;

  SetNewDriveTab (secprotrk, secsize);
  Read_Dir(drivenum);

  IF a_error = 0 THEN
  BEGIN
    REPEAT
      entry := A_FindNext(search);
      IF entry > 0 THEN
      BEGIN
        WriteLn (' * ',a_dir[entry].name,'.',a_dir[entry].ext,' locked.');
        a_dir[entry].flag := a_dir[entry].flag OR $20;
      END;
    UNTIL entry = 0;

    Write_Dir (drivenum);
    IF a_error > 0 THEN
      WriteLn ('Directory write error ');
  END
  ELSE
    WriteLn ('Directory read error ');

  SetOldDriveTab;

  C_On;
END.

Format ATARI DD Disk on a PC 


(**********************************************************************)
(*                                                                    *)
(* Ph�niX SoftCrew  Turbo Pascal Programme                            *)
(* most (c) by PSC Software Development Lippstadt/Warendorf           *)
(*                                                                    *)
(* Ph�niX SoftCrew          ####   ####  ####                         *)
(* c/o Carsten Strotmann    #   # ##    ##                            *)
(*                          ####   ###  ##     Software Development   *)
(*                          #        ## ##                            *)
(*                          #     ####   ####                         *)
(*                                                                    *)
(**********************************************************************)

(*

  Programmname   : ATARI - Formatter
  Filename       : AFORMAT.PAS
  von            : Carsten Strotmann
  letzte �nderung: 11.02.91
  Bemerkung      :

*)

PROGRAM AtariDDFormatter;

USES DOS,CRT,PSCCrt;

VAR
  track,side,drive,drivetype,error,sekprotrk,seksize  : BYTE;
  drvstr                  : STRING[3];
  newtab                  : ARRAY [1..11] OF BYTE;
  oldtab                  : POINTER;

FUNCTION FormTrack (side,drive,track,sektor,seksize,sek: BYTE):BYTE;

TYPE
  formtype = RECORD
        track, side, sektor,length : BYTE;
  END;

VAR
  buffer : ARRAY [1..17] OF formtype;
  reg    : REGISTERS;
  u      : BYTE;

BEGIN
  FOR u := 1 TO sek DO
  BEGIN
    buffer[u].track := track;
    buffer[u].side  := side;
    buffer[u].sektor:= u;
    buffer[u].length:= seksize;
  END;
  reg.ah := $5;
  reg.al := sek;
  reg.dh := side;
  reg.dl := drive;
  reg.ch := track;
  reg.es := Seg(buffer[1]);
  reg.bx := Ofs(buffer[1]);
  Intr ($13,reg);
  FormTrack := reg.ah;
END;

FUNCTION DiskError :BYTE;

VAR
  reg : REGISTERS;

BEGIN
  reg.ah := 1;
  Intr ($13,reg);
  DiskError := reg.ah;
END;

PROCEDURE DiskReset;

VAR
  reg : REGISTERS;

BEGIN
  reg.ah := 0;
  Intr ($13,reg);
END;

PROCEDURE SetDrive (drive,value : BYTE);
VAR
  reg : REGISTERS;

BEGIN
  reg.ah := $17;
  reg.dl := drive;
  reg.al := value;
  Intr ($13,reg);
END;

PROCEDURE NewDriveTab (sektrack,sekbyte,phy :BYTE);
BEGIN
  newtab[1] := $DF;                   {Schrittzeit}
  newtab[2] := 2;                     {DMA Modus}
  newtab[3] := $2;                    {Motor nachlauf $24}
  newtab[4] := sekbyte;               {Bytes pro Sektor}
  newtab[5] := sektrack;              {Max. Anzahl Sek./Track}
  newtab[6] := $1B;                   {Freiraum zwischen Sektoren ZEIT $1B}
  newtab[7] := $FF;                   {nicht belegt}
  newtab[8] := $10;                   {Freiraum zwischen Sektoren}
  newtab[9] := $FF;                   {ASCII Code zum f�llen}
  newtab[10]:= 15;                    {Ruhezeit zum Ausschwingen}
  newtab[11]:= 8;                     {Anlaufzeit des Motors}
  Getintvec ($1E,oldtab);
  Setintvec ($1E,@newtab);
END;

PROCEDURE OldDriveTab;
BEGIN
  Setintvec ($1E,oldtab);
END;

BEGIN
  drvstr := ParamStr (1);
  drvstr[1] := UpCase(drvstr[1]);

  IF drvstr='D2:' THEN
  BEGIN
    drive := 1;
    drivetype := 1;
  END
  ELSE
  BEGIN
    drive := 0;
    drivetype := 2;
  END;

  Writeln;
  Writeln ('Formatiere Diskette in Laufwerk D',drive+1,': im ATARI DD-Format.');
  Writeln;
  Writeln ('0.........10........20........30.......39');

  sekprotrk := 18;
  seksize := 1;
  side := 0;
  IF Diskerror>0 THEN
    DiskReset;
  SetDrive(drive,drivetype);
  NewDriveTab (sekprotrk,seksize,$54);
  FOR track := 0 TO 39 DO
  BEGIN
    REPEAT
      error := FormTrack(side,drive,track,track,seksize,sekprotrk);
      IF error > 0 THEN
      BEGIN
        Writeln;
        Writeln ('Fehler :',error,' beim Formatieren aufgetreten !');
        DiskReset;
        OldDriveTab;
        HALT;
      END;
    Write (#127);
    UNTIL error = 0;
  END;
  OldDriveTab;
  Writeln;
  Writeln;
  Writeln ('Formatierung ohne Fehler erledigt. 720 Sektoren/256 Bytes frei.');
  Writeln;
  Writeln;
END.

