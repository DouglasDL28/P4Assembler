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

decenas     .req r10
unidades    .req r11

@Botón DECENAS
@GPIO para lectura (entrada) puerto 2
mov r0,#2
mov r1,#0
bl SetGpioFunction

@Botón UNIDADES
@GPIO para lectura (entrada) puerto 3
mov r0,#3
mov r1,#0
bl SetGpioFunction

@Botón INICIO
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
    @Iniciar
    mov decenas,#0  @Decenas
    mov unidades,#0  @Unidades

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

    strb r9,[r1]

    cmp r9,#100
    bge error_ingreso

    mov r0,decenas
    lrd r1,=puertosDecenas
    bl SetDisplay

    mov r0,unidades
    lrd r1,=puertosUnidades
    bl SetDisplay

    @Dividir para obtener decenas y unidades.
    mov r0,r9
    bl Division

    mov decenas,r0     @ COCIENTE / DECENAS
    mov unidades,r1     @ RESIDUO / UNIDADES

    cicloUnidadesSoftware:
        sub unidades,#1

        bl retro

        @Cambiar display unidades
        mov r0,unidades
        lrd r1,=puertosUnidades
        bl SetDisplay

        cmp unidades,#0
        beq cicloDecenasSoftware
        b cicloUnidadesSoftware

    cicloDecenasSoftware:
        sub decenas,#1
        mov unidades,#9

        @Cambiar Display decenas
        mov r0,decenas
        lrd r1,=puertosDecenas
        bl SetDisplay

        @Cambiar Display unidades
        mov r0,unidades
        lrd r1,=puertosUnidades
        bl SetDisplay

        cmp decenas,#0
        blt completado
        b cicloUnidadesSoftware


Hardware:
    @@ Verificar botón de decenas
    mov r0,#2
    bl GetGpio
    mov r5,r0
    cmp r5,#0
    bne sumaDecenas

    @@ Verificar botón de unidades
    mov r0,#3
    bl GetGpio
    mov r5,r0
    cmp r5,#0
    bne sumaUnidades

    @@ Verificar botón de decenas
    mov r0,#4
    bl GetGpio
    mov r5,r0
    cmp r5,#0
    bne cicloUnidadesHardware

    sumaDecenas:
        cmp decenas,#9
        addlt decenas,#1
        movge decenas,#0

        @Cambiar Display decenas
        mov r0,decenas
        lrd r1,=puertosDecenas
        bl SetDisplay

    sumaUnidades:
        @Suma a unidades
        cmp unidades,#9
        addlt unidades,#1
        movge unidades,#0

        @Cambiar Display unidades
        mov r0,unidades
        lrd r1,=puertosUnidades
        bl SetDisplay

        b Hardware

    cicloUnidadesHardware:
        sub unidades,#1

        bl retro

        @Cambiar Display unidades
        mov r0,unidades
        lrd r1,=puertosUnidades
        bl SetDisplay

        cmp unidades,#0
        beq cicloDecenasHardware
        b cicloUnidadesHardware

    cicloDecenasHardware:
        sub decenas,#1
        mov unidades,#9

        @Cambiar Display decenas
        mov r0,decenas
        lrd r1,=puertosDecenas
        bl SetDisplay

        @Cambiar Display unidades
        mov r0,unidades
        lrd r1,=puertosUnidades
        bl SetDisplay

        cmp decenas,#0
        blt completado
        b cicloUnidadesHardware


completado:

    @Display decenas en 0
    mov r0,#0
    ldr r1,=puertosDecenas
    bl SetDisplay

    @Display unidades en 0
    mov r0,#0
    ldr r1,=puertosUnidades
    bl SetDisplay

    @@Encender LED.
    mov r0,#17
    mov r1,#1
    bl SetGpio

    bl retro
    bl retro
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


@Subrutina
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


.data
.align 2
.global myloc
.global puertosDecenas
.global puertosUnidades

myloc: .word 0

ingreso_numero:    .asciz "Ingrese un número (0-99). "

ingreso_unidades:   .asciz "Ingreso unidades. "

mensaje_debug:      .asciz "Debug"

mensaje_error:      .asciz "El dato que ingresó no es válido. "

mensaje_ingreso:    .asciz "Ingrese una opción: "

formatoD: .asciz "%d"

ingreso: .word 0

salir: .asciz "Se ha salido del programa. "

puertosDecenas:     .word 27,22,14,15

puertosUnidades:    .word 18,25,8,7

mov r0,#9
ldr r1,=puertosDecenas
bl SetDisplay

0110

