@ Maria Isabel Ortiz Naranjo
@ Douglas de León 
@ Carnet: 18176
@ Carnet: 18037
@Proyecto#4
@ 17/05/2019

@ ----------------------------------
@ Build:
@ gcc -o 4 proyecto4.s gpio0_2.s phys_to_virt.c timerLib.c timer.s
@ -----------------------------------

.text
.align 2
.global main
.type main,%function

main: 
    stmfd sp!, {lr}

@utilizando la biblioteca GPIO (gpio0.s)
bl GetGpioAddress     @solo se llama una vez

@Botón 
@GPIO para lectura (entrada) puerto 2
mov r0,#2
mov r1,#0
bl SetGpioFunction

@Botón
@GPIO para lectura (entrada) puerto 3
mov r0,#3
mov r1,#0
bl SetGpioFunction

@Botón
@GPIO para lectura (entrada) puerto 4
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

@Display2
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
    @@Apagar LED.
    mov r0,#17
    mov r1,#0
    bl SetGpio

    ldr r0, =mensaje_ingreso
    bl puts

    bl getchar
    mov r4,r0

    mov r5,r4

    @@Por software
    cmp r5,#0x31    @Comparar con '1'
    moveq r11,#10
    beq unSegundo

    @@Por hardware
    cmp r5,#0x32    @Comparar con '2'
    moveq r11,#6
    beq dosSegundos

    cmp r5,#0x33    @Comparar con '3'
    beq fin

    b error_ingreso

Software:
    @Ingreso decenas.
    ldr r0,=ingreso_decenas
    bl puts
    ldr r0,=formatoD
    ldr r1,=ingreso
    bl scanf

    strb r11,[r1]

    @Ingreso unidades.
    ldr r0,=ingreso_unidades
    bl puts
    
    ldr r0,=formatoD
    ldr r1,=ingreso
    bl scanf

    strb r10,[r1]

    cmp r10,#0
    ble encenderLED 





    

Hardware:

encenderLED:
    @@Apagar LED.
    mov r0,#17
    mov r1,#1
    bl SetGpio

    bl retro
    bl retro

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
.global myloc

myloc: .word 0

ingreso_decenas: .asciz "Ingrese las decenas. "

ingreso_unidades: .asciz "Ingreso unidades. "

mensaje_debug: .asciz "Debug"

mensaje_error: .asciz "El dato que ingresó no es válido. "

mensaje_ingreso:
    .asciz "Ingrese una opción: "

formatoD: .asciz "%d"

ingreso: .byte 0

salir: 
    .asciz "Se ha salido del programa "