
;Programme illustrant l'utilisation des fonctions du VDI (TEXT et CIRCLE)

               TEXT

               INCLUDE       "INIT_GEM.L"   ;initialise le VDI et l'AES
               INCLUDE       "INIT_TOS.L"
               INCLUDE       "MACROS.L"

               SETBLOCK      ;initialise GEM


               PRINTLINE     MESSAGE         ;texte
               WAIT                          ;attente d'une touche
               CCONOUT       #27
               CCONOUT       #'E'            ;on efface l'�cran

               move          #23,opcode      ;STYLE INTERIOR
               move          #0,sptsin
               move          #1,sintin
               move          grhandle,handle
               move          #2,intin        ;motifs pr��tablis (1-24)
               VDI

               move          #24,opcode      ;SET FILL STYLE
               move          #0,sptsin
               move          #1,sintin
               move          grhandle,handle
               move          #9,intin        ;motif nr�9 style 2
               VDI

               move          #25,opcode      ;FILL COLOR
               move          #0,sptsin
               move          #1,sintin
               move          grhandle,handle
               move          #10,intin
               VDI

               move          #11,opcode      ;CIRCLE
               move          #3,sptsin
               move          #0,sintin
               move          #4,idsfct
               move          grhandle,handle
               move          #320,ptsin      ;x
               move          #100,ptsin+2    ;y
               move          #0,ptsin+4
               move          #0,ptsin+6
               move          #150,ptsin+8    ;R
               move          #0,ptsin+10
               VDI



               move          #22,opcode       ;TEXT COLOR
               move          #0,sptsin
               move          #1,sintin
               move          grhandle,handle
               move          #2,intin         ;couleur 2
               VDI

               move          #32,opcode       ;WRITE MODE
               move          #0,sptsin
               move          #1,sintin
               move          grhandle,handle
               move          #1,intin         ;MODE and
               VDI


               move          #106,opcode      ;TEXT EFFECTS
               move          #0,sptsin
               move          #1,sintin
               move          grhandle,handle
               move          #%100,intin      ;italique
               VDI

               move          #8,opcode        ;TEXT
               move          #1,sptsin
               move          #22,sintin
               move          grhandle,handle

               lea           TABLE,a0   ;a0 pointe sur le texte
               lea           intin,a1   ;a1 sur le tableau INTIN

               move          #22,d0     ;compteur de boucle

;ici on d�pose les donn�es du texte dans INTIN

BOUCLE         move.b        (a0)+,d1   ;lire l'octet point� par (a0)+
               ext.W         d1         ;l'�tendre � un MOT
               move.W        d1,(a1)+   ;le pose dans INTIN (incr�mente)
               dbf           d0,boucle  ;pour tous les 22 caract�res...


;et l� on affiche le texte (seule la coordonn�e x varie dans la boucle!)

               move          #640,d5     ;compteur de boucle

               move          #10,ptsin+2 ;coordonn�e y=10

MODIF          move          d5,ptsin    ;fait varier coordonn�e x
               VDI                       ;on appelle la fonction TEXT
               dbf           d5,MODIF    ;on d�cr�mente x de d5



               WAIT
               TERM       ;on quitte le prg  (avec des types de caract�res
                          ;'italique' car ils sont toujours selectionn�s!)



               DATA


TABLE          DC.B          'TEXT et CIRCLE du VDI ',0

MESSAGE        DC.B          27,'E','Voil� un exemple d',39,'utilisation des'
               DC.B          ' fonctions du VDI',13,10,13,10,'Le bureau GEM '
               DC.B          'aurra des caract�res en ITALIQUE au retour'
               DC.B          '...',7,0


               INCLUDE       "TABLEAU.L"    ;le tableau du VDI


               END


 