  ORG       X:$0010
  DC $400000
  DC $59999A
  DC $000FFF
  DC $000001
  DC $000001
  DC $000001
  DC $000001
  DC $000001
  DC $000001
  DC $000001
  DC $000001
  DC $000000
  ORG       P:$0000
 P:0000 JMP $0040
  ORG       P:$000C
 P:000C JSR $0084
  ORG       P:$0010
 P:0010 JSR $0095
  ORG       P:$0040
 P:0040 MOVEP X:<<$FFEB,X0
 P:0041 MOVEC #<00,SP
 P:0042 MOVEP #>$004100,X:<<$FFEC
 P:0044 MOVEP #>$0001F8,X:<<$FFE1
 P:0046 BTST #$04,X:<<$FFEE
 P:0047 MOVEP #>$00F800,X:<<$FFED
 P:0049 MOVEP #>$000000,X:<<$FFFE
 P:004B MOVEP #>$003000,X:<<$FFFF
 P:004D MOVEP #>$000001,X:<<$FFE0
 P:004F MOVE  #$40,Y0
 P:0050 MOVE  #>$59999A,Y1
 P:0052 MOVE  #>$002000,R3
 P:0054 MOVEC #>$000FFF,M3
 P:0056 MOVE  #$10,R1
 P:0057 MOVEC #<02,M1
 P:0058 CLR A 
 P:0059 MOVE  #>$001FFF,X1
 P:005B DO X1,$005F
 P:005D MOVE  A,X:(R3)
 P:005E MOVE  A,Y:(R3)+
 P:005F ANDI #$FC,MR
 P:0060 JCLR #$00,X:<<$FFE9,$0068
 P:0062 MOVEP X:<<$FFEB,N1
 P:0063 JCLR #$00,X:<<$FFE9,$0063
 P:0065 MOVEP X:<<$FFEB,X:(R1+N1)
 P:0066 MOVE  X:<$10,Y0
 P:0067 MOVE  X:<$11,Y1
 P:0068 JCLR #$00,X:<$1B,$0060
 P:006A CLR A 
 P:006B CLR B 
 P:006C MOVE  X:<$13,X0
 P:006D MPY +Y0,X0,B 
 P:006E MOVE  X:(R3),X0
 P:006F MPY +X0,Y1,A 
 P:0070 ADD A,B 
 P:0071 MOVE  B,X:<$15
 P:0072 MOVE  B,X:(R3)
 P:0073 CLR A 
 P:0074 CLR B 
 P:0075 MOVE  X:<$14,X0
 P:0076 MPY +Y0,X0,B 
 P:0077 MOVE  Y:(R3),X0
 P:0078 MPY +X0,Y1,A 
 P:0079 ADD A,B 
 P:007A MOVE  B,X:<$16
 P:007B MOVE  B,Y:(R3)+
 P:007C BCLR #$00,X:<$1B
 P:007D MOVE  R3,A
 P:007E MOVE  #>$002000,X1
 P:0080 CMP X1,A 
 P:0081 JNE <$0060
 P:0082 MOVEC X:<$12,M3
 P:0083 JMP <$0060
 P:0084 BSET #$00,X:<$1B
 P:0085 MOVE  X0,X:<$17
 P:0086 MOVE  X1,X:<$18
 P:0087 JCLR #$00,X:<$19,$008F
 P:0089 MOVEP X:<<$FFEF,X1
 P:008A MOVE  X1,X:<$14
 P:008B BCLR #$00,X:<$19
 P:008C MOVE  X:<$17,X0
 P:008D MOVE  X:<$18,X1
 P:008E RTI 
 P:008F MOVEP X:<<$FFEF,X0
 P:0090 MOVE  X0,X:<$13
 P:0091 BSET #$00,X:<$19
 P:0092 MOVE  X:<$17,X0
 P:0093 MOVE  X:<$18,X1
 P:0094 RTI 
 P:0095 MOVE  X0,X:<$17
 P:0096 MOVE  X1,X:<$18
 P:0097 JCLR #$00,X:<$1A,$009F
 P:0099 MOVE  X:<$16,X1
 P:009A MOVEP X1,X:<<$FFEF
 P:009B BCLR #$00,X:<$1A
 P:009C MOVE  X:<$17,X0
 P:009D MOVE  X:<$18,X1
 P:009E RTI 
 P:009F MOVE  X:<$15,X0
 P:00A0 MOVEP X0,X:<<$FFEF
 P:00A1 BSET #$00,X:<$1A
 P:00A2 MOVE  X:<$17,X0
 P:00A3 MOVE  X:<$18,X1
 P:00A4 RTI 
