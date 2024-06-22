--CONTROLLO RITARDI <5 solo UNO a UNO da PHP perché è for each row

--controlla che i ritardi siano <5
create or replace function controllaRitardi() returns trigger as $$
declare
	cdf lettore.cdf%TYPE;
	k integer;
begin
	cdf:=NEW.cdf;

	k:=biblioteca.calcolaRitardi(cdf);

	if k>4 then
		raise exception 'limite di ritardi raggiunto, rivolgersi alla biblioteca';
	end if;
	return NEW;
end;
$$ language 'plpgsql';

--estrae i ritardi dato un cdf
create or replace function calcolaRitardi(cf varchar(16)) returns integer as $$
declare
	nR integer;
begin
	select n_ritardi into nR
	from lettore
	where lettore.cdf=cf;

	return nR;
end;
$$ language 'plpgsql';

--trigger per controllo ritardi
create trigger controllaRitardi after insert on prestato for each row execute procedure controllaRitardi();

--PRESTITI ATTIVI (MAX 3 SE NORMALE, MAX 5 SE PREMIUM)
create or replace function controllaAttivi() returns trigger as $$
declare
	quanti bigint;
	cf lettore.cdf%TYPE;
	type lettore.tipo%TYPE;
begin
	cf:=NEW.persona;

	select tipo into type
	from lettore
	where cdf=cf;

	select count(*) into quanti
	from prestato
	where persona=cf;
	--premium
	if type=true then
		if quanti>5 then
			raise exception 'Troppi prestiti attivi (MASSIMO 5)';
		end if;
	else
		if quanti>3 then
			raise exception 'Troppi prestiti attivi (MASSIMO 3)';
		end if;
	end if;

	return NEW;
end;
$$ language 'plpgsql';

--trigger per controllo prestiti
create trigger prestitiAttivi after insert on prestato for each row execute procedure controllaAttivi();

--AGGIORNARE RITARDI
--con current_date
--controlla se il libro è in ritardo
create or replace function checkRitardo() returns trigger as $$
declare
	oggi date;
	d_riconsegna date;
	cf lettore.cdf%TYPE;
	rit integer;
begin
	oggi:=current_date;

	cf:=OLD.persona;
	d_riconsegna:=OLD.d_fine;

	if oggi>d_riconsegna then
		select n_ritardi into rit
        	from lettore
        	where cdf=cf;
        
        	update lettore  
        	set n_ritardi=(rit+1)
        	where cdf=cf;
	end if;
	return NULL;

end;
$$ language 'plpgsql';

--trigger per controllo se è in ritardo
create trigger aggiornaRitardo after delete on prestato for each row execute procedure checkRitardo();

--DISPONIBILITA' VOLUME
--funzione che controlla la disponibilità del volume su copia, e nel caso lo sia
--fa procedere con il prestito e segna la copia come non disponibile
create or replace function checkDisponibilita() returns trigger as $$
declare
	id_l prestato.volume%TYPE;
	ok boolean;
begin
	id_l:=NEW.volume;
	
	select disp into ok
	from copia
	where id=id_l;

	if ok=false then
		raise exception 'Libro già in prestito';
	else
		update copia set disp=NOT ok where id=id_l;
	end if;
	return NEW;
end;
$$ language 'plpgsql';

--trigger on insert su prestato
create trigger controlloDisponibilita after insert on prestato for each row execute procedure checkDisponibilita();

--      FUNZIONE COLLEGATA CHE, UNA VOLTA RIMOSSO UN LIBRO DAI PRESTITI LO
--      RIMETTE COME DISPONIBILE
create or replace function tornaDisponibile() returns trigger as $$
declare
	id_l prestato.volume%TYPE;
begin
	id_l:=OLD.volume;
	update copia set disp=true where id=id_l;
	return NULL;
end;
$$ language 'plpgsql';

--trigger su delete da prestito
create trigger rimettiDisponibile after delete on prestato for each row execute procedure tornaDiponibile();

--ESTENSIONE PRESTITO
--funzione
create or replace function estendiPrestito() returns trigger as $$
declare
	d_ric date;
	oggi date;
	cf lettore.cdf%TYPE;
begin
	oggi:=current_date;
	d_ric:=OLD.d_fine;

	if oggi>d_ric then
		raise exception 'Non è possibile allungare il periodo di prestito perché il libro è già in ritardo';
	end if;
	return NEW;
	
end;
$$ language 'plpgsql';

--trigger on update
create trigger estensioneData after update on prestato for each row execute procedure estendiPrestito();


