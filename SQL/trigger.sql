--vincolo integrità: ogni casa è destinata ad una sola specie
create or replace function controlla_casa_specie()
returns trigger
language plpgsql as $$
  declare
    n integer;
    gabbie_vuote integer;
  begin
    select count(*) into n
    from gabbia, casa
    where casa = numero and gabbia.area = casa.area and casa.area = new.area and numero = new.casa;

    select count(*) into gabbie_vuote
    from gabbia, casa
    where casa = numero and gabbia.area = casa.area and casa.area = new.area and numero = new.casa and gabbia.specie is null;

    if n=0 or n=gabbie_vuote or (new.specie is null and new.animale is null) or exists(
  		select *
  		from esemplare_animale, gabbia, casa
  		where animale = codice and gabbia.specie = esemplare_animale.specie and casa = numero and gabbia.area = casa.area and gabbia.specie = new.specie and numero = new.casa and casa.area = new.area
  	) then --primo inseriemento o gabbie tutte vuote, casa e area null o esiste un animale della sua specie (per induzione se viene inserito un animale (primo inerimento o gabbie tutte vuote), inserendo il secondo animale deve essere della sua stessa specie, atrimenti non viene inserito)
      return new;
    end if;

    raise notice 'specie non adeguata per questa casa';
  	return null;
  end;
$$;

create trigger controlla_inserimento_animale_gabbia
before insert or update on gabbia
for each row
execute procedure controlla_casa_specie();

--il blocco in scrittura da parte del utente su esemplare_animale.numero_visite_veterinarie avviene settendo i permessi di quel utente

--inserimento visita corrente - spostare in storico e poi inserire e calcolo attributo derivato
--attributo derivato: numero_visite_veterinarie = somma visite veterinarie storico e corrente
create or replace function controlla_visita_corrente()
returns trigger
language plpgsql as $$
  declare
    vvc record;
    nvv integer;
  begin
    select * into vvc from visita_veterinaria_corrente where animale = new.animale and specie = new.specie;
    if(vvc.data is null and vvc.animale is null and vvc.specie is null) then
      --calcolo attributo derivato
      select numero_visite_veterinarie into nvv
      from esemplare_animale
      where codice = new.animale and specie = new.specie;

      update esemplare_animale set numero_visite_veterinarie = (nvv+1) where codice = new.animale and specie = new.specie;

      return new;
    else
      --sposto visita corrente in storico
      insert into visita_veterinaria_storico(data, animale, specie, malattia, peso, dieta, veterinario) values (vvc.data, vvc.animale, vvc.specie, vvc.malattia, vvc.peso, vvc.dieta, vvc.veterinario);

      delete from visita_veterinaria_corrente where animale = new.animale and specie = new.specie;

      --calcolo attributo derivato
      select numero_visite_veterinarie into nvv
      from esemplare_animale
      where codice = new.animale and specie = new.specie;

      update esemplare_animale set numero_visite_veterinarie = (nvv+1) where codice = new.animale and specie = new.specie;

      return new;
    end if;
  end;
$$;

create trigger controlla_inserimento_visita_veterinaria
before insert on visita_veterinaria_corrente
for each row
execute procedure controlla_visita_corrente();

--il blocco in scrittura da parte del utente su visita_veterinaria_storico avviene settendo i permessi di quel utente

--eliminazione esemplare animale - setta data uscita (se null altrimenti non fa niente)
create or replace function controlla_esemplare()
returns trigger
language plpgsql as $$
  declare
    du integer;
    vvc record;
  begin
    select data_uscita into du from esemplare_animale where codice = old.animale and specie = old.specie;

    if du is null then
      select * into vvc from visita_veterinaria_corrente where animale = old.animale and specie = old.specie;
      insert into visita_veterinaria_storico(data, animale, specie, malattia, peso, dieta, veterinario) values (vvc.data, vvc.animale, vvc.specie, vvc.malattia, vvc.peso, vvc.dieta, vvc.veterinario);
      delete from visita_veterinaria_corrente where animale = old.animale and specie = old.specie;

      update esemplare_animale set data_uscita = now() where codice = old.animale and specie = old.specie;
    end if;
    return null;

  end;
$$;

create trigger controlla_eliminazione_esemplare
before delete on esemplare_animale
for each row
execute procedure controlla_esemplare();
