; ------------
; EFFACE ECRAN
; ------------

 move.l 4(sp),a0
 lea clear, a1
 movem.l (a1)+,d0-d7/a2-a6
loop:
;---- 1 ----
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 64(a0),a0
;---- 2 ----
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 64(a0),a0
;---- 3 ----
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 64(a0),a0
;---- 4 ----
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 64(a0),a0
;---- 5 ----
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 64(a0),a0
;---- 6 ----
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 48(a0),a0
 movem.l d1-d7/a2-a6,(a0)
 lea 64(a0),a0

 dbf d0,loop
 rts

clear:
 dc.l 25,0,0,0,0,0,0,0,0,0,0,0,0
 end

 