// IMPERIAL COURT HUD - VERSIÓN ULTRA BÁSICA
// Este script se enfoca únicamente en la detección de toques
// Para diagnosticar problemas con la detección de eventos touch

// SOLO UNA VARIABLE GLOBAL
integer gToques = 0;

// UN SOLO ESTADO PARA MAYOR SIMPLICIDAD
default
{
    state_entry()
    {
        // Mensaje de bienvenida
        llOwnerSay("IMPERIAL COURT HUD - VERSIÓN DIAGNÓSTICO");
        llOwnerSay("TOQUE el objeto para probar detección de eventos");
        
        // Texto flotante visible
        llSetText("TOQUE AQUÍ\n(Touch Test v1.0)", <1.0, 0.0, 0.0>, 1.0);
    }

    // EVENTO TOUCH - VERSIÓN SIMPLIFICADA AL MÁXIMO
    touch_start(integer num)
    {
        // Incrementar contador
        gToques++;
        
        // Mostrar información
        llOwnerSay("¡TOQUE DETECTADO! Total: " + (string)gToques);
        llOwnerSay("Tocado por: " + llDetectedName(0));
        
        // Cambiar color para confirmar visualmente
        llSetColor(<0.0, 1.0, 0.0>, ALL_SIDES);
        
        // Mostrar opciones básicas
        llDialog(llGetOwner(), 
                "Toque detectado exitosamente.\n¿Qué desea hacer?", 
                ["Reiniciar", "Salir", "Prueba"], -99999);
        
        // Timer para restaurar color
        llSetTimerEvent(1.0);
    }
    
    // TIMER PARA RESTAURAR APARIENCIA
    timer()
    {
        llSetColor(<1.0, 1.0, 1.0>, ALL_SIDES);
        llSetTimerEvent(0.0);
    }
    
    // ESCUCHAR RESPUESTAS
    listen(integer channel, string name, key id, string message)
    {
        if (id == llGetOwner())
        {
            if (message == "Reiniciar")
            {
                llOwnerSay("Reiniciando script...");
                llResetScript();
            }
            else if (message == "Prueba")
            {
                llOwnerSay("Prueba confirmada. Los eventos touch funcionan correctamente.");
            }
        }
    }
    
    // CONFIGURACIÓN AL APARECER
    on_rez(integer start)
    {
        llResetScript();
    }
}