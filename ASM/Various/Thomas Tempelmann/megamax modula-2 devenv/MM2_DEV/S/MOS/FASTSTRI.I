IMPLEMENTATION MODULE FastStrings;
(*$Y+,N+,M-,L-*)

FROM SYSTEM IMPORT ASSEMBLER;
IMPORT Strings;

(*
  18.06.88  TT : Ersterstellung
  29.06.88  TT : Delete wg. Volst�ndigkeit neu.
*)

VAR     valid: BOOLEAN;

PROCEDURE Chr ( REF s: ARRAY OF CHAR; n: CARDINAL ): CHAR;
  BEGIN
    ASSEMBLER
        JMP     Strings.Chr
    END
  END Chr;

PROCEDURE Length ( REF str: ARRAY OF CHAR ): CARDINAL;
  BEGIN
    ASSEMBLER
        JMP     Strings.Length
    END
  END Length;

PROCEDURE Pos ( REF pattern, source: ARRAY OF CHAR ): INTEGER;
  BEGIN
    ASSEMBLER
        CLR.W   (A3)+           ; start
        JMP     Strings.Pos
    END
  END Pos;

PROCEDURE PosLen ( REF pattern, source: ARRAY OF CHAR ): CARDINAL;
  BEGIN
    ASSEMBLER
        CLR.W   (A3)+           ; start
        JMP     Strings.PosLen
    END
  END PosLen;

PROCEDURE Assign ( REF source: ARRAY OF CHAR; VAR dest : ARRAY OF CHAR );
  BEGIN
    ASSEMBLER
        MOVE.L  #valid,(A3)+
        JMP     Strings.Assign
    END
  END Assign;

PROCEDURE Delete ( REF str    : ARRAY OF CHAR;
                       pos    : INTEGER;
                       len    : INTEGER );
  BEGIN
    ASSEMBLER
        MOVE.L  #valid,(A3)+
        JMP     Strings.Delete
    END
  END Delete;

PROCEDURE Append ( REF source: ARRAY OF CHAR; VAR dest : ARRAY OF CHAR );
  BEGIN
    ASSEMBLER
        MOVE.L  #valid,(A3)+
        JMP     Strings.Append
    END
  END Append;

PROCEDURE Insert ( REF source : ARRAY OF CHAR;
                       pos    : INTEGER;
                   VAR dest   : ARRAY OF CHAR );
  BEGIN
    ASSEMBLER
        MOVE.L  #valid,(A3)+
        JMP     Strings.Insert
    END
  END Insert;

PROCEDURE Copy ( REF source : ARRAY OF CHAR;
                     pos    : INTEGER;
                     len    : INTEGER;
                 VAR dest   : ARRAY OF CHAR );
  BEGIN
    ASSEMBLER
        MOVE.L  #valid,(A3)+
        JMP     Strings.Copy
    END
  END Copy;


PROCEDURE Concat ( REF source1, source2: ARRAY OF CHAR; VAR dest: ARRAY OF CHAR );
  BEGIN
    ASSEMBLER
        MOVE.L  #valid,(A3)+
        JMP     Strings.Concat
    END
  END Concat;

PROCEDURE Split ( REF source : ARRAY OF CHAR;
                      pos    : INTEGER;
                  VAR dest1  : ARRAY OF CHAR;
                  VAR dest2  : ARRAY OF CHAR );
  BEGIN
    ASSEMBLER
        MOVE.L  #valid,(A3)+
        JMP     Strings.Split
    END
  END Split;

PROCEDURE Compare ( REF left, right: ARRAY OF CHAR ): Strings.Relation;
  BEGIN
    ASSEMBLER
        JMP     Strings.Compare
    END
  END Compare;

END FastStrings.
 
(* $FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$00000164$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFF6BD4D$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191$FFFBF191�$000003B4T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$000003B4$000000F4$0000017F$00000206$000002BE$00000438$000005E9$000006E3$000008C4$000009EC$00000801$0000082B$00000823$00000544$0000052E$FFED0C36���*)
