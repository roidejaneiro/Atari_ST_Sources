MODULE CompInit;

(*
 * Treibermodul, das den Compiler als gelinktes Programm lauff�hig macht.
 *
 * Anwendung:
 * ----------
 *
 * Der Compiler kann dann als TTP-Programm oder von einer Command-Shell
 * aufgerufen werden. Die Argumente sind wie folgt:
 *
 *  <Dateiname> [ optionen ]
 *
 * Also kommt zuerst der Name der zu compilierenden Datei, dann k�nnen
 * Optionen, jeweils mit Leerzeichen getrennt, folgen:
 *   -Q            Kurzausgaben, wie Importe, usw.
 *   +Q            KEINE Kurzausgaben, wie Importe, usw.
 *   /O<pfad>      <pfad> ist der gew�nschte Ausgabepfad. Fehlt er, wird
 *                 einer der unten deklarierten Pfade (Def/Imp/ModOutPath)
 *                 verwendet.
 *   /P<name>      Erzeugt ein Protokoll in der Datei <name>
 *   /C<zahl>      F�r Protokoll: Breite der Ausgabezeilen.
 *   /Q            Compiler macht �BERHAUPT KEINE Ausgaben
 *
 *
 * Installation:
 * -------------
 *
 * Zuerst m�ssen hier im Modul die 'set'-Aufrufe angepa�t werden
 * auf die Pfade, wie sie auf dem Zielsystem verwendet werden, ebenso
 * m�ssen die Zuweisungen f. 'ErrListFile', 'DefOutPath', 'ImpOutPath',
 * 'ModOutPath' und 'DefLibName' angepa�t werden.
 * Siehe dazu Anmerkungen mit ">>> .... <<<".
 *
 * In der Shell sollte beim Linker die vollst. Optimierung gew�hlt
 * werden. Die Stackgr��e sollte 16000 betragen. Die Treiber-Module
 *   M2Init,
 *   GEMDOSIO.IMP und
 *   CompInit (dieses Modul)
 * m�ssen in den Linker-Optionen aktiviert werden.
 *
 * Dann kann der Compiler (MM2COMP.MOD) gelinkt werden und sollte ggf.
 * in "MM2COMP.TTP" umbenannt werden. Achtung: Das Linken des Compilers
 * dauert ungew�hnlich lang!
 *
 * Weiterhin beachte die Hinweise hier im Programmtext!
 *)

FROM SYSTEM IMPORT ADDRESS, ADR;

FROM ShellMsg IMPORT DefPaths, ImpPaths, ModPaths, SrcPaths,
  Active, DefSfx, ImpSfx, ModSfx, ErrListFile,
  DefLibName, DefOutPath, ImpOutPath, ModOutPath,
  CodeName, ErrorMsg, TextName, TextLine, TextCol;

FROM ErrBase IMPORT RaiseError, ErrResp, RtnCond;

FROM PrgCtrl IMPORT CurrentExitCode, CatchProcessTerm, TermCarrier;

FROM MOSGlobals IMPORT MemArea;

IMPORT Lists, Strings, InOut;



VAR     handle: ADDRESS;

CONST   pathSize = 64;  (* -- Dieser Wert darf ver�ndert werden -- *)
        maxPath = 20;   (* -- Dieser Wert darf ver�ndert werden -- *)

VAR     pathArray: ARRAY [1..maxPath] OF ARRAY [0..pathSize] OF CHAR;


PROCEDURE setPaths;
  VAR err: BOOLEAN; idx: CARDINAL;
  PROCEDURE set (VAR path: Lists.List; name: ARRAY OF CHAR);
    VAR ok: BOOLEAN;
    BEGIN
      IF Strings.Length (name) >= pathSize THEN
        RaiseError (-1, "'pathSize' erh�hen!", callerCaused, mayContinue)
      ELSE
        IF idx < maxPath THEN
          INC (idx);
          Strings.Assign (name, pathArray [idx], ok);
          Lists.AppendEntry (path, ADR (pathArray[idx]), err)
        ELSE
          RaiseError (-1, "'maxPath' erh�hen!", selfCaused, mayContinue)
        END
      END
    END set;
  BEGIN
    idx:= 0;
    Lists.CreateList (DefPaths,err);
    Lists.CreateList (SrcPaths,err);

    (* >>> Hier k�nnen die gew�nschten Pfade zugewiesen werden. <<< *)
    (* Suchpfade f�r Def-Module (notwendig): *)
    set (DefPaths, '.\');
    set (DefPaths, 'A:\MM2\DEF\');
    (* Suchpfade f�r Quelltexte (optional): *)
    set (SrcPaths, '.\');
  END setPaths;


PROCEDURE termination;
  (*
   * Die Funktion wird aufgerufen, wenn der Compiler fertig ist.
   * Dann kann hier gepr�ft werden, ob ein Fehler aufgetreten ist
   * und dann beispielsweise die Informationen in eine Datei geschrieben
   * werden, damit ein danach aufzurufender Editor (z.B. TEMPUS) die
   * Fehlerstelle leicht anspringen kann.
   *)
  BEGIN
    CASE CurrentExitCode () OF
      0: (* fehlerfreie �bersetzung *)
    | 1: (* keine Datei zum �bersetzen angegeben *)
    | 2: (* Datei (I/O)-Fehler *)
         InOut.WriteString (ErrorMsg);
         InOut.WriteLn;
    | 3: (* Syntaxfehler *)
         InOut.WriteString (ErrorMsg);
         InOut.WriteLn;
         (*
          * 'TextName', 'TextLine', 'TextCol' enthalten Namen des
          * Quelltextes und die Fehlerposition, die nun weitergereicht
          * werden k�nnen.
          *)
    ELSE
    END
  END termination;

VAR carrier: TermCarrier;
    wsp: MemArea;

BEGIN
  setPaths;  (* Hier werden die Suchpfade f�r DEF-Dateien gesetzt *)
  DefSfx:= 'DEF';
  ImpSfx:= 'IMP';
  ModSfx:= 'MOD';
  ErrListFile:= 'MODULA.ERR';   (* >>> Hier Pfad mit eintragen! <<< *)

  (* Ausgabepfade f�r �bersetzte Dateien: *)
  DefOutPath:= '.\';        (* >>> Pfad f. Symboldateien (.DEF) <<< *)
  ImpOutPath:= '.\';        (* >>> Pfad f. Implementations-Codes (.IMP) <<< *)
  ModOutPath:= '.\';        (* >>> Pfad f. Hauptmodul-Codes (.MOD) <<< *)

  (* Name der Library (incl. Pfad!) *)
  DefLibName:= 'MM2DEF.M2L';    (* >>> Hier Pfad mit eintragen! <<< *)

  (* Vorbereitungen zum Abfangen von �bersetzungsfehlern treffen *)
  Active:= TRUE;
  CatchProcessTerm (carrier, termination, wsp);
END CompInit.
