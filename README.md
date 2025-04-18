# Imperial Russian Court Roleplay System

Sistema avanzado de scripts LSL para roleplay de la Corte Imperial Rusa en Second Life, combinando tecnologías interactivas sofisticadas con mecánicas de simulación social dinámicas. Ambientado en la Rusia de 1905, este sistema ofrece una experiencia inmersiva que reproduce el funcionamiento de la Corte Imperial Rusa con precisión histórica.

![Sistema de la Corte Imperial Rusa](https://imgur.com/placeholder.jpg)

## Estructura del Repositorio

Este repositorio está organizado en las siguientes secciones:

```
scripts/
├── core/            # Scripts principales del sistema
├── huds/            # HUDs para diferentes personajes y roles
├── systems/         # Sistemas funcionales (combate, economía, etc.)
├── modules/         # Módulos complementarios (artes, familia, etc.)
├── objects/         # Objetos interactivos del entorno
└── documentation/   # Guías de instalación y uso
```

## Tecnologías Clave
- Scripting LSL para integración con Second Life
- Notecards para almacenamiento persistente de datos
- Sistema de interacción en tiempo real para jugadores
- Mecánicas completas de roleplay con múltiples estadísticas
- Soporte multi-idioma (inglés y español)

## Módulos Principales
- **Sistema de Estadísticas:** Muestra las estadísticas del jugador como texto flotante
- **HUDs Específicos:** HUDs especializados para cada miembro de la familia Romanov
- **Sistema Económico:** Manejo de rublos y transacciones bancarias
- **Sistema Religioso:** Artefactos religiosos y mecánicas de resurrección
- **Sistema de Combate:** Mecánicas de combate para duelos y conflictos
- **Sistema Cultural:** Módulos de artes, literatura, música y baile

## Características Históricas
- Condición de hemofilia para el Zarevich Alexei que requiere atención médica especial
- Los jugadores deben comer y beber para mantener la salud
- Resurrección a través de artefactos religiosos (íconos) con mecánicas de fe
- Sistema de herencia familiar - si un jugador muere, el siguiente en la línea familiar hereda todo
- Completo sistema económico con moneda de rublos rusos y banca
- Facciones políticas con mecánicas de lealtad
- Fantasma interactivo de Ekaterina que proporciona información histórica
- Métricas de salud afectadas por veneno, requiriendo intervención de médicos
- Más de 50 objetos interactivos distribuidos por el entorno de juego

## Instalación

1. Descarga los scripts desde la [página de releases](https://github.com/yourusername/imperial-russian-court/releases)
2. Sigue las instrucciones en la [guía de instalación](scripts/documentation/Imperial_Russian_Court_Installation_Guide.html)

## Servidor de Descarga

También puedes acceder a los scripts a través del servidor de descarga incluido en este repositorio:

```
# Instalar dependencias
pip install flask

# Ejecutar el servidor
python download_server.py
```

Luego navega a `http://localhost:5000` para acceder a la interfaz de descarga.

## Contribuciones

¡Las contribuciones son bienvenidas! Por favor lee [CONTRIBUTING.md](CONTRIBUTING.md) para obtener detalles sobre nuestro código de conducta y el proceso para enviarnos pull requests.

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.