	opt	d+
	lea	stars,a0

	move.w	#300,d0
	move.w	#120,d1
	move.w	#3250,d2
	move.w	#50-1,d7
re
	move.w	#128,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	sub.w	#25,d2
	move.w	d2,(a0)+
	dbf	d7,re	

	move.w	#300,d0
	move.w	#120,d1
	move.w	#2000,d2
	move.w	#30-1,d7
	move.w	#0,d3
re5
	move.w	#128,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	sub.w	#35,d2
	dbf	d7,re5	

	move.w	#-128,ANGLEZ
calkul0	
	move.w	#21-1,d7
.re
	movem.l	d0-a6,-(sp)
	
	sub.w	#12,ANGLEZ
	and.w	#$1ff,ANGLEZ

	move.w	#0,X1
	move.w	#0,Y1
	move.w	#200,Z1
	bsr	CALCUL
	move.w	d0,X1
	move.w	d1,Y1
	move.w	d2,Z1
	movem.l	(sp)+,d0-a6

	move.w	#128,(a0)
	move.w	ANGLEZ,d2
	add.w	#128,d2
	add.w	d2,(a0)+

	move	#0,(a0)+
	
	move.w	#0,(a0)+

;	neg.w	(a0)+

	move.w	X1,(a0)
	add.w	#300,(a0)+		
	move.w	Y1,(a0)
	add.w	#120-200,(a0)+		
	move.w	Z1,(a0)
	add.w	#985,(a0)+		

	dbf	d7,.re

	move.w	#300,d0
	move.w	#120-400,d1
	move.w	#985,d2
	move.w	#60-1,d7
re2
	move.w	#384,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	d0,(a0)+
	move.w	d1,(a0)+
	add.w	#35,d2
	move.w	d2,(a0)+
	dbf	d7,re2	

	nop
	move.w	#0,-(sp)
	pea	fname
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,-(sp)


	pea	stars
	move.l	#count,-(sp)
	move.w	d0,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	(sp)+,d0
	move.w	d0,-(sp)	
	move.w	#$3C,-(sp)
	trap	#1
	addq.l	#4,sp

	move.w	#0,-(sp)
	trap	#1
		

jug	dc.w	0

X1	dc.w	0
Y1	DC.W	0
Z1	DC.W	0
ANGLEX	DC.W	0                                             
ANGLEY	DC.W	0
ANGLEZ	DC.W	0
SINX	DC.W	0
COSX	DC.W	0
SINY	DC.W	0
COSY	DC.W	0
SINZ	DC.W	0
COSZ	DC.W	0
CALCUL	
	MOVEM.W	X1,D0-D5	
	ADD.W	D3,D3
	ADD.W	D4,D4
	ADD.W	D5,D5
	LEA	SINUS,A0
	LEA	SINX(PC),A1
	LEA	SINY(PC),A3
	LEA	SINZ(PC),A4
	MOVE.W	(A0,D3.W),(A1)
	MOVE.W	(A0,D4.W),$4(A1)
	MOVE.W	(A0,D5.W),$8(A1)
	LEA	COSINUS,A0
	LEA	COSX(PC),A2
	MOVE.W	(A0,D3.W),(A2)
	MOVE.W	(A0,D4.W),$4(A2)
	MOVE.W	(A0,D5.W),$8(A2)

	MOVEM.W	(A1),D3-D4	
       	MULS	D0,D4		
	NEG	D3	
	MULS	D1,D3
	ADD.L	D3,D4
	ADD.L	D4,D4
	SWAP	D4		* cos a*x-sin a*y= X=d4
	MOVEM.W	(A1),D5-D6	
       	MULS	D0,D5
	MULS	D1,D6
	ADD.L	D6,D5
	ADD.L	D5,D5
	SWAP	D5		* sin a*x+cos a*y= Y=d5

	MOVEM.W	(A3),D0-D1	* z= Z=d2
	MULS	D4,D1
	MULS	D2,D0
	ADD.L	D1,D0
	ADD.L	D0,D0
	SWAP	D0
	MOVEM.W	(A3),D6-D7	* cos b*X+sin b*Z=X' =d0 
	NEG	D6		
	MULS	D4,D6		
	MULS	D2,D7		
	ADD.L	D6,D7		
	ADD.L	D7,D7		
	SWAP 	D7		

	MOVEM.W	(A4),D1-D2	* cos b*Z-sin b*X=Z' =d7  
	MULS	D5,D2 		* Y= Y'=D5
	NEG	D1
	MULS	D7,D1
	ADD.L	D2,D1
	ADD.L	D1,D1
	SWAP 	D1		* cos c*Y'-sin c*Z'= YY''=D1
**********
	MOVEM.W	(A4),D2-D3	
	MULS	D5,D2 		
	MULS	D7,D3
	ADD.L	D3,D2
	ADD.L	D2,D2		 
	SWAP 	D2		*	XX''=D0    ZZ''=D2
**********	
	RTS	
*********************************
																																
SINUS		incbin	f:\PURE_C\new_sin.tab
		EVEN
COSINUS		EQU	SINUS+256

fname		dc.b	'd:\battle04.dat',0
	even


stars	ds.w	150*6
srat
count	equ	srat-stars
