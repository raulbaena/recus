-- BASE DE DADES Biblioteca

DROP DATABASE if exists centre_salut;
CREATE DATABASE centre_salut;

\c centre_salut;

--table master----------------------------------------------------------

CREATE TABLE pacients(
	id_pacient bigserial PRIMARY KEY,
	nom varchar(50) not null,
	cognoms varchar(100) not null,
	dni varchar(9) unique not null,
	data_naix date NOT NULL,
	sexe bigint not null,
	telefon varchar(9) not null,
	direccio varchar(50) NOT NULL
);



CREATE TABLE proves(
	id_prova bigserial PRIMARY KEY,
	nom varchar(50) not null,
	descripcion varchar(300) not null
);


CREATE TABLE resultats_patologics(
	id_resultat integer NOT NULL,
	stamp timestamp NOT NULL,
	userid text NOT NULL
);

/*
CREATE TABLE proves_resultat_fix(
	id_prova_fix bigserial PRIMARY KEY
	references proves(id_prova)
	--nom varchar(50) not null,
--	descripcion varchar(300) not null
);


CREATE TABLE new_pacients(
nom varchar(50) not null,
cognoms varchar(100) not null,
dni varchar(9) unique not null,
data_naix date NOT NULL,
telefon varchar(9) not null,
direccio varchar(50) NOT NULL,
id_pacient bigserial PRIMARY KEY);
*/

--not master table------------------------------------------------------


CREATE TABLE analitiques(
	id_analitica bigserial PRIMARY KEY,
	id_pacient bigint not null references pacients(id_pacient),
	date_analitica date NOT NULL DEFAULT current_date
);



CREATE TABLE resultats(
	id_resultat bigserial PRIMARY KEY,
	resultat varchar(50),
	id_analitica bigint not null references analitiques(id_analitica),
	id_prova bigint not null references proves(id_prova),
	unique (id_analitica,id_prova)
);



CREATE TABLE tecnica_valors(
	id_tecnica_valor bigserial PRIMARY KEY,
	id_prova bigint not null references proves(id_prova),
	id_tecnica bigint not null,
	sexe bigint not null,
	edat_inicial bigint not null,
	edat_final bigint not null,
	min_patologic int,
	max_patologic int,
	min_panic int,
	max_panic int,
	valor varchar(20),
	data_inici date not null,
	res_numeric bool not null,
	unique (id_prova, id_tecnica)
);

/*
CREATE TABLE tmp_resultats(
	id_resultat bigserial PRIMARY KEY,
	resultat varchar(50) not null,
	id_analitica bigint not null references analitiques(id_analitica),
	id_prova bigint not null references proves(id_prova),
	unique (id_analitica,id_prova)
);

*/
/* ****************** C À R R E G A   D E   D A D E S *************** */

-- pacients
--INSERT INTO pacients values (id_pacient,nom,cognom,dni,data_naix,sexe,telefon,direccio);

INSERT INTO pacients values 
(DEFAULT,'ram','singh','53320079F','1991-06-06',1,987654321,'C\salva 13');
INSERT INTO pacients values 
(DEFAULT,'sham','kumar','12345678A','1990-03-08',1,987654300,'C\carreta 1');
INSERT INTO pacients values 
(DEFAULT,'raul','jat','02345678A','1992-04-08',1,987654300,'C\mardid 10');
INSERT INTO pacients values 
(DEFAULT,'david','jaat','00345678A','1995-06-10',2,987654300,'C\londres 20');
INSERT INTO pacients values 
(DEFAULT,'jhon','contreu','00045678A','1998-08-12',2,987654300,'C\careta 50');


-- proves
--INSERT INTO proves values (id_prova,nom,descripcion);

INSERT INTO proves values (DEFAULT,'VIH','Prova per veure pacient');
INSERT INTO proves values (DEFAULT,'Colesterol','colesterol del pacient');
INSERT INTO proves values (DEFAULT,'weight','Prova per weight pacient');
INSERT INTO proves values (DEFAULT,'fat','fat pacient');
INSERT INTO proves values (DEFAULT,'alre','alerigi pacient');

INSERT INTO proves values (DEFAULT,'a1','alerigi pacient');
INSERT INTO proves values (DEFAULT,'a2','alerigi pacient');
INSERT INTO proves values (DEFAULT,'a3','alerigi pacient');
INSERT INTO proves values (DEFAULT,'a4','alerigi pacient');
INSERT INTO proves values (DEFAULT,'a5','alerigi pacient');

INSERT INTO proves values (DEFAULT,'b1','alerigi pacient');
INSERT INTO proves values (DEFAULT,'b2','alerigi pacient');

INSERT INTO proves values (DEFAULT,'c1','alerigi pacient');
INSERT INTO proves values (DEFAULT,'c2','alerigi pacient');
INSERT INTO proves values (DEFAULT,'c3','alerigi pacient');



--proves_resultat_fix
--insert into proves_resultat_fix values (bigint);
insert into proves_resultat_fix values(11);
insert into proves_resultat_fix values(12);

-- analitiques
--INSERT INTO analitiques values (id_analitica,id_pacient,date_analitica);

INSERT INTO analitiques values (DEFAULT,1,'2018-05-01');
--INSERT INTO analitiques values (DEFAULT,1,'2018-06-01');
INSERT INTO analitiques values (DEFAULT,2,'2018-07-01');
INSERT INTO analitiques values (DEFAULT,2,'2018-08-01');
--INSERT INTO analitiques values (DEFAULT,2,'2019-01-01');
INSERT INTO analitiques values (DEFAULT,5,'2018-05-03');
INSERT INTO analitiques values (DEFAULT,5,'2018-12-30');
INSERT INTO analitiques values (DEFAULT,5,'2019-01-30');



-- resultats
--INSERT INTO resultats values (id_resultat,resultat,id_analitica,id_prova);

INSERT INTO resultats values (DEFAULT,'Negatiu',1,1);
INSERT INTO resultats values (DEFAULT,'400',1,2);
INSERT INTO resultats values (DEFAULT,'400',1,3);
INSERT INTO resultats values (DEFAULT,'400',1,4);
INSERT INTO resultats values (DEFAULT,'400',1,5);

INSERT INTO resultats values (DEFAULT,'200',2,2);
INSERT INTO resultats values (DEFAULT,'200',2,3);
INSERT INTO resultats values (DEFAULT,'200',2,4);
INSERT INTO resultats values (DEFAULT,'200',2,5);
INSERT INTO resultats values (DEFAULT,'positive',2,1);

INSERT INTO resultats values (DEFAULT,'150',3,2);
INSERT INTO resultats values (DEFAULT,'500',3,3);
INSERT INTO resultats values (DEFAULT,'nagative',3,1);

INSERT INTO resultats values (DEFAULT,'Positiu',4,1);
INSERT INTO resultats values (DEFAULT,'50',4,2);
INSERT INTO resultats values (DEFAULT,'50',4,3);

INSERT INTO resultats values (DEFAULT,'nagative',5,1);
INSERT INTO resultats values (DEFAULT,'50',5,3);
INSERT INTO resultats values (DEFAULT,'50',6,3);



-- tecnica_valors
--INSERT INTO tecnica_valors values (id_tecnica_valor,id_prova,id_tecnica,sexe,edat_inicial,
--edat_final,min_patologic,max_patologic,min_panic,max_panic,valor,data_inici,res_numeric);

INSERT INTO tecnica_valors values 
(DEFAULT,1,1,0,0,999,null,null,null,null,'positiu','2018-01-01',False);
INSERT INTO tecnica_valors values 
(DEFAULT,2,1,1,0,999,150,250,100,300,null,'2018-02-01',True);
INSERT INTO tecnica_valors values 
(DEFAULT,2,2,2,0,999,100,200,50,250,null,'2018-03-01',True);
INSERT INTO tecnica_valors values 
(DEFAULT,3,2,1,0,1,100,200,50,250,null,'2018-04-01',True);
INSERT INTO tecnica_valors values 
(DEFAULT,4,2,1,1,4,100,200,50,250,null,'2018-04-01',True);
INSERT INTO tecnica_valors values 
(DEFAULT,5,2,1,4,999,100,200,50,250,null,'2018-04-01',True);


alter table resultats add num_rep int default 1;

------------------------------------------------------------------------
--######################################################################
------------------------------------------------------------------------

INSERT INTO pacients values 
(DEFAULT,'Sergi','Muñoz Carmona','12345678A','08-03-1998',987654321,'Carrer del retard Nº1');
--ERROR:  duplicate key value violates unique constraint "pacients_dni_key"
--DETAIL:  Key (dni)=(12345678A) already exists.
INSERT INTO pacients values 
(1,'Sergi','Muñoz Carmona','12345678A','08-03-1998',987654321,'Carrer del retard Nº1');
--ERROR:  duplicate key value violates unique constraint "pacients_pkey"
--DETAIL:  Key (id_pacient)=(1) already exists.



INSERT INTO proves values 
(1,'Colesterol','Prova per evaluar els nivells de colesterol del pacient');
--ERROR:  duplicate key value violates unique constraint "proves_pkey"
--DETAIL:  Key (id_prova)=(1) already exists.



INSERT INTO analitiques values (1,2,current_date);
--ERROR:  duplicate key value violates unique constraint "analitiques_pkey"
--DETAIL:  Key (id_analitica)=(1) already exists.
INSERT INTO analitiques values (DEFAULT,7,current_date);
--ERROR:  insert or update on table "analitiques" violates foreign key constraint "analitiques_pacient_fkey"
--DETAIL:  Key (pacient)=(7) is not present in table "pacients".



INSERT INTO resultats values (1,'Positiu',4,1);
--ERROR:  duplicate key value violates unique constraint "resultats_pkey"
--DETAIL:  Key (id_resultat)=(1) already exists.
INSERT INTO resultats values (DEFAULT,'Positiu',90,1);
--ERROR:  insert or update on table "resultats" violates foreign key constraint "resultats_analitica_fkey"
--DETAIL:  Key (analitica)=(90) is not present in table "analitiques".
INSERT INTO resultats values (DEFAULT,'Positiu',4,90);
--ERROR:  insert or update on table "resultats" violates foreign key constraint "resultats_prova_fkey"
--DETAIL:  Key (prova)=(90) is not present in table "proves".



INSERT INTO tecnica_valors values 
(1,2,2,100,200,50,250,null,'2018-12-01',True);
--ERROR:  duplicate key value violates unique constraint "tecnica_valors_pkey"
--DETAIL:  Key (id_tecnica_valor)=(1) already exists.
INSERT INTO tecnica_valors values 
(DEFAULT,2,2,100,200,50,250,null,current_date,True);
--ERROR:  duplicate key value violates unique constraint "tecnica_valors_id_prova_id_tecnica_key"
--DETAIL:  Key (id_prova, id_tecnica)=(2, 2) already exists.
