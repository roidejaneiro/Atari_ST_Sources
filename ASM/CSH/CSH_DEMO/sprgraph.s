*
*  NEOchrome cut buffer contents (left justified):
*
*    pixels/scanline    = $001B (bytes/scanline: $0004)
*  # scanlines (height) = $00A5
*
*  Monochrome mask (1 plane; background=0/non-background=1)
*
*
*
	dc.w	$7FFF,$FF00,$FFFF,$FF80,$FFFF,$FF80,$FFFF,$FF80
	dc.w	$F800,$0F80,$F800,$0F80,$F800,$0F80,$FFFF,$FF80
	dc.w	$FFFF,$FF80,$FFFF,$FF80,$FFFF,$FF80,$F800,$0F80
	dc.w	$F800,$0F80,$F800,$0F80,$7000,$0700,$7000,$0700
	dc.w	$F800,$0F80,$F800,$0F80,$F800,$0F80,$7C00,$1F00
	dc.w	$7C00,$1F00,$7C08,$1F00,$3E1C,$3E00,$3E3E,$3E00
	dc.w	$3E7F,$3C00,$1EF7,$FC00,$1FE3,$FC00,$1FC1,$F800
	dc.w	$0F80,$F800,$0700,$7000,$7FFF,$FF00,$FFFF,$FF80
	dc.w	$FFFF,$FF80,$FFFF,$FF80,$F800,$0F80,$F800,$0F80
	dc.w	$F800,$0F80,$FFFF,$FF80,$FFFF,$FF80,$FFFF,$FF80
	dc.w	$FFFF,$FF80,$F800,$0F80,$F800,$0F80,$F800,$0F80
	dc.w	$7000,$0700,$01FF,$C000,$0FFF,$F800,$1FFF,$FC00
	dc.w	$3FFF,$FE00,$7F00,$7F00,$F800,$0F80,$F000,$0780
	dc.w	$F000,$0780,$F000,$0780,$F800,$0F80,$7F00,$7F00
	dc.w	$3FFF,$FE00,$1FFF,$FC00,$0FFF,$F800,$01FF,$C000
	dc.w	$7FFF,$FF00,$FFFF,$FF80,$FFFF,$FF80,$FFFF,$FF00
	dc.w	$F800,$0000,$F800,$0000,$F800,$0000,$F800,$0000
	dc.w	$FFFF,$0000,$FFFF,$8000,$FFFF,$0000,$F800,$0000
	dc.w	$F800,$0000,$F800,$0000,$7000,$0000,$07FF,$FF00
	dc.w	$1FFF,$FF80,$3FFF,$FF80,$7FFF,$FF00,$FC00,$0000
	dc.w	$F800,$0000,$F800,$0000,$F800,$0000,$F800,$0000
	dc.w	$F800,$0000,$F800,$0000,$F800,$0000,$F800,$0000
	dc.w	$F800,$0000,$F800,$0000,$7800,$3C00,$FC00,$7E00
	dc.w	$FC00,$7E00,$FC00,$7E00,$FC00,$7E00,$FFFF,$FE00
	dc.w	$FFFF,$FE00,$FFFF,$FE00,$FFFF,$FE00,$FFFF,$FE00
	dc.w	$FC00,$7E00,$FC00,$7E00,$FC00,$7E00,$FC00,$7E00
	dc.w	$7800,$3C00,$0FFF,$FF00,$3FFF,$FF80,$7FFF,$FF80
	dc.w	$FFFF,$FF80,$FFFF,$FF00,$F000,$0000,$FFFF,$F000
	dc.w	$FFFF,$F800,$FFFF,$F000,$F000,$0000,$FFFF,$FF00
	dc.w	$FFFF,$FF80,$7FFF,$FF80,$3FFF,$FF80,$0FFF,$FF00
	dc.w	$1FFF,$FF00,$3FFF,$FF80,$7FFF,$FF80,$FFFF,$FF80
	dc.w	$FFFF,$FF00,$FC00,$0000,$F800,$0000,$F800,$0000
	dc.w	$F800,$0000,$FC00,$0000,$FFFF,$FF00,$FFFF,$FF80
	dc.w	$7FFF,$FF80,$3FFF,$FF80,$0FFF,$FF00,$7FFF,$F800
	dc.w	$FFFF,$FC00,$FFFF,$FC00,$FFFF,$F800,$FFFF,$F000
	dc.w	$E000,$0000,$FFFF,$F800,$FFFF,$FC00,$7FFF,$FC00
	dc.w	$3FFF,$FC00,$0000,$1C00,$7FFF,$FC00,$FFFF,$FC00
	dc.w	$FFFF,$FC00,$7FFF,$F800,$7800,$3C00,$FC00,$7E00
	dc.w	$FC00,$7E00,$FC00,$7E00,$FC00,$7E00,$FFFF,$FE00
	dc.w	$FFFF,$FE00,$FFFF,$FE00,$FFFF,$FE00,$FFFF,$FE00
	dc.w	$FC00,$7E00,$FC00,$7E00,$FC00,$7E00,$FC00,$7E00
	dc.w	$7800,$3C00

