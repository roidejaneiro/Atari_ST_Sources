DEFINITION MODULE HdlError;


FROM SysTypes IMPORT ExcDesc;

FROM ErrBase IMPORT ErrResp, RtnCond;

FROM MOSGlobals IMPORT MemArea;

TYPE    ErrProc = PROCEDURE (     (* errNo:   *) INTEGER,
                                  (* msg:     *) ARRAY OF CHAR, (* max. 32 Zeichen *)
                                  (* causer:  *) ErrResp,
                                  (* cont:    *) RtnCond,
                              VAR (* excData: *) ExcDesc ): BOOLEAN;
        (* RETURN: FALSE: Continue Prg.; TRUE: Not caught *)


PROCEDURE CatchErrors ( call: ErrProc; workSpace: MemArea ): BOOLEAN;
  (*
   * Liefert FALSE, wenn Anmeldung nicht durchf�hrbar ist.
   *)

PROCEDURE SysCatchErrors ( call: ErrProc; workSpace: MemArea ): BOOLEAN;

PROCEDURE ReleaseCatcher ( call: ErrProc );

PROCEDURE GetErrorMsg ( number: INTEGER; VAR msg: ARRAY OF CHAR );
  (*
   * Liefert in 'msg' einen String (H�chstl�nge 32 Zeichen), der eine
   * Beschreibung der zugeh�rigen Fehlernummer enth�lt.
   * Die Fehlernummern sind in 'MOSGlobals' definiert, die Meldungen
   * werden �ber 'MOSConfig.RuntimeErrMsg' initialisiert (z.B. in 'GEMError').
   *)

END HdlError.
