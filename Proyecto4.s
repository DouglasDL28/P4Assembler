@ Maria Isabel Ortiz Naranjo
@ Douglas de León
@ Carnet: 18176
@ Carnet: 18037
@Proyecto#4
@ 17/05/2019

@ ----------------------------------
@ Build:
@ gcc -o 4 Proyecto4.s gpio0_2.s phys_to_virt.c timerLib.c timer.s subrutinas.s
@ -----------------------------------

.text
.align 2
.global main
.type main,%function

main:
stmfd sp!, {lr}

@utilizando la biblioteca GPIO (gpio0.s)
bl GetGpioAddress     @solo se llama una vez

decenas     .req r10
unidades    .req r11

@Botón DECENAS
@GPIO para lectura (entrada) puerto 26
mov r0,#2
mov r1,#0
bl SetGpioFunction

@Botón UNIDADES
@GPIO para lectura (entrada) puerto 19
mov r0,#3
mov r1,#0
bl SetGpioFunction

@Botón INICIO
@GPIO para lectura (entrada) puerto 13
mov r0,#4
mov r1,#0
bl SetGpioFunction

@LED
@GPIO para escritura (salida) puerto 17
mov r0,#17
mov r1,#1
bl SetGpioFunction

@Display1
@GPIO para escritura (salida) puerto 27
mov r0,#27
mov r1,#1
bl SetGpioFunction

@Display1
@GPIO para escritura (salida) puerto 22
mov r0,#22
mov r1,#1
bl SetGpioFunction

@Display1
@GPIO para escritura (salida) puerto 14
mov r0,#14
mov r1,#1
bl SetGpioFunction

@Display1
@GPIO para escritura (salida) puerto 15
mov r0,#15
mov r1,#1
bl SetGpioFunction

@Display2
@GPIO para escritura (salida) puerto 18
mov r0,#18
mov r1,#1
bl SetGpioFunction

@Display20x31
@GPIO para escritura (salida) puerto 25
mov r0,#25
mov r1,#1
bl SetGpioFunction

@Display2
@GPIO para escritura (salida) puerto 8
mov r0,#8
mov r1,#1
bl SetGpioFunction

@Display2
@GPIO para escritura (salida) puerto 7
mov r0,#7
mov r1,#1
bl SetGpioFunction

ciclo:

ldr r0,=menu
bl puts

@Iniciar
mov decenas,#0  @Decenas
mov unidades,#0  @Unidades

@Display decenas en 0
mov r0,#0
ldr r1,=puertosDecenas
bl SetDisplay

@Display unidades en 0
mov r0,#0
ldr r1,=puertosUnidades
bl SetDisplay

@@Apagar LED.
mov r0,#17
mov r1,#0
bl SetGpio

ldr r0, =mensaje_ingreso
bl puts

bl getchar
mov r5,r0

@@Por software
cmp r5,#0x31    @Comparar con '1'
beq Software

@@Por hardware
cmp r5,#0x32    @Comparar con '2'
beq Hardware

@Salir del programa
cmp r5,#0x33    @Comparar con '3'
beq fin

b error_ingreso

Software:
@Ingreso decenas.
ldr r0,=ingreso_numero
bl puts

ldr r0,=formatoD
ldr r1,=ingreso
bl scanf

ldr r1,=ingreso
ldr r9,[r1]

cmp r9,#100
bge error_ingreso

@Dividir para obtener decenas y unidades.
mov r0,r9
mov r1,#10
bl Division

mov decenas,r0     @ COCIENTE / DECENAS
mov unidades,r1     @ RESIDUO / UNIDADES

/*push {r0-r12}
 ldr r0,=impresionD
 mov r1,decenas
 bl printf
 
 ldr r0,=impresionD
 mov r1,unidades
 bl printf
 pop {r0-r12} */

@Display decenas
mov r0,decenas
ldr r1,=puertosDecenas
bl SetDisplay

@Display unidades
mov r0,unidades
ldr r1,=puertosUnidades
bl SetDisplay

bl retro



/*    @Display decenas en 0
 mov r0,#0
 ldr r1,=puertosDecenas
 bl SetDisplay
 
 @Display unidades en 0
 mov r0,#0
 ldr r1,=puertosUnidades
 bl SetDisplay
 */
cicloUnidadesSoftware:
sub unidades,#1

@Display unidades en 0
mov r0,unidades
ldr r1,=puertosUnidades
bl SetDisplay

bl retro

cmp unidades,#0
beq cicloDecenasSoftware
b cicloUnidadesSoftware

cicloDecenasSoftware:
sub decenas,#1
mov unidades,#9

cmp decenas,#0
blt completado

@Display decenas en 0
mov r0,decenas
ldr r1,=puertosDecenas
bl SetDisplay

@Display unidades en 0
mov r0,unidades
ldr r1,=puertosUnidades
bl SetDisplay

bl retro

b cicloUnidadesSoftware


Hardware:

@@Verifica botón decenas
mov r0,#26
bl GetGpio
mov r5,r0

teq r5,#0
bne sumaDecenas

@@Verifica botón unidades
mov r0,#19
bl GetGpio
mov r5,r0
teq r5,#0
bne sumaUnidades

@@Verifica botón inicio
mov r0,#13
bl GetGpio
mov r5,r0
teq r5,#0
bne cicloUnidadesHardware

b Hardware

sumaDecenas:
cmp decenas,#9
addlt decenas,#1
movge decenas,#0

@Cambiar Display decenas
mov r0,decenas
ldr r1,=puertosDecenas
bl SetDisplay
bl retro

b Hardware

sumaUnidades:
@Suma a unidades
cmp unidades,#9
addlt unidades,#1
movge unidades,#0

@Cambiar Display unidades
mov r0,unidades
ldr r1,=puertosUnidades
bl SetDisplay
bl retro

b Hardware

cicloUnidadesHardware:
sub unidades,#1

@Display unidades en 0
mov r0,unidades
ldr r1,=puertosUnidades
bl SetDisplay

bl retro

cmp unidades,#0
beq cicloDecenasHardware
b cicloUnidadesHardware

cicloDecenasHardware:
sub decenas,#1
mov unidades,#9

cmp decenas,#0
blt completado

@Display decenas en 0
mov r0,decenas
ldr r1,=puertosDecenas
bl SetDisplay

@Display unidades en 0
mov r0,unidades
ldr r1,=puertosUnidades
bl SetDisplay

bl retro

b cicloUnidadesHardware


completado:

@Display decenas en 0
@mov r0,#0
@ldr r1,=puertosDecenas
@bl SetDisplay

@Display unidades en 0
@mov r0,#0
@ldr r1,=puertosUnidades
@bl SetDisplay

@@Encender LED.
mov r0,#17
mov r1,#1
bl SetGpio

bl retro
bl retro
bl retro
bl retro

bl getchar
b ciclo


error_ingreso:
ldr r0, =mensaje_error
bl puts

bl getchar
b ciclo

fin:
ldr r0, =salir
bl puts

mov r7,#1
swi 0

.data
.align 2

.global puertosDecenas
.global puertosUnidades
.global impresionD

menu:   .asciz "MENU: \n 1. Prueba por Software. \n 2. Prueba por Hardware \n 3. Salir."

mensaje_decenas: .asciz "Decenas: "

mensaje_unidades: .asciz "Unidades: "

ingreso_numero:    .asciz "Ingrese un número (0-99). "

ingreso_unidades:   .asciz "Ingreso unidades. "

mensaje_debug:      .asciz "Debug"

mensaje_error:      .asciz "El dato que ingresó no es válido. "

mensaje_ingreso:    .asciz "Ingrese una opción: "

formatoD: .asciz    "%d"

impresionD: .asciz  "%d \n"

ingreso: .word 0

salir: .asciz "Se ha salido del programa. "

puertosDecenas:     .word 27,22,14,15

puertosUnidades:    .word 18,25,8,7

.global myloc
myloc: .word 0
.end

