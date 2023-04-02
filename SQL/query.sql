--operazione 1: ultimo controllo veterinario di un esemplare di animale
select data, animale, Visita_Veterinaria_Corrente.specie, malattia, peso, dieta, veterinario
from Visita_Veterinaria_Corrente, Esemplare_Animale
where animale = codice and Visita_Veterinaria_Corrente.specie = Esemplare_Animale.specie and codice = ###INPUT### and Esemplare_Animale.specie = ###INPUT###;
--oppure
select data, animale, Visita_Veterinaria_Corrente.specie, malattia, peso, dieta, veterinario
from Visita_Veterinaria_Corrente, Esemplare_Animale
where animale = codice and Visita_Veterinaria_Corrente.specie = Esemplare_Animale.specie and nome = ###INPUT###;

--operazione 2: inserimento di un controllo veterinario di un esemplare di animale
insert into Visita_Veterinaria_Corrente(data, animale, specie, malattia, peso, dieta, veterinario) values(###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###);

--operazione 3: lista esemplari di animale (attuali) presenti nello zoo, divisi per aree
select codice, paese_provenienza, sesso, Esemplare_Animale.nome, data_nascita, data_entrata, data_uscita, Esemplare_Animale.specie, numero_visite_veterinarie, Area.nome as area
from Esemplare_Animale, Gabbia, Casa, Area
where animale = codice and Gabbia.specie = Esemplare_Animale.specie and casa = numero and Gabbia.area = Casa.area and Casa.area = Area.nome and data_uscita is null
order by Area.nome;

--operazione 4: dato un esemplare di animale visualizzare la gabbia, casa, area
select lettera as gabbia, numero as casa, Area.nome as area
from Esemplare_Animale, Gabbia, Casa, Area
where animale = codice and Gabbia.specie = Esemplare_Animale.specie and casa = numero and Gabbia.area = Casa.area and Casa.area = Area.nome and codice = ###INPUT### and Esemplare_Animale.specie = ###INPUT###;
--oppure
select lettera as gabbia, numero as casa, Area.nome as area
from Esemplare_Animale, Gabbia, Casa, Area
where animale = codice and Gabbia.specie = Esemplare_Animale.specie and casa = numero and Gabbia.area = Casa.area and Casa.area = Area.nome and Esemplare_Animale.nome = ###INPUT###;

--operazione 5: eliminazione / inserimento dell’esemplare di animale
delete from Esemplare_Animale where codice = ###INPUT### and specie = ###INPUT###;
insert into Esemplare_Animale(codice, paese_provenienza, sesso, nome, data_nascita, data_entrata, data_uscita, specie) values(###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###, ###INPUT###);

--operazione 6: visualizzazione delle gabbie vuote
select lettera as gabbia, numero as casa, Area.nome as area
from Gabbia, Casa, Area
where casa = numero and Gabbia.area = Casa.area and Casa.area = Area.nome and animale is null and specie is null;
-- specie is null perchè parte della chiave di Esemplare_Animale

--operazione 7: esemplari di animale con ultimo controllo veterinario oltre un mese fa
select codice, paese_provenienza, sesso, Esemplare_Animale.nome, data_nascita, data_entrata, data_uscita, Esemplare_Animale.specie, numero_visite_veterinarie, data
from Visita_Veterinaria_Corrente, Esemplare_Animale
where animale = codice and Visita_Veterinaria_Corrente.specie = Esemplare_Animale.specie and data < (now() - interval '1 MONTH');

--operazione 8: media controlli veterinari veterinarie per ogni specie
select Esemplare_Animale.specie, avg(numero_visite_veterinarie)
from Specie_Animale, Esemplare_Animale
where Specie_Animale.specie = Esemplare_Animale.specie
group by Esemplare_Animale.specie;

--operazione 9: numero di controlli veterinari effettuati su una esemplare di animale rispetto la sua specie
select ea1.codice, ea1.paese_provenienza, ea1.sesso, ea1.nome, ea1.data_nascita, ea1.data_entrata, ea1.data_uscita, ea1.specie, ea1.numero_visite_veterinarie / (select avg(ea2.numero_visite_veterinarie) from Esemplare_Animale as ea2 where ea2.specie = ea1.specie)
from Esemplare_Animale as ea1
where ea1.codice = ###INPUT### and ea1.specie = ###INPUT###;
--oppure
select ea1.codice, ea1.paese_provenienza, ea1.sesso, ea1.nome, ea1.data_nascita, ea1.data_entrata, ea1.data_uscita, ea1.specie, ea1.numero_visite_veterinarie / (select avg(ea2.numero_visite_veterinarie) from Esemplare_Animale as ea2 where ea2.specie = ea1.specie)
from Esemplare_Animale as ea1
where ea1.nome = ###INPUT###;

--operazione: visualizzare lo storico delle visite veterinarie di un esemplare di animale
select data, animale, Visita_Veterinaria_Storico.specie, malattia, peso, dieta, veterinario
from Visita_Veterinaria_Storico, Esemplare_Animale
where animale = codice and Visita_Veterinaria_Storico.specie = Esemplare_Animale.specie and codice = ###INPUT### and Esemplare_Animale.specie = ###INPUT###
union
select data, animale, Visita_Veterinaria_Corrente.specie, malattia, peso, dieta, veterinario
from Visita_Veterinaria_Corrente, Esemplare_Animale
where animale = codice and Visita_Veterinaria_Corrente.specie = Esemplare_Animale.specie and codice = ###INPUT### and Esemplare_Animale.specie = ###INPUT###;
--oppure
from Visita_Veterinaria_Storico, Esemplare_Animale
where animale = codice and Visita_Veterinaria_Storico.specie = Esemplare_Animale.specie and nome = ###INPUT###
union
select data, animale, Visita_Veterinaria_Corrente.specie, malattia, peso, dieta, veterinario
from Visita_Veterinaria_Corrente, Esemplare_Animale
where animale = codice and Visita_Veterinaria_Corrente.specie = Esemplare_Animale.specie and nome = ###INPUT###;

--operazione: visualizzare i turni degli interventi di pulizia dei rispettivi giorni della settimana, addetti, case e aree
select giorno_settimanale, codice_fiscale, Persona.nome, cognome, numero as casa, Area.nome as area
from Intervento_Pulizia, Persona, Casa, Area
where addetto = codice_fiscale and casa = numero and Intervento_Pulizia.area = Casa.area and Casa.area = Area.nome;
