
               TEXT

               INCLUDE       "LINEQU.L"
               INCLUDE       "INIT_TOS.L"
               INCLUDE       "MACROS.L"

               SETBLOCK

               DC.W          $A000
               movea.l       a0,a5

               move.l        #CONTROL,ticontrol(a0)
               move.l        #INTIN,tiintin(a0)
               move.l        #PTSIN,tiptsin(a0)
               move.l        #INTOUT,tiintout(a0)
               move.l        #PTSOUT,tiptsout(a0)

               PRINTLINE     UN
               WAIT
               DC.W          $A00A
               CCONOUT       #27
               CCONOUT       #'E'


               move          #0,_fg_bp_1(a5)
               move          #1,_fg_bp_2(a5)

               move          #0,_wrt_mode(a5)


               move          #1,_patmsk(a5)
               move.l        #PAT,_patptr(a5)
               move          #4,sptsin
               move          #0,_clip(a5)
               jsr           TRACER

               
               WAIT
               PRINTLINE     DEUX
               WAIT
               CCONOUT       #27
               CCONOUT       #'E'

               move          #1,_clip(a5)


               move          #0,_xmn_clip(a5)
               move          #0,_ymn_clip(a5)
               move          #320,_xmx_clip(a5)
               move          #190,_ymx_clip(a5)
               jsr           TRACER

               WAIT
               TERM


TRACER         move          #320,ptsin
               move          #10,ptsin+2
               move          #570,ptsin+4
               move          #100,ptsin+6
               move          #320,ptsin+8
               move          #190,ptsin+10
               move          #70,ptsin+12
               move          #100,ptsin+14
               move          #320,ptsin+16
               move          #10,ptsin+18

               move          #9,d6

BOUCLE         add           #1,d6
               move          d6,_y1(a5)
               DC.W          $A006
               cmpi          #190,d6
               bne           BOUCLE

               rts


               DATA

PAT            DC.W          %1111111111111110
               DC.W          %0000000000000000



UN             DC.B          27,'E','Je trace un POLYGONE avec $A006 :',0
DEUX           DC.B          27,'E','Je trace le m�me POLYGONE en utilisant '
               DC.B          'le CLIPPING',0

               BSS

               INCLUDE       "TABLEAU.L"

               END


 