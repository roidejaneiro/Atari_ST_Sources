
        Was Sie �ber die Dateien auf dieser Diskette wissen sollten...

Zun�chst  noch  einmal herzlichen Dank f�r die 20 DM.  ( Sie k�nnen stolz  auf 
sich  sein,  denn  so  haben  Sie quasi einen  eigenen  kleinen  Beitrag  dazu 
geleistet, da� sich das Prinzip der Public Domain-Programme weiter durchsetzen 
wird.  )  Doch  nun  zu den Dateien,  die ich Ihnen wie versprochen  auf  Ihre 
Diskette �berspielt habe:
------------------------------------------------------------------------------
NEU: Es gibt mittlerweile eine '89er Version von Ballerburg, die ich Ihnen 
hiermit ebenfalls �berspielt habe (BALLER.PRG...). Der Sourcecode bezieht sich 
auf diese erweiterte Version.  Die Verbesserungen zum Vorg�nger: 
- es gibt keine Probleme mehr mit dem Blitter-TOS oder TOS 1.4 (hoffe ich).  
- man  kann  in  einer Tabelle alle Ergebnisse  von   bis  zu  sechs  Spielern 
  speichern.   
- es gibt Spieloptionen,  wie z.B. Festlegung einer maximalen Rundenzahl, nach 
 der das Spiel beendet wird und der Sieger nach dem Spielstand ermittelt wird. 
------------------------------------------------------------------------------
Ich  habe Ihnen den gesamten Sourcecode von Ballerburg �berspielt.  Er besteht 
aus  den Hauptteilen BALLER1.C und BALLER2.C sowie aus MUSIK.C,  den  Routinen 
zum   Abspielen  der  mit  dem  Musik-Editor  erstellten   Datei   BALLER.MUS. 
Schlie�lich  geh�rt  dazu noch BALLER.H,  die Header-Datei,  die die Namen der 
Objekte der Resource-Datei enth�lt.
Die  Listings sind f�r das Lattice C von Metacomco geschrieben.  Zum  besseren 
Verst�ndnis  des Programmes,  bzw.,  damit Sie das Programm auf Ihren Compiler 
anpassen k�nnen, m�chte ich hier einige Punkte erl�utern:
1.  Im Gegensatz zu den meisten anderen Compilern ist hier der Datentyp int 32 
Bit und der Datentyp short 16 Bit breit.
2.  Ein  mit  dem  Lattice  C  erstelltes Programm hat  die  (  unangenehme  ) 
Eigenschaft,   sich   nach  dem  Laden  fast  den  gesamten  Speicherplatz  zu 
reservieren.  (  Damit  man dann mit speziell implementierten  UNIX  �hnlichen 
Funktionen  die Speicherverwaltung vornehmen kann.  ) Dies hat aber zur Folge, 
da�  es bereits beim Laden von Resource-Dateien oder beim Aufruf  der  Gemdos-
Funktion Malloc zu Schwierigkeiten aufgrund mangelnden Speicherplatzes  kommen 
kann.  Daher  habe  ich  von  der M�glichkeit  Gebrauch  gemacht,  durch  'int 
_mneed=20000;' den automatisch reservierten Speicherplatz zu verkleinern.  Die 
so  reservierten  20K werden teilweise von der  Routine  m_laden()  gebraucht. 
Ansonsten  wird  der  Speicher  wie gewohnt  mit  der  Gemdos-Funktion  Malloc 
reserviert.
3.  Ich habe von einigen Winkelfunktionen Gebrauch gemacht, die nicht in jedem 
C  implementiert  sind.  Sie arbeiten alle mit doppelt genauen  float  Werten. 
atan2(y,x) berechnet den Arcustangens von Y/X.
4.  Bei  Typumwandlungen  habe ich immer auf Korrektheit geachtet,  so da� ich 
auch  bei  Warnungen  ( im Gegensatz zu Fehlern  )  die  entsprechenden  casts 
verwendet habe.
So,  ich hoffe, diese Informationen und die Kommentare in den Listings reichen 
aus,  da�  Sie die interessanten Teile des Programmes verstehen k�nnen und Sie 
so  vielleicht  ein  paar Anregungen f�r Ihre  eigenen  Sch�pfungen  bekommen. 
Sollten Sie im Besitz des Musik-Editors sein und wollen Sie in Ihre  Programme 
Musikst�cke  einbauen,  so  m��ten Sie alle notwendigen Informationen  in  der 
MUSIK.C Datei finden,  die Sie dann einfach nur zu Ihrem Programm dazuzulinken 
haben.

Neben  dem  Sourcecode habe ich Ihnen auch noch  eine  ausf�hrliche  Anleitung 
�berspielt,  die  unter anderem genau auf die Strategien der Computer  eingeht 
und vieles tiefergehend erl�utert, als das die im Spiel 'eingebaute' Anleitung 
kann.  Sollten  Sie  1st  Word  besitzen,  so  steht  Ihnen  neben  der  Datei 
ANLEITNG.TXT, die Sie sich einfach vom Desktop aus anschauen k�nnen, auch noch 
ANLEITNG.DOC  zur  Verf�gung,  von  der Sie sich dann einen  sch�nen  Ausdruck 
anfertigen k�nnen.

Schlie�lich  noch  zu den versprochenen Informationen,  wie man eigene  Burgen 
erstellen kann.  Ich habe Ihnen dazu eine BALLER.DAT Datei �berspielt,  die im 
Gegensatz zu der normalen mit Bemerkungen regelrecht 'vollgestopft' ist.  Wenn 
Sie sich diese zu Gem�te gef�hrt haben,  ist es ein leichtes,  Burgen zun�chst 
auf  dem Millimeterpapier zu entwerfen und anschlie�end mit einem Editor  oder 
Textverarbeitungsprogramm  die  Burgendatei  um  die  n�tigen  Zahlenwerte  zu 
erweitern.

Ich hoffe,  Sie sind nun wunschlos gl�cklich mit all den sch�nen Dateien,  die 
sich   nun  auf  Ihrer  Diskette  befinden.   Sollten  dennoch  einmal  Fragen 
auftauchen, so k�nnen Sie sich an mich wenden.



Sch�ne Gr��e 

  Eckhard Kruse
  Reichenbergweg 7
  D-3302 Cremlingen-Weddel


