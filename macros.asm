
.eqv 	READYBIT 	0xffff0000
.eqv 	VALUEBIT 	0xffff0004

.eqv HEAP 	0x10040000
.eqv ROWSIZE 	256
.eqv ROSIZEx2   512

.eqv EMPTY  0
.eqv X      1
.eqv CIRCLE 2
.eqv BOTH   3

.eqv WHITE		0x00FFFFFF
.eqv MAGENTA    0x00FF00FF
.eqv RED        0x00FF0000
.eqv YELLOW     0x00FFFF00
.eqv GREEN      0x0000FF00
.eqv ORANGE		0x00FF7F00
.eqv PURPLE		0x00800080

.macro numToSlot(%num)

    
	beq %num, 1, conv1
	beq %num, 2, conv2
	beq %num, 3, conv3
	beq %num, 4, conv4
	beq %num, 5, conv5
	beq %num, 6, conv6
	beq %num, 7, conv7
	beq %num, 8, conv8
	beq %num, 9, conv9

	j macroexit

conv1:
	la %num, square1
	j macroexit
conv2:
	la %num, square2
	j macroexit
conv3:
	la %num, square3
	j macroexit
conv4:
	la %num, square4
	j macroexit
conv5:
	la %num, square5
	j macroexit
conv6:
	la %num, square6
	j macroexit
conv7:
	la %num, square7
	j macroexit
conv8:
	la %num, square8
	j macroexit
conv9:
	la %num, square9
	j macroexit
macroexit:

.end_macro

.macro getSquareMacro(%square)

    numToSlot(%square)
    lw %square, (%square)

.end_macro