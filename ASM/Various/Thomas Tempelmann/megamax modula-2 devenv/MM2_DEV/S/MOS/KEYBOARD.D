DEFINITION MODULE Keyboard;

 (*
  *                                       Thomas Tempelmann 28.08.88
  *                                             F�r Megamax Modula-2
  *
  *   Dieses Modul bietet Funktionen zum Auswerten der erweiterten
  *   Tastencodes, wie sie z.B. von den Funktionstasten und den
  *   Cursortasten erzeugt werden.
  *
  *   Es sind auch Funktionen vorhanden, die zwischen verschiedenen
  *   internen Darstellungsformaten von Tasten mit Scan-Codes konvertieren.
  *   (z.B. von 'GEMGlobals.GemChar/.SpecialKeySet' nach dem hier verwendeten
  *   'Key'-Type).
  *
  * ---------------------
  *  30.08.89  TT  Die Tastenabfragefunktionen wurden entfernt;
  *                intern wurden Belegung von wdLeft/Right und soln/eoln
  *                vertauscht.
  *
  *)

FROM MOSGlobals IMPORT Key;
FROM SYSTEM IMPORT LONGWORD, WORD, BYTE;


PROCEDURE GemCharToKey (gemChar: WORD; specialKeySet: BYTE; VAR k: Key);
PROCEDURE KeyToGemChar (k: Key; VAR gemChar: WORD; VAR specialKeySet: BYTE);
  (*
   * Konvertieren Werte aus 'GEMGlobals.GemChar' und 'GEMGlobals.SpecialKeySet'
   * nach 'Key' und umgekehrt.
   *)

PROCEDURE LongToKey (l: LONGWORD; VAR k: Key);
PROCEDURE KeyToLong (k: Key; VAR l: LONGWORD);
  (*
   * Konvertieren Tastenwerte, die in einem Longword (4 Byte) abgelegt sind
   * (z.B. von den BIOS- und GEMDOS-Funktionen) nach 'Key' und umgekehrt.
   *)


 (*
  * Sollen in einem Programm Sondertasten, wie die Help-Taste oder den
  * Funktionstasten, abgefragt werden, gibt es dazu zwei M�glichkeiten.
  * Entweder man orientiert sich nur an den von Atari vordefinierten
  * Tastencodes (Kombination aus dem Scan- und dem ASCII-Code) oder
  * man erkennt die Taste als solche und ber�cksichtigt dann die evtl.
  * zus�tzlichen Kontrolltasten, wie Shift, Control und Alternate.
  *
  * Die erste M�glichkeit ist einfacher zu realisieren, jedoch ein-
  * schr�nkend da nicht alle Tastenkombinationen kodiert sind. So
  * erh�lt man bei den 10 Funktionstasten nur 20 Kombinationen, indem
  * entweder die Funktionstasten alleine oder mit der Shift-Taste ver-
  * wendet werden. Zus�tzlich gedr�ckte Alternate- oder Control-Tasten
  * werden ignoriert. Ebensolches zeigt sich auch bei anderen Tasten.
  *
  * Besteht Bedarf, auch unkodierte Kombinationen zu erkennen, mu� man
  * sich eines umst�ndlicheren Verfahrens bedienen. Denn auch die Tasten
  * sind nicht immer einfach an ihrem Scan-Code erkennbar, denn das TOS
  * simuliert durch Kombination mit z.B. der Alternate-Taste die Bedie-
  * nung anderer, nicht wirklich vorhandener, Tasten.
  * So kann man das Dr�cken von Alternate-X nicht durch Erkennen des
  * ASCII-Codes 'X' (oder auch noch 'x') und des Alternate-Tastenstatus
  * ermitteln sondern mu� darauf gefa�t sein, da� diese Kombination schon
  * einen eigenen Scan/ASCII-Code hat.
  * Auch das Abfragen der Funktionstasten ist umst�ndlich. Liefert F1
  * alleine den Scan-Code $3B, in Verbindung mit Shift den Code $54,
  * was die imagin�re Taste F11 simuliert.
  * Soll Control-F1 erkannt werden, mu� also F1 und die Control-Taste
  * abgefragt werden, bei Alternate/Shift-F1 mu� der Alternate-Status
  * und die F11-Taste abgefragt werden. Soll, was bei der vorigen
  * Kombination zweier Kontrolltasten sinnvoll ist, der Unterschied
  * zwischen Alternate-F1 und Alternate/Shift-F1 erkannt werden, ist
  * zu Bedenken, da� die Shift-Taste im ersten Fall nicht, im anderen
  * Fall aber doch im Kontrolltasten-Status registiert ist.
  * Aus diesem Grund wird hier die Funktion 'KeyCap' bereitgestellt,
  * die einem die Arbeit der Tastenerkennung abnimmt. Sie liefert einen
  * Wert des Aufz�hlungstyps 'Cap', der die Taste als solche beschreibt.
  * Es braucht dann nur noch der Kontrolltasten-Status abgefragt werden
  * (der steht im 'Key'-Record).
  *
  * Tastenkombinationen sollten also entweder mit der 'SpecialKey'-Funktion
  * (s.u.) oder kombiniert mit 'KeyCap' und dem Kontrolltasten-Status
  * ermittelt werden, jedoch nie aus einer Vermischung von Kontrolltasten-
  * Abfrage und 'SpecialKey'-Funktion.
  *
  * Sollen normale ASCII-Zeichen alle normal behandelt werden, sind die
  * anderen Sondertasten (Funktionstasten, Cursortasten, Insert, ..., aber
  * nicht Esc, Return, Delete usw.) mit der 'IsCharacter'-Funktion
  * (wenn sie FALSE liefert) zu behandeln.
  * Sollen dagegen auch z.B. Control-Tasten (Control-A .. Control-Z)
  * behandelt werden, ist nicht deren ASCII-Code dazu abzufragen (denn
  * Return liefert z.B. den gleichen Code wie Control-M), sondern erstmal
  * die Funktion 'IsSpecial' oder gleich 'SpecialKey' zu befragen.
  * Es geht nat�rlich auch, einfach nur Abzufragen, ob die Help-Taste
  * gedr�ckt wurde (IF SpecialKey (k) = help THEN ...)
  *)


TYPE

  Cap = (unspecCap, escCap, tabCap, backspaceCap, deleteCap,
         returnCap, enterCap, helpCap, undoCap, insertCap, clrHomeCap,
         upCap, downCap, leftCap, rightCap, f1Cap, f2Cap,
         f3Cap, f4Cap, f5Cap, f6Cap, f7Cap, f8Cap, f9Cap, f10Cap);
      (*
       * Alle in der Aufz�hlung enthaltenen Tasten werden immer
       * so erkannt, wie die Tasten f�r den Benutzer sichtbar sind,
       * unabh�ngig davon, ob zus�tzlich z.B. eine Shift-Taste
       * gedr�ckt wird. Um also zu ermitteln, ob F1 oder Shift-F1 gedr�ckt
       * wurde, mu� nach Erkennen von 'f1Cap' (aus dieser Aufz�hlung) im
       * 'ctrl'-Feld des 'Key'-Records die Shift-Taste abgefragt werden.
       *)

PROCEDURE KeyCap (VAR k: Key): Cap;
  (*
   * Wird 'unspecCap' geliefert, ist die Taste keine der in der Aufz�hlung
   * 'Cap' enthaltenen Tasten.
   * Sollen die Alternate-Kombinationen mit Buchstaben oder Ziffern (nur
   * auf dem Buchstabenblock, aber nicht auf dem Ziffernblock m�glich)
   * erkannt werden, mu� die Auswertung �ber die Funktion 'SpecialKey'
   * erfolgen.
   *)


TYPE

  SpecialCode = (unspecKey, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10,
                 f11, f12, f13, f14, f15, f16, f17, f18, f19, f20,
                 esc, tab, backspace, delete, delLine, insert, insLine,
                 return, enter, up, down, left, right, pgUp, pgDown,
                 wdLeft, wdRight, soln, eoln, clr, home, help, undo,
                 ctrlA, ctrlB, ctrlC, ctrlD, ctrlE, ctrlF, ctrlG, ctrlH,
                 ctrlI, ctrlJ, ctrlK, ctrlL, ctrlM, ctrlN, ctrlO, ctrlP,
                 ctrlQ, ctrlR, ctrlS, ctrlT, ctrlU, ctrlV, ctrlW, ctrlX,
                 ctrlY, ctrlZ,
                 alt1, alt2, alt3, alt4, alt5, alt6, alt7, alt8, alt9, alt0,
                 altA, altB, altC, altD, altE, altF, altG, altH,
                 altI, altJ, altK, altL, altM, altN, altO, altP,
                 altQ, altR, altS, altT, altU, altV, altW, altX,
                 altY, altZ);
       (*
        * 'return' ist die Return-Taste auf dem alphanum. Tastenblock,
        * 'enter' ist die Enter-Taste auf dem Ziffernblock.
        * F11-F20 werden durch Shift-F1 bis Sihft-F10 eingegeben.
        * 'home' ist die "Clr/Home"-Taste ohne, 'clr' mit der Shift-Taste.
        * 'pgUp' / 'pgDown' werden mit Shift-Auf-/Ab-Pfeilen,
        * 'wdLeft' / 'wdLeft' Shift-Links-/Rechts-Pfeilen und
        * 'soln' / 'eoln' durch Control-Links-/Rechts-Pfeilen eingegeben.
        * 'delLine' wird mit Control-Delete,
        * 'insLine' mit Shift-Insert erreicht.
        * Es wird daf�r gesorgt, da� z.B. das Dr�cken von Alternate und 'Z'
        * immer 'altZ' zum Ergebnis hat, unabh�ngig davon, wo die 'Z'-Taste
        * landesabh�ngig auf der Tastatur angebracht ist.
        *)

PROCEDURE SpecialKey (VAR k: Key): SpecialCode;
  (*
   * Wird 'unspecKey' geliefert, ist die Taste keine der in der Aufz�hlung
   * 'SpecialCode' enthaltenen Tasten (und 'IsSpecial' liefert FALSE).
   *)


PROCEDURE IsSpecial (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste eine Sondertaste ist.
   * Als Sondertasten z�hlen (fast) alle nicht-druckbaren Zeichen, also
   * die Funktionstasten, die Cursortasten, die Buchstabentasten mit
   * Control und Alternate, die Tasten Esc, Help, Home, Return, Enter,
   * Backspace, Tab, Delete, Insert, Undo und die Alternate-Kombinationen
   * mit den Ziffern des Buchstabenblocks, kurz: alle in 'SpecialCode'
   * aufgez�hlten Tasten.
   * Control-M wird beispielsweise von dieser Funktion nicht mit 'Return'
   * verwechselt.
   * Diese Funktion ist nicht die Inversion zu 'IsCharacter' !
   * Es ist auch zu beachten, da� nicht alle undruckbaren Zeichen hiermit
   * erkannt werden, so z.B. nicht Control-Kombinationen mit den Tasten
   * rechts der Buchstabentasten.
   *)

PROCEDURE IsCharacter (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste ein normales Zeichen darstellt,
   * das auch z.B. mit 'Terminal.Read' gelesen werden w�rde.
   * Dazu geh�ren alle druckbaren Zeichen, sowie Control-Zeichen,
   * Esc, Return, Enter, Backspace, Delete und Tab.
   * Alle solche Zeichen enthalten in 'c.ch' den ASCII-Code und
   * k�nnen mit den Funktionen aus 'Characters' weiterverarbeitet
   * werden.
   *)

PROCEDURE IsASCII (VAR k: Key): BOOLEAN;
  (*
   * Genau wie 'IsCharacter'.
   *)


PROCEDURE IsCursor (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste eine Cursor-Taste (Pfeiltasten,
   * auch mit Shift- oder Ctrl) ist.
   *)

PROCEDURE IsAlternate (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste Alternate-A bis Alternate-Z oder
   * Alternate-1 bis Alternate-0 ist.
   *)

PROCEDURE IsFunction (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste eine Funktionstaste ist.
   *)


PROCEDURE OnNumBlock (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste vom Ziffernblock stammt.
   * Damit kann unterschieden werden, ob ASCII-Zeichen auf dem Ziffernblock
   * eingegeben wurden, die weitere Auswertung kann auf das Abfragen der
   * Scan-Codes somit verzichten.
   *)

PROCEDURE OnAlphaBlock (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste vom Buchstabenblock stammt.
   *)

PROCEDURE OnCursorBlock (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste vom Cursor-Block stammt.
   *)

PROCEDURE OnFunctionBlock (VAR k: Key): BOOLEAN;
  (*
   * Liefert TRUE, wenn die Taste vom Funktionstasten-Block stammt.
   *)

END Keyboard.
