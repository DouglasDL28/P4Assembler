
.global Division
Division:
contador    .req r2
divisor     .req r1
dividendo   .req r0

mov contador,#0 @inicializar contador

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

push {r1-r12,lr}
ldr r6, =myloc
ldr r8, [r6]        @ obtener direccion de la memoria virtual
ldr r5,[r8,#0x34]    @Direccion r0+0x34:lee en r5 estado de puertos de entrada
mov r7,#1
lsl r7,r0
and r5,r7         @se revisa el bit 14 (puerto de entrada)
mov r0,r5

pop {r1-r12,pc}


.global SetDisplay
SetDisplay:
@Recibe número en R0
@Recibo arreglo en R1

numero          .req r10
array           .req r11
contador        .req r9

push {r0-r12,lr}
mov contador,#4 @Inicializar el contador en 4
mov array,r1
mov numero,r0

recorrido:
LDR r4,[array],#4

mov r8,numero

AND R8,#1
LSR numero,#1

mov r0,r4
mov r1,r8
BL SetGpio

SUB contador,#1

CMP contador,#0
BNE recorrido

.unreq numero
.unreq array
.unreq contador

pop {r0-r12,pc}

