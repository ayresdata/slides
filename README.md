# slides

## Como organizar este repo

Los templates van en `templates`. En el caso de querer incluir slides, seguir la siguiente jerarquía de directorios:

```
Año/Tecnología/Conferencia_o_evento.
```

Por ejemplo, una presentación en el PL del 2017 sobre Postgres, debería ser: `2017/Postgres/PLSC17/`.

Para los PDF, se recomienda usar un subdirectorio llamado `output` (para evitar templates y pdfs en el mismo directorio).


# A futuro

A futuro vamos a usar Latex, pero para salir al ruedo vamos a usar markdown.

# Tool

La tool que permitía CSS y me pareció la más  limpia fue: 

https://github.com/partageit/markdown-to-slides
https://github.com/pwlmaciejewski/markdown-html

# Generar slides

Para generar slides basta con ejecutar _make_ en la raíz del repositorio. Los slides en HTML se guardan en el directorio _output_ con la misma jerarquía de directorios que la original.

