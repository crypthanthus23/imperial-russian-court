# Contribución al Proyecto

¡Gracias por tu interés en contribuir al sistema de roleplay de la Corte Imperial Rusa!

## Proceso de Contribución

1. Haz un fork del repositorio
2. Crea una rama para tu característica (`git checkout -b feature/nueva-caracteristica`)
3. Haz commit de tus cambios (`git commit -m 'Añadir nueva característica'`)
4. Haz push a la rama (`git push origin feature/nueva-caracteristica`)
5. Abre un Pull Request

## Guías de Estilo LSL

Por favor, adhiere a estas guías cuando contribuyas con scripts LSL:

### Limitaciones de LSL
- No uses operadores ternarios (`? :`) ya que no son compatibles con todas las versiones de LSL
- No uses declaraciones `break` o `continue` dentro de bucles
- No uses `void` como tipo de retorno
- Limita los menús a 12 botones por página para compatibilidad

### Convenciones de Nomenclatura
- Nombra los scripts con el prefijo `Imperial_` seguido del módulo o funcionalidad
- Usa camelCase para nombres de variables y funciones
- Usa MAYÚSCULAS para constantes y canales de comunicación

### Documentación
- Comienza cada script con un encabezado que incluya:
  - Nombre del script
  - Propósito
  - Versión
  - Autor
- Documenta las funciones con una breve descripción de su propósito
- Incluye comentarios para explicar código complejo

## Pruebas
- Todos los scripts deben probarse en Second Life antes de enviar un pull request
- Verifica que no haya errores de tipo o sintaxis
- Comprueba la interoperabilidad con otros scripts del sistema

## Licencia
Al contribuir, aceptas que tus contribuciones estarán bajo la misma licencia que el proyecto.