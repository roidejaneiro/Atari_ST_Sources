* get rid of top, left, right borders
* by James Ingram, April 1994

	opt	o-,ow-


	include	\includes\macros.s
	
	
	
	super_on

	c_off		; timer C off

	jsr	initialise

* get screen address
	move.l	#scrn,d0
	add.l	#255,d0
	clr.b	d0
	move.l	d0,screen

	move.l	d0,a6

* set the screen address
	move.l	d0,d1
	moveq	#-1,d0
	jsr	set_scrn

	movem.l	my_pal,d0-7
	movem.l	d0-7,$ffff8240.w

* fill screen with junk, to show effect

	move.w	#screen_len/4-1,d1
fill:
	move.l	#$80808080,(a6)+
	dbra	d1,fill


	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	jsr	inp
	move.l	(a7)+,$70.w

	
	jsr	restore

	c_on		; timer C on

	super_off
	clr.w	-(a7)
	trap	#1


my_70:
* interrupts off
	move.w	sr,-(a7)
	or.w	#$0700,sr

	movem.l	d0-7/a0-6,-(a7)

* pause for a bit (nearly 15,000 clock cycles!)
	move.w	#1064,d0
pause:
	nop
	dbra	d0,pause

* into 60 Hz
	eor.b	#2,$ffff820a.w

	rept	8
	nop
	endr

* back into 50 Hz
	eor.b	#2,$ffff820a.w

	move.w	#$8209,a0
	lea	$ff8260,a1	; resolution
	moveq	#0,d0
	moveq	#16,d1
	moveq	#2,d3
	moveq	#0,d4



.wait:
	move.b	(a0),d0
	beq.s	.wait

	eor.w	#$f00,$ffff8240.w

	sub.w	d0,d1
	lsl.w	d1,d0

	eor.w	#$f00,$ffff8240.w

	move.w	#$820a,a0	; sync modus

	rept	83
	nop
	endr


	move.w	#226,d0


lines	equ	227

	rept	lines
* LEFT HAND BORDER!
	move.b	d3,(a1)		; to monochrome
	move.b	d4,(a1)		; to lo-res

	dcb.w	90,$4e71

* RIGHT AGAIN...
	move.b	d4,(a0)
	move.b	d3,(a0)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d3,(a1)
	nop
	move.b	d4,(a1)

	dcb.w	12,$4e71


	endr


* FINAL LINE...
* LEFT HAND BORDER!
	move.b	d3,(a1)		; to monochrome
	move.b	d4,(a1)		; to lo-res

	dcb.w	90,$4e71

* RIGHT AGAIN...
	move.b	d4,(a0)
	move.b	d3,(a0)

	dcb.w	13,$4e71

* EXTRA!
	move.b	d3,(a1)
	nop
	move.b	d4,(a1)


	movem.l	(a7)+,d0-7/a0-6

	move.w	(a7)+,sr
	rte

my_pal	incbin	\includes\spr_pal.dat

	include	\includes\misc.s
	include	\includes\init.s

	section	bss

scrn:
	ds.b	256		; byte boundary
s:
	ds.b	32*160		; top border area
	ds.b	32000		; main screen
	ds.b	32000
screen_len	equ	*-s


screen	ds.l	1
