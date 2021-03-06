* "Hereinfallen" eines Bildes
* Aufruf: fallin(quelle,ziel);

.text
.xdef _fallin
_fallin:        movem.l d0-d7/a0-a6,-(a7) *Register retten
                movea.l 64(a7),a0         *Quelle
                movea.l 68(a7),a1         *Ziel
                move.w  #$7d00,d3         *Offset f�r letzte Zeile

fli_j1:         move.w  #1,d1           *Z�hler f�r Abstand
                move.w  d3,d2           *Offset f�r letzte Zeile
                lea     (a0,d3),a3      *Quelladresse
                lea     (a1,d3),a4      *Zieladresse

fli_j2:         move.w  d1,d5           *Z�hler f�r zu kopierende Zeilen

fli_jb2:        move.w  #39,d4          *Z�hler f�r 39 Langworte

fli_j3:         move.l  -(a3),-(a4)     *Kopieren
                dbra    d4,fli_j3       *Schleife

                cmpa.l  a4,a1           *Alles kopiert ?
                beq.s   fli_neg         *Ja --> Weiter

                subq.w  #1,d5           *Zeilenz�hler erniedrigen
                beq.s   fli_j4          *Wenn alle gel�scht --> weiter

                add.l   #160,a3         *Quelle auf alte Zeile
                bra.s   fli_jb2         *Nochmals kopieren

fli_j4:         addq.w  #1,d1

                bra.s   fli_j2          *N�chste Zeile zeichnen

fli_neg:        movem.l d0-d3/a0-a2,-(a7) *Register retten
                move.w  #37,-(a7)         *Vsync-Funktion
                trap    #14               *XBIOS-Aufruf
                addq.l  #2,a7             *Stapelzeiger zur�ckbiegen
                movem.l (a7)+,d0-d3/a0-a2 *Register holen

                sub.w   #160,d3         *Quelloffset erniedrigen
                bne     fli_j1          *Zur�ck in Hauptschleife

fli_j6:         movem.l (a7)+,d0-d7/a0-a6
                rts
