; STEAL font program for pov 15 (2 plane set)
	bra	skip
filename:	dc.b	"pov15.dat",0	;destination name
	even
pic:	incbin	"pov15set.pi1"	;source picture
	even

skip:	move.l	sp,A5
	move.l	4(A5),A5
	move.l	$C(A5),D0
	add.l	$14(A5),D0
	add.l	$1C(A5),D0
	add.l	#$100,D0
	move.l	D0,-(sp)
	move.l	A5,-(sp)
	move.w	D0,-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp

	bsr	set_super
	dc.w	$a00a
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez

	move.l	screen_base,a1
	lea	pic+34,a0
	move.w	#32000/4-1,d0
loop:	move.l	(a0)+,(a1)+
	dbf	d0,loop
	
	move.l	screen_base,a0
	add.l	#160,a0

	move.l	a0,a6
	lea	buffer,a1
	move.w	#20-1,d1
across:
	move.w	#16-1,d0
shift:
	move.l	(a0),(a1)+
	move.l	#$ff58ff00,(a0)
;	move.l	4(a0),(a1)+
;	move.l	#$ff00ff00,4(a0)
	add.w	#160,a0
	bsr	pause
	dbf	d0,shift
	sub.w	#160*16,a0
	add.w	#8,a0
	dbf	d1,across

	add.w	#160*16,a6
	move.l	a6,a0
	move.w	#20-1,d1
.loop2:
	move.w	#16-1,d0
.loop:
	move.l	(a0),(a1)+
	move.l	#-1,(a0)
;	move.l	4(a0),(a1)+
;	move.l	#-1,4(a0)
	add.w	#160,a0
	bsr	pause
	dbf	d0,.loop
	sub.w	#160*16,a0
	add.w	#8,a0
	dbf	d1,.loop2

	add.w	#160*16,a6
	move.l	a6,a0
	move.w	#20-1,d1
.loop4:
	move.w	#16-1,d0
.loop3:
	move.l	(a0),(a1)+
	move.l	#-1,(a0)
;	move.l	4(a0),(a1)+
;	move.l	#-1,4(a0)
	add.w	#160,a0
	bsr	pause
	dbf	d0,.loop3
	sub.w	#160*16,a0
	add.w	#8,a0
	dbf	d1,.loop4

;now save
	bsr	f_create
	bsr	f_write
	bsr	f_close

wait:	bsr	get_key

	CMP.B	#27,D0		;Wait for ESC.
	bne	wait

	bsr	set_new_palette
	bsr	set_med_rez
	dc.w	$a009
	bsr	set_user

	MOVE.W	#$0,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1
	RTS

***********************
* SUBROUTINES SECTION *
***********************

f_create:
	move.w	#0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp
	move.w	d0,handle
	rts

f_write:
	move.l	#buffer,-(sp)
	move.l	#eob-buffer,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts

f_close:
	move.w	handle,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

pause:	move.w	d0,-(sp)
	move.w	#5000,d0
pau:	nop
	dbf	d0,pau
	move.w	(sp)+,d0
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts

get_old_palette:
	move.w	#8-1,d0
	lea	$ff8240,a0
	lea	old_palette,a1
get_old:
	move.l	(a0)+,(a1)+
	dbf	D0,get_old
	rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
handle:		dc.w	0
old_palette:	ds.w	16
	even
buffer:	ds.b	(16*8)*20
	ds.b	(16*8)*10
;	ds.b	(16*8)*20
eob:
