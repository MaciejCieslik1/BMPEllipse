	.eqv	print_int, 1
	.eqv	print_string, 4
	.eqv	read_string, 8
	.eqv	sys_exit, 10
	.eqv	open_file, 1024
	.eqv	write_to_file, 64
	.eqv	seek_in_file, 62
	.eqv	close_file, 57
	.eqv	sbrk, 9
	.eqv	read_int, 5
	.eqv	IMAGE_SIZE, 200
	.data

filename: .asciz  "ellipse.bmp"
radiusx: .asciz "Enter value of radius x:\n"
radiusy: .asciz "Enter value of radius y:\n"
xcentre: .asciz "Enter value of x centre:\n"
ycentre: .asciz "Enter value of y centre:\n"


bmp_header:
    .byte 0x42, 0x4D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x36, 0x00, 0x00, 0x00, 0x28, 0x00,
          0x00, 0x00, 0xC8, 0x00, 0x00, 0x00, 0xC8, 0x00,
          0x00, 0x00, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x13, 0x0B, 0x00, 0x00, 0x13, 0x0B,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
          0x00, 0x00, 0x00, 0x00, 0x00, 0x00
          
          
	.text
get_data:
	li	a7, print_string
	la	a0, radiusx
	ecall
	li	a7, read_int
	ecall
	mv	t0, a0		# radius x
	
	li	a7, print_string
	la	a0, radiusy
	ecall
	li	a7, read_int
	ecall
	mv	t1, a0		# radius y
	
	li	a7, print_string
	la	a0, xcentre
	ecall
	li	a7, read_int
	ecall
	mv	s10, a0		# x centre
	
	li	a7, print_string
	la	a0, ycentre
	ecall
	li	a7, read_int
	ecall
	mv	s11, a0		# y centre
	
	li	a4, IMAGE_SIZE	 
	
	blez	t0, get_data
	blez	t1, get_data
	blez	s10, get_data
	blez	s11, get_data
	bge	t0, s10, get_data
	bge	t1, s11, get_data
	bge	s10, a4, get_data
	bge	s11, a4, get_data
	add	t2, t0, s10
	bge	t2, a4, get_data
	add	t3, t1, s11
	bge	t3, a4, get_data
begin:		
	mv	t2, t0			# default x value
	li	t3, 0			# default y value
	mul	t4, t0, t0 		# radius x square
	mul	t5, t1, t1 		# radius y square
	li	s8, 1  			# value of 1
	slli	s1, t4, 1  		# radius x square * 2
	slli	s2, t5, 1  		# radius y square * 2
	slli	s5, t0, 1  		# temporary value
	sub	s5, s8, s5
	mul	s3, t5, s5  		# x change, s5 not longer important
	mv	s4, t4			# y change
	li	s5, 0  			# error ellipse
	mul	s6, t0, s2  		# stopping x
	li	s7, 0  			# stopping y
	slli	a0, a4, 5
	li	a7, sbrk
	ecall
	mv	s9, a0
	li	a3, 0  			# number of cordinates counter 
loop1:
	blt	s6, s7, endloop1
	jal 	PlotEllipsePoints
	addi	t3, t3, 1
	add	s7, s7, s1
	add	s5, s5, s4
	add	s4, s4, s1
	slli	t6, s5, 1  	# temporary register
	add	t6, t6, s3
	bgtz	t6, first_if
	j	loop1
first_if:
	addi	t2, t2, -1
	sub	s6, s6, s2
	add	s5, s5, s3
	add	s3, s3, s2
	j	loop1
endloop1:
	li	t2, 0
	mv	t3, t1
	mv	s3, t5
	slli	t6, t1, 1  	# temporary value in t6
	sub	t6, s8, t6  
	mul	s4, t4, t6
	li	s5, 0
	li	s6, 0
	mul	s7, s1, t1
loop2:
	blt	s7, s6, create_pixels
	jal 	PlotEllipsePoints
	addi	t2, t2, 1
	add	s6, s6, s2
	add	s5, s5, s3
	add	s3, s3, s2
	slli	t6, s5, 1  	# temporary register
	add	t6, t6, s4
	bgtz	t6, second_if
	j	loop2
second_if:
	addi	t3, t3, -1
	sub	s7, s7, s1
	add	s5, s5, s4
	add	s4, s4, s1
	j	loop2
PlotEllipsePoints:
    	# Point1 x and y
    	mv 	a1, s10  
    	add 	a1, a1, t2  	# a0 = xCenter + x
    	mv 	a2, s11  
    	add 	a2, a2, t3  	# a0 = yCenter + y
    	add	a5, a3, s9   	# calulates the correct address for current coordinate (offset + basic address)
    	sw	a1, (a5)  	# save xCenter + x to memory
    	addi	a3, a3, 4  	# adds 1 to coordinate counter
    	add	a5, a3, s9
    	sw	a2, (a5)  	# save yCenter + y to memory
    	addi	a3, a3, 4  	# adds 1 to coordinate counter

    	#Point2 x and y
    	mv 	a1, s10  
    	sub 	a1, a1, t2  	# a0 = xCenter - x
    	mv 	a2, s11  
    	add 	a2, a2, t3  	# a0 = yCenter + y    	
    	add	a5, a3, s9   	# calulates the correct address for current coordinate (offset + basic address)
    	sw	a1, (a5)  	# save xCenter - x to memory
    	addi	a3, a3, 4  	# adds 1 to coordinate counter
    	add	a5, a3, s9
    	sw	a2, (a5)  	# save yCenter + y to memory
    	addi	a3, a3, 4  	# adds 1 to coordinate counter

    	#Point3 x and y
    	mv 	a1, s10  
    	sub 	a1, a1, t2  	# a0 = xCenter - x
    	mv 	a2, s11 
    	sub 	a2, a2, t3  	# a0 = yCenter - y
    	add	a5, a3, s9   	# calulates the correct address for current coordinate (offset + basic address)
    	sw	a1, (a5)  	# save xCenter - x to memory
    	addi	a3, a3, 4  	# adds 1 to coordinate counter
    	add	a5, a3, s9
    	sw	a2, (a5)  	# save yCenter - y to memory
    	addi	a3, a3, 4  	# adds 1 to coordinate counter
    	
    	#Point4 x and y
    	mv 	a1, s10  
    	add 	a1, a1, t2  	# a0 = xCenter + x
    	mv 	a2, s11  
    	sub 	a2, a2, t3  	# a0 = yCenter - y
    	add	a5, a3, s9   	# calulates the correct address for current coordinate (offset + basic address)
    	sw	a1, (a5)  	# save xCenter + x to memory
    	addi	a3, a3, 4  	# adds 1 to coordinate counter
    	add	a5, a3, s9
    	sw	a2, (a5)  	# save yCenter - y to memory
    	addi	a3, a3, 4 	# adds 1 to coordinate counter
    	
    	ret
create_pixels:
	mul	a2, a4, a4
	slli	a0, a2, 1
	add	a0, a0, a2 
	mv	t1, a0
	li	a7, sbrk
	ecall
	mv	t0,a0		# beginning pixel's buffer address
	mv	s1, a0		# copy of the beginning pixel's buffer address
	srli	a3, a3, 2
	addi	a3, a3, -2
create_background_loop:
	bltz	t1, create_ellipse
	addi	t1, t1, -1	# decrease pixels counter by 1
	
	li	t4, 255		# RGB R color
	li	t5, 255		# RGB G color
	li 	s6, 255		# RGB B color
  
 	# Save R, G, B values to buffer
  	sb 	t4, (t0)        # save R as 1 byte
  	addi 	t0, t0, 1       # go to the next place in buffer
  	sb 	t5, (t0)        # save G as 1 byte
 	addi 	t0, t0, 1       # go to the next place in buffer
  	sb 	s6, (t0)        # save B as 1 byte
  	addi 	t0, t0, 1    
	j	create_background_loop
create_ellipse:
	# a3 - coordinate counter(stores number of cooridnates x and y in buffer)
	# s9 - address of the first coordinate
	# t0 - current coordinate address
	mv	t0, s9
	mv	t1, s1 	# addres of first pixel
	mv	s6, a4
create_ellipse_loop:
	bltz	a3, write_bmp_header
	lw	t2, (t0)	# read x coordinate
	addi	t0, t0, 4	# add indent = 4 to address to point to the next y coordinate
	lw	t3, (t0)	# read y coordinate
	addi	t0, t0, 4	# add indent = 4 to address to point to the next x coordinate
	addi	a3, a3, -2	# decrease coordinates counter by 2
	mul	t4, t3, s6	# calculate position of the beggining of te correct row(y * pixels in row)
	add	t4, t4, t2	# add x to get correct position
	slli	s5, t4, 1	# multiple pixel position by 2
	add	s5, s5, t4	# add pixel position to doubled pixel position to provide padding for rgb 3 byte value
	li	t4, 255		# RGB R color
	li	t5, 0		# RGB G color
	li 	t6, 0		# RGB B color
	add	s7, t1, s5	# calculate position of ellipse pixel
	sb 	t4, (s7)        # save R as 1 byte
  	addi 	s7, s7, 1       # go to the next place in buffer
  	sb 	t5, (s7)        # save G as 1 byte
 	addi 	s7, s7, 1       # go to the next place in buffer
  	sb 	t6, (s7)        # save B as 1 byte  
	j	create_ellipse_loop
write_bmp_header:
    	la  	a0, bmp_header	# Load address of bmp header
    	li  	a2, 54          # load size of bmp header
    	mv  	a3, a4  	# load image size(widht or heigth they are the same)
    	li  	a5, 3           # load 3 bytes per pixel for RGB standard = 3
    	mul 	a3, a3, a5      # Calculate total size of pixels in line
    	li  	a5, 4           # Load offset = 4
    	add 	a3, a3, a5      # Adjust total bytes to account for alignment (if needed)
    	mul 	a3, a3, a3      # Square number of pixels in line to get total size
    	add 	a2, a2, a3      # Add pixels total size to the header size
    	sb   	a2, 2(a0)       # Store the low byte of a2 at the third byte of bmp_header
	srli 	a2, a2, 8       # Right shift a2 by 8 bits
	sb   	a2, 3(a0)       # Store the next byte of a2 at the fourth byte of bmp_header
	srli 	a2, a2, 8       # Right shift a2 by another 8 bits
	sb   	a2, 4(a0)       # Store the next byte of a2 at the fifth byte of bmp_header
	srli 	a2, a2, 8       # Right shift a2 by another 8 bits
	sb   	a2, 5(a0)       # Store the high byte of a2 at the sixth byte of bmp_header
write_bmp_to_file:
    	# open file for writting
    	la  	a0, filename  	# addres of writting file
    	li  	a1, 1          	# open mode: write only
    	li	a7, open_file
    	ecall
    	mv	a5, a0
    	# save bmp header
    	la  	a1, bmp_header  	# address of bmp header
    	li  	a7, write_to_file	# system call wrtie to file
    	li  	a2, 54         		# sizeof the bmp header
    	ecall
    	# Save pixels to bmp file
    	mv	a0, a5
    	mv	a1, s1
    	li  	a7, write_to_file       # system call wrtie to file
    	mul	a6, a4, a4
    	slli	a2, a6, 1
    	add	a2, a2, a6
    	ecall
   	# Close BMP file
   	mv	a0, a5
    	li  	a7, close_file        # system call close file
    	ecall
end:
	li	a7, sys_exit
	ecall
