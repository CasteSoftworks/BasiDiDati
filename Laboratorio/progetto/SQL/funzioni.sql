--CONTROLLO RITARDI <5 solo UNO a UNO da PHP perché è for each row

--controlla che i ritardi siano <5
create or replace function controllaRitardi() returns trigger as $$
declare
	cdf biblioteca.lettore.cdf%TYPE;
	k integer;
begin
	cdf:=NEW.persona;

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
	from biblioteca.lettore
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
	cf biblioteca.lettore.cdf%TYPE;
	type biblioteca.lettore.tipo%TYPE;
begin
	cf:=NEW.persona;

	select tipo into type
	from biblioteca.lettore
	where cdf=cf;

	select count(*) into quanti
	from biblioteca.prestato
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
	cf biblioteca.lettore.cdf%TYPE;
	rit integer;
begin
	oggi:=current_date;

	cf:=OLD.persona;
	d_riconsegna:=OLD.d_fine;

	if oggi>d_riconsegna then
		select n_ritardi into rit
        	from biblioteca.lettore
        	where cdf=cf;
        
        	update biblioteca.lettore  
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
	id_l biblioteca.prestato.volume%TYPE;
	ok boolean;
begin
	id_l:=NEW.volume;
	
	select disp into ok
	from biblioteca.copia
	where id=id_l;

	if ok=false then
		raise exception 'Libro già in prestito';
	else
		update biblioteca.copia set disp=NOT ok where id=id_l;
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
	id_l biblioteca.prestato.volume%TYPE;
begin
	id_l:=OLD.volume;
	update biblioteca.copia set disp=true where id=id_l;
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
	cf biblioteca.lettore.cdf%TYPE;
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

--STATISTICHE SEDE (tre sottofunzioni più funzione che le chiama)
--numero volumi
create or replace function volumiSede(idS varchar(5)) returns bigint as $$
declare
	qV bigint;
begin
	select count(c.id) into qV
	from biblioteca.copia c
	where c.dove=idS;
	return qV;
end;
$$ language 'plpgsql';
--numero isbn
create or replace function isbnSede(idS varchar(5)) returns bigint as $$
declare
        qI bigint;
begin               
        select count(distinct c.libro) into qI   
        from biblioteca.copia c
        where c.dove=idS;
	return qI;
end;
$$ language 'plpgsql';
--numero prestiti
create or replace function prestitiSede(idS varchar(5)) returns bigint as $$ 
declare
        qP bigint;
begin               
        select count(c.*) into qP
        from biblioteca.copia c
        where c.dove=idS and disp=FALSE;
        return qP;
end;
$$ language 'plpgsql';
--mega funzione
create or replace function statSede() returns table(
	sB varchar(5),
	qV bigint,
	qI bigint,
	qP bigint
) as $$
declare
	biblio biblioteca.biblioteca%ROWTYPE;
	qVol bigint;
	qIsb bigint;
	qPre bigint;
	ritorno record;
begin
	for biblio in select * from biblioteca.biblioteca
	loop
		qVol:=biblioteca.volumiSede(biblio.sede);
		qIsb:=biblioteca.isbnSede(biblio.sede);
		qPre:=biblioteca.prestitiSede(biblio.sede);
		
		return query
		select biblio.sede,qVol,qIsb,qPre;

	end loop;
end;
$$ language 'plpgsql';

--RICERCA ISBN con o senza SEDE
create or replace function cercaLibroISBN(isRic varchar(17))
returns table(
	title varchar(100),
	codice varchar(17),
	luogo varchar(100)
) as $$
declare
begin
        return query
	select titolo, id, indirizzo
        from biblioteca.libro l inner join biblioteca.copia c on l.isbn=c.libro inner join   
        biblioteca.biblioteca b on b.sede=c.dove
        where l.isbn=isRic and b.sede<>'00000' and c.disp=TRUE;
end;
$$ language 'plpgsql';

--RICERCA TITOLO con o senza SEDE
create or replace function cercaLibroTitolo(tiRic varchar(17))
returns table(
        title varchar(100),
        codice varchar(17),
        luogo varchar(100)
) as $$
declare
begin
        return query 
        select titolo, id, indirizzo
        from biblioteca.libro l inner join biblioteca.copia c on l.isbn=c.libro inner join            
        biblioteca.biblioteca b on b.sede=c.dove
        where LOWER(l.titolo) LIKE ('%'||LOWER(tiRic)||'%') and b.sede<>'00000' and c.disp=TRUE;
end;
$$ language 'plpgsql';

--RICERCA AUTORE
create or replace function cercaLibroAutore(auRic varchar(100))
returns table(
        title varchar(100),
        codice varchar(17),
        luogo varchar(100)
) as $$
declare
begin
        return query 
        select l.titolo, c.id, b.indirizzo
        from biblioteca.libro l inner join biblioteca.copia c on l.isbn=c.libro inner join            
        biblioteca.biblioteca b on b.sede=c.dove inner join biblioteca.scritto s 
	on l.isbn=s.libro inner join biblioteca.autore a on s.autore=a.id
        where LOWER(a.nome) LIKE ('%'||LOWER(auRic)||'%') and b.sede<>'00000' and c.disp=TRUE;
end;
$$ language 'plpgsql';

--RITARDI PER SEDE
--due sottofunzioni (una ritardo una per sede) più una che cicla le sedi
--per ritardo
create or replace function vediRitardo(libro varchar(10)) returns boolean as $$
declare 
	oggi date;
	d_f date;
begin
	oggi:=current_date;
	select d_fine into d_f
	from biblioteca.prestato
	where volume=libro;

	if oggi>d_f then
		return true;
	end if;

	return false;
end;
$$ language 'plpgsql';
--finale
create or replace function ritardiPerOgniSede() returns table (
	sede varchar(5),
	volume varchar(10),
	chi varchar(16)
) as $$
declare
	ut biblioteca.lettore%ROWTYPE;
	bi biblioteca.biblioteca%ROWTYPE;
	cp biblioteca.copia%ROWTYPE;
	vol biblioteca.prestato.volume%TYPE;
	ok boolean;
begin
	for bi in select * from biblioteca.biblioteca
	loop
		for ut in select * from biblioteca.lettore
		loop
			for cp in select * from biblioteca.copia
			loop
				select p.volume into vol
				from biblioteca.prestato p
				where p.persona=ut.cdf and cp.dove=bi.sede and p.volume=cp.id;
				
				ok:=biblioteca.vediRitardo(vol);
				
				if ok is true then
					return query 
					select bi.sede, vol, ut.cdf;
				end if;
			end loop;
		end loop;
	end loop;

end;
$$ language 'plpgsql';
select * from ritardiPerOgniSede();

create trigger lettoreNoneliminabile after delete on lettore for each row execute procedure checkSeHaPrestiti();
