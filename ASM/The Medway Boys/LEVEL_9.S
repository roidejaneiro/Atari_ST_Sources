	opt	o+,ow-,a+		; Optimierung einschalten
start:	movea.l	#stackend,sp
	move.l	sp,d0
	subi.l	#start-$120,d0
	move.l	d0,-(sp)
	pea	start-$100(pc)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	adda.w	#$c,sp
	move.w #1,-(sp)
	pea -1
	pea -1
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	pea text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp
	move.w #7,-(sp)
	trap #1
	addq.l #2,sp

	bsr.s	super
	move.l	$84.w,old_trap1+2	;store & change TRAP #1 vector
	move.l	$84.w,$bc.w		;my trap #15
	move.l	#my_trap1,$84.w
	bsr.s	user
	pea	null(pc)
	pea	null(pc)
	pea	file_name(pc)
	move.w	#0,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea.l	16(sp),sp
	bsr.s	super
	move.l	old_trap1+2(pc),$84.w
	bsr.s	user
	clr.w	-(sp)
	trap	#1

null:	dc.l 0,0

file_name:	dc.b 'level_9.exe',0	; nachgeladenes Programm (pexec)
	EVEN 


super:	clr.l	-(sp)		;supervisor state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,d7
	rts	
user:	move.l	d7,-(sp)		;user state
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts	
my_trap1: 
	movea.l	sp,a0
	btst	#$d-8,(sp)
	bne.s	supervisor
	move.l	usp,a0
	subq.l	#6,a0
supervisor:	
	addq.l	#6,a0
	cmpi.w	#$3f,(a0) 	; read
	beq.s	func_3f
old_trap1:	
	jmp	0.l

func_3f:	
	move.l	8(a0),puffer
	lea 12(a0),a0
	moveq #5,d0
clog	move.w -(a0),-(a7)
	dbf d0,clog
	trap #15
	lea 12(a7),a7
	tst.l d0
	bmi ret_addr5
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	puffer(pc),a0	; Puffer
	bsr.s	decrunch
	movem.l	(sp)+,d1-d7/a0-a6
ret_addr5:	
	rte

decrunch
	move.w $ffff8240.w,-(sp)
	link	a3,#-120
	movem.l	d0-a6,-(sp)
	lea	120(a0),a4	; a4 = Anfang entpackte Daten
	move.l	a4,a6		; a6 = Ende entpackte Daten
	bsr.s	.getinfo
	cmpi.l	#'ICE!',d0	; Kennung gefunden?
	bne	.not_packed
	bsr.s	.getinfo		; gepackte L�nge holen
	lea.l	-8(a0,d0.l),a5	; a5 = Ende der gepackten Daten
	bsr.s	.getinfo		; ungepackte L�nge holen (original)
	move.l	d0,(sp)		; Originall�nge: sp�ter nach d0
	adda.l	d0,a6		; a6 = Ende entpackte Daten
	move.l	a6,a1

	moveq	#119,d0		; 120 Bytes hinter entpackten Daten
.save:	move.b	-(a1),-(a3)	; in sicheren Bereich sichern
	dbf	d0,.save
	move.l	a6,a3		; merken f�r Picture decrunch
	move.b	-(a5),d7		; erstes Informationsbyte
	bsr.s	.normal_bytes
	move.l	a3,a5		; f�r 120 Bytes restore

.no_picture
	movem.l	(sp),d0-a3	; hole n�tige Register

.move	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	.move
	moveq	#119,d0		; um �berschriebenen Bereich
.rest	move.b	-(a3),-(a5)	; wieder herzustellen
	dbf	d0,.rest
.not_packed:
	movem.l	(sp)+,d0-a6
	unlk	a3
	move.w (sp)+,$ffff8240.w
	rts

.getinfo: moveq	#3,d1		; ein Langwort vom Anfang
.getbytes: lsl.l	#8,d0		; der Daten lesen
	move.b	(a0)+,d0
	dbf	d1,.getbytes
	rts

.normal_bytes:	
	bsr.s	.get_1_bit
	bcc.s	.test_if_end	; Bit %0: keine Daten
	moveq.l	#0,d1		; falls zu copy_direkt
	bsr.s	.get_1_bit
	bcc.s	.copy_direkt	; Bitfolge: %10: 1 Byte direkt kop.
	lea.l	.direkt_tab+20(pc),a1
	moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0		; d0.w Bytes lesen
	bsr.s	.get_d0_bits
	swap.w	d0
	cmp.w	d0,d1		; alle gelesenen Bits gesetzt?
	dbne	d3,.nextgb	; ja: dann weiter Bits lesen
.no_more: add.l	20(a1),d1 	; Anzahl der zu �bertragenen Bytes
.copy_direkt:	
	move.b	-(a5),-(a6)	; Daten direkt kopieren
	move.w a6,$ffff8240.w
	dbf	d1,.copy_direkt	; noch ein Byte
.test_if_end:	
	cmpa.l	a4,a6		; Fertig?
	bgt.s	.strings		; Weiter wenn Ende nicht erreicht
	rts	

;************************** Unterroutinen: wegen Optimierung nicht am Schlu�

.get_1_bit:
	add.b	d7,d7		; hole ein bit
	bne.s	.bitfound 	; quellfeld leer
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.bitfound:
	rts	

.get_d0_bits:	
	moveq.l	#0,d1		; ergebnisfeld vorbereiten
.hole_bit_loop:	
	add.b	d7,d7		; hole ein bit
	bne.s	.on_d0		; in d7 steht noch Information
	move.b	-(a5),d7		; hole Informationsbyte
	addx.b	d7,d7
.on_d0:	addx.w	d1,d1		; und �bernimm es
	dbf	d0,.hole_bit_loop	; bis alle Bits geholt wurden
	rts	

;************************************ Ende der Unterroutinen


.strings: lea.l	.length_tab(pc),a1	; a1 = Zeiger auf Tabelle
	moveq.l	#3,d2		; d2 = Zeiger in Tabelle
.get_length_bit:	
	bsr.s	.get_1_bit
	dbcc	d2,.get_length_bit	; n�chstes Bit holen
.no_length_bit:	
	moveq.l	#0,d4		; d4 = �berschu�-L�nge
	moveq.l	#0,d1
	move.b	1(a1,d2.w),d0	; d2: zw. -1 und 3; d3+1: Bits lesen
	ext.w	d0		; als Wort behandeln
	bmi.s	.no_�ber		; kein �berschu� n�tig
.get_�ber:
	bsr.s	.get_d0_bits
.no_�ber:	move.b	6(a1,d2.w),d4	; Standard-L�nge zu �berschu� add.
	add.w	d1,d4		; d4 = String-L�nge-2
	beq.s	.get_offset_2	; L�nge = 2: Spezielle Offset-Routine


	lea.l	.more_offset(pc),a1 ; a1 = Zeiger auf Tabelle
	moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
	dbcc	d2,.getoffs
	moveq.l	#0,d1		; Offset-�berschu�
	move.b	1(a1,d2.w),d0	; request d0 Bits
	ext.w	d0		; als Wort
	bsr.s	.get_d0_bits
	add.w	d2,d2		; ab jetzt: Pointer auf Worte
	add.w	6(a1,d2.w),d1	; Standard-Offset zu �berschu� add.
	bpl.s	.depack_bytes	; keine gleiche Bytes: String kop.
	sub.w	d4,d1		; gleiche Bytes
	bra.s	.depack_bytes


.get_offset_2:	
	moveq.l	#0,d1		; �berschu�-Offset auf 0 setzen
	moveq.l	#5,d0		; standard: 6 Bits holen
	moveq.l	#-1,d2		; Standard-Offset auf -1
	bsr.s	.get_1_bit
	bcc.s	.less_40		; Bit = %0
	moveq.l	#8,d0		; quenty fourty: 9 Bits holen
	moveq.l	#$3f,d2		; Standard-Offset: $3f
.less_40: bsr.s	.get_d0_bits
	add.w	d2,d1		; Standard-Offset + �ber-Offset

.depack_bytes:			; d1 = Offset, d4 = Anzahl Bytes
	lea.l	2(a6,d4.w),a1	; Hier stehen die Originaldaten
	adda.w	d1,a1		; Dazu der Offset
	move.b	-(a1),-(a6)	; ein Byte auf jeden Fall kopieren
.dep_b:	move.b	-(a1),-(a6)	; mehr Bytes kopieren
	dbf	d4,.dep_b 	; und noch ein Mal
	bra	.normal_bytes	; Jetzt kommen wieder normale Bytes


.direkt_tab:
	dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001	; Anzahl 1-Bits
	dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1	; Anz. Bytes

.length_tab:
	dc.b 9,1,0,-1,-1		; Bits lesen
	dc.b 8,4,2,1,0		; Standard-L�nge - 2 (!!!)

.more_offset:
	dc.b	  11,   4,   7,  0	; Bits lesen
	dc.w	$11f,  -1, $1f	; Standard Offset

puffer:		ds.l 1
		ds.b 500
stackend: 	ds.b 20

text		dc.b 27,'f',27,'E'
		dc.b "                            The Medway Boys Present",10,10,10,13
		dc.b "                               Level 9 Adventures",10,10,13
		dc.b "                               Colossal Adventure",10,13
		dc.b "                               Dungeon Adventure",10,13
		dc.b "                               Adventure Quest",10,13
		dc.b "                               Snowball",10,13
		dc.b "                               Return to Eden",10,13
		dc.b "                               Worm in Paradise",10,10,10,13
		dc.b "                     All games Cracked and Packed by ZIPPY",10,10,13
		dc.b "                         All games supplied by Ruthless",10,10,10,13
		dc.b "I don't think anyone has ever cracked these games before.... probably because",10,13
		dc.b "they're written in Level 9's own interpreted adventure language 'A Code', and",10,13
		dc.b "believe me, this makes them very awkward to trace !!!!",10,13
		dc.b "When you try to restore a saved game you will be asked to enter a word from the",10,13
		dc.b "manual, just type anything and press return.",10,10,13
		dc.b "Watch out for Lancelot, Gnome Ranger and Ingrid's Back...... Coming soon !!",0
	even
		dc.w 0

