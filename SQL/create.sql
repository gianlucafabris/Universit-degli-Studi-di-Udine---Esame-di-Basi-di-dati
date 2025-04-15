-- database: Zoo

create database if not exists Zoo;
comment on database Zoo
  is 'DataBase di esempio per progetto Universitario';

-- schema: public

create schema if not exists public;
comment on schema public
  is 'standard public schema';

-- tables: creation

create table if not exists Specie_Animale(
  specie varchar(50) primary key,
  denominazione_latina varchar(50)
);

create table if not exists Esemplare_Animale(
  codice integer not null check (codice > 0),
  paese_provenienza varchar(50) not null,
  sesso char(1) not null check (sesso in('m', 'f')),
  nome varchar(50) not null,
  data_nascita date not null,
  data_entrata date not null check (data_entrata >= data_nascita),
  data_uscita date check (data_uscita is null or data_uscita > data_entrata),
  specie varchar(50) not null,
  numero_visite_veterinarie integer default 0,
  foreign key(specie) references Specie_Animale(specie) on update cascade on delete no action,
  primary key(specie, codice)
);

create table if not exists Area(
  nome varchar(50) primary key
);

create table if not exists Casa(
  numero integer not null check (numero > 0),
  area varchar(50) not null,
  foreign key(area) references Area(nome) on update cascade on delete no action,
  primary key(numero, area)
);

create table if not exists Gabbia(
  lettera varchar(1) not null check (lettera ~* '[a-z]'), --controllo se il char è una lettera
  casa integer not null,
  area varchar(50) not null,
  specie varchar(50),
  animale integer,
  foreign key(casa, area) references Casa(numero, area) on update cascade on delete no action,
  foreign key(specie, animale) references Esemplare_Animale(specie, codice) on update cascade on delete no action,
  primary key(lettera, casa, area)
);

create table if not exists Persona(
  codice_fiscale varchar(16) primary key,
  nome varchar(50) not null,
  cognome varchar(50) not null,
  veterinario varchar(1) not null check (veterinario in('y', 'n')),
  codice_albo varchar(10) unique check ((codice_albo is null and veterinario='n') or (codice_albo is not null and veterinario='y')) --vincolo integrità: codice_albo unique e not null se veterinario='y'
);

create table if not exists Intervento_Pulizia(
  addetto varchar(16) not null,
  giorno_settimanale varchar(9) not null check (giorno_settimanale in('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
  area varchar(50) not null,
  casa integer not null,
  foreign key(casa, area) references Casa(numero, area) on update cascade on delete no action,
  foreign key(addetto) references Persona(codice_fiscale) on update cascade on delete no action,
  primary key(addetto, giorno_settimanale),
  unique(casa, area) --vincolo integrità: casa area unique not null
);

create table if not exists Visita_Veterinaria_Storico(
  data date not null,
  animale integer not null,
  specie varchar(50) not null,
  malattia varchar(100),
  peso decimal(10, 2),
  dieta varchar(1000),
  veterinario varchar(16) not null,
  foreign key(specie, animale) references Esemplare_Animale(specie,codice) on update cascade on delete no action,
  foreign key(veterinario) references Persona(codice_fiscale) on update cascade on delete no action,
  primary key(data, animale, specie)
);

create table if not exists Visita_Veterinaria_Corrente(
  data date not null,
  animale integer not null,
  specie varchar(50) not null,
  malattia varchar(100),
  peso decimal(10, 2),
  dieta varchar(1000),
  veterinario varchar(16),
  foreign key(specie, animale) references Esemplare_Animale(specie, codice) on update cascade on delete no action,
  foreign key(veterinario) references Persona(codice_fiscale) on update cascade on delete no action,
  primary key(data, animale, specie)
);
