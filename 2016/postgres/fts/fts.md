#FTS (*F*ull *T*ext *S*earch)

<br>
<br>
<br>
<br>
<br>
<br>
<br>

abel.osorio @ ayres.io Data Team

---
## Prerequisitos

* PostgreSQL 8.3 o superior.

---
## Búsqueda de texto
### Operadores más conocidos: `=`, `~`, `~*`, `LIKE`, `ILIKE`.

```sql
postgres=# SELECT 'tortuga' = 'tortuga',
                  'tortuga' ~ 'tor*',
                  'tortuga' ~* 'tor',
                  'tortuga' LIKE '%uga',
                  'tortuga' ILIKE '%UGA';

 ?column? | ?column? | ?column? | ?column? | ?column? 
----------+----------+----------+----------+----------
 t        | t        | t        | t        | t
(1 fila)
```

---
## Problemas con estos operadores

* No tienen soporte lingüístico. Se hace complicado buscar derivados de una palabra, ej: camino, caminar, caminando...

* No proveen un orden (_ranking_) por relevancia de los resultados de búsqueda.

* Falta de índices. ¿Por qué? Si quisierámos, podríamos indexar la búsqueda de `LIKE '%gatos'`. ¿Y si ahora queremos buscar por `LIKE 'gatos%'`? habría que crear otro índice...

---
## FTS al rescate!

**FTS** o **Full Text Search** es una técnica de búsqueda de una o más _cadenas_ en un _documento_ **por similitud** y, opcionalmente, permite ordenar los resultados de la búsqueda por relevancia.

Un _documento_ es la unidad de búsqueda, por ejemplo: un post, un e-mail, una cadena de texto, una columna de una tabla... etc.

---
## ¿Cómo funciona?

* Representa al documento con el tipo _tsvector_.

* Y a la cadena (más específicamente _query_) con el tipo _tsquery_.

* Finalmente accede a _FTS_ utilizando el operador _@@_, el cual retorna _true_ si un _tsvector_ verifica un _tsquery_.

---
## ¿Cómo funciona?
### _tsvector_

Contiene una representación normalizada del _documento_.

Por ejemplo, para llevar la cadena "Los gatos más curiosos" a _tsvector_ PostgreSQL:

1. Identifica los _tokens_ (palabras, números, etc).

2. Convierte estos _tokens_ en _lexemas_ (_tokens_ normalizados). En este punto también se eliminan las _stop words_.

3. Almacena toda esta información en un arreglo.

---
## ¿Cómo funciona?
### _tsvector_

```sql
postgres=# SELECT to_tsvector('Los gatos más curiosos');
    to_tsvector     
--------------------
 'curios':4 'gat':2
(1 fila)
```

---
## ¿Cómo funciona?
### _tsquery_

Contiene los términos de búsqueda (conjunto de lexemas) y opcionalmente se pueden combinar con los operadores _AND_ (_&_), _OR_ (_|_), y _NOT_ (_!_).

```sql
postgres=# SELECT to_tsvector('Los gatos más curiosos') @@ 'curios & gat'::tsquery;
 ?column? 
----------
 t
(1 fila)

postgres=# SELECT to_tsvector('Los gatos más curiosos') @@ 'curios & ! gat'::tsquery;
 ?column? 
----------
 f
(1 fila)
```

---
## ¿Cómo funciona?

Notar que el orden de los factores es indistinto y que se puede usar cualquier diccionario (por defecto PostgreSQL utiliza el _simple_):

```sql
postgres=# SELECT plainto_tsquery('spanish', 'yo vender gato') @@ to_tsvector('spanish', 'Yo vendo un gato');
 ?column? 
----------
 t
(1 fila)

postgres=# SELECT plainto_tsquery('english', 'I sell a cat') @@ to_tsvector('english', 'sell cat');
 ?column? 
----------
 t
(1 fila)
```

---
## Índices
### _GIN_ vs _GiST_

PostgreSQL recomienda GIN para indexar campos de tipo _tsvector_.

#### GIN

- Almacena los lexemas (sin posición).
- Tarda 3 veces más que GiST en generar el índice.

#### GiST
- Guarda un hash de ancho fijo, pudiendo generar el mismo para 2 vectores distintos.
- Tarda 3 veces más en buscar por el índice.

---
## Índices
### Playtime

En este ejemplo se utiliza una base de datos de **IMDB**.

```sql
postgres=# SELECT count(*) FROM movie_info;
  count  
---------
 8596642
(1 fila)

postgres=# SELECT count(*) FROM char_name;
  count  
---------
 2261485
(1 fila)
```

---
## Índices
### Playtime

Busquemos las películas que tengan "movie of a boy" en su descripción... SIN ÍNDICE!

```sql
postgres=# EXPLAIN ANALYZE
           SELECT info
             FROM movie_info
             WHERE to_tsvector('english', info) @@ plainto_tsquery('english', 'movie of a boy');
```

_Enter_ y...

---

```
                         / / / /
                         \ \ \ \
                     |   / / / /   |
                     |~~~~~~~~~~~~~| __
                     |             |/  \
                     |  Cafecito?  |   /
                     |             |  /
                     |             |_/
                     \_____________/
```

---
## Índices
### Playtime

Bueno... no tardó tanto!

```sql
postgres=# EXPLAIN ANALYZE
           SELECT info
             FROM movie_info
             WHERE to_tsvector('english', info) @@ plainto_tsquery('english', 'movie of a boy');
                                                    QUERY PLAN
-------------------------------------------------------------------------------------------------------------------
 Seq Scan on movie_info  (cost=0.00..225222.63 rows=215 width=45) (actual time=61.134..91796.849 rows=889 loops=1)
   Filter: (to_tsvector('english'::regconfig, info) @@ '''movi'' & ''boy'''::tsquery)
   Rows Removed by Filter: 8595753
 Planning time: 13.482 ms
 Execution time: 91797.087 ms
(5 filas)

```

---
## Índices
### Playtime

```sql
postgres=# SELECT CURRENT_TIMESTAMP;
           CREATE INDEX ON movie_info USING GIN (to_tsvector('english', info));
           SELECT CURRENT_TIMESTAMP;
```

---
## Índices
### Playtime

```sql
postgres=# SELECT CURRENT_TIMESTAMP;
           CREATE INDEX ON movie_info USING GIN (to_tsvector('english', info));
           SELECT CURRENT_TIMESTAMP;

              now              
-------------------------------
 2016-12-06 17:34:37.715389-03
(1 fila)

CREATE INDEX
              now              
-------------------------------
 2016-12-06 17:36:53.622951-03
(1 fila)

```

---
## Índices
### Playtime

```sql
postgres=# EXPLAIN ANALYZE
           SELECT info
             FROM movie_info
             WHERE to_tsvector('english', info) @@ plainto_tsquery('english', 'movie of a boy');
                                                               QUERY PLAN                                                                
-----------------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on movie_info  (cost=37.67..870.41 rows=215 width=45) (actual time=3.213..4.011 rows=889 loops=1)
   Recheck Cond: (to_tsvector('english'::regconfig, info) @@ '''movi'' & ''boy'''::tsquery)
   Heap Blocks: exact=851
   ->  Bitmap Index Scan on movie_info_to_tsvector_idx1  (cost=0.00..37.61 rows=215 width=0) (actual time=3.130..3.130 rows=889 loops=1)
         Index Cond: (to_tsvector('english'::regconfig, info) @@ '''movi'' & ''boy'''::tsquery)
 Planning time: 0.089 ms
 Execution time: 4.084 ms
(7 filas)

```

---
## Orden por relevancia
### _ts_rank()_

Ordena los resultados según la frecuencia con la que aparecen los lexemas en el documento.

`ts_rank([ weights float4[], ] vector tsvector, query tsquery [, normalization integer ]) returns float4`

---
## Orden por relevancia
### _ts_rank()_

Vamos a verlo con la tabla _char_name_. Pero antes indexémosla:

```sql
postgres=# SELECT CURRENT_TIMESTAMP;
           CREATE INDEX ON char_name USING GIN (to_tsvector('english', name));
           SELECT CURRENT_TIMESTAMP;
              now              
-------------------------------
 2016-12-06 18:17:59.381113-03
(1 fila)

CREATE INDEX
              now              
-------------------------------
 2016-12-06 18:18:19.331772-03
(1 fila)

```

---
## Orden por relevancia
### _ts_rank()_

```sql
postgres=# SELECT name
             FROM char_name
             WHERE to_tsvector('english', name) @@ plainto_tsquery('english', 'uncle john')
             ORDER BY ts_rank(to_tsvector('english', name),
                              plainto_tsquery('english', 'uncle john'))
                   DESC
             LIMIT 10;
               name                
-----------------------------------
 John S. 'Uncle John' Copeland
 Uncle John Adams
 Uncle John
 Uncle John Henry Carson
 Uncle John Shaft's girlfriend
 Uncle John Lyman
 Uncle John Burgess
 Uncle John Shaft
 Uncle John's Button Man #1
 Uncle John Lee Davis
(10 filas)

```

---
## Para seguir leyendo!

- _ts_headline_ permite marcar los términos de la búsqueda en el documento.
- _ts_stat_ permite obtener estadísticas de las ocurrencias de un _tsquery_ dentro de un documento.
- Configuración de FTS.

Y mucho más en https://www.postgresql.org/docs/current/static/textsearch.html.

---
## Fin

Gracias por su tiempo, **Ayres Data Team**.<br><br>

<p style="text-align:center">¿Preguntas?</p>