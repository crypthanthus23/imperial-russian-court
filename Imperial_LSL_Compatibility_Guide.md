# Guía de Compatibilidad LSL para el Sistema de la Corte Imperial Rusa

## Restricciones de Sintaxis en LSL

Linden Scripting Language (LSL) tiene varias limitaciones y restricciones de sintaxis que deben considerarse al modificar o desarrollar scripts para el Sistema de la Corte Imperial Rusa. Esta guía aborda los problemas comunes encontrados y proporciona soluciones compatibles.

### 1. Prohibición de Operadores Ternarios

**Problema:** LSL no admite operadores ternarios (`condición ? valor_si_verdadero : valor_si_falso`).

**Solución:** Reemplazar con estructuras if-else.

```lsl
// INCORRECTO - No funcionará en LSL
integer valor = (a > b) ? a : b;

// CORRECTO - Compatible con LSL
integer valor;
if (a > b)
    valor = a;
else
    valor = b;
```

### 2. No se admite la palabra clave "void"

**Problema:** LSL no utiliza la palabra clave "void" para funciones sin valor de retorno.

**Solución:** Simplemente omitir el tipo de retorno.

```lsl
// INCORRECTO - No funcionará en LSL
void miFuncion() {
    llOwnerSay("Hola");
}

// CORRECTO - Compatible con LSL
miFuncion() {
    llOwnerSay("Hola");
}
```

### 3. No hay sentencias "break" en bucles

**Problema:** LSL no admite la sentencia "break" para salir de bucles.

**Solución:** Usar variables de control o restructurar la lógica.

```lsl
// INCORRECTO - No funcionará en LSL
integer i;
for (i = 0; i < 10; i++) {
    if (algunaCondicion)
        break;
}

// CORRECTO - Compatible con LSL usando variable de control
integer i;
integer continuar = TRUE;
for (i = 0; i < 10 && continuar; i++) {
    if (algunaCondicion)
        continuar = FALSE;
}
```

### 4. Comparación directa de strings

**Problema:** LSL no permite comparación directa de strings con operadores relacionales.

**Solución:** Usar `strcmp()` o `==` para igualdad exacta.

```lsl
// INCORRECTO - No funcionará en LSL para clasificar strings
if (nombre < "Nikolai") {
    // código
}

// CORRECTO - Verificar igualdad
if (nombre == "Nikolai") {
    // código
}

// CORRECTO - Para comparación lexicográfica
if (strcmp(nombre, "Nikolai") < 0) {
    // código
}
```

### 5. Palabras clave reservadas

**Problema:** Palabras como "event" y "key" son reservadas y no pueden usarse como nombres de variables.

**Solución:** Usar nombres alternativos.

```lsl
// INCORRECTO - No funcionará en LSL
key key = llGetOwner();
integer event = 5;

// CORRECTO - Compatible con LSL
key usuario = llGetOwner();
integer evento = 5;
```

### 6. Funciones no existentes

**Problema:** Algunas funciones comunes en otros lenguajes no existen en LSL.

**Solución:** Identificar alternativas correctas.

```lsl
// INCORRECTO - No existe en LSL
llGetText(objectKey);

// CORRECTO - La función equivalente
llGetObjectName();
```

## Problemas Específicos del Sistema Imperial Ruso

### 1. Indices de Sistemas de Partículas

Los sistemas de partículas en LSL requieren índices numéricos exactos. Verificar la documentación oficial de LSL para los valores correctos en funciones como `llParticleSystem()`.

### 2. Comunicación entre Scripts

Para garantizar que todos los componentes del sistema se comuniquen correctamente:

1. Usar el mismo canal base en todos los scripts (el valor por defecto es `-98765`)
2. Seguir estrictamente el formato de mensajes establecido:
   `COMANDO|PARÁMETRO1|PARÁMETRO2|...`
3. Asegurarse de que todos los listeners estén configurados correctamente

### 3. Limitación de 24 Caracteres en Botones de Diálogo

Los botones en cuadros de diálogo LSL no pueden exceder los 24 caracteres. Abreviar textos largos de manera inteligible.

```lsl
// INCORRECTO - Excede el límite de 24 caracteres
llDialog(owner, "Seleccione:", ["Solicitar Audiencia con Su Majestad Imperial"], -98765);

// CORRECTO - Dentro del límite
llDialog(owner, "Seleccione:", ["Audiencia Imperial"], -98765);
```

## Optimizaciones para Second Life

### 1. Gestión de Memoria

LSL tiene un límite estricto de memoria (64KB). Para optimizar:

- Evitar listas excesivamente grandes
- Liberar memoria cuando sea posible (asignar `[]` a listas no utilizadas)
- Considerar la modularidad para distribuir la carga de procesamiento

### 2. Reducción de Lag

Para minimizar el lag en regiones con muchos usuarios:

- Limitar el uso de `llSensor()` y otros métodos de escaneo
- Reducir la frecuencia de temporizadores
- Limitar el número de partículas y otras operaciones intensivas

### 3. Gestión de Canales de Comunicación

Para evitar interferencias con otros sistemas:

- Usar canales negativos grandes (como `-98765`) para reducir colisiones
- Considerar añadir identificadores únicos a mensajes
- Cerrar listeners cuando no sean necesarios

## Herramientas de Diagnóstico

El `Imperial_System_Diagnostics_Module.lsl` puede ayudar a identificar problemas de:

1. Sintaxis LSL en componentes individuales
2. Conectividad entre módulos
3. Interacciones de usuario simuladas

Recomendación: Ejecutar este diagnóstico después de cada modificación significativa del sistema.

---

*Esta guía fue creada para asegurar la compatibilidad y funcionamiento óptimo del Sistema de Juego de Rol de la Corte Imperial Rusa en Second Life.*