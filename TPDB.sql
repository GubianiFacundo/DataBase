--DOMINIOS
CREATE DOMAIN dletras AS varchar(40)
    CHECK (VALUE ~ '^[[:alpha:]]+$') NOT NULL;
    
CREATE DOMAIN dnumdni AS varchar(8)
    CHECK (VALUE ~ '^[[:digit:]]{8}$');
    
CREATE DOMAIN dnumcuil AS varchar(11)
    CHECK (VALUE ~ '^[[:digit:]]{11}$') NOT NULL; 
--Más adelante pide validar el cuil con SP

CREATE DOMAIN dsexo AS char (1)
   CHECK ((VALUE = 'M') or (VALUE = 'F')) NOT NULL;

CREATE DOMAIN dsangre AS varchar (3)
    CHECK  (VALUE IN ('A+','A-','B+','B-','AB+','AB-','0-','0+')) NOT NULL;
        
CREATE DOMAIN dmail AS varchar(40)
    CHECK (VALUE ~ '^[a-z0-9._-]+@[a-z0-9.-]+\.[a-z]{2,3}$');

CREATE DOMAIN dcivil AS varchar(12)
    DEFAULT 'SOLTERO' 
    CHECK (VALUE IN ('SOLTERO','COMPROMETIDO','CASADO','DIVORCIADO','VIUDO')) NOT NULL;
        
CREATE DOMAIN dcbu AS varchar(22)
    CHECK (VALUE ~ '^[[:digit:]]{22}$')     
-- END DOMINIOS

-- TABLAS
CREATE TABLE Persona (
    dni dnumdni,
    cuil dnumcuil,
    nombre dletras,
    primer_apellido dletras,
    segundo_apellido dletras,
    sexo dsexo,
    fecha_nac DATE NOT NULL,
    grupo_sanguineo dsangre,
    estado_civil dcivil,
    domicilio VARCHAR(40) NOT NULL,
    mail dmail,
    ocupacion VARCHAR(50),
    cbu dcbu,
    nacionalidad dletras,
    PRIMARY KEY (dni)
);

CREATE TABLE AdultoResponsable (
    adulto_id SMALLSERIAL,
    relacion_niño VARCHAR(30) NOT NULL,
    dni dnumdni,
    PRIMARY KEY (adulto_id),
    FOREIGN KEY (dni) REFERENCES Persona (dni) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Estado (
	estado_id SMALLSERIAL,
	descripcion VARCHAR (500),
	PRIMARY KEY (estado_id)
);

CREATE TABLE Niño (
	niño_id SMALLSERIAL,
	hora_inicio_clases TIME NOT NULL CHECK(hora_inicio_clases < hora_fin_clases),
	hora_fin_clases TIME NOT NULL,
	tarifa_base NUMERIC(8, 2) NOT NULL,
	comentarios VARCHAR(500),
	dni dnumdni,
	estado_id SMALLINT,
	adulto_id INTEGER,
	PRIMARY KEY (niño_id),
	FOREIGN KEY (dni) REFERENCES Persona (dni) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (adulto_id) REFERENCES AdultoResponsable (adulto_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (estado_id) REFERENCES Estado (estado_id) ON DELETE RESTRICT
);

CREATE TABLE Tracking (
	tracking_id SERIAL,
	niño_id INTEGER,
	periodo_ini DATE,
	periodo_fin DATE,
	estado_id SMALLINT,
	PRIMARY KEY (tracking_id),
	FOREIGN KEY (niño_id) REFERENCES Niño (niño_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (estado_id) REFERENCES Estado (estado_id) ON DELETE RESTRICT
);
CREATE TABLE IncidenciasSociales (
	incidencia_id SMALLSERIAL, 
	descripcion VARCHAR (500),
	niño_id INTEGER,
	PRIMARY KEY (incidencia_id),
	FOREIGN KEY (niño_id) REFERENCES Niño (niño_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE EnfermedadesContraidas (
	enfermedad_id SMALLSERIAL,
	nombre dletras,
	fec_contagio DATE NOT NULL,
	niño_id SMALLINT,
	PRIMARY KEY (enfermedad_id),
	FOREIGN KEY (niño_id) REFERENCES Niño (niño_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Vacunas (
	vacuna_id SMALLSERIAL, 
	nombre dletras, 
	fecha DATE NOT NULL,
	niño_id SMALLINT,
	PRIMARY KEY (vacuna_id),
	FOREIGN KEY (niño_id) REFERENCES Niño (niño_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE Titulo (
	titulo_id SMALLSERIAL,
	nombre VARCHAR(30),
	PRIMARY KEY (titulo_id)
);
CREATE TABLE Cargo (
	codigo SMALLSERIAL, 
	nombre VARCHAR(50) NOT NULL,
	sueldo_basico NUMERIC (8, 2) NOT NULL,
	PRIMARY KEY (codigo)
);
CREATE TABLE Educador (
	educador_id SMALLSERIAL, 
	legajo SERIAL UNIQUE,
	hora_ini TIME NOT NULL CHECK(hora_ini < hora_fin),
	hora_fin TIME NOT NULL,
	comentarios VARCHAR (500),
	dni dnumdni,
	estado_id SMALLINT,
	educador_tutor_id SMALLINT,
	codigo SMALLINT,
	titulo_id SMALLINT,
	PRIMARY KEY (educador_id),
	FOREIGN KEY (dni) REFERENCES Persona (dni) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (educador_tutor_id) REFERENCES Educador (educador_id),
	FOREIGN KEY (estado_id) REFERENCES Estado (estado_id) ON UPDATE CASCADE,
	FOREIGN KEY (codigo) REFERENCES Cargo (codigo) ON UPDATE CASCADE,
	FOREIGN KEY (titulo_id) REFERENCES Titulo (titulo_id)
);
CREATE TABLE Aula (
    aula_id SMALLSERIAL,
    denominacion VARCHAR (200),
    metros_cuadrados NUMERIC (6, 2) NOT NULL,
    capacidad SMALLINT NOT NULL,
    educador_id SMALLINT,
    educador_reemplazante_id SMALLINT,
    PRIMARY KEY (aula_id),
    FOREIGN KEY (educador_id) REFERENCES Educador (educador_id) ON UPDATE CASCADE,
    FOREIGN KEY (educador_reemplazante_id) REFERENCES Educador (educador_id) ON UPDATE CASCADE
);
CREATE TABLE Curso (
	curso_id SMALLSERIAL,
	denominacion VARCHAR(200),
	aula_id SMALLINT,
	PRIMARY KEY (curso_id),
	FOREIGN KEY (aula_id) REFERENCES Aula (aula_id) ON UPDATE CASCADE
);
CREATE TABLE EstadoMaterial (
	estado_mat_id SMALLSERIAL,
	descripcion VARCHAR (500),
	PRIMARY KEY (estado_mat_id)
);
CREATE TABLE MaterialEducativo (
	material_id SMALLSERIAL,
	titulo VARCHAR(50) NOT NULL,
	formato VARCHAR(50),
	comentarios VARCHAR (500),
	PRIMARY KEY (material_id)
);
CREATE TABLE MaterialEducativoCopia (
	mat_id_copia SMALLSERIAL,
	material_id SMALLINT,
	aula_id SMALLINT,
	estado_mat_id SMALLINT,
	PRIMARY KEY (mat_id_copia),
	FOREIGN KEY (material_id) REFERENCES MaterialEducativo (material_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (aula_id) REFERENCES Aula (aula_id),
	FOREIGN KEY (estado_mat_id) REFERENCES EstadoMaterial (estado_mat_id) ON UPDATE CASCADE
);

CREATE TABLE Inventario (
	nro_inventario SMALLSERIAL,
	nombre VARCHAR(50),
	fec_ad DATE NOT NULL,
	valor_actual NUMERIC (8, 2),
	valor_compra NUMERIC (8, 2),
	aula_id SMALLINT,
	estado_mat_id SMALLINT,
	PRIMARY KEY (nro_inventario),
	FOREIGN KEY (aula_id) REFERENCES Aula (aula_id),
	FOREIGN KEY (estado_mat_id) REFERENCES EstadoMaterial (estado_mat_id) ON UPDATE CASCADE
);
CREATE TABLE ProfesorEspecial (
	profesor_especial_id SMALLSERIAL, 
	dni dnumdni, 
	materia VARCHAR(30) NOT NULL,
	PRIMARY KEY (profesor_especial_id),
	FOREIGN KEY (dni) REFERENCES Persona (dni) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE HorarioMateriaEspecial (
	horario_id SMALLSERIAL,
	hora_ini DATE NOT NULL CHECK (hora_ini < hora_fin), 
	hora_fin DATE,
	profesor_especial_id SMALLINT,
	curso_id SMALLINT,
	PRIMARY KEY (horario_id),
	FOREIGN KEY (profesor_especial_id) REFERENCES ProfesorEspecial (profesor_especial_id),
	FOREIGN KEY (curso_id) REFERENCES Curso (curso_id)
);
CREATE TABLE TelefonoContacto (
	telefono_contacto_id SMALLSERIAL,
	nro_telefono VARCHAR (20) NOT NULL,
	descripcion VARCHAR (200),
	dni dnumdni,
	PRIMARY KEY (telefono_contacto_id),
	FOREIGN KEY (dni) REFERENCES Persona (dni)
);
CREATE TABLE PeriodoEducador (
	periodo_id SMALLSERIAL,
	fec_ini DATE NOT NULL CHECK(fec_ini < fec_fin),
	fec_fin DATE NOT NULL, 
	cargo VARCHAR(50),
	PRIMARY KEY (periodo_id)
);

CREATE TABLE Factura (
	factura_id SMALLSERIAL,
	nom_escuela VARCHAR (50),
	fecha_fac DATE NOT NULL,
	nro_fac SMALLINT,
	pagado BOOLEAN,
	tarifa NUMERIC (8, 2),
	bonificado BOOLEAN, 
	mora BOOLEAN,
	dni_niño dnumdni,
	PRIMARY KEY (factura_id),
	FOREIGN KEY (dni_niño) REFERENCES Persona (dni) ON UPDATE CASCADE
)
--END TABLAS

--VISTAS
CREATE VIEW vFullname AS
	SELECT concat_ws(', ', (per.primer_apellido ||' '|| per.segundo_apellido), per.nombre) as Fullname, per.*
	FROM Persona per;
					 
--1	
CREATE VIEW vAula AS
	SELECT aul.*, ed.legajo, per.dni, per.nombre, per.primer_apellido, per.segundo_apellido, edr.legajo AS legajo_Reemplazante,
	perr.dni AS dni_Reemplazante, perr.nombre AS nombre_Reemplazante, perr.primer_apellido AS primer_Apellido_Reemplazante,
	perr.segundo_apellido AS primer_Segundo_Reemplazante, me.titulo, inv.nombre AS inventario_Nombre, inv.valor_compra,
	(inv.valor_compra *((EXTRACT(YEAR FROM NOW())- EXTRACT(YEAR FROM inv.fec_ad))/10)) AS valor_actual FROM Aula aul
	JOIN Educador ed ON ed.educador_id = aul.educador_id
	JOIN Persona per ON per.dni = ed.dni
	JOIN Educador edr ON edr.educador_id = aul.educador_id
	JOIN Persona perr ON perr.dni = edr.dni
	JOIN MaterialEducativoCopia mec ON mec.aula_id = aul.aula_id
	JOIN MaterialEducativo me ON me.material_id = mec.material_id
	JOIN Inventario inv ON inv.aula_id = aul.aula_id;
														   
--2
CREATE VIEW vAulas_responsables AS
	SELECT aul.*, ed.legajo, per.dni, per.nombre, per.primer_apellido, per.segundo_apellido,
	edr.legajo AS legajo_Reemplazante, perr.dni AS dni_Reemplazante, perr.nombre AS nombre_Reemplazante,
	perr.primer_apellido AS primer_Apellido_Reemplazante, perr.segundo_apellido AS primer_Segundo_Reemplazante FROM Aula aul
	JOIN Educador ed ON ed.educador_id = aul.educador_id
	JOIN Persona per ON per.dni = ed.dni
	JOIN Educador edr ON edr.educador_id = aul.educador_id
	JOIN Persona perr ON perr.dni = edr.dni;
--3

--4
CREATE VIEW vAlumno_Total AS 
	SELECT ni.niño_id, ni.hora_inicio_clases, ni.hora_fin_clases, ni.tarifa_base, ni.comentarios,
	per.dni, per.cuil, per.nombre, per.primer_apellido, per.segundo_apellido, per.sexo, per.fecha_nac,
	per.grupo_sanguineo, per.estado_civil, per.domicilio, es.estado_id, es.descripcion, inc.incidencia_id, inc.descripcion AS descripcion_Incidencia, vac.vacuna_id, 
	vac.nombre AS nombre_vacuna, vac.fecha, en.enfermedad_id, en.nombre AS nombre_enfermedad, en.fec_contagio, ad.adulto_id, ad.relacion_niño,
	perr.dni AS dni_Adulto_Responsable, per.cuil AS cuil_Adulto_Responsable, perr.nombre AS nombre_Adulto_Responsable,
	perr.primer_apellido AS primer_Apellido_Adulto_Responsable, perr.segundo_apellido AS segundo_Apelldio_Adulto_Responsable,
	perr.sexo AS sexo_Adulto_Responsable, perr.fecha_nac AS fecha_Nac_Adulto_Responsable, perr.grupo_sanguineo AS grupo_Sanguineo_Adulto_Responsable,
	perr.estado_civil AS estado_Civil_Adulto_Responsable, perr.domicilio AS domicilio_Adulto_Responsable, perr.mail, perr.ocupacion, perr.cbu, perr.nacionalidad FROM Niño ni
	JOIN Persona per ON per.dni = ni.dni
	JOIN Estado es ON es.estado_id = ni.estado_id
	JOIN IncidenciasSociales inc ON inc.niño_id = ni.niño_id
	JOIN Vacunas vac ON vac.niño_id = ni.niño_id
	JOIN EnfermedadesContraidas en ON en.niño_id = ni.niño_id
	JOIN AdultoResponsable ad ON ad.adulto_id = ni.adulto_id
	JOIN Persona perr ON perr.dni = ad.dni;
														   
--5
CREATE VIEW vTablas AS
        SELECT schemaname, relname, n_live_tup 
        FROM pg_stat_user_tables 
		ORDER BY n_live_tup DESC;
														   
--6
CREATE VIEW vResumenDeCtaCte AS
	SELECT CAST(EXTRACT(YEAR FROM fac.fecha_fac) * 100 + EXTRACT(MONTH FROM fac.fecha_fac) AS integer) AS añoMes,
	EXTRACT(YEAR FROM fac.fecha_fac) as año, EXTRACT(MONTH FROM fac.fecha_fac) as mes,
	SUM(fac.tarifa) AS monto_facturado, SUM(fac.tarifa) AS monto_cobrado, COUNT(mora) AS cantidad_morosos FROM Factura fac
	WHERE pagado = true
	GROUP BY año, mes;
														   
--7
CREATE VIEW vAlumnosMorosos AS
	SELECT ni.niño_id, ni.hora_inicio_clases, ni.hora_fin_clases, ni.tarifa_base, ni.comentarios,
	per.dni, per.cuil, per.nombre, per.primer_apellido, per.segundo_apellido, per.sexo, per.fecha_nac,
	per.grupo_sanguineo, per.estado_civil, per.domicilio, ad.adulto_id, ad.relacion_niño,
	perr.dni AS dni_Adulto_Responsable, per.cuil AS cuil_Adulto_Responsable, perr.nombre AS nombre_Adulto_Responsable,
	perr.primer_apellido AS primer_Apellido_Adulto_Responsable, perr.segundo_apellido AS segundo_Apelldio_Adulto_Responsable,
	perr.sexo AS sexo_Adulto_Responsable, perr.fecha_nac AS fecha_Nac_Adulto_Responsable, perr.grupo_sanguineo AS grupo_Sanguineo_Adulto_Responsable,
	perr.estado_civil AS estado_Civil_Adulto_Responsable, perr.domicilio AS domicilio_Adulto_Responsable, perr.mail, perr.ocupacion, perr.cbu, perr.nacionalidad,
	SUM(CASE WHEN fac.pagado THEN 1 ELSE 0 END) AS cuotas_Adeudadas, SUM(fac.tarifa) AS monto FROM Niño ni
	JOIN Persona per ON per.dni = ni.dni
	JOIN AdultoResponsable ad ON ad.adulto_id = ni.adulto_id
	JOIN Persona perr ON perr.dni = ad.dni
	JOIN Factura fac ON fac.dni_niño = ni.dni
	WHERE fac.pagado = FALSE
	GROUP BY ni.dni, ni.niño_id, per.dni, ad.adulto_id, perr.dni
	HAVING SUM(CASE WHEN fac.pagado THEN 1 ELSE 0 END) > 3;
														   
--8
CREATE VIEW vProfesoresNoResponsables AS
	SELECT ed.*, per.nombre, per.primer_apellido, per.segundo_apellido, per.sexo, per.fecha_nac FROM Educador ed
	JOIN Persona per ON per.dni = ed.dni
	WHERE NOT (ed.educador_id IN (SELECT aul.educador_id
           FROM Aula aul));
								  
--9
CREATE VIEW vAlumnosActivosYBaja AS
	SELECT ni.*, es.estado_id AS estado_Niño FROM Niño ni 
	JOIN Estado es ON es.estado_id = ni.estado_id
	WHERE es.estado_id = 1 OR es.estado_id = 3
--END VISTAS

--TRIGGER
								  
--1
CREATE TRIGGER tProfesorNoAula BEFORE INSERT ON Aula
FOR EACH ROW EXECUTE PROCEDURE profesorNoAula();
								  
--2
								  
--FUNCIONES
								  
--1
CREATE OR REPLACE FUNCTION profesorNoAula() RETURNS TRIGGER AS
$BODY$
DECLARE
	cant integer;
BEGIN
	cant = (SELECT COUNT(*) FROM Aula aul WHERE aul.educador_id = new.educador_id);
	if (cant <3) THEN
	RETURN NEW;
	END IF;
	IF (cant >= 3) THEN
	RAISE EXCEPTION 'El profesor alcanzó el máximo de aulas como titular responsable';
	END IF;
END;
$BODY$
LANGUAGE plpgsql VOLATILE;
								  
--2 
CREATE OR REPLACE FUNCTION validarCuil(dnumcuil) RETURNS VARCHAR
AS
$BODY$
DECLARE
	RES BIGINT;
	DIG BIGINT;
	NUM BIGINT;
	CUIT ALIAS FOR $1;							  
BEGIN
	IF LENGTH(CUIT) != 11 OR SUBSTR(CUIT, 1, 2) = '00' THEN
	RETURN 0;
	END IF;
	RES = 0;
	FOR I IN 1..10 LOOP
	NUM = (SUBSTR(CUIT, I, 1));
	IF (I = 1 OR I = 7) THEN RES = RES + NUM * 5;
	ELSIF (I = 2 OR I = 8) THEN RES = RES + NUM * 4;
	ELSIF (I = 3 OR I = 9) THEN RES = RES + NUM * 3;
	ELSIF (I = 4 OR I = 10) THEN RES = RES + NUM * 2;
	ELSIF (I = 5) THEN RES = RES + NUM * 7;
	ELSIF (I = 6) THEN RES = RES + NUM * 6;
	END IF;
	END LOOP;
	DIG = 11 - MOD(RES,11);
	IF DIG = 11 THEN
	DIG = 0;
	END IF;
	IF DIG = (SUBSTR(CUIT,11,1)) THEN
	RETURN 1;
	ELSE
	RETURN 0;
	END IF;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;
					 
--3
CREATE OR REPLACE FUNCTION facturarMes() RETURNS NUMERIC AS 
$BODY$
DECLARE
	total NUMERIC;
BEGIN
	total = (SELECT SUM(fac.tarifa) FROM factura fac WHERE fac.fecha_fac = EXTRACT(MONTH FROM CURRENT_DATE) AND fac.fecha_fac = EXTRACT(YEAR FROM CURRENT_DATE));
	RETURN total;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
--END FUNCIONES
																																		
--SCRIPTS

--esto se ejecuta en cmd pero antes hay que ir a la direccion de postgresql en %ProgramFiles% (version y bin)
--cd %ProgramFiles%\PostgreSQL\version\bin
--EJEMPLO: %ProgramFiles%/PostgreSQL/11/bin
																																		
--3 BACKUP  
pg_dump -h localhost -p 5432 -U postgres -d basedato -v %userprofile%\documents\basedato.backup

--4 RESTORE BACKUP
pg_restore -h localhost -p 5432 -U postgres -d basedato -v %userprofile%\documents\basedato.backup