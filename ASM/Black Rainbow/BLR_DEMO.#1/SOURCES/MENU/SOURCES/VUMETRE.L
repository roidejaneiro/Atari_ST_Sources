; --------------------------------------------------
;
; VU-METRE SUR LES 3 VOIES SONORES (C) FANTOMAS 1990
;
; --------------------------------------------------

 move.l 4(sp),a0       ; Adresse de l'ecran dans a0

 lea (a0),a3
 moveq #15,d0
efface:
 clr.w (a3)
 clr.w 8(a3)
 clr.w 16(a3)
 lea -320(a3),a3
 dbra d0,efface

 lea $ff8800,a1
 move.b #8,(a1)
 moveq #0,d0
 bsr.s vumetre
 move.b #9,(a1)
 moveq #8,d0
 bsr.s vumetre
 move.b #10,(a1)
 moveq #16,d0
 bsr.s vumetre
 rts

vumetre:
 lea (a0),a3                       ; Adresse de l'ecran dans a3
 add.w d0,a3                       ; adresse ecran+d0
 move.b (a1),d0                    ; volume de la voie dans d0
loop:
 move.w #%0011111111111111,(a3)
 lea -320(a3),a3
 dbra d0,loop
fini:
 rts

 end

 