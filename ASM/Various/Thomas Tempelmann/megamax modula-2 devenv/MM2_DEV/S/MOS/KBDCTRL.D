DEFINITION MODULE KbdCtrl;

(*
 *                                                 Thomas Tempelmann 28.08.88
 *                                                             Stand 04.22.90
 *
 * Die Funktionen dieses Moduls bieten Zugriff auf den Tastaturpuffer.
 * Sie k�nnen auch in Interruptroutinen aufgerufen werden.
 *
 * VORSICHT:
 *   Die Funktionen, die direkt auf den Tastaturpuffer zugreifen, verhindern
 *   nicht, da� w�hrenddessen gerade ein neues Zeichen im Interrupt eingef�gt
 *   wird. Werden die Funktionen im Tastatur-Interrupt aufgerufen, macht
 *   das nat�rlich nichts, weil w�hrenddessen kein weiterer Interrupt auf-
 *   treten kann. Erfolt der Aufruf aber aus dem User-Modus bzw. im normal
 *   laufenden Programm, m�ssen w�hrenddessen die Interrupts gesperrt werden.
 *   Das ist beispielsweise durch ein "Monitor-Modul" (Priorit�t im Modulkopf,
 *   mu� mind. 5 sein!) oder durch die Funktion 'LockKeyBuffer' (s.u.) m�glich.
 *
 * Damit bei den Tastenabfragen �ber die hiesigen Funktionen oder auch
 * �ber die BIOS/GEMDOS-Funktionen im oberen Wort neben dem Scan-Code
 * auch der Status der Shift-, Ctrl- und Alt- Tasten �bermittelt wird,
 * wird Bit 3 der Systemvariable 'conterm' (bei Adr. $484) automatisch
 * bei der Initialisierung dieses Modul von seinem K�rper (Body) gesetzt.
 * Bei Proze�ende des (�ltesten) importierenden Moduls oder Freigabe eines
 * importierenden residenten Moduls/Programms wird der alte Wert in 'conterm'
 * wiederhergestellt.
 * Der alte Wert wird in der globalen Variablen 'PreviousMode' gerettet
 * und kann ggf. ver�ndert werden, um damit eine andere R�ckstellung des
 * Wertes bei Programmende/-freigabe zu bewirken.
 * Zwischendurch kann der 'conterm'-Wert auch mit der Funktion 'SetMode'
 * ver�ndert werden.
 *)

FROM MOSGlobals IMPORT Key, CtrlKey, CtrlSet;
FROM SYSTEM IMPORT ADDRESS;


VAR PreviousMode: BOOLEAN;
 (*
  * Enth�lt den Wert des 'conterm'-Bits (Nr.3) vor dem Start dieses
  * Moduls.
  * Der Wert dieser Variablen wird bei Programmende/-freigabe wieder
  * nach 'conterm' geschrieben.
  *)

PROCEDURE CurrentMode (): BOOLEAN;
PROCEDURE SetMode (extended: BOOLEAN);
PROCEDURE SetExtMode (VAR lastMode: BOOLEAN);
 (*
  * 'CurrentMode' liefert den aktuellen Status des Bit 3 aus 'conterm',
  * 'SetMode' setzt oder l�scht das Bit, je nach dem �bergebenen
  * BOOLEAN-Wert.
  * 'SetExtMode' setzt das Bit und liefert in 'lastMode' den vorherigen
  * Wert, soda� dieser danach mit 'SetMode (lastMode)' zur�ckgesetzt
  * werden kann (dies ist eine optimierte Funktion, um kurzzeitig das Bit
  * zu setzen und danach wiederherzustellen).
  * VORSICHT: Diese drei Prozeduren nicht in Interrupt-Routinen aufrufen!
  *)


PROCEDURE LookKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Liefert die als n�chste anstehende Taste (also die �lteste im
  * Puffer), ohne sie aus dem Puffer zu entfernen.
  * Wenn 'ok' = FALSE, ist keine Taste vorhanden.
  *)

PROCEDURE GetKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Holt die als n�chste anstehende (die �lteste) Taste aus dem Puffer.
  * Wenn 'ok' = FALSE, ist keine Taste vorhanden.
  *)

PROCEDURE LookMostRecentKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Liefert die zuletzt eingef�gte Taste (also die j�ngste im
  * Puffer), ohne sie aus dem Puffer zu entfernen.
  * Wenn 'ok' = FALSE, ist keine Taste vorhanden.
  *)

PROCEDURE PushBackKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * Schreibt die Taste so in den Puffer zur�ck, da� sie als
  * n�chste Taste wieder ausgelesen wird.
  * Wenn 'ok' = FALSE, ist der Puffer voll.
  *)

PROCEDURE PutKey ( VAR k: Key; VAR ok: BOOLEAN );
 (*
  * F�gt die Taste in Puffer hinten an, so, als ob die Taste
  * gedr�ckt worden w�re.
  * Wenn 'ok' = FALSE, ist der Puffer voll.
  *)

PROCEDURE ClrKeyBuffer;
 (*
  * L�scht die anstehenden Tasten im Puffer.
  *)

PROCEDURE KeysAvail (): CARDINAL;
 (*
  * Liefert Anzahl der vorhandenen Tasten im Puffer
  *)

PROCEDURE KeyBufferSize (): CARDINAL;
 (*
  * Liefert Fassungsverm�gen des Puffers.
  *)

VAR KbdRec: ADDRESS;
 (*
  * Zeigt auf den verwendeten Tastaturpuffer-Descriptor des BIOS.
  * Wird von diesem Modul automatisch initialisiert, kann jedoch
  * bei Bedarf ver�ndert werden.
  *)


(*
 *   Die folgenden beiden Funktionen erlauben es, mehrere Tasten mittels
 * 'PutKey' oder 'PushBackKey' nacheinander in den Puffer zu schreiben,
 * ohne da� Tastendr�cke von der Tastatur dazwischengeraten k�nnen.
 * Dazu werden alle Interrupts gesperrt.
 *   Bei ihrer Verwendung ist unbedingt darauf zu achten, da� nach dem Aufruf
 * von 'LockKeyBuffer' und dem Einf�gen der Tasten wieder 'UnlockKeyBuffer'
 * aufgerufen wird. Auch sollte die Zeit zwischen den beiden Aufrufen so
 * kurz wie m�glich gehalten werden.
 *)

PROCEDURE LockKeyBuffer ( VAR hdl: LONGCARD );
 (*
  * Sperrt die Interrupts bis einschl. Level 6. Dabei wird in 'hdl'
  * ein Wert zur�ckgegeben, der beim Aufruf von 'UnlockKeyBuffer'
  * wieder �bergeben werden mu�.
  *)

PROCEDURE UnlockKeyBuffer ( hdl: LONGCARD );
 (* Gibt die Interrupts wieder frei *)

END KbdCtrl.
