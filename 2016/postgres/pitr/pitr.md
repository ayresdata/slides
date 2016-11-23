<!-- $theme: default -->

# _PITR_ (*P*oint *I*n *T*ime *R*ecovery)  

## _Rebobinando_ PostgreSQL ;)

<BR />

<br />
<br />
<br />
<BR />
<BR />
<BR />
<BR />
gerardo.herzig @ ayres.io Data Team

---

## Prerequisitos:
- SQL
- Linux
- Terminal / shell script

---
## _Backups_
### Los Backups son geniales!!
... (a las 4 am)

![Backup con pg_dump][pg_dump]

---

### Pero los errores suceden...
#### (A toda hora!!)
![Dropeando la tabla principal][drop_table]
Oops!!

---
## PITR - *Implementación básica :: Concepto*
![Imagen conceptual][pitr_concepto]

---
## PITR - *Implementación básica :: Concepto*
![Imagen conceptual][pitr_mas_archive_cmd]

---
## PITR - *Implementación básica :: Concepto*
![Imagen conceptual][pitr_mas_pg_basebackup]

---


## *Configuración* 
En el "master":
- *postgresql.conf:*
   ```bash
   wal_level = archive #o hot_standby
   archive_command = 'rsync %p $BACKUP_IP:/wal_files/%f' ##Ejemplo minimalista!!
   max_wal_senders = 2 # mínimo
   ```
- *pg_hba.conf:*
  ```bash
   #type "database" user     address     auth_method 
   host replication backuper $BACKUP_IP md5 
   ```

- Usuario dedicado:
  ```sql 
  CREATE USER backuper REPLICATION;

  ```

---
## *Mientras tanto...*
En el "archiver":
- Realizamos el filesystem backup (marcando nuestro tiempo 0)
  ```bash
  postgres@archiver:~ pg_basebackup -D $DATA_DIR -Ubackuper -h $MASTER_IP
  ```
  
 Los *WAL* files se acumularán en /wal_files/...los ultizaremos pronto! 

---
## Aplicando *PITR* (finalmente!!)
- Llegado el momento, configuramos al *archiver* para procesar los *WAL* files hasta unos momentos antes del incidente :)
   ```bash
   postgres@archiver:~ cat $DATA_DIR/recovery.conf
   restore_command = 'cp /wal_files/%f %p'
   recovery_target_time = '2016-11-21 14:47:49'
   ```
   
   
- Levantamos el servicio, dejamos que procese los WALs y....
---
![salvados][count]

Tada!!!!! :) :) :)

---
## Como seguir:
- Testear!
- Automatizar
- Monitorear

---

### Podéis hacerme 3 preguntas...

Gracias, espero que os haya iluminado..

Vuelvan prontos!

;)


[pg_dump]: ./img/execute_pgdump.jpg
[drop_table]: ./img/execute_drop_table_4.jpg
[pitr_concepto]: ./img/pitr_concepto.png
[pitr_mas_archive_cmd]:./img/pitr_mas_archive_cmd.png
[pitr_mas_pg_basebackup]:./img/pitr_mas_pg_basebackup.png
[count]: ./img/execute_select_count.jpg



