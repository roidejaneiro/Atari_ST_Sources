;	Ritar en cirkel med float sinus rutiner

	move.w	#0,-(sp)	; Fixa l�guppl��sning
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#2,-(sp)	; H�mta physic
	trap	#14
	addq.l	#2,sp
	move.l	d0,physic

	move.l	#90,d1		; Ber�kna radien till float
	move	#$e,d0
	trap	#6
	move.l	d0,radie_fl
	move.l	d1,radie_fl+4

	move.l	#0,vinkel	; B�rja p� noll vinkel

loopa	move.l	vinkel,d1	; Konva ett tal till float (vinkel att kalka)
	move	#$e,d0
	trap	#6

	move.l	rad_tal,d3	; G�r om grader till radianer
	move.l	rad_tal+4,d4
	move.l	d1,d2
	move.l	d0,d1
	move.w	#3,d0
	trap	#6
	move.l	d0,vinkel_grad
	move.l	d1,vinkel_grad+4

	bsr	visa_fl			; Visa vinkeln som radianer

	move.l	vinkel_grad+4,d2	; Calka sinus
	move.l	vinkel_grad,d1
	move.w	#4,d0
	trap	#6

	move.l	d1,d2		; Multiplicera me radien
	move.l	d0,d1
	move.l	radie_fl,d3
	move.l	radie_fl+4,d4
	move.w	#2,d0
	trap	#6

	move.l	d1,d2		; G�r om till integer
	move.l	d0,d1
	move.w	#$D,d0
	trap	#6

	add.l	#100,d0
	move.w	d0,y		; Y v�rde

	move.l	vinkel_grad,d1		; Calka cosinus
	move.l	vinkel_grad+4,d2
	move.w	#5,d0
	trap	#6

	move.l	d1,d2		; Multiplicera me radien
	move.l	d0,d1
	move.l	radie_fl,d3
	move.l	radie_fl+4,d4
	move.w	#2,d0
	trap	#6

	move.l	d1,d2		; G�r om till integer
	move.l	d0,d1
	move.w	#$D,d0
	trap	#6

	add.l	#160,d0
	move.w	d0,x		; X v�rde

	move.w	x,d0		; S�tt ut en prick p� X,Y
	move.w	y,d1
	move.w	#3,d2
	move.l	physic,a0
	bsr	prick

	add.l	#1,vinkel
	cmp.l	#361,vinkel	; K�r alla 360 grader
	blt	loopa
	
	move.w	#7,-(sp)	; V�nta p� knapp
	trap	#1
	addq.l	#2,sp

	clr.w	-(sp)		; Hejd�
	trap	#1

visa_fl	move.l	d1,d2		; Rutin f�r att visa float tal i d0-d1
	move.l	d0,d1
	move.w	#$c,d0
	move.w	#30,d3
	move.l	#buf,a0
	trap	#6

	move.l	#buf1,-(sp)	; Visa str�ng
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

prick	mulu	#$a0,d1		; S�tter ut en prick d0,d1 med f�rg d2
	move.w	d0,d3		; Adress i a0
	lsr.w	#1,d3 
	and.w	#-8,d3
	add.w	d3,d1 
	adda.w	d1,a0 
	and.w	#$f,d0
	neg.w	d0
	add.w	#$f,d0
	moveq	#3,d3 
n�sta_bitplan
	move.w	(a0),d1 
	lsr.w	#1,d2 
	bcs.s	nolla 
	bclr	d0,d1 
	bra.s	�ndra_bitplan
nolla	bset	d0,d1 
�ndra_bitplan
	move.w	d1,(a0)+
	dbf	d3,n�sta_bitplan
	
	rts

; Visa ett tal i d0 som hex (.l)

showhex	move.l	#hextext+9,a0
	move.w	#7,d2		; 8 tecken
nexthex	move.l	d0,d1		; kom ih�g d0
	and.l	#%1111,d0	; Bara de 4 l�gsta bitarna

	add.b	#48,d0		; �ka till siffrorna

	cmp.b	#58,d0		; �r det en siffra?
	blt	decimal_hex	; Ja

	add.b	#39,d0		; L�gg till lite till s� det blir abcdef

decimal_hex
	move.b	d0,-(a0)	; L�gg in tecknet

	move.l	d1,d0		; �terst�ll d0
	ror.l	#4,d0		; Rulla bitarna 4 steg h�ger
	dbra	d2,nexthex	; L�gg in alla 8 tecken

	move.l	#hextext,-(sp)	; Visa str�ngen
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	rts

hextext dc.b	'$        ',10,13,0

x	dc.w	0
y	dc.w	0
vinkel	dc.l	0
physic	dc.l	0
vinkel_grad 	ds.l	2
rad_tal		dc.l	$e52ee046,$12345678
radie_fl 	ds.l	2

buf1	dc.b	27,'b',3,27,'H'
buf	ds.b	100
