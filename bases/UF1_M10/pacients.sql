DROP DATABASE lab_clinic;
CREATE DATABASE lab_clinic;
\c lab_clinic;

CREATE TABLE pacients (
  idpacient serial PRIMARY KEY,
  nom varchar(15) NOT NULL,
  cognoms varchar(30) NOT NULL,
  dni varchar(9),
  data_naix date NOT NULL,
  sexe varchar(1) NOT NULL,
  adreca varchar(50) NOT NULL,
  ciutat varchar(30) NOT NULL,
  c_postal varchar(10) NOT NULL,
  telefon varchar(9) NOT NULL,
  email varchar(30) NOT NULL,
  num_ss varchar(12) ,
  num_cat varchar(20) ,
  nie varchar(20),
  passaport varchar(20) 
);
