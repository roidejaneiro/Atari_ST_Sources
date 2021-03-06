DEFINITION MODULE SysCtrl;

(*
 * Dies Modul dient dazu, die relevanten Informationen zu ermitteln,
 * mit denen ein Programm seine derzeitige Position und Aufrufkette
 * bestimmen kann.
 *
 * So bedienen sich die Module 'GEMError' und 'GEMScan' dieser Funktionen,
 * um dann das bekannte Scanning zu erm�glichen. Siehe dazu auch die
 * mitgelieferten Quelltexte zu diesen Modulen.
 *)

FROM SysTypes IMPORT ScanDesc, ExcDesc;

PROCEDURE ExcToScanAddr ( REF exc: ExcDesc; VAR info: ScanDesc );
  (*
   * Wurde eine Exception mit dem Excepts-Modul abgefangen,
   * k�nnen hiermit die Scan-Werte aus dem Exception-Record
   * ermittelt werden. Wird z.B. von
   *)

PROCEDURE GetScanAddr ( VAR info: ScanDesc );
  (*
   * Liefert Scan-Werte der Funktion, die diese Routine aufruft.
   * 'info.pc' zeigt hinter die Adresse dieses Aufrufs.
   *
   * Damit kann eine Prozedur ihre eigene Adresse ermitteln und dann
   * z.B. mit ModCtrl.GetModName (info.pc, ...) den Funktionsnamen
   * und die rel. Adresse erhalten oder �ber das Modul GEMScan anzeigen
   * lassen.
   *)

PROCEDURE ScanBack ( VAR info: ScanDesc ): BOOLEAN;
  (*
   * Ermittelt aus den �bergebenen Scan-Werten in 'info' die aufrufende
   * Prozedur und liefert TRUE, wenn dies m�glich ist. Dann sind alle
   * drei Werte von 'info' ver�ndert und 'info.pc' zeigt auf die Adresse
   * hinter dem Aufruf.
   *)

END SysCtrl.
