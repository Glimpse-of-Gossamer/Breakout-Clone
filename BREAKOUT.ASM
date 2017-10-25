.model tiny
.stack
.code
start:
	cli
	mov ax,1234h        
	mov ax,cs
	mov ds,ax           
	mov ax, 0b800h
	mov es, ax

;variables galore!
	blockx dw 23
	blocky dw 480
	count dw 0
	count2 dw 0
	ballx dw 81	
	bally dw 1600
	paddx dw 67
	paddy dw 3200
	balldx dw 2
	balldy dw 0ff60h
	collidey dw 0

;reset screen
screen:
	mov bx, 0
	add bx, count
	mov si, bx
	add count, 2	

	mov al, 0
	mov [es:si], al

	cmp count, 3840
	jle screen
	add count2, 2
	cmp count2, 160
	jle screen

;draw pins
	mov count, 0
pins:
	mov bx, blockx
	add bx, count
	mov si, bx
	add si, blocky
	add count, 4	

	mov al, 99h
	mov [es:si], al

	cmp count, 80
	jle pins

;draw paddle
	mov count, 0
paddle:
	mov bx, paddx
	add bx, count
	mov si, bx
	add si, paddy
	add count, 2	

	mov al, 33h
	mov [es:si], al

	cmp count, 18
	jle paddle



;movepaddle


delayloop:   

;y boundary
	cmp balldy, 160
	jne otherwise
	cmp bally, 3040
	jne otherwise
	jmp padh
otherwise:	
	cmp bally, 3680
	jl below
	mov ah, 0
	int 21h
;paddle is hit
padh:
	mov bx, paddx
	cmp ballx, bx
	jl above
	mov bx, paddx
	add bx, 20
	cmp ballx, bx
	jg above	
	mov balldy, 0ff60h
below:	
	cmp bally, 160
	jge above
	mov balldy, 160
above:


;x boundary
	cmp ballx, 158
	jle left
	mov balldx, 0FFFEh
left:
	cmp ballx, 2
	jge right
	mov balldx, 2
right:

;remove prev ball
	mov si, ballx
	add si, bally
	
	mov al, 0
	mov [es:si], al

;get new address
	mov bx, ballx
	add bx, balldx
	mov ballx, bx

	mov bx, bally
	add bx, balldy
	mov bally, bx

;draw the ball
	mov si, ballx
	add si, bally

	mov al, 77h
	mov [es:si], al

;timer
	mov cx, 3000h
delay:
	in al,64h;
	and al,1
	jz nokey
	in al, 60h
	cmp al, 4dh
	jz rightm
	cmp al, 4bh
	jz leftm
	jmp clrbuf
rightm:
	mov si, paddx
	add si, paddy
	mov al, 0
	mov [es:si], al
	add paddx, 2
	mov si, paddx
	add si, paddy 
	add si, 18
	mov al, 33h
	mov [es:si], al
	jmp clrbuf
leftm:
	sub paddx, 2
	mov si, paddx
	add si, paddy 
	mov al, 33h
	mov [es:si], al
	mov si, paddx
	add si, paddy 
	add si, 20
	mov al, 0
	mov [es:si], al
	jmp clrbuf
clrbuf:
      	in al,60h
        	in al,64h
        	and al,1     
   	jnz clrbuf
nokey:

	sub cx, 1
	jnz delay 
	jmp delayloop

end