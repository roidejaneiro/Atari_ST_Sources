IMPLEMENTATION MODULE ResCtrl;
(*$Y+,L-,R-*)

FROM SYSTEM IMPORT ASSEMBLER, ADDRESS, ADR, TSIZE, BYTE, WORD, LONGWORD;

FROM MOSCtrl IMPORT RemovalRoot, RemovalEntry, GetPDB, PDB;

FROM MOSGlobals IMPORT MemArea;


PROCEDURE CatchRemoval ( VAR hdl: RemovalCarrier; info: PROC; wsp: MemArea );
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),D2
        MOVE.L  -(A3),D1
        MOVE.L  -(A3),D0
        MOVE.L  -(A3),A0                ; A0: hdl
        MOVE.L  D0,RemovalEntry.call(A0)
        MOVE.L  D1,RemovalEntry.wsp.bottom(A0)
        MOVE.L  D2,RemovalEntry.wsp.length(A0)
        ; hdl.next:= root
        ; hdl.prev:= root.prev
        ; root.prev.next:= hdl
        ; root.prev:= hdl
        LEA     RemovalRoot,A2               ; A2: root
        MOVE.L  A2,RemovalEntry.next(A0)
        MOVE.L  RemovalEntry.prev(A2),A1     ; A1: root.prev
        MOVE.L  A1,RemovalEntry.prev(A0)
        MOVE.L  A0,RemovalEntry.next(A1)
        MOVE.L  A0,RemovalEntry.prev(A2)
    END
  END CatchRemoval;

PROCEDURE Resident (): BOOLEAN;
  BEGIN
    ASSEMBLER
        CLR.L   -(A7)
        MOVE.L  A7,(A3)+        ; PtrPBD
        CLR.L   -(A7)
        MOVE.L  A7,(A3)+        ; process
        JSR     GetPDB
        ADDQ.L  #4,A7
        MOVE.L  (A7)+,D0
        BEQ     no
        MOVE.L  D0,A0
        MOVE.W  PDB.resident(A0),(A3)+
        RTS
     no CLR     (A3)+
    END
  END Resident;

PROCEDURE Private ( n: CARDINAL; VAR d: ARRAY OF BYTE );
  BEGIN
    ASSEMBLER
        SUBQ.L  #8,A3
    END
  END Private;

END ResCtrl.
 
(* $FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFEE2C3C$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820$FFF3E820�$00000031T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000000DD$00000078$0000004F$00000025$00000031$FFEE2C3C$FFEE2C3C$FFEE2C3C$00000029$000002F2$00000091$000004E4$0000050A$0000051F$00000540$00000582���*)
