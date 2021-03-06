BOF
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,OldStack

	move.b	#14,$484		* No Key-Click
	clr.l	d0
	jsr	MusicSpace+28		* Init Music
	move.l	#PlayMusic,$4da.w

	move.l	OldStack(pc),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	move.l	#EOF-BOF+$100,-(sp)
*	move.l	#4096,-(sp)
	move.w	#$31,-(sp)
	trap	#1
	
PlayMusic
	jsr	MusicSpace+32	* Play Note
	tst.b	MusicSpace+36	* End Of Song Reached 
	bne.s	NoEndOfMusic
	clr.l	d0		* Yes, -> Reset Pointers
	jsr	MusicSpace+28
NoEndOfMusic
	rts

OldStack	dc.l	0
MusicSpace
	dc.w	$601A,$0000,$0C42,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$6000,$00BE
	dc.w	$6000,$017E,$0000,$6000,$000C,$41FA,$FFF8,$4210
	dc.w	$6000,$04C8,$4DFA,$03F2,$C0FC,$000D,$4BFA,$0BD1
	dc.w	$DAC0,$1E2D,$000B,$E14F,$1E2D,$000A,$7C00,$1C2D
	dc.w	$000C,$6100,$0408,$08EE,$0007,$0018,$4E75,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0008,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0010,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$3F00,$6100
	dc.w	$041A,$301F,$0240,$00FF,$43FA,$FF74,$45FA,$FF92
	dc.w	$47FA,$FFB0,$3200,$D040,$D041,$D040,$41FA,$09CA
	dc.w	$49F0,$0000,$301C,$4BF0,$0000,$234D,$0002,$301C
	dc.w	$4BF0,$0000,$254D,$0002,$301C,$4BF0,$0000,$274D
	dc.w	$0002,$7000,$1340,$0013,$1540,$0013,$1740,$0013
	dc.w	$1340,$0018,$1540,$0018,$1740,$0018,$7001,$1340
	dc.w	$0014,$1540,$0014,$1740,$0014,$1340,$0012,$1540
	dc.w	$0012,$1740,$0012,$1340,$0015,$1540,$0015,$1740
	dc.w	$0015,$41FA,$0A1F,$2348,$000E,$2548,$000E,$2748
	dc.w	$000E,$41FA,$FF50,$7002,$720A,$7400,$10C2,$D401
	dc.w	$B43C,$0050,$66F6,$51C8,$FFF2,$70FF,$1340,$0016
	dc.w	$1540,$0016,$1740,$0016,$41FA,$FE8A,$1080,$4E75
	dc.w	$6100,$039A,$41FA,$FE7E,$4A10,$6700,$FFF2,$43FA
	dc.w	$FEAE,$1029,$0016,$8029,$0038,$8029,$005A,$1080
	dc.w	$6618,$43FA,$0248,$1011,$0200,$003F,$B03C,$003F
	dc.w	$6700,$FFCC,$10BC,$0001,$4E75,$4DFA,$0232,$49FA
	dc.w	$FE7E,$6100,$0016,$4DFA,$0240,$49FA,$FE94,$6100
	dc.w	$000A,$4DFA,$024E,$49FA,$FEAA,$6100,$0162,$4A2C
	dc.w	$0014,$6700,$0080,$532C,$0012,$670E,$296C,$0006
	dc.w	$000A,$422C,$0014,$6000,$006C,$197C,$0001,$0012
	dc.w	$206C,$0002,$1018,$6A3C,$B03C,$00FE,$6606,$1958
	dc.w	$0013,$60F0,$B03C,$00FF,$6606,$422C,$0016,$4E75
	dc.w	$B03C,$00C0,$6C0A,$0200,$001F,$1940,$0012,$60D4
	dc.w	$0240,$0007,$D06C,$0000,$43FA,$FE6A,$43F1,$0000
	dc.w	$1298,$60C0,$422C,$0014,$2948,$0002,$41FA,$082C
	dc.w	$4880,$D040,$3030,$0000,$41FA,$0518,$D0C0,$2948
	dc.w	$0006,$6004,$206C,$000A,$532C,$0015,$670E,$4A10
	dc.w	$6A04,$6100,$007E,$2948,$000A,$4E75,$4A10,$6A0E
	dc.w	$6100,$0070,$4A2C,$0014,$67F2,$6000,$FF5A,$1018
	dc.w	$B03C,$007F,$6752,$B03C,$007E,$660A,$1C18,$1E18
	dc.w	$E14F,$1E06,$6018,$D02C,$0013,$0600,$000C,$1940
	dc.w	$0017,$4880,$D040,$43FA,$0412,$3E31,$0000,$102C
	dc.w	$0018,$0000,$00C0,$1940,$0020,$7C00,$1C18,$1946
	dc.w	$0015,$2948,$000A,$2A6C,$000E,$082E,$0007,$0018
	dc.w	$6600,$FE9C,$6000,$0156,$1958,$0015,$2948,$000A
	dc.w	$4E75,$1018,$B03C,$0088,$6E1C,$0240,$0007,$D06C
	dc.w	$0000,$43FA,$FDA0,$1031,$0000,$43FA,$0857,$D2C0
	dc.w	$2949,$000E,$4E75,$B03C,$00FF,$6606,$1940,$0014
	dc.w	$4E75,$B03C,$00C0,$6C0A,$0200,$000F,$1940,$0018
	dc.w	$4E75,$B03C,$00C2,$6700,$FE46,$5648,$4E75,$082E
	dc.w	$0007,$0018,$6600,$FE38,$102C,$0020,$6A00,$FE30
	dc.w	$0200,$003F,$6608,$08AC,$0007,$0020,$4E75,$7E07
	dc.w	$082C,$0006,$0020,$6600,$002E,$532C,$001E,$6600
	dc.w	$FE0E,$532C,$001F,$671E,$206C,$001A,$1018,$2948
	dc.w	$001A,$1200,$C207,$1941,$001E,$E608,$0200,$001F
	dc.w	$D02C,$0017,$6046,$41FA,$0827,$102C,$0020,$E748
	dc.w	$0240,$00FF,$D0C0,$4A10,$6B10,$082C,$0006,$0020
	dc.w	$6608,$197C,$0001,$001F,$4E75,$08AC,$0006,$0020
	dc.w	$1010,$E608,$C007,$1940,$001E,$1018,$C007,$5200
	dc.w	$1940,$001F,$2948,$001A,$102C,$0017,$4880,$D040
	dc.w	$41FA,$02E8,$3D70,$0000,$0004,$4E75,$FF00,$FEF7
	dc.w	$0900,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FDEF,$1200,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$FBDF,$2400,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$40E7,$007C
	dc.w	$0700,$2D4D,$0014,$3D47,$0004,$3D46,$0008,$1D6D
	dc.w	$0005,$000A,$102D,$0006,$0200,$007F,$E208,$6402
	dc.w	$5200,$1D40,$000B,$1D6D,$0007,$000F,$1D6D,$0008
	dc.w	$000E,$426E,$000C,$49FA,$FF74,$1014,$802E,$0002
	dc.w	$1D6D,$0009,$0018,$082E,$0000,$0018,$6704,$C02E
	dc.w	$0000,$082E,$0001,$0018,$6704,$C02E,$0001,$1880
	dc.w	$082E,$0002,$0018,$660C,$41FA,$016C,$2D48,$0010
	dc.w	$46DF,$4E75,$41F8,$8800,$43F8,$8802,$10BC,$000D
	dc.w	$12AD,$0000,$10BC,$000B,$12AD,$0004,$10BC,$000C
	dc.w	$4211,$50EE,$0006,$46DF,$4E75,$41F8,$8800,$43F8
	dc.w	$8802,$49FA,$FF08,$0014,$003F,$10BC,$0007,$1294
	dc.w	$10BC,$0008,$4211,$10BC,$0009,$4211,$10BC,$000A
	dc.w	$4211,$41FA,$FEEA,$4228,$0018,$41FA,$FEFC,$4228
	dc.w	$0018,$41FA,$FF0E,$4228,$0018,$4E75,$49FA,$FECE
	dc.w	$4DFA,$FECC,$6100,$00BA,$4DFA,$FEDE,$6100,$00B2
	dc.w	$4DFA,$FEF0,$6100,$00AA,$41F8,$8800,$43F8,$8802
	dc.w	$10BC,$0007,$1294,$4DFA,$FEA6,$10BC,$0000,$302E
	dc.w	$0004,$D06E,$000C,$082E,$0001,$0018,$6702,$1200
	dc.w	$1280,$10BC,$0001,$E048,$1280,$4DFA,$FE9C,$10BC
	dc.w	$0002,$302E,$0004,$D06E,$000C,$082E,$0001,$0018
	dc.w	$6702,$1200,$1280,$10BC,$0003,$E048,$1280,$4DFA
	dc.w	$FE92,$10BC,$0004,$302E,$0004,$D06E,$000C,$082E
	dc.w	$0001,$0018,$6702,$1200,$1280,$10BC,$0005,$E048
	dc.w	$1280,$10BC,$0006,$E609,$1281,$10BC,$0008,$103A
	dc.w	$FE34,$E608,$1280,$10BC,$0009,$103A,$FE42,$E608
	dc.w	$1280,$10BC,$000A,$103A,$FE50,$E608,$1280,$4E75
	dc.w	$1014,$C02E,$0002,$B02E,$0002,$6602,$4E75,$2A6E
	dc.w	$0014,$4A6E,$0008,$670C,$0C6E,$FFFF,$0008,$6704
	dc.w	$536E,$0008,$6100,$008C,$082E,$0002,$0018,$667A
	dc.w	$206E,$0010,$4ED0,$102D,$0000,$D12E,$0006,$6B0A
	dc.w	$102D,$0004,$B02E,$0006,$6E0E,$1D6D,$0004,$0006
	dc.w	$41FA,$0008,$2D48,$0010,$4E75,$102D,$0001,$D12E
	dc.w	$0006,$6B0A,$102D,$0002,$B02E,$0006,$6DEA,$1D6D
	dc.w	$0002,$0006,$41FA,$0008,$2D48,$0010,$4E75,$4A6E
	dc.w	$0008,$66D4,$41FA,$0008,$2D48,$0010,$4E75,$102D
	dc.w	$0003,$D12E,$0006,$6AC0,$422E,$0006,$102E,$0002
	dc.w	$8114,$08AE,$0007,$0018,$4E75,$4A6E,$0008,$66A8
	dc.w	$60E6,$102E,$000A,$670C,$B03C,$00FF,$6720,$532E
	dc.w	$000A,$661A,$302E,$000E,$D16E,$000C,$532E,$000B
	dc.w	$660C,$102D,$0006,$6706,$6A06,$50EE,$000A,$4E75
	dc.w	$1D40,$000B,$446E,$000E,$4E75,$0EEE,$0E18,$0D4D
	dc.w	$0C8E,$0BDA,$0B2F,$0A8F,$09F7,$0968,$08E1,$0861
	dc.w	$07E9,$0777,$070C,$06A7,$0647,$05ED,$0598,$0547
	dc.w	$04FC,$04D4,$0470,$0431,$03F4,$03DC,$0386,$0353
	dc.w	$0324,$02F6,$02CC,$02A4,$027E,$025A,$0238,$0218
	dc.w	$01FA,$01DE,$01C3,$01AA,$0192,$017B,$0166,$0152
	dc.w	$013F,$012D,$011C,$010C,$00FD,$00EF,$00E1,$00D5
	dc.w	$00C9,$00BE,$00B3,$00A9,$009F,$0096,$008E,$0086
	dc.w	$007F,$0077,$0071,$006A,$0064,$005F,$0059,$0054
	dc.w	$0050,$004B,$0047,$0043,$003F,$003C,$0038,$0035
	dc.w	$0032,$002F,$002D,$002A,$0028,$0026,$0024,$0022
	dc.w	$0020,$8492,$3105,$310A,$310A,$310A,$310A,$932F
	dc.w	$052F,$0A2F,$0A2F,$0A94,$2F05,$2F0A,$2F0A,$2F0A
	dc.w	$2F05,$8091,$2F28,$FF80,$932C,$0F92,$2E0F,$932A
	dc.w	$322C,$0F2C,$0F92,$2E32,$932C,$0F92,$2E0F,$932A
	dc.w	$142A,$142C,$1492,$2E0A,$2E3C,$90FF,$8104,$0504
	dc.w	$0A04,$0A04,$0A04,$0A04,$0504,$0A04,$0A04,$0A0B
	dc.w	$050B,$0A0B,$0A0B,$0A0B,$050B,$1482,$1B05,$1B05
	dc.w	$1705,$1405,$FF81,$060A,$060A,$8306,$0A81,$060A
	dc.w	$FF81,$060A,$060A,$8306,$0582,$1B05,$1705,$1405
	dc.w	$FF85,$3146,$2F0A,$2E0F,$2A41,$3132,$330A,$360A
	dc.w	$365A,$3146,$2F0A,$2E0F,$2A41,$3132,$3B14,$3814
	dc.w	$360A,$3628,$3A05,$3805,$3605,$3105,$3346,$300A
	dc.w	$2E0F,$2B41,$3332,$3814,$3514,$330A,$333C,$3346
	dc.w	$300A,$2E0F,$2B41,$3332,$3814,$3514,$330A,$3328
	dc.w	$3705,$3505,$3305,$3005,$FF86,$3B0A,$3A0A,$360A
	dc.w	$3314,$3614,$351E,$330A,$3114,$330A,$350A,$380A
	dc.w	$3B0A,$3A14,$361E,$330A,$315A,$3B0A,$3A0A,$360A
	dc.w	$3314,$3614,$351E,$330A,$3114,$330A,$350A,$380A
	dc.w	$3B0A,$3A14,$3B1E,$3D0A,$3D37,$822A,$052A,$052A
	dc.w	$0527,$0A23,$0523,$0595,$FF80,$932A,$0A2A,$142A
	dc.w	$142A,$142A,$142C,$0A2C,$502A,$142A,$0A2A,$1494
	dc.w	$2A14,$2A14,$912A,$0A2A,$2893,$2A0A,$2A14,$2A14
	dc.w	$2A14,$2A14,$2C0A,$2C50,$2A14,$2A0A,$2A14,$2A14
	dc.w	$2C0A,$2C3C,$FF80,$922C,$0A2C,$1493,$2A14,$2A14
	dc.w	$922E,$142E,$1493,$2C0A,$2C28,$922C,$0A2C,$1493
	dc.w	$2A14,$2A14,$2C0A,$2C46,$922E,$0AFF,$862F,$0A2C
	dc.w	$0A28,$0A23,$1427,$0A2A,$0A31,$142E,$0A2A,$0A25
	dc.w	$1429,$0A2C,$0A2F,$142C,$0A28,$0A23,$1427,$0A2A
	dc.w	$0A31,$502E,$0AFF,$8106,$0A06,$0A83,$060A,$810B
	dc.w	$0AFF,$7F02,$FF90,$822A,$0A2A,$0A27,$0527,$0A27
	dc.w	$0523,$0A23,$0520,$0A20,$051E,$0AFF,$807F,$0A36
	dc.w	$0536,$0A36,$0A36,$0536,$28FF,$7F14,$FF82,$2A0A
	dc.w	$2A0A,$2705,$270A,$2705,$1E05,$1E05,$1E05,$1E05
	dc.w	$1B05,$1B05,$1B05,$1B03,$FF80,$922E,$32FF,$8106
	dc.w	$32FF,$8092,$310F,$310F,$932F,$3291,$2F0F,$2F0F
	dc.w	$922E,$3292,$310F,$310F,$932F,$142F,$1494,$2F14
	dc.w	$2F0A,$912F,$3CFF,$8109,$0A0B,$0A0D,$0A0E,$140D
	dc.w	$0A0B,$0A07,$1409,$0A0B,$0A0C,$1E0B,$1409,$0A0B
	dc.w	$0A0D,$0A0E,$1410,$0A12,$0A10,$0AFF,$8491,$2D0A
	dc.w	$2D0A,$8306,$0A84,$932D,$142D,$0A83,$060A,$8491
	dc.w	$2B14,$2B0A,$8306,$0A84,$932B,$142B,$0A83,$060A
	dc.w	$0605,$0605,$8491,$2D0A,$2D0A,$8306,$0A84,$932D
	dc.w	$142D,$0A83,$1E0A,$842F,$142F,$0A83,$060A,$842F
	dc.w	$142F,$0A83,$0605,$0605,$0605,$0605,$90FF,$8531
	dc.w	$0A2F,$0A2D,$0A2C,$142A,$0A28,$0A27,$1425,$0A23
	dc.w	$0A22,$1423,$0A25,$1431,$0A2F,$0A2D,$0A2C,$142A
	dc.w	$0A28,$0A2A,$5AFF,$852D,$1428,$0A2A,$1428,$0A2A
	dc.w	$0A2B,$1E26,$0A28,$1426,$0A28,$142D,$1428,$0A2A
	dc.w	$142B,$0A2D,$0A2C,$5A95,$FF00,$0000,$0025,$004A
	dc.w	$0073,$007F,$008F,$00E7,$0137,$0173,$019A,$01C4
	dc.w	$01D0,$01D3,$01EA,$01F8,$01FB,$0217,$021C,$0220
	dc.w	$0244,$026A,$02BC,$02E4,$0012,$0034,$0046,$0086
	dc.w	$008A,$0090,$0094,$00A1,$00AB,$0001,$01FE,$FD01
	dc.w	$01FE,$0001,$01FE,$FD01,$01FE,$0007,$0101,$FEFD
	dc.w	$0101,$FE00,$080B,$FEF4,$870C,$0FFF,$FEF4,$0001
	dc.w	$01FE,$F101,$01FE,$F405,$0605,$0988,$0CFF,$028F
	dc.w	$0304,$FEFD,$8F03,$04FE,$008F,$0304,$FEFD,$8F03
	dc.w	$04FE,$FB90,$03FE,$008F,$0304,$FEFD,$8F03,$04FE
	dc.w	$FE03,$FEF9,$03FE,$0003,$FEFB,$03FE,$FE03,$FEF9
	dc.w	$03FE,$FB03,$0AFE,$0CC0,$5090,$0E84,$0DFF,$0010
	dc.w	$0EFF,$FEF4,$0010,$0EFF,$0211,$0EFF,$9003,$130C
	dc.w	$9003,$130C,$9003,$130C,$FF12,$1214,$1212,$1408
	dc.w	$1214,$FFFE,$F4C3,$5A12,$1214,$FE00,$1515,$1615
	dc.w	$1516,$FF7F,$FF01,$FF7F,$0002,$0200,$017F,$FE01
	dc.w	$FF7F,$0004,$0400,$017F,$FD01,$FF7F,$0000,$2800
	dc.w	$017F,$FE01,$FF7F,$0000,$2800,$027F,$FC63,$FF7F
	dc.w	$0002,$0200,$0150,$FF01,$FF7F,$0804,$0300,$0132
	dc.w	$FF01,$FF7F,$0002,$0400,$017F,$F801,$FF7F,$0000
	dc.w	$0002,$017F,$F801,$FF7F,$0000,$0000,$037F,$F801
	dc.w	$FF7F,$0000,$0000,$008A,$2139,$0000,$0000,$008A
	dc.w	$1941,$0000,$0000,$008A,$2949,$0000,$0000,$008A
	dc.w	$2939,$0000,$0000,$0089,$6100,$0000,$0000,$007F
	dc.w	$F901,$FF7F,$0000,$5E00,$0100,$0505,$7FF9,$01FF
	dc.w	$7F00,$005E,$0001,$0004,$047F,$F901,$FF7F,$0000
	dc.w	$3200,$018E,$0304,$7FFC,$01FF,$7F00,$008D,$0001
	dc.w	$8E03,$087F,$FC01,$FF7F,$0000,$EBFF,$0122,$0508
	dc.w	$0AFF,$01FF,$7FFF,$0000,$0005,$2600,$0F90,$0000
EOF
