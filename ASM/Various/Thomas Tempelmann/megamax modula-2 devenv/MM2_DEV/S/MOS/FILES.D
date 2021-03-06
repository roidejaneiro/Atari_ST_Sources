DEFINITION MODULE Files;

FROM MOSGlobals IMPORT Time, Date;

FROM FileBase IMPORT File0;

TYPE File = File0;

     Access = ( readOnly, writeOnly, readWrite,       (* Bin�rmodus *)
                readSeqTxt, writeSeqTxt, appendSeqTxt (* Textmodus  *) );

     ReplaceMode = ( noReplace, replaceOld );


PROCEDURE Init (VAR f: File);
  (*
   * Initialisiert eine File-Variable. Danach darf jede beliebige
   * Datei-Operation erfolgen, ohne da� mit undefinierten Ergebnissen
   * gerechnet werden mu� (dies ist sonst nur bei Open & Create
   * gesichert).
   * Eine Fehler-/Statusabfrage mit 'State' liefert daraufhin
   * 'MOSGlobals.fFileNotOpen'.
   *)

PROCEDURE Open (VAR f       : File;
                REF fileName: ARRAY OF CHAR;
                    mode    : Access);
  (*
   * Wenn 'mode' = 'appendSeqTxt', dann wird, sofern die Datei auf Disk o.�.
   * ge�ffnet wird, nicht ab Anfang der Datei �berschrieben, sondern am Ende
   * angef�gt.
   * Wenn ein Fehler auftritt, bleibt die Datei geschlossen und 'State'
   * liefert die Fehlernummer.
   *)

PROCEDURE Create (VAR f       : File;
                  REF fileName: ARRAY OF CHAR;
                      mode    : Access;
                      replMode: ReplaceMode);
  (*
   * Wenn 'replMode'='noReplace', wird ein Fehler geliefert, wenn schon
   * eine Datei unter dem Namen existiert.
   * Wenn 'replMode'='replaceOld', wird, falls 'mode'='writeSeqTxt', eine
   * schon vorhandene Datei gel�scht, wenn 'mode'='appendSeqTxt', wird, wenn
   * schon eine Datei existiert, diese nicht gel�scht sondern die Daten
   * angeh�ngt.
   * Wenn ein Fehler auftritt, bleibt die Datei geschlossen und 'State'
   * liefert die Fehlernummer.
   *)

PROCEDURE Close (VAR f: File);
  (*
   * Schlie�t Datei und aktualisiert die Datums-/Zeitkennung, falls die
   * Datei beschrieben wurde.
   * Die Datei wird auf jeden Fall geschlossen (die File-Variable wird
   * ung�ltig).
   * Es ist unbedingt ratsam, das erfolgreiche Schlie�en mittels 'State'
   * zu pr�fen, da ein evtl. folgendes 'Open' oder 'Create' nicht, wie
   * fast alle �brigen Dateifunktionen, selbstt�tig auf vorangehende
   * Fehler pr�fen!
   *)

PROCEDURE Remove (VAR f: File);
  (*
   * Schlie�t Datei, und l�scht sie aus dem Directory, falls sie mit
   * 'Create' angelegt wurde.
   * Die Datei wird auf jeden Fall geschlossen (die File-Variable wird
   * ung�ltig), evtl. aufgetretene Fehler sind �ber 'State' zu ermitteln.
   *)


PROCEDURE Flush (f: File);
  (*
   * Hat nur bei eigenen Anwendungen Sinn, falls die flush-Routinen
   * eigener Unit-Treiber (siehe Handbuch sowie Modul 'FileBase')
   * aufgerufen werden sollen.
   *)


PROCEDURE SetDateTime ( f: File; d: Date; t: Time );
  (*
   * Setzt Datums-/Zeitkennung einer ge�ffneten Datei.
   *
   * Funktioniert nur bei Dateien, die mit 'Open' - also
   * nicht mit 'Create' - ge�ffnet wurden!
   *)

PROCEDURE GetDateTime ( f: File; VAR d: Date; VAR t: Time );
  (*
   * Ermittelt Datums-/Zeitkennung einer ge�ffneten Datei.
   *)


PROCEDURE GetFileName (f: File; VAR name: ARRAY OF CHAR);
  (*
   * Liefert den Dateinamen, unter dem die Datei ge�ffnet wurde.
   * 'name' sollte vom Typ 'FileStr' sein, damit der Name auf
   * jedenfall hineinpa�t.
   *)


PROCEDURE AccessMode (f: File): Access;
  (*
   * Liefert den Zugriffsmodus bei der ge�ffneten Datei 'f'.
   * L�st eine Fehlermeldung aus, wenn die Datei nicht offen ist
   * oder ein Fehler (s. State-Funktion) ansteht!
   *)

PROCEDURE DiskAccess (f: File): BOOLEAN;
  (*
   * Liefert TRUE, wenn die ge�ffnete Datei keine Unit, sondern
   * eine Disk-Datei ist.
   * L�st eine Fehlermeldung aus, wenn die Datei nicht offen ist
   * oder ein Fehler (s. State-Funktion) ansteht!
   *)


PROCEDURE EOF (f: File): BOOLEAN;
  (*
   * Bei Dateien, die mit 'readSeqTxt' ge�ffnet sind, wird TRUE geliefert,
   * wenn der letzte Lesezugriff das EOF-Zeichen (CTRL-Z, s.u.) mit einlas,
   * bei Textdateien auf Disk o.�. wird jedoch sp�testens dann TRUE geliefert,
   * wenn der letzte Lesezugriff �ber das Dateiende hinweg (!) erfolgte.
   *
   * Bei Bin�rdateien wird genau dann TRUE geliefert, wenn der Dateizeiger
   * auf das Ende der Datei zeigt (Length(f)=Pos(f)) (dahinter kann er nicht
   * zeigen; wenn doch, wird's kritisch).
   *)

PROCEDURE SetEOFMode (f: File; checkChar: BOOLEAN; eofChar: CHAR);
  (*
   * Normalerweise wird bei Textdateien das Ende der Datei durch das
   * Zeichen EOF (Ctrl-Z) erkannt oder bei Diskdateien auch durch das
   * physikalische Dateiende.
   * Mit dieser Funktion kann jeweils f�r die angegebene, offene Datei
   * sowohl das Endezeichen ('eofChar') umdefiniert werden, als auch die
   * Erkennung des Endezeichens ('checkChar') ganz unterdr�ckt werden.
   * In dem Fall wird dann bei Diskdateien die Funktion EOF in jedem Fall
   * nach �berlesen des Dateiendes TRUE liefern; bei Dateien auf andere
   * Devices, z.B. 'CON:', wird EOF dann nie TRUE liefern.
   *)

PROCEDURE GetEOFMode (f: File; VAR checkChar: BOOLEAN; VAR eofChar: CHAR);
  (* Liefert den gerade eingestellten Modus zum Erkennen des Dateiendes.
   * Darf nur bei Textdateien, die mit 'readSeqTxt' ge�ffnet wurden,
   * aufgerufen werden, sonst erfolgt Fehlermeldung.
   * Die Voreinstellung, die bei jedem �ffnen einer Textdatei eingestellt
   * wird, ist wie folgt: 'checkChar' = TRUE; 'eofChar' = 32C (=$1A, Ctrl-Z).
   *)


PROCEDURE State (f: File): INTEGER;
  (*
   * Liefert einen positiven Wert, wenn letzte Operation an der Datei keinen
   * Fehler erzeugte, ansonsten eine negative Fehlernummer.
   *
   * Wenn die Datei nicht offen ist (nach Init, Close, Remove), wird
   * 'MOSGlobals.fFileNotOpen' geliefert.
   *)

PROCEDURE GetStateMsg (no: INTEGER; VAR msg: ARRAY OF CHAR);
  (*
   * Liefert in 'msg' einen String (H�chstl�nge 32 Zeichen), der eine
   * Beschreibung der zugeh�rigen Fehlernummer 'no' enth�lt.
   * Funktion ist identisch mit 'Directory.GetErrMsg'.
   *)

PROCEDURE ResetState (VAR f: File);
  (*
   * Diese Prozedur mu� aufgerufen werden, wenn vorher mit Aufruf von
   * 'State' ein Fehler erkannt wurde.
   *)

PROCEDURE Abort (VAR f: File);
  (*
   * Unterbindet alle weiteren Operationen auf dieser Datei.
   * Das bedeutet, da� jegliche weitere Funktionen, bis auf
   * Close, Remove und Init, ignoriert werden - es treten dann
   * auch keine Fehlermeldungen mehr auf.
   * Diese Funktion kann beispielsweise nach Erkennnen eines
   * fatalen Fehlers aufgerufen werden, anstatt weitere im Programmflu�
   * auftretenden Dateioperationen auf andere Weise extra zu vermeiden.
   * Nach Aufruf dieser Funktion wird die Datei wie eine Geschlossene
   * behandelt: Read-Funktionen lesen keine Zeichen, EOF liefert immer
   * TRUE.
   *)

PROCEDURE SysOpen (VAR f: File; REF n: ARRAY OF CHAR; m: Access);
PROCEDURE SysCreate (VAR f: File; REF n: ARRAY OF CHAR; m: Access; r: ReplaceMode);
  (*
   * Diese Funktionen arbeiten z.Zt. wegen Problemen mit dem GEMDOS
   * nicht ordnungsgem�� und k�nnen daher nicht, wie beabsichtigt,
   * verwendet werden.
   *)

    (*****************************************
     * Es folgen Funktionen, die nur system- *
     * intern benutzt werden d�rfen!         *
     *****************************************)

PROCEDURE @CheckState (f: File): BOOLEAN;

END Files.
