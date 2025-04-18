// Imperial Russian Court - Sistema de Combate Simplificado
// Rusia Imperial 1905

// URL del servidor (cambia esto a la URL de tu servidor Replit)
string SERVER_URL = "https://tu-nombre-de-usuario.replit.app";

// Variables del sistema de combate
integer weapon_damage = 10; // Daño base del arma
string weapon_type = "Sable"; // Tipo de arma
string weapon_owner = ""; // UUID del dueño
string weapon_owner_name = ""; // Nombre del dueño

// Configuración de idioma
string language = "ES"; // Por defecto español

// Funciones de combate
makeHttpRequest(string method, string endpoint, string data) {
    string url = SERVER_URL + endpoint;
    llHTTPRequest(url, [HTTP_METHOD, method, HTTP_MIMETYPE, "application/json"], data);
}

// Función para aplicar daño a un personaje
applyDamage(key target_id, integer amount) {
    string json = llList2Json(JSON_OBJECT, [
        "amount", (string)amount
    ]);
    
    makeHttpRequest("POST", "/api/players/" + (string)target_id + "/damage", json);
}

// Función para mostrar texto localizado
string getTranslatedText(string key) {
    if (key == "weapon_equipped") {
        if (language == "EN") return "Combat weapon equipped. Type: ";
        return "Arma de combate equipada. Tipo: ";
    }
    else if (key == "select_language") {
        if (language == "EN") return "Select your preferred language:";
        return "Selecciona tu idioma preferido:";
    }
    else if (key == "spanish") {
        return "Español";
    }
    else if (key == "english") {
        return "English";
    }
    else if (key == "damage_applied") {
        if (language == "EN") return "You have inflicted damage to ";
        return "Has infligido daño a ";
    }
    else if (key == "amount") {
        if (language == "EN") return "Amount: ";
        return "Cantidad: ";
    }
    else if (key == "attack_missed") {
        if (language == "EN") return "The attack missed.";
        return "El ataque falló.";
    }
    else if (key == "combat_help") {
        if (language == "EN") return "COMBAT HELP\n\nTouch the weapon to equip it.\nClick on a player to attack them.\nSay '/damage X' to set damage (X = amount).\n\nCurrent damage: ";
        return "AYUDA DE COMBATE\n\nToca el arma para equiparla.\nHaz clic en un jugador para atacarle.\nDi '/damage X' para establecer el daño (X = cantidad).\n\nDaño actual: ";
    }
    
    return key;
}

default {
    state_entry() {
        llSetText(weapon_type, <1.0, 0.0, 0.0>, 1.0);
    }
    
    touch_start(integer total_number) {
        key toucher = llDetectedKey(0);
        
        // Si no está equipada, equipar el arma
        if (weapon_owner == "") {
            weapon_owner = (string)toucher;
            weapon_owner_name = llKey2Name(toucher);
            llOwnerSay(getTranslatedText("weapon_equipped") + weapon_type);
            
            // Preguntar idioma
            llDialog(toucher, getTranslatedText("select_language"), 
                [getTranslatedText("spanish"), getTranslatedText("english")], 999);
        }
        // Si ya está equipada, mostrar ayuda
        else if ((string)toucher == weapon_owner) {
            llOwnerSay(getTranslatedText("combat_help") + (string)weapon_damage);
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        // Manejar selección de idioma
        if (channel == 999) {
            if (message == "Español") {
                language = "ES";
                llOwnerSay(getTranslatedText("combat_help") + (string)weapon_damage);
            }
            else if (message == "English") {
                language = "EN";
                llOwnerSay(getTranslatedText("combat_help") + (string)weapon_damage);
            }
        }
    }
    
    // Atacar al hacer clic
    collision_start(integer num_detected) {
        // Solo el dueño puede atacar
        if (weapon_owner == "") return;
        
        integer i;
        for (i = 0; i < num_detected; i++) {
            key target = llDetectedKey(i);
            
            // No atacar al dueño o a objetos
            if (target == llGetOwner() || !llGetAgentSize(target)) continue;
            
            // Aplicar daño
            applyDamage(target, weapon_damage);
            
            // Informar al usuario
            llOwnerSay(getTranslatedText("damage_applied") + llKey2Name(target) + 
                ". " + getTranslatedText("amount") + (string)weapon_damage);
        }
    }
    
    // Comandos para configurar el arma
    listen(integer channel, string name, key id, string msg) {
        // Solo escuchar al dueño
        if ((string)id != weapon_owner) return;
        
        // Comando para establecer el daño
        if (llGetSubString(msg, 0, 7) == "/damage ") {
            integer amount = (integer)llGetSubString(msg, 8, -1);
            if (amount > 0 && amount <= 100) {
                weapon_damage = amount;
                llOwnerSay(getTranslatedText("amount") + (string)weapon_damage);
            }
        }
    }
    
    on_rez(integer start_param) {
        llResetScript();
    }
}