/****** BOLETÍN PL/SQL *******/

/* 1. Hacer un procedimiento que muestre el nombre y el salario del empleado cuyo código es 7782. */

CREATE OR REPLACE PROCEDURE mostrar_salario
IS
   v_nombre emp.ename%TYPE;
   v_salario emp.sal%TYPE;
BEGIN
    SELECT ename, sal INTO v_nombre, v_salario
    FROM emp
    WHERE empno='7782';
    DBMS_OUTPUT.PUT_LINE(' Nombre del empleado: ' || v_nombre || '. Salario: ' || v_salario);
END;
/

---Llamamos al procedimiento.
exec mostrar_salario;


/* 2. Hacer un procedimiento que reciba como parámetro un código de empleado y devuelva su nombre. */

CREATE OR REPLACE PROCEDURE mostrar_nombre (p_codemp emp.empno%type)
IS
  v_nombre emp.ename%TYPE;
BEGIN
    SELECT ename INTO v_nombre
    FROM emp
    WHERE empno=p_codemp;
    DBMS_OUTPUT.PUT_LINE('El nombre del empleado es: '|| v_nombre || '.');
END mostrar_nombre;
/

---Llamamos al procedimiento.
EXEC mostrar_nombre('7782');


/* 3. Hacer un procedimiento que devuelva los nombres de los tres empleados más antiguos. */

CREATE OR REPLACE PROCEDURE mostrar_antiguos
IS
  CURSOR c_antiguos IS
    SELECT ename
    FROM emp
    ORDER BY hiredate
    FETCH FIRST 3 ROWS ONLY;
  v_nombre emp.ename%TYPE;
BEGIN
    FOR v_antiguos IN c_antiguos
    LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_antiguos.ename);
    END LOOP;
END;
/

---Llamamos al procedimiento.
exec mostrar_antiguos;


/* 4. Hacer un procedimiento que reciba el nombre de un tablespace y muestre los nombres de los usuarios que lo tienen como tablespace por defecto (Vista DBA_USERS) */

CREATE OR REPLACE PROCEDURE MostrarUsuariosTablespace (p_tablespace VARCHAR2)
IS
    CURSOR c_usuarios IS
        SELECT username
        FROM dba_users
        WHERE default_tablespace=p_tablespace;
    v_acumuser NUMBER:=0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Usuarios: ');
    FOR v_usuarios IN c_usuarios LOOP
        DBMS_OUTPUT.PUT_LINE(CHR(9) || rpad(v_usuarios.username, 10));
        v_acumuser:=v_acumuser+1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(CHR(9) || rpad('Total Usuarios Tablespace ',30) || p_tablespace || ': ' || v_acumuser);
END;
/

---Llamamos al procedimiento.
exec MostrarUsuariosTablespace('USERS');


/* 5. Modificar el procedimiento anterior para que haga lo mismo pero devolviendo el número de usuarios que tienen ese tablespace como tablespace por defecto. Nota: Hay que convertir el procedimiento en función. */

CREATE OR REPLACE FUNCTION num_usuarios_tablespace (p_nom_tablespace VARCHAR2)
RETURN NUMBER
IS
    v_num_usuarios NUMBER;
BEGIN
    SELECT COUNT (username)
    INTO v_num_usuarios
    FROM dba_users
    WHERE default_tablespace=p_nom_tablespace;
    RETURN v_num_usuarios;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No hay usuarios con ese tablespace por defecto.');
    RETURN -1;
END;
/

---Llamamos a la función.
DECLARE 
    v_num_usuarios NUMBER;
BEGIN
    v_num_usuarios:=num_usuarios_tablespace('USERS');
    DBMS_OUTPUT.PUT_LINE('Numero de usuarios: ' || v_num_usuarios);
END;
/


/* 6. Hacer un procedimiento llamado mostrar_usuarios_por_tablespace que muestre por pantalla un listado de los tablespaces existentes con la lista de usuarios de cada uno y el número de los mismos, así: (Vistas DBA_TABLESPACES y DBA_USERS) 

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
Total Usuarios BD: nn */

---Creamos la cabecera del procedimiento.
CREATE OR REPLACE PROCEDURE MostrarCabeceraTablespace
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯');
    DBMS_OUTPUT.PUT_LINE('-¯-¯-¯-¯-¯-¯Usuarios por Tablespaces-¯-¯-¯-¯-¯-');
    DBMS_OUTPUT.PUT_LINE('-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯');
END;
/

---Creamos el procedimiento que muestra los usuarios ingresando el nombre del tablespace.
CREATE OR REPLACE PROCEDURE MostrarUsuariosTablespace (p_tablespace VARCHAR2)
IS
    CURSOR c_usuarios IS
        SELECT username
        FROM dba_users
        WHERE default_tablespace=p_tablespace;
    v_acumuser NUMBER:=0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Usuarios: ');
    FOR v_usuarios IN c_usuarios LOOP
        DBMS_OUTPUT.PUT_LINE(CHR(9) || rpad(v_usuarios.username, 10));
        v_acumuser:=v_acumuser+1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(CHR(9) || rpad('Total Usuarios Tablespace ',30) || p_tablespace || ': ' || v_acumuser);
END;
/

---Creamos el procedimiento que muestra los usuarios totales de la base de datos.
CREATE OR REPLACE PROCEDURE MostrarUsuariosTotales
IS
  CURSOR c_usuarios IS
    SELECT COUNT (username) AS num_usuarios
    FROM dba_users;
    v_num_usuarios NUMBER;
BEGIN
    FOR v_usuarios IN c_usuarios
    LOOP
        DBMS_OUTPUT.PUT_LINE('Total Usuarios BD: ' || v_usuarios.num_usuarios);
    END LOOP;
END;
/

---Creamos el procedimiento final que llama a los dos anteriores para mostrar los usuarios por tablespace y el total de usuarios de la base de datos.
CREATE OR REPLACE PROCEDURE MostrarUsuariosPorTablespace
IS
    CURSOR c_tablespaces IS
        SELECT tablespace_name
        FROM dba_tablespaces;
    v_tablespace dba_tablespaces.tablespace_name%TYPE;
BEGIN
    MostrarCabeceraTablespace;
    FOR v_tablespaces IN c_tablespaces
    LOOP
        DBMS_OUTPUT.PUT_LINE('Tablespace: ' || v_tablespaces.tablespace_name);
        MostrarUsuariosTablespace(v_tablespaces.tablespace_name);
    END LOOP;
    MostrarUsuariosTotales;
END;
/

/* 7. Hacer un procedimiento llamado mostrar_codigo_fuente que reciba el nombre de otro procedimiento y muestre su código fuente. (DBA_SOURCE) */
CREATE OR REPLACE PROCEDURE mostrar_fuente (p_nombre_procedimiento VARCHAR2)
IS
    v_cod_fuente dba_source.text%TYPE;
    cursor c_cod_fuente is
        select text
        from dba_source
        where name = p_nombre_procedimiento;
BEGIN
    for v_cod in c_cod_fuente
    loop
        v_cod_fuente := v_cod.text;
        DBMS_OUTPUT.PUT_LINE(v_cod_fuente);
    END LOOP;
END;
/

exec mostrar_fuente('MOSTRAR_SALARIO');

/* 8. Hacer un procedimiento llamado mostrar_privilegios_usuario que reciba el nombre de un usuario y muestre sus privilegios de sistema y sus privilegios sobre objetos. (DBA_SYS_PRIVS y DBA_TAB_PRIVS) */

---Creamos el procedimiento que muestra los privilegios de sistema ingresando el nombre de usuario.
CREATE OR REPLACE PROCEDURE MostrarPrivilegiosSistema (p_nombre VARCHAR2)
IS
    CURSOR c_priv_sys IS
        SELECT privilege 
        FROM DBA_SYS_PRIVS 
        WHERE GRANTEE = p_nombre;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-----------------------');
    DBMS_OUTPUT.PUT_LINE('Privilegios de sistema: ');
    DBMS_OUTPUT.PUT_LINE('-----------------------');
    FOR r_privilegios IN c_priv_sys
    LOOP
        DBMS_OUTPUT.PUT_LINE(r_privilegios.privilege);
    END LOOP;
END MostrarPrivilegiosSistema;
/

---Creamos el procedimiento que muestra los privilegios sobre objetos ingresando el nombre de usuario.
CREATE OR REPLACE PROCEDURE MostrarPrivilegiosObjeto (p_nombre VARCHAR2)
IS
    CURSOR c_priv_obj IS
        SELECT privilege, table_name 
        FROM DBA_TAB_PRIVS 
        WHERE GRANTEE = p_nombre;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-----------------------');
    DBMS_OUTPUT.PUT_LINE('Privilegios sobre objetos: ');
    DBMS_OUTPUT.PUT_LINE('-----------------------');
    FOR r_privilegios IN c_priv_obj
    LOOP
        DBMS_OUTPUT.PUT_LINE(r_privilegios.privilege || ' -- ' || r_privilegios.table_name);
    END LOOP;
END;
/

---Creamos el procedimiento que llama a los dos anteriores para mostrar los privilegios de sistema y sobre objetos ingresando el nombre de usuario.
CREATE OR REPLACE PROCEDURE MostrarPrivilegiosUsuario (p_nombre VARCHAR2)
IS
BEGIN
    MostrarPrivilegiosSistema(p_nombre);
    MostrarPrivilegiosObjeto(p_nombre);
END;
/

---Ejecutamos el procedimiento.
exec MostrarPrivilegiosUsuario('SYSTEM');


/* 9. Realiza un procedimiento llamado listar_comisiones que nos muestre por pantalla un listado de las comisiones de los empleados agrupados según la localidad donde está ubicado su departamento con el siguiente formato: 
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
        b) Alguna comisión es mayor que 10000.*/

---Comprobar si la tabla emp está vacía
CREATE OR REPLACE PROCEDURE EmpVacio
IS
    e_emp_vacia EXCEPTION;

    v_num_emp NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_num_emp FROM emp;
    IF v_num_emp = 0 THEN
        RAISE e_emp_vacia;
    END IF;
EXCEPTION
    WHEN e_emp_vacia THEN
        DBMS_OUTPUT.PUT_LINE('La tabla de empleados está vacía');
END;
/

---Comprobar si alguna comisión es mayor que 10000
CREATE OR REPLACE PROCEDURE ComisionMayor
IS
    e_com_mayor EXCEPTION;

    v_comisiones NUMBER;
BEGIN
    SELECT count(ename) INTO v_comisiones FROM emp;
    IF v_comisiones > 10000 THEN
        RAISE e_com_mayor;
    END IF;
EXCEPTION
    WHEN e_com_mayor THEN
        DBMS_OUTPUT.PUT_LINE('Alguna comisión es mayor que 10000');
END;
/

--- Anexamos las dos funciones anteriores a una única función que las llame
CREATE OR REPLACE PROCEDURE ComprobarExcepciones
IS
BEGIN
    EmpVacio;
    ComisionMayor;
END;
/

---Creamos la cabecera del procedimiento
CREATE OR REPLACE PROCEDURE MostrarCabecera
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯');
    DBMS_OUTPUT.PUT_LINE('-¯-¯-¯-¯-¯-¯-¯-¯LISTAR COMISIONES-¯-¯-¯-¯-¯-¯-¯-');
    DBMS_OUTPUT.PUT_LINE('-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯');
END;
/

---Mostramos el nombre de los departamentos ingrsando una localidad.
CREATE OR REPLACE PROCEDURE MostrarDepartamento (v_localidad dept.loc%TYPE)
IS
    CURSOR c_departamento IS
        SELECT dname
        FROM dept
        WHERE loc = v_localidad
        ORDER BY dname ASC;
    v_dname dept.dname%TYPE;
BEGIN
    FOR r_departamento IN c_departamento
    LOOP
        v_dname := r_departamento.dname;
        DBMS_OUTPUT.PUT_LINE(CHR(9) || rpad('Departamento: ',15) || v_dname);
    END LOOP;
END;
/

---Mostramos el nombre de los empleados ingresando un departamento.
CREATE OR REPLACE PROCEDURE ListarEmpleados (p_deptno dept.dname%TYPE)
IS
    CURSOR c_empleados IS
        SELECT ename, comm
        FROM emp
        WHERE deptno = (SELECT deptno FROM dept WHERE dname = p_deptno)
        ORDER BY ename ASC;
    v_ename emp.ename%TYPE;
    v_comm emp.comm%TYPE;
BEGIN
    OPEN c_empleados;
    LOOP
        FETCH c_empleados INTO v_ename, v_comm;
        EXIT WHEN c_empleados%NOTFOUND;
        IF v_comm IS NULL THEN
            DBMS_OUTPUT.PUT_LINE(CHR(9) || v_ename || ' no tiene comision');
        ELSE
            DBMS_OUTPUT.PUT_LINE(CHR(9) || v_ename || '..........' || v_comm);
        END IF;
    END LOOP;
    CLOSE c_empleados;
END;
/

---Mostramos el total de comisiones de un departamento ingresando un departamento.
CREATE OR REPLACE PROCEDURE MostrarTotalDepartamento (p_dept dept.dname%TYPE)
IS
    v_total NUMBER := 0;
BEGIN
    SELECT SUM (comm) INTO v_total 
    FROM emp 
    WHERE deptno = (SELECT deptno FROM dept WHERE dname = p_dept);
    IF v_total IS NULL THEN
        DBMS_OUTPUT.PUT_LINE(CHR(9) || 'No hay empleados con comisiones en este departamento.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(CHR(9) || 'Total Comisiones en el Departamento ' || p_dept || ': ' || v_total);
    END IF;
END;
/

---Mostramos los departamentos, sus empleados y el total de comisiones de los mismos de una localidad ingresando la misma.
CREATE OR REPLACE PROCEDURE ListarDepartamentos (v_localidad dept.loc%TYPE)
IS
    p_dept dept.dname%TYPE;
BEGIN
    MostrarDepartamento(v_localidad);
    FOR r_departamento IN (SELECT dname FROM dept WHERE loc = v_localidad ORDER BY dname ASC)
    LOOP
        p_dept := r_departamento.dname;
        ListarEmpleados(p_dept);
        MostrarTotalDepartamento(p_dept);
    END LOOP;
END;
/

---Mostramos el total de comisiones de la empresa.
CREATE OR REPLACE PROCEDURE MostrarTotalEmpresa
IS
    CURSOR c_comisiones IS
        SELECT SUM(comm) AS total_comisiones
        FROM emp;
    v_total_comisiones NUMBER;
BEGIN
    FOR r_comisiones IN c_comisiones
    LOOP
        v_total_comisiones := r_comisiones.total_comisiones;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Comisiones en la Empresa: ' || v_total_comisiones);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------------------');
END;
/

---Creamos el procedimiento principal.
CREATE OR REPLACE PROCEDURE ListarComisiones
IS
    CURSOR c_localidad IS
        SELECT loc
        FROM dept
        GROUP BY loc
        ORDER BY loc ASC;
    v_localidad c_localidad%ROWTYPE;
BEGIN
    ComprobarExcepciones;
    MostrarCabecera;
    FOR v_localidad in c_localidad
    LOOP
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Localidad: ' || v_localidad.loc);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
        ListarDepartamentos (v_localidad.loc);
    END LOOP;
    MostrarTotalEmpresa;
END;
/

---Llamamos al procedimiento principal.
EXEC ListarComisiones;


/* 10. Realiza un procedimiento que reciba el nombre de una tabla y muestre los nombres de las restricciones que tiene, a qué columna afectan y en qué consisten exactamente. (DBA_TABLES, DBA_CONSTRAINTS, DBA_CONS_COLUMNS) */

CREATE OR REPLACE PROCEDURE listar_restricciones (p_tabla varchar2)
IS
    cursor c_tabla is
        SELECT a.constraint_name, b.column_name, a.constraint_type
        FROM dba_constraints a, dba_cons_columns b, dba_tables c
        WHERE a.constraint_name = b.constraint_name
        AND a.table_name = c.table_name
        AND a.table_name = p_tabla;
BEGIN
    for v_tabla in c_tabla loop
        dbms_output.put_line('-----------------------------------');
        dbms_output.put_line('Tabla: ' || p_tabla);
        dbms_output.put_line('Restriccion: ' || v_tabla.constraint_name);
        dbms_output.put_line('Columna: ' || v_tabla.column_name);
        dbms_output.put_line('Descripcion: ' || v_tabla.constraint_type);
    end loop;
END listar_restricciones;
/

/* 11. Realiza al menos dos de los ejercicios anteriores en Postgres usando PL/pgSQL. */

---
/* 3. Hacer un procedimiento que devuelva los nombres de los tres empleados más antiguos. */

CREATE OR REPLACE FUNCTION TresMasAntiguos() RETURNS VOID
AS $ANTIGUOS$
DECLARE
    v_nombre emp.ename%TYPE;
    c_antiguos CURSOR FOR
        SELECT ename
        FROM emp
        ORDER BY hiredate ASC
        FETCH FIRST 3 ROWS ONLY;
BEGIN
    FOR v_antiguos in c_antiguos LOOP
        v_nombre := v_antiguos.ename;
        RAISE NOTICE '%','Nombre: ' || v_nombre;
    END LOOP;
END;
$ANTIGUOS$ LANGUAGE plpgsql;

SELECT TresMasAntiguos();

/* 9. Realiza un procedimiento llamado listar_comisiones que nos muestre por pantalla un listado de las comisiones de los empleados agrupados según la localidad donde está ubicado su departamento con el siguiente formato: 
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
        b) Alguna comisión es mayor que 10000.*/
        

---Comprobar si la tabla emp está vacía
CREATE OR REPLACE FUNCTION EmpVacio() RETURNS VOID
AS $VACIO$
DECLARE
    v_num_emp INT=0;
BEGIN
    SELECT COUNT(*) INTO v_num_emp FROM emp;
    IF v_num_emp = 0 THEN
        RAISE EXCEPTION 'La tabla de empleados está vacía.';
    END IF;
END;
$VACIO$ LANGUAGE plpgsql;

---Comprobar si alguna comisión es mayor que 10000
CREATE OR REPLACE FUNCTION ComisionMayor() RETURNS VOID
AS $COMMAYOR$
DECLARE
    v_comisiones INT;
BEGIN

    SELECT count(ename) INTO v_comisiones FROM emp;
    IF v_comisiones > 10000 THEN
        RAISE EXCEPTION 'Alguna comisión es mayor que 10000';
    END IF;
END;
$COMMAYOR$ LANGUAGE plpgsql;

--- Anexamos las dos funciones anteriores a una única función que las llame
CREATE OR REPLACE FUNCTION ComprobarExcepciones() RETURNS VOID
AS $EXCEPCIONES$
BEGIN
    PERFORM EmpVacio();
    PERFORM ComisionMayor();
END;
$EXCEPCIONES$ LANGUAGE plpgsql;

---Creamos la cabecera del procedimiento
CREATE OR REPLACE FUNCTION MostrarCabecera() RETURNS VOID
AS $CABECERA$
BEGIN
    RAISE NOTICE '%','-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯';
    RAISE NOTICE '%','-¯-¯-¯-¯-¯-¯-¯-¯LISTAR COMISIONES-¯-¯-¯-¯-¯-¯-¯-';
    RAISE NOTICE '%','-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯-¯';
END;
$CABECERA$ LANGUAGE plpgsql;

---Mostramos el nombre de los departamentos ingrsando una localidad.
CREATE OR REPLACE FUNCTION MostrarDepartamentos (v_localidad dept.loc%TYPE) RETURNS VOID
AS $DEPARTAMENTO$
DECLARE
    c_departamento CURSOR FOR
        SELECT dname
        FROM dept
        WHERE loc = v_localidad
        ORDER BY dname ASC;
    v_dname dept.dname%TYPE;
BEGIN
    FOR r_departamento IN c_departamento
    LOOP
        v_dname := r_departamento.dname;
        RAISE NOTICE '%',CHR(9) || rpad('Departamento: ',15) || v_dname;
    END LOOP;
END;
$DEPARTAMENTO$ LANGUAGE plpgsql;


---Mostramos el nombre de los empleados ingresando un departamento.
CREATE OR REPLACE FUNCTION MostrarEmpleados(v_departamento dept.dname%TYPE) RETURNS VOID
AS $EMPLEADOS$
DECLARE
    c_empleados CURSOR FOR
        SELECT ename, comm
        FROM emp
        WHERE deptno = (SELECT deptno FROM dept WHERE dname = v_departamento)
        ORDER BY ename ASC;
    v_ename emp.ename%TYPE;
    v_comm emp.comm%TYPE;
BEGIN
    OPEN c_empleados;
    LOOP
        FETCH c_empleados INTO v_ename, v_comm;
        EXIT WHEN NOT FOUND;
        IF v_comm IS NULL THEN
            RAISE NOTICE '%',chr(9) || chr(9) || v_ename || '..........' || 'No tiene comisiones';
        ELSE
        RAISE NOTICE '%',chr(9) || chr(9) || v_ename || '..........' || v_comm;
        END IF;
    END LOOP;
    CLOSE c_empleados;
END;
$EMPLEADOS$ LANGUAGE plpgsql;

---Mostramos el total de comisiones de un departamento ingresando un departamento.
CREATE OR REPLACE FUNCTION MostrarTotalDepartamento(v_departamento dept.dname%TYPE) RETURNS VOID
AS $TOTALCOMISIONES$
DECLARE
    v_total_comisiones INT=0;
BEGIN
    SELECT SUM(comm) INTO v_total_comisiones FROM emp WHERE deptno = (SELECT deptno FROM dept WHERE dname = v_departamento);
    IF v_total_comisiones IS NULL THEN
        RAISE NOTICE '%',chr(9) || 'No hay empleados con comisiones en este departamento.';
    ELSE
        RAISE NOTICE '%',chr(9) || 'Total Comisiones en el Departamento ' || v_departamento || ': ' || v_total_comisiones;
    END IF;
END;
$TOTALCOMISIONES$ LANGUAGE plpgsql;


---Mostramos los departamentos, sus empleados y el total de comisiones de los mismos de una localidad ingresando la misma.
CREATE OR REPLACE FUNCTION ListarDepartamentos (v_localidad dept.loc%TYPE) RETURNS VOID
AS $LISTAR$
DECLARE
    v_dept dept.dname%TYPE;
BEGIN
    PERFORM MostrarDepartamentos(v_localidad);
    FOR v_dept IN (SELECT dname FROM dept WHERE loc = v_localidad ORDER BY dname ASC) LOOP
        PERFORM MostrarEmpleados(v_dept);
        PERFORM MostrarTotalDepartamento(v_dept);
    END LOOP;
END;
$LISTAR$ LANGUAGE plpgsql;

---Mostramos el total de comisiones de la empresa.
CREATE OR REPLACE FUNCTION MostrarTotalEmpresa() RETURNS VOID
AS $TOTAL$
DECLARE
    v_total INT;
    c_comisiones CURSOR FOR 
        SELECT SUM(comm) AS total_comisiones
        FROM emp;
BEGIN
    FOR r_comisiones IN c_comisiones
    LOOP
        v_total := r_comisiones.total_comisiones;
    END LOOP;
    RAISE NOTICE '%','------------------------------------------------------------';
    RAISE NOTICE '%',chr(9) || 'Total Comisiones de la Empresa: ' || v_total;
    RAISE NOTICE '%','------------------------------------------------------------';
END;
$TOTAL$ LANGUAGE plpgsql;

---Creamos el procedimiento principal.
CREATE OR REPLACE FUNCTION ListarComisiones() RETURNS VOID
AS $LISTARCOMISIONES$
DECLARE
    c_localidad CURSOR FOR
        SELECT loc
        FROM dept
        GROUP BY loc
        ORDER BY loc ASC;
BEGIN
    PERFORM ComprobarExcepciones();
    PERFORM MostrarCabecera();
    FOR v_localidad IN c_localidad
    LOOP
        RAISE NOTICE '%','-------------------------------------';
        RAISE NOTICE '%','Localidad: ' || v_localidad.loc;
        RAISE NOTICE '%','-------------------------------------';
        PERFORM ListarDepartamentos(v_localidad.loc);
    END LOOP;
    PERFORM MostrarTotalEmpresa();
END;
$LISTARCOMISIONES$ LANGUAGE plpgsql;
