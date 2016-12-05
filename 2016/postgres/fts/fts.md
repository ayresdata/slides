#FTS (*F*ull *T*ext *S*earch)

<footer>
abel.osorio @ ayres.io Data Team
</footer>

---
## Prerequisitos

* PostgreSQL.

---
## Búsqueda de texto
### Operadores más conocidos: `=`, `~`, `~*`, `LIKE`, `ILILKE`.

```
postgres=# SELECT 'tortuga' = 'tortuga', 'tortuga' ~ 'tor*', 'tortuga' ~* 'tor', 'tortuga' LIKE '%uga', 'tortuga' ILIKE '%UGA';
 ?column? | ?column? | ?column? | ?column? | ?column? 
----------+----------+----------+----------+----------
 t        | t        | t        | t        | t
(1 fila)
```

---
## Problemas con estos operadores

* No tienen soporte lingüístico. Se hace complicado buscar derivados de una palabra, ej: camino, caminar, caminando...
* No proveen un orden (_ranking_) de los resultados de búsqueda.
* Falta de índices.

---
## FTS al rescate!

```
postgres=# SELECT plainto_tsquery('spanish', 'yo vender gato') @@ to_tsvector('spanish', 'Yo vendo un gato');
 ?column? 
----------
 t
(1 fila)
```

---
## ¿Cómo funciona?

* Tokens
* Lexems
* Query

---
## Índices

---
## ¿Preguntas?


**Ayres Data Team**