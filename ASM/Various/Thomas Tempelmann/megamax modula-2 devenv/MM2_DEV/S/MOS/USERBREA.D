DEFINITION MODULE UserBreak;

(*
   Dies Modul dient dazu, Programme durch Dr�cken von Ctrl-C oder
   Ctrl-Enter abzubrechen.
   
   Zur Aktivierung dieser Option mu� die exportierte Prozedur
   'EnableBreak', zur Deaktivierung 'DisableBreak' aufgerufen
   werden. 'EnableBreak' liefert TRUE, wenn die Aktivierung wie
   gew�nscht erfolgte.
   
   Ctrl-C wird erst erkannt, wenn AES-Events (Keyboard, Button
   oder Timer) abgefragt werden, also z.B. bei Benutung der
   Funktionen aus Textwindows oder einem MultiEvent-Aufruf.
   Dann erscheint wie bei einem Laufzeitfehler eine Meldung
   und das Programm kann abgebrochen oder fortgef�hrt werden.
   
   Ctrl-Enter ist gegen�ber Ctrl-C mit Vorsicht zu benutzen.
   Diese Funktion reagiert sofort. Dies kann u.U. dazu f�hren,
   da� sich das System danach fehlerhaft verh�lt.
   Dies passiert dann, wenn Ctrl-Enter zu einem Zeitpunkt
   gedr�ckt wird, in dem Betriebssystemfunktionen ausgef�hrt
   werden. Deshalb sollte zuerst immer Ctrl-C probiert werden
   und nur, wenn es unbedingt notwendig ist, Ctrl-Enter verwendet
   werden.
   
   Sollte sich das Programm allerdings in einer Endlosschleife
   befinden, die nur aus Modula-Funktionen besteht, oder das
   Programm gerade eine zeitaufwendige Berechnung durchf�hren,
   kann in der Regel Ctrl-Enter ohne Gefahr benutzt werden.
   
   �brigens ist das Modul ausschlie�lich in MODULA programmiert.
*)


PROCEDURE EnableBreak () :BOOLEAN;
   (*
    *  Nach Aufruf dieser Routine ist es m�glich, das laufende
    *  Programm zu unterbrechen.
    *)

PROCEDURE DisableBreak;
   (*
    *  Hiernach kann das Programm nicht mehr mit Ctrl-C bzw.
    *  Ctrl-Enter abgebrochen werden. Dies ist auch der
    *  Anfangszustand.
    *)

VAR Break: BOOLEAN;
   (*
    * Wird TRUE, sobald Ctrl-C gedr�ckt wurde.
    *
    * Sobald daraufhin ein Event-Aufruf (z.B. EventMulti) oder eine
    * Ausgabe �ber TextWindows erfolgt, wird das Programm automatisch
    * terminiert.
    * Programme k�nnen diese Variable auch selbst abfragen und dann ggf.
    * zur�ck auf FALSE setzen.
    *)

END UserBreak.
