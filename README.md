# PLSQL-PGSQL

## Descripción
Sobre el esquema SCOTT, cuyas tablas son:

- DEPT

| Columna | tipo de dato | Restricción |
| --- | --- | --- |
| DEPTNO | NUMBER(2) | NOT NULL |
| DNAME | VARCHAR2(14) | NOT NULL |
| LOC | VARCHAR2(13) | NOT NULL |

- EMP

| Columna | tipo de dato | Restricción |
| --- | --- | --- |
| EMPNO | NUMBER(4) | NOT NULL |
| ENAME | VARCHAR2(10) | NOT NULL |
| JOB | VARCHAR2(9) | NOT NULL |
| MGR | NUMBER(4) | NULL |
| HIREDATE | DATE | NOT NULL |
| SAL | NUMBER(7,2) | NOT NULL |
| COMM | NUMBER(7,2) | NULL |
| DEPTNO | NUMBER(2) | NOT NULL |

Y haciendo uso de los permisos del usuario **sysdba** en oracle, vamos a realizar los siguientes enunciados.

## Enunciados

1. Hacer un procedimiento que muestre el nombre y el salario del empleado cuyo código es 7782.

2. Hacer un procedimiento que reciba como parámetro un código de empleado y devuelva su nombre.

3. Hacer un procedimiento que devuelva los nombres de los tres empleados más antiguos.

4. Hacer un procedimiento que reciba el nombre de un tablespace y muestre los nombres de los usuarios que lo tienen como tablespace por defecto (Vista DBA_USERS).

5. Modificar el procedimiento anterior para que haga lo mismo pero devolviendo el número de usuarios que tienen ese tablespace como tablespace por defecto. Nota: Hay que convertir el procedimiento en función.

6. Hacer un procedimiento llamado MostrarUsuarioPorTablespace que muestre por pantalla un listado de los tablespaces existentes con la lista de usuarios de cada uno y el número de los mismos, así: (Vistas DBA_TABLESPACES y DBA_USERS) 

Tablespace xxxx:

	Usr1
	Usr2
	...

Total Usuarios Tablespace xxxx: n1

Tablespace yyyy:

	Usr1
	Usr2
	...

Total Usuarios Tablespace yyyy: n2
....
Total Usuarios BD: nn.

7. Hacer un procedimiento llamado MostraCodigoFuente que reciba el nombre de otro procedimiento y muestre su código fuente. (DBA_SOURCE)

8. Hacer un procedimiento llamado MostrarPrivilegiosUsuario que reciba el nombre de un usuario y muestre sus privilegios de sistema y sus privilegios sobre objetos. (DBA_SYS_PRIVS y DBA_TAB_PRIVS).

9. Realiza un procedimiento llamado ListarComisiones que nos muestre por pantalla un listado de las comisiones de los empleados agrupados según la localidad donde está ubicado su departamento con el siguiente formato: 
Localidad NombreLocalidad
    Departamento: NombreDepartamento
        Empleado1 ……. Comisión 1
        Empleado2 ……. Comisión 2
        .
        .
        .
        Empleadon ……. Comision n
    Total Comisiones en el Departamento NombreDepartamento: SumaComisiones
    Departamento: NombreDepartamento
        Empleado1 ……. Comisión 1
        Empleado2 ……. Comisión 2
        .
        .
        .
        Empleadon ……. Comision n
    Total Comisiones en el Departamento NombreDepartamento: SumaComisiones
    .
    .
Total Comisiones en la Localidad NombreLocalidad: SumaComisionesLocalidad
Localidad NombreLocalidad
.
.
Total Comisiones en la Empresa: TotalComisiones
    
Nota: Los nombres de localidades, departamentos y empleados deben aparecer por orden alfabético.

Si alguno de los departamentos no tiene ningún empleado con comisiones, aparecerá un mensaje informando de ello en lugar de la lista de empleados.

El procedimiento debe gestionar adecuadamente las siguientes excepciones:
    a) La tabla Empleados está vacía.
    b) Alguna comisión es mayor que 10000.

10. Realiza un procedimiento que reciba el nombre de una tabla y muestre los nombres de las restricciones que tiene, a qué columna afectan y en qué consisten exactamente. (DBA_TABLES, DBA_CONSTRAINTS, DBA_CONS_COLUMNS).

11. Realiza al menos dos de los ejercicios anteriores en Postgres usando PL/pgSQL. (En mi caso, lo he realizado del procedimiento TresMásAntiguos y ListarComisiones, que son los ejercicios 3 y 9 respectivamente).# PLSQL-PGSQL
