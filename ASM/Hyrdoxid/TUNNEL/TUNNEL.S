
 	LEA.L 	PILE,SP
	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
	CLR.B	$484.W
	MOVE.B	#18,$FFFFC02
	move.l	$70.w,OLD_VBL
	move.l	#NEW_VBL,$70.w
	move.b	$ffffa09,OLD_A09
	BSR	INITS
	BSR	CLS
	BSR	CLR_REGISTERS
	move.l	#$ff,$ffff9800
	bsr	vbl
	bsr	vbl
LOOP
	CLR.L	$FFFF9800
	bsr	CALC_PTS
	BSR	SYNCHRO
	CMPI.B	#56,$FFFFC02
	BNE.S	NO_ALT
	MOVE.L	#$FF,$FFFF9800
NO_ALT
	BSR	VBL
	CMPI.B	#57,$FFFFC02
	BNE	LOOP
	BRA	SORTIE
***************************INITIALISATIONS*********************************************************
INITS
	MOVEC	CACR,D0			
	MOVE.L	D0,OLD_CACR
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR

	MOVE.W	#2,-(SP)
	TRAP	#14
	ADDQ.L	#2,SP
	MOVE.L	D0,OLDXBIOS2
	
	MOVE.W	#-1,-(SP)		
	MOVE.W	#88,-(SP)		
	TRAP	#14			
	ADDQ.L	#4,SP			
	MOVE.W	D0,OLDMODECODE	

	move.l	$44E.W,OLDXBIOS2
	
	MOVE.L	#XBIOS2,D0
	ANDI.L	#$FFFFFFFF-2,D0
	MOVE.L	D0,AFFECR

	MOVE.L	#XBIOS3,D0
	ANDI.L	#$FFFFFFFF-2,D0
	MOVE.L	D0,WORKECR
	BSR	TRUE_COLOR
	BSR	SYNCHRO
	RTS
SYNCHRO
	MOVE.L	AFFECR,A1
	MOVE.L	WORKECR,A2
	MOVE.L	A2,AFFECR
	MOVE.L	A1,WORKECR
	move.b 	affecr+1,$ffff8201.w
	move.b 	affecr+2,$ffff8203.w
	move.b 	affecr+3,$ffff820d.w
	RTS
TRUE_COLOR:
	CLR.B	$FFFF8260.W
	MOVE	#384,$FFFF8210.W	;TAILLE EN MOT
	MOVE	#256,$FFFF8266.W	;256=TC
	MOVE	#254,$FFFF8282.W	;NBRE DE DEMI-LINES
	MOVE	#203,$FFFF8284.W	;FIN LIGNE HORIZONTALE
	MOVE	#39,$FFFF8286.W	;DEBUT LIGNE HORIZONTALE
	MOVE	#14,$FFFF8288.W	;FULL GAUCHE	
	MOVE	#175,$FFFF828A.W	;FULL DROIT
	MOVE	#216,$FFFF828C.W	;SYNCHRO HORIZONTAL
	MOVE	#625,$FFFF82A2.W	;NBRE DE CHAMPS
	MOVE	#613,$FFFF82A4.W	;FIN SCREEN
	MOVE	#47,$FFFF82A6.W	;DEBUT ECRAN
	MOVE	#87,$FFFF82A8.W	;FULL HAUT
	MOVE	#567,$FFFF82AA.W	;FULL BAS
	MOVE	#619,$FFFF82AC.W	;SYNCHRO VERTICAL
	MOVE	#385,$FFFF82C0.W	;????
	CLR	$FFFF82C2.W	;PIXEL OPTIONS
	RTS
*******************************SOUS ROUTINES*****************************************
CALC_PTS
	move.l	WORKECR,a0
	lea	COORD,a2
	lea	Y_TABLE,a1
	move	#44,d4
	move	#$3111,d7
	movec	d7,CACR
LOOP_PTS
	move	#350,8(a2)
	move	#512,d3
	sub	8(a2),d3	;512-2*ZE=Q*512
;-----------------------------
;2)calcul de X=XE/Q
;Q=D3    XE=D1  X=D1
;-----------------------------
	move.l	(a2),d1
	divs	d3,d1	;XE*512/Q*512=X
	add	#192,d1	;CENTRE LES X
;-----------------------------
;3)calcul des Y=YE/Q
;Y=D2
;-----------------------------
	move.l	4(a2),d2
	divs	d3,d2
	add	#120,d2
;affiche le pt
	andi.l	#$ffff,d1
	asl	d1
	add.l	(a1,d2.w*4),d1
	move	#-1,(a0,d1.l)	
	lea	10(a2),a2
	dbf	d4,LOOP_PTS
	move	#$2510,d7
	movec	d7,CACR
	rts
NEW_VBL
	addq	#1,$466.w
	rte
EFFA2
	MOVE.L	WORKECR,A0		
*	MOVE.W	#points/30,D1
	MOVEQ.W	#0,D4
*	MOVE.L	SAVE1,A1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
EFF2
	REPT	30
	MOVE.L	(A1)+,D3
	MOVE.W	D4,(A0,D3.L)
	ENDR
	DBF	D1,EFF2
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	RTS
VBL:
	MOVE.L	D0,-(SP)
	move.l	$466.w,d0		
VSYNC:	cmp.l	$466.w,d0
	BEQ.S	VSYNC
	MOVE.L	(SP)+,D0
	RTS
CLS
	MOVEM.L	D0/A0-a1,-(SP)
	MOVE.L	AFFECR,A0
	move.l 	workecr,a1
	MOVEQ.L	#0,D1
	MOVE.L	#$3111,D0		;active cache
	MOVEC.L	D0,CACR
	MOVE.W	#60000,D0
OK
	MOVE.L	D1,(A0)+
	MOVE.L	D1,(A1)+
	DBF	D0,OK
	MOVE.L	#$2510,D0		;coupe cache
	MOVEC.L	D0,CACR
	MOVEM.L	(SP)+,D0/A0-a1
	RTS

CLR_REGISTERS
	movem.l	clr,d0-d6/a0-a6
	rts
SORTIE
	MOVE.L	OLD_CACR,D0
	MOVEC.L	D0,CACR
	move.b	OLD_A09,$ffffa09
	move.l	OLD_VBL,$70.w
	MOVE.B	#15,$484.W
	MOVE.B	#8,$FFFFC02
	MOVE.W	OLDMODECODE,-(SP)
	MOVE.W	#3,-(SP)	
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.L	OLDXBIOS2,-(SP)
	MOVE.W	#5,-(SP)
	TRAP	#14
	LEA	14(SP),SP		
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#2,SP
	CLR.W	-(SP)
	TRAP	#1

	SECTION DATA
Y_TABLE
OXO	SET	0
	REPT	240
	DC.L	OXO
OXO	SET	OXO+768
	ENDR
COORD	INCBIN	F:TUNNEL.INL
	SECTION	BSS
TUNNEL_TAB		DS.B	40000
OLD_CACR		DS.L	1
SCREEN_ADD		DS.L	1
COMPT		DS.W	1
OLD_VBL		DS.L	1
OLD_A09		DS.B	1
CURVE_COMPT	DS.W	1
AFFECR:		DS.L 	1
WORKECR:		DS.L 	1
OLDXBIOS2:		DS.L	1
OLDMODECODE	DS.W	1
CLR		DS.L	17
		DS.L	2000
PILE		DS.L	10
		DS.B	4
XBIOS2:		DS.B	768*241
		DS.B	4
XBIOS3:		DS.B	768*241
	END
