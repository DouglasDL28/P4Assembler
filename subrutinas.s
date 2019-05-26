
.global Division
Division:
contador    .req r1
divisor     .req r5
dividendo   .req r0

mov contador,#0 @inicializar contador
mov divisor,#10
ciclo:
cmp divisor, dividendo
bgt fin
sub dividendo,divisor
add contador,#1
b ciclo
fin:
.unreq contador
.unreq dividendo
.unreq divisor
mov r1,r0   @guarda el residuo
mov r0,r2   @guarda el cociente
mov pc,lr

.global GetGpio
GetGpio:
@Revision del boton
@Para revisar si el nivel de un GPIO esta en alto o bajo
@se lee en la direccion 0x3F200034 para los GPIO 0-31

push {lr}
ldr r6, =myloc
ldr r8, [r6]        @ obtener direccion de la memoria virtual
ldr r5,[r8,#0x34]    @Direccion r0+0x34:lee en r5 estado de puertos de entrada
mov r7,#1
lsl r7,r0
and r5,r7         @se revisa el bit 14 (puerto de entrada)
mov r0,r5

pop {pc}

