--
-- PostgreSQL database dump
--

-- Dumped from database version 13.11 (Debian 13.11-1.pgdg110+1)
-- Dumped by pg_dump version 15.6 (Debian 15.6-0+deb12u1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY biblioteca.scritto DROP CONSTRAINT IF EXISTS scritto_libro_fkey;
ALTER TABLE IF EXISTS ONLY biblioteca.scritto DROP CONSTRAINT IF EXISTS scritto_autore_fkey;
ALTER TABLE IF EXISTS ONLY biblioteca.prestato DROP CONSTRAINT IF EXISTS prestato_volume_fkey;
ALTER TABLE IF EXISTS ONLY biblioteca.prestato DROP CONSTRAINT IF EXISTS prestato_persona_fkey;
ALTER TABLE IF EXISTS ONLY biblioteca.copia DROP CONSTRAINT IF EXISTS copia_libro_fkey;
ALTER TABLE IF EXISTS ONLY biblioteca.copia DROP CONSTRAINT IF EXISTS copia_dove_fkey;
ALTER TABLE IF EXISTS ONLY biblioteca.bibliotecario DROP CONSTRAINT IF EXISTS bibliotecario_ufficio_fkey;
DROP TRIGGER IF EXISTS rimettidisponibile ON biblioteca.prestato;
DROP TRIGGER IF EXISTS prestitiattivi ON biblioteca.prestato;
DROP TRIGGER IF EXISTS estensionedata ON biblioteca.prestato;
DROP TRIGGER IF EXISTS controllodisponibilita ON biblioteca.prestato;
DROP TRIGGER IF EXISTS controllaritardi ON biblioteca.prestato;
DROP TRIGGER IF EXISTS aggiornaritardo ON biblioteca.prestato;
ALTER TABLE IF EXISTS ONLY public.movie DROP CONSTRAINT IF EXISTS movie_pkey;
ALTER TABLE IF EXISTS ONLY public.country DROP CONSTRAINT IF EXISTS country_pkey;
ALTER TABLE IF EXISTS ONLY public.country DROP CONSTRAINT IF EXISTS country_name_key;
ALTER TABLE IF EXISTS ONLY biblioteca.scritto DROP CONSTRAINT IF EXISTS scritto_pkey;
ALTER TABLE IF EXISTS ONLY biblioteca.prestato DROP CONSTRAINT IF EXISTS prestato_pkey;
ALTER TABLE IF EXISTS ONLY biblioteca.libro DROP CONSTRAINT IF EXISTS libro_pkey;
ALTER TABLE IF EXISTS ONLY biblioteca.lettore DROP CONSTRAINT IF EXISTS lettore_pkey;
ALTER TABLE IF EXISTS ONLY biblioteca.copia DROP CONSTRAINT IF EXISTS copia_pkey;
ALTER TABLE IF EXISTS ONLY biblioteca.biblioteca DROP CONSTRAINT IF EXISTS biblioteca_pkey;
ALTER TABLE IF EXISTS ONLY biblioteca.bibliotecario DROP CONSTRAINT IF EXISTS bibiliotecario_pkey;
ALTER TABLE IF EXISTS ONLY biblioteca.autore DROP CONSTRAINT IF EXISTS autore_pkey;
DROP TABLE IF EXISTS public.movie;
DROP TABLE IF EXISTS public.country;
DROP VIEW IF EXISTS biblioteca."statSedi";
DROP TABLE IF EXISTS biblioteca.scritto;
DROP TABLE IF EXISTS biblioteca.prestato;
DROP TABLE IF EXISTS biblioteca.libro;
DROP TABLE IF EXISTS biblioteca.lettore;
DROP TABLE IF EXISTS biblioteca.copia;
DROP TABLE IF EXISTS biblioteca.bibliotecario;
DROP TABLE IF EXISTS biblioteca.biblioteca;
DROP TABLE IF EXISTS biblioteca.autore;
DROP FUNCTION IF EXISTS biblioteca.vediritardo(libro character varying);
DROP FUNCTION IF EXISTS biblioteca.tornadisponibile();
DROP FUNCTION IF EXISTS biblioteca.ritardiperognisede();
DROP FUNCTION IF EXISTS biblioteca.estendiprestito();
DROP FUNCTION IF EXISTS biblioteca.controllaritardi();
DROP FUNCTION IF EXISTS biblioteca.controllaattivi();
DROP FUNCTION IF EXISTS biblioteca.checkritardo();
DROP FUNCTION IF EXISTS biblioteca.checklibro(id character varying);
DROP FUNCTION IF EXISTS biblioteca.checkdisponibilita();
DROP FUNCTION IF EXISTS biblioteca.cercalibrotitolo(tiric character varying);
DROP FUNCTION IF EXISTS biblioteca.cercalibroisbn(isric character varying);
DROP FUNCTION IF EXISTS biblioteca.cercalibroautore(auric character varying);
DROP FUNCTION IF EXISTS biblioteca.calcolaritardi(cf character varying);
-- *not* dropping schema, since initdb creates it
DROP SCHEMA IF EXISTS biblioteca;
--
-- Name: biblioteca; Type: SCHEMA; Schema: -; Owner: giacomo_castellana
--

CREATE SCHEMA biblioteca;


ALTER SCHEMA biblioteca OWNER TO giacomo_castellana;

--
-- Name: SCHEMA biblioteca; Type: COMMENT; Schema: -; Owner: giacomo_castellana
--

COMMENT ON SCHEMA biblioteca IS 'per il progetto';


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: calcolaritardi(character varying); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.calcolaritardi(cf character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
	nR integer;
begin
	select n_ritardi into nR
	from biblioteca.lettore
	where lettore.cdf=cf;

	return nR;
end;
$$;


ALTER FUNCTION biblioteca.calcolaritardi(cf character varying) OWNER TO giacomo_castellana;

--
-- Name: cercalibroautore(character varying); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.cercalibroautore(auric character varying) RETURNS TABLE(title character varying, codice character varying, luogo character varying)
    LANGUAGE plpgsql
    AS $$
declare
begin
        return query 
        select l.titolo, c.id, b.indirizzo
        from biblioteca.libro l inner join biblioteca.copia c on l.isbn=c.libro inner join            
        biblioteca.biblioteca b on b.sede=c.dove inner join biblioteca.scritto s 
	on l.isbn=s.libro inner join biblioteca.autore a on s.autore=a.id
        where LOWER(a.nome) LIKE ('%'||LOWER(auRic)||'%') and b.sede<>'00000' and c.disp=TRUE;
end;
$$;


ALTER FUNCTION biblioteca.cercalibroautore(auric character varying) OWNER TO giacomo_castellana;

--
-- Name: cercalibroisbn(character varying); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.cercalibroisbn(isric character varying) RETURNS TABLE(title character varying, codice character varying, luogo character varying)
    LANGUAGE plpgsql
    AS $$
declare
begin
        return query
	select titolo, id, indirizzo
        from biblioteca.libro l inner join biblioteca.copia c on l.isbn=c.libro inner join   
        biblioteca.biblioteca b on b.sede=c.dove
        where l.isbn=isRic and b.sede<>'00000' and c.disp=TRUE;
end;
$$;


ALTER FUNCTION biblioteca.cercalibroisbn(isric character varying) OWNER TO giacomo_castellana;

--
-- Name: cercalibrotitolo(character varying); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.cercalibrotitolo(tiric character varying) RETURNS TABLE(title character varying, codice character varying, luogo character varying)
    LANGUAGE plpgsql
    AS $$
declare
begin
        return query 
        select titolo, id, indirizzo
        from biblioteca.libro l inner join biblioteca.copia c on l.isbn=c.libro inner join            
        biblioteca.biblioteca b on b.sede=c.dove
        where LOWER(l.titolo) LIKE ('%'||LOWER(tiRic)||'%') and b.sede<>'00000' and c.disp=TRUE;
end;
$$;


ALTER FUNCTION biblioteca.cercalibrotitolo(tiric character varying) OWNER TO giacomo_castellana;

--
-- Name: checkdisponibilita(); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.checkdisponibilita() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION biblioteca.checkdisponibilita() OWNER TO giacomo_castellana;

--
-- Name: checklibro(character varying); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.checklibro(id character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare
begin
        FOUND:=false; 
        perform *
        from prestato
        where volume=id; 
        
        if FOUND=true then 
                return true;
        end if; 
        return false; 
end;    
$$;


ALTER FUNCTION biblioteca.checklibro(id character varying) OWNER TO giacomo_castellana;

--
-- Name: checkritardo(); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.checkritardo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION biblioteca.checkritardo() OWNER TO giacomo_castellana;

--
-- Name: controllaattivi(); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.controllaattivi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION biblioteca.controllaattivi() OWNER TO giacomo_castellana;

--
-- Name: controllaritardi(); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.controllaritardi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION biblioteca.controllaritardi() OWNER TO giacomo_castellana;

--
-- Name: estendiprestito(); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.estendiprestito() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION biblioteca.estendiprestito() OWNER TO giacomo_castellana;

--
-- Name: ritardiperognisede(); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.ritardiperognisede() RETURNS TABLE(sede character varying, volume character varying, chi character varying)
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION biblioteca.ritardiperognisede() OWNER TO giacomo_castellana;

--
-- Name: tornadisponibile(); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.tornadisponibile() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	id_l biblioteca.prestato.volume%TYPE;
begin
	id_l:=OLD.volume;
	update biblioteca.copia set disp=true where id=id_l;
	return NULL;
end;
$$;


ALTER FUNCTION biblioteca.tornadisponibile() OWNER TO giacomo_castellana;

--
-- Name: vediritardo(character varying); Type: FUNCTION; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE FUNCTION biblioteca.vediritardo(libro character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION biblioteca.vediritardo(libro character varying) OWNER TO giacomo_castellana;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: autore; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.autore (
    id character varying(8) NOT NULL,
    nome character varying(100) NOT NULL,
    d_nascita date,
    d_morte date,
    bio text
);


ALTER TABLE biblioteca.autore OWNER TO giacomo_castellana;

--
-- Name: biblioteca; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.biblioteca (
    sede character varying(5) NOT NULL,
    indirizzo character varying(100),
    nome character varying(100) NOT NULL
);


ALTER TABLE biblioteca.biblioteca OWNER TO giacomo_castellana;

--
-- Name: bibliotecario; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.bibliotecario (
    cdf character varying(16) NOT NULL,
    nome character varying(100) NOT NULL,
    ufficio character varying(5) NOT NULL,
    pass character varying(16) NOT NULL
);


ALTER TABLE biblioteca.bibliotecario OWNER TO giacomo_castellana;

--
-- Name: copia; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.copia (
    id character varying(10) NOT NULL,
    libro character varying(17) NOT NULL,
    dove character varying(5) NOT NULL,
    disp boolean NOT NULL
);


ALTER TABLE biblioteca.copia OWNER TO giacomo_castellana;

--
-- Name: lettore; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.lettore (
    cdf character varying(16) NOT NULL,
    nome character varying(100) NOT NULL,
    tipo boolean NOT NULL,
    n_ritardi integer NOT NULL,
    pass character varying(16) NOT NULL
);


ALTER TABLE biblioteca.lettore OWNER TO giacomo_castellana;

--
-- Name: libro; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.libro (
    isbn character varying(17) NOT NULL,
    titolo character varying(100) NOT NULL,
    casa_ed character varying(50),
    trama text
);


ALTER TABLE biblioteca.libro OWNER TO giacomo_castellana;

--
-- Name: prestato; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.prestato (
    persona character varying(16) NOT NULL,
    volume character varying(10) NOT NULL,
    d_fine date NOT NULL
);


ALTER TABLE biblioteca.prestato OWNER TO giacomo_castellana;

--
-- Name: scritto; Type: TABLE; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TABLE biblioteca.scritto (
    autore character varying(8) NOT NULL,
    libro character varying(17) NOT NULL
);


ALTER TABLE biblioteca.scritto OWNER TO giacomo_castellana;

--
-- Name: statSedi; Type: VIEW; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE VIEW biblioteca."statSedi" AS
 WITH np AS (
         SELECT b_1.sede AS posto,
            count(DISTINCT c_1.id) AS npr
           FROM (biblioteca.biblioteca b_1
             LEFT JOIN biblioteca.copia c_1 ON ((((b_1.sede)::text = (c_1.dove)::text) AND (c_1.disp = false))))
          GROUP BY b_1.sede
        )
 SELECT b.sede AS dove,
    count(DISTINCT c.id) AS qid,
    count(DISTINCT c.libro) AS qis,
    COALESCE(n.npr, (0)::bigint) AS qpr
   FROM ((biblioteca.biblioteca b
     LEFT JOIN biblioteca.copia c ON (((b.sede)::text = (c.dove)::text)))
     LEFT JOIN np n ON (((b.sede)::text = (n.posto)::text)))
  GROUP BY b.sede, n.npr
  ORDER BY b.sede;


ALTER TABLE biblioteca."statSedi" OWNER TO giacomo_castellana;

--
-- Name: country; Type: TABLE; Schema: public; Owner: giuseppe_difilippo
--

CREATE TABLE public.country (
    iso3 character(3) NOT NULL,
    name character varying(20) NOT NULL
);


ALTER TABLE public.country OWNER TO giuseppe_difilippo;

--
-- Name: movie; Type: TABLE; Schema: public; Owner: marco_montali
--

CREATE TABLE public.movie (
    id character varying(10) NOT NULL,
    official_title character varying(200) NOT NULL,
    budget numeric(12,2),
    year character(4),
    length integer,
    plot text
);


ALTER TABLE public.movie OWNER TO marco_montali;

--
-- Data for Name: autore; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.autore VALUES ('21800658', 'Fiore Dei Liberi', '1350-01-01', '1410-01-01', 'Fiore dei Liberi è stato un maestro di scherma italiano e autore del celebre manuale di arti marziali "Fior di Battaglia" (Il Fiore di Battaglia). Nato a Cividale del Friuli, Fiore ha viaggiato in tutta Europa, apprendendo e insegnando le tecniche di combattimento con la spada e altre armi. Il suo manuale, scritto in volgare italiano, è uno dei più antichi e completi trattati di scherma medievale e include tecniche di combattimento a mani nude, con spada, daga, lancia e cavallo.');
INSERT INTO biblioteca.autore VALUES ('29429327', 'Cormac McCarty', '1933-07-20', '2023-06-13', 'Cormac McCarthy è stato un autore statunitense noto per i suoi romanzi di grande intensità e oscurità. Tra le sue opere più celebri ci sono "La strada" (vincitore del Premio Pulitzer per la narrativa nel 2007), "Non è un paese per vecchi" e "Meridiano di sangue". I suoi scritti spesso esplorano temi di violenza, redenzione e la inesorabile durezza della vita umana. Le sue opere sono state adattate con successo in film acclamati dalla critica.');
INSERT INTO biblioteca.autore VALUES ('63131341', 'J.R.R. Tolkien', '1892-01-03', '1973-09-02', 'John Ronald Reuel Tolkien è stato un autore, filologo e accademico britannico, noto soprattutto per i suoi celebri romanzi fantasy "Lo Hobbit" e "Il Signore degli Anelli". Nato in Sudafrica e cresciuto in Inghilterra, Tolkien è stato professore di anglosassone e di letteratura inglese medievale alla Università di Oxford. Le sue opere hanno creato mondi complessi e dettagliati, popolati da razze fantastiche e miti elaborati, e hanno avuto un enorme impatto sulla letteratura fantasy moderna. Oltre ai suoi romanzi, Tolkien ha scritto numerosi saggi e opere accademiche, ed è stato uno dei membri del gruppo letterario degli Inklings.');
INSERT INTO biblioteca.autore VALUES ('90952744', 'Christopher Paolini', '1983-11-17', NULL, 'Christopher Paolini è un autore statunitense noto soprattutto per la serie fantasy "Ciclo della Eredità". Paolini ha iniziato a scrivere il primo libro della serie, "Eragon", quando aveva solo quindici anni. La storia, che segue le avventure di un giovane allevatore di draghi, è diventata un bestseller internazionale e ha dato origine a tre seguiti: "Eldest", "Brisingr" e "Inheritance". Dopo il successo del ciclo, Paolini ha continuato a lavorare su nuovi progetti, espandendo il mondo che ha creato con racconti aggiuntivi e altre opere di fantasia.');
INSERT INTO biblioteca.autore VALUES ('56983713', 'William Gibson', '1948-03-17', NULL, 'William Gibson è un autore di fantascienza canadese-americano, considerato uno dei padri del genere cyberpunk. Ha raggiunto la fama con il suo romanzo di esordio "Neuromante" (1984), che ha vinto i premi Hugo, Nebula e Philip K. Dick. Il romanzo ha introdotto molti concetti innovativi, tra cui il cyberspazio, e ha influenzato profondamente la cultura pop e la tecnologia. Gibson ha continuato a scrivere numerosi romanzi e racconti, esplorando temi come la interazione tra tecnologia e società.');
INSERT INTO biblioteca.autore VALUES ('35572997', 'Antonio Manciolino', NULL, NULL, 'Antonio Manciolino è stato un maestro di scherma italiano, noto per il suo manuale "Opera Nova", pubblicato intorno al 1531. Questo trattato è uno dei primi libri stampati sulla scherma e descrive dettagliatamente le tecniche di combattimento con la spada e il pugnale. Manciolino apparteneva alla tradizione della scherma bolognese, una delle scuole più influenti del Rinascimento italiano, e il suo lavoro ha contribuito a diffondere le tecniche di questa scuola in tutta Europa.');
INSERT INTO biblioteca.autore VALUES ('83560072', 'Terry Brooks', '1944-01-08', NULL, 'Terry Brooks è un autore americano noto per la sua serie di romanzi fantasy "Shannara". Nato a Sterling, Illinois, ha iniziato la sua carriera letteraria negli anni 70 con il suo primo romanzo, "La Spada di Shannara". La sua opera ha avuto un grande impatto sul genere fantasy, rendendolo uno degli autori più venduti al mondo. Brooks ha continuato a scrivere numerosi libri, esplorando vari universi e temi, guadagnando una vasta schiera di fan in tutto il mondo.');
INSERT INTO biblioteca.autore VALUES ('20386502', 'Henry M. Richardson', NULL, NULL, 'Tabletop RPG Designer from Portland, OR');
INSERT INTO biblioteca.autore VALUES ('62858412', 'Guido Barbujani', '1955-01-31', NULL, 'Guido Barbujani è un genetista e scrittore italiano. Durante la sua carriera accademica, ha lavorato alla Stony Brook University, alle Università di Padova e Bologna, e dal 1996 è professore ordinario di genetica alla Università di Ferrara. Dal 2011 al 2014 è stato presidente della Associazione Genetica Italiana');
INSERT INTO biblioteca.autore VALUES ('24123327', 'Lisa Vozza', '1966-01-01', NULL, 'Biologa e divulgatrice scientifica, è Chief Scientific Officer presso la Associazione Italiana per la Ricerca sul Cancro (AIRC). Insieme a Rino Rappuoli nel 2010 ha vinto il Premio letterario Galileo con "I vaccini dellaera globale"');
INSERT INTO biblioteca.autore VALUES ('dpub1BBR', 'Losim Trumivis', '1002-06-02', '1058-05-28', 'lorem ipsum crux trembus');


--
-- Data for Name: biblioteca; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.biblioteca VALUES ('00000', 'Via del Pozzo 46, Pavia', 'Magazzino Centrale');
INSERT INTO biblioteca.biblioteca VALUES ('26620', 'via Liberazione 33, Roma', 'Biblioteca Libera');
INSERT INTO biblioteca.biblioteca VALUES ('60297', 'Via Della Stazione 44, Paderno Dugnano', 'Biblioteca della Stazione');
INSERT INTO biblioteca.biblioteca VALUES ('9787', 'Viale Traiano 33, Roma', 'Biblioteca del Viale');
INSERT INTO biblioteca.biblioteca VALUES ('13576', 'Via Caproni 94, Vieste', 'Biblioteca Civica Caproni');


--
-- Data for Name: bibliotecario; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.bibliotecario VALUES ('RSSDVD78D10H501Q', 'Davide Rossi', '9787', 'OrsoBubu');
INSERT INTO biblioteca.bibliotecario VALUES ('BNCMRT82C30H501N', 'Marta Bianchi', '60297', 'OrsoBalu');
INSERT INTO biblioteca.bibliotecario VALUES ('FRRLCA85B20H501M', 'Luca Ferretti', '60297', 'OrsoKoda');
INSERT INTO biblioteca.bibliotecario VALUES ('MRNGLI90A01H501Z', 'Giulia Marini', '13576', 'OrsoYogi');
INSERT INTO biblioteca.bibliotecario VALUES ('CSTGCM01B06F205W', 'Giacomo Castellana', '00000', 'OrsoLabiato');


--
-- Data for Name: copia; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.copia VALUES ('J04GR1pmgy', '978-88-45-27240-0', '9787', true);
INSERT INTO biblioteca.copia VALUES ('LJbVIOY9VO', '978-88-45-27240-0', '9787', true);
INSERT INTO biblioteca.copia VALUES ('EWJ1lvYlRt', '978-88-45-27240-0', '9787', true);
INSERT INTO biblioteca.copia VALUES ('ohPo1RE1LI', '979-86-28-76262-2', '60297', true);
INSERT INTO biblioteca.copia VALUES ('25V9y4QcDE', '979-84-67-03682-3', '26620', true);
INSERT INTO biblioteca.copia VALUES ('AO7gffceBy', '978-88-17-06162-9', '9787', true);
INSERT INTO biblioteca.copia VALUES ('n5TvJRNfs8', '978-88-17-06162-9', '9787', true);
INSERT INTO biblioteca.copia VALUES ('eEGPb2AGTc', '978-88-84-74176-9', '13576', true);
INSERT INTO biblioteca.copia VALUES ('PFswvHAiSz', '978-88-84-74176-9', '13576', true);
INSERT INTO biblioteca.copia VALUES ('V8me7lU5Aa', '978-14-47-28945-6', '9787', true);
INSERT INTO biblioteca.copia VALUES ('50aLoj9U1b', '978-88-17-06163-6', '9787', true);
INSERT INTO biblioteca.copia VALUES ('GI7nuzbBqx', '978-88-17-06163-6', '9787', true);
INSERT INTO biblioteca.copia VALUES ('muQWYcQCno', '978-88-17-06163-6', '13576', true);
INSERT INTO biblioteca.copia VALUES ('gp271KDzBD', '978-88-17-06163-6', '13576', true);
INSERT INTO biblioteca.copia VALUES ('lqeFIbP9f7', '978-88-17-06163-6', '13576', true);
INSERT INTO biblioteca.copia VALUES ('8oNeTJdAT9', '978-88-17-06164-3', '26620', true);
INSERT INTO biblioteca.copia VALUES ('gtIwKgYs68', '978-88-17-06164-3', '26620', true);
INSERT INTO biblioteca.copia VALUES ('3HFDJgSEy7', '978-88-17-06164-3', '26620', true);
INSERT INTO biblioteca.copia VALUES ('NrNbsG7JZe', '978-88-17-06164-3', '26620', true);
INSERT INTO biblioteca.copia VALUES ('eyaNa34C7F', '978-88-17-06960-1', '13576', true);
INSERT INTO biblioteca.copia VALUES ('cFKzfDDrmi', '978-88-17-06960-1', '13576', true);
INSERT INTO biblioteca.copia VALUES ('nhkwuaf1EK', '978-88-17-06960-1', '13576', true);
INSERT INTO biblioteca.copia VALUES ('Al877pSWJi', '978-88-17-06960-1', '9787', true);
INSERT INTO biblioteca.copia VALUES ('Nw7ELKd7bz', '978-88-45-29000-2', '60297', true);
INSERT INTO biblioteca.copia VALUES ('3lTEVn5ifr', '978-88-45-29000-2', '9787', true);
INSERT INTO biblioteca.copia VALUES ('nqEHTof2HH', '978-88-45-29000-2', '13576', true);
INSERT INTO biblioteca.copia VALUES ('WV3u8IgMIM', '978-88-45-29000-2', '26620', true);
INSERT INTO biblioteca.copia VALUES ('mfsby60X2q', '978-88-45-29000-2', '26620', true);
INSERT INTO biblioteca.copia VALUES ('NGrHEfGFOo', '978-88-06-23398-3', '60297', true);
INSERT INTO biblioteca.copia VALUES ('BPfEP3ySbN', '978-88-06-23398-3', '60297', true);
INSERT INTO biblioteca.copia VALUES ('AL2MFxKW4l', '978-88-06-23398-3', '60297', true);
INSERT INTO biblioteca.copia VALUES ('BoCG1khi30', '978-88-06-23398-3', '60297', true);
INSERT INTO biblioteca.copia VALUES ('p2DNSKMvVV', '978-88-06-23398-3', '13576', true);
INSERT INTO biblioteca.copia VALUES ('2cXoyVC5xN', '978-88-04-37655-2', '60297', true);
INSERT INTO biblioteca.copia VALUES ('yWR6JWza9U', '978-88-04-37655-2', '9787', true);
INSERT INTO biblioteca.copia VALUES ('6Dw9M4SYJ9', '978-88-04-37655-2', '26620', true);
INSERT INTO biblioteca.copia VALUES ('sIe4oKy2s6', '978-88-04-37832-7', '9787', true);
INSERT INTO biblioteca.copia VALUES ('ycGiQFDpVa', '978-88-04-37832-7', '9787', true);
INSERT INTO biblioteca.copia VALUES ('UVbEFrUQVS', '978-88-04-37832-7', '60297', true);
INSERT INTO biblioteca.copia VALUES ('X9IeDXgx7L', '978-88-04-38404-5', '60297', true);
INSERT INTO biblioteca.copia VALUES ('ppfERSyjb7', '978-88-04-38404-5', '13576', true);
INSERT INTO biblioteca.copia VALUES ('LhdwfiibLl', '978-17-92-33301-9', '9787', true);
INSERT INTO biblioteca.copia VALUES ('hNuok9Tj44', '978-17-92-33301-9', '13576', true);
INSERT INTO biblioteca.copia VALUES ('I2XaASziu5', '978-17-92-33301-9', '26620', true);
INSERT INTO biblioteca.copia VALUES ('9s3Is0ACg8', '978-17-92-34609-5', '13576', true);
INSERT INTO biblioteca.copia VALUES ('NwyFYb1xTj', '978-17-92-34609-5', '9787', true);
INSERT INTO biblioteca.copia VALUES ('3viJJNbQuf', '978-88-08-72125-9', '26620', true);
INSERT INTO biblioteca.copia VALUES ('nGORvgYFkO', '978-88-08-72125-9', '13576', true);
INSERT INTO biblioteca.copia VALUES ('otLll13moF', '978-88-08-72125-9', '9787', true);
INSERT INTO biblioteca.copia VALUES ('QzmJig9lah', '978-88-08-72125-9', '60297', true);
INSERT INTO biblioteca.copia VALUES ('eNtw9IsWvv', '978-88-45-27240-0', '9787', false);
INSERT INTO biblioteca.copia VALUES ('1PuHkRoMwg', '979-86-28-76262-2', '60297', false);
INSERT INTO biblioteca.copia VALUES ('ZuxEuWmiiu', '978-88-84-74176-9', '13576', false);
INSERT INTO biblioteca.copia VALUES ('MN68KLNDU0', '979-84-67-03682-3', '26620', false);
INSERT INTO biblioteca.copia VALUES ('kDnyfXs20H', '978-88-17-06162-9', '9787', false);
INSERT INTO biblioteca.copia VALUES ('1yPtg0KHCu', '979-86-28-76262-2', '60297', false);
INSERT INTO biblioteca.copia VALUES ('sARl7WwbFA', '978-88-45-29000-2', '60297', false);
INSERT INTO biblioteca.copia VALUES ('BPnOiNxj2p', '978-14-47-28945-6', '9787', true);
INSERT INTO biblioteca.copia VALUES ('LAzUtZnlD6', '978-14-47-28945-6', '26620', false);
INSERT INTO biblioteca.copia VALUES ('WzHLwe8dV0', '978-14-47-28945-6', '9787', true);
INSERT INTO biblioteca.copia VALUES ('B9NMu238g9', '123-45-67-89012-3', '13576', true);
INSERT INTO biblioteca.copia VALUES ('yb6hubeE0v', '123-45-67-89012-3', '13576', true);
INSERT INTO biblioteca.copia VALUES ('yGR0Q6nSIb', '123-45-67-89012-3', '13576', true);
INSERT INTO biblioteca.copia VALUES ('x6pWiZeTQI', '123-45-67-89012-3', '13576', true);


--
-- Data for Name: lettore; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.lettore VALUES ('CNTFRC88D25H501X', 'Federica Conti', false, 0, 'ReOberon');
INSERT INTO biblioteca.lettore VALUES ('CSTMRC90A01H501Z', 'Marco Castellana', false, 0, 'ReScar');
INSERT INTO biblioteca.lettore VALUES ('RSSLRA85B60H501N', 'Laura Rossi', true, 0, 'ReMida');
INSERT INTO biblioteca.lettore VALUES ('BNCLSN80A01H501K', 'Alessandro Bianchi', false, 0, 'ReArtu');


--
-- Data for Name: libro; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.libro VALUES ('978-88-45-27240-0', 'Il Silmarillion', 'Bompiani', '"Il Silmarillion", iniziato nel 1917 e la cui elaborazione è stata proseguita da Tolkien fino alla morte, rappresenta il tronco da cui si sono diramate tutte le sue successive opere narrative. "Opera prima", dunque, essa costituisce il repertorio mitico di Tolkien, quello da cui è derivata la filiazione delle sue favole: "Lo Hobbit", "Il Signore degli Anelli", "Il cacciatore di Draghi". "Il Silmarillion", che comprende cinque racconti legati come i capitoli di una unica storia sacra, narra la parabola di una caduta: dalla "musica degli inizi", il momento cosmogonico, alla guerra di Elfi e Uomini contro lo Avversario. Lo ultimo dei racconti costituisce lo antecedente immediato del "Signore degli Anelli"');
INSERT INTO biblioteca.libro VALUES ('978-88-17-06162-9', 'Eragon', 'Rizzoli', 'Quando Eragon trova una liscia pietra blu nella foresta, è convinto che gli sia toccata una grande fortuna: potrà venderla e nutrire la sua famiglia per tutto lo inverno. Ma la pietra in realtà è un uovo. Quando si schiude rivelando il suo straordinario contenuto, un cucciolo di drago, Eragon scopre che gli è toccato in sorte una eredità antica come lo Impero. Forte di una spada magica e dei consigli di un vecchio cantastorie, dovrà cavarsela in un universo denso di magia, mistero e insidie, imparare a distinguere chi gli è amico da chi gli è nemico, dimostrare di essere il degno erede dei Cavalieri dei Draghi.');
INSERT INTO biblioteca.libro VALUES ('978-14-47-28945-6', 'Blood Meridian', 'Picador', 'Through the hostile landscape of the Texas-Mexico border wanders the Kid, a fourteen year-old Tennessean who is quickly swept-up in the relentless tide of blood. But the apparent chaos is not without its order: while Americans hunt Indians – collecting scalps as their bloody trophies – they too are stalked as prey.');
INSERT INTO biblioteca.libro VALUES ('978-04-41-56959-5', 'Neuromancer', 'Penguin', '"Neuromancer" by William Gibson is a seminal science fiction novel set in a cyberpunk future where cyberspace, artificial intelligence, and megacorporations dominate society. The story follows Case, a washed-up computer hacker who is hired by a mysterious employer for a final, dangerous job. As he navigates a world of high-tech espionage and virtual realities, Case confronts themes of identity, technology, and power. The novel''s gritty, fast-paced narrative and richly imagined setting have made it a cornerstone of the cyberpunk genre.');
INSERT INTO biblioteca.libro VALUES ('979-84-67-03682-3', 'L''Ultima Impresa', '/', 'L''ombra nera della tempesta incombe minacciando di gettare nell''oblio la luce di un''intera epoca.

Un manipolo di uomini è impegnato nel salvare dall''abisso la memoria delle proprie gesta prima che finisca il tempo del loro mondo.

Non sono le imprese dei grandi protagonisti, ma le azioni quotidiane degli sconosciuti comprimari, i mattoni che compongono il tempio della storia.

Senza concessioni al romanticismo, fatti e misfatti vengono rivissuti attraverso gli occhi nostalgici di coloro che ne sono stati protagonisti, con tutta la crudezza e il realismo che resta una volta tolta la coperta fiorita della celebrazione.

Le famose e famigerate Bande Nere del Gran Diavolo, il signor Giovanni de'' Medici, si ritrovano tutt''altro che vinte per avviare un''ultima impresa che possa incidere il loro nome nella Storia.

Il vento del tempo ha ormai spazzato via il loro mondo fatto di riti antichi e sapienze marziali. Ultimi custodi della voce di Marte, gli uomini in cremisi tramano nella tempesta decisi a non varcare la soglia dell''Averno con la vergogna di esser periti fallendo.

Non vi è esitazione nel loro animo, né crudeltà innecessaria nei loro gesti.

I loro avversari s''indaffarano a cancellare dalla memoria le storie di questi uomini, a far scordare al mondo l''ardore e la fierezza dei Diavoli delle Bande Nere.

Queste sono le loro storie, la loro memoria affidata ai pochi che la sapranno portare, e la cronaca della loro Ultima Impresa.');
INSERT INTO biblioteca.libro VALUES ('979-86-28-76262-2', 'Flos Duellatorum', '/', 'In questo testo ho riportato la trascrizione e traduzione del "Flos Duellatorum" del maestro Fiore dei Liberi. Si tratta di un manoscritto del XV secolo di cui purtroppo il testo originale è andato perduto: si dispone unicamente di un facsimile stilato dal filologo Francesco Novati nel 1902. Come sempre potrai trovare le immagini prese dal manoscritto e le glosse in lingua originale ed in italiano, condite qua e là da alcune note utili a rendere maggiormente chiara la traduzione. Come sempre verranno unicamente riportate le parole dell''autore senza mie opinioni o interpretazioni. Sperando che questo volume possa esserti utile nello studio delle arti marziali europee, sia che tu faccia parte di un gruppo di rievocazione storica o di una scuola di scherma, ti auguro buona lettura.');
INSERT INTO biblioteca.libro VALUES ('978-88-06-23398-3', 'Non è un paese per vecchi', 'Einaudi', 'In un paesaggio desolato del Texas occidentale, Llewelyn Moss trova una valigia contenente due milioni di dollari in mezzo a una scena di crimine. La sua decisione di tenere i soldi lo mette nel mirino di un killer spietato, Anton Chigurh, e di un vecchio sceriffo, Ed Tom Bell, che cerca di proteggere Moss e mantenere lo ordine in un mondo che sembra sempre più fuori controllo.');
INSERT INTO biblioteca.libro VALUES ('978-88-45-29000-2', 'Il Signore degli Anelli', 'Bompiani', 'Nel tranquillo mondo della Contea, il giovane hobbit Frodo Baggins eredita un anello magico con il potere di dominare il destino del mondo. Con l’aiuto di un coraggioso gruppo di amici e alleati, Frodo intraprende un pericoloso viaggio verso il Monte Fato per distruggere lo Anello e sconfiggere il malvagio Sauron, il Signore Oscuro che cerca di ottenere il potere assoluto.');
INSERT INTO biblioteca.libro VALUES ('978-88-17-06163-6', 'Eldest', 'Rizzoli', 'Dopo la vittoria a Farthen Dûr, Eragon e il suo drago Saphira viaggiano verso Ellesméra per continuare il loro addestramento sotto la guida degli Elfi. Mentre il giovane Cavaliere dei Draghi impara a padroneggiare nuove abilità, suo cugino Roran lotta per proteggere la loro casa dalla tirannia di Galbatorix. La guerra si intensifica e il destino di Alagaësia è sempre più incerto.');
INSERT INTO biblioteca.libro VALUES ('978-88-17-06164-3', 'Brisingr', 'Rizzoli', 'Eragon e il suo drago Saphira continuano la loro lotta contro l’oppressivo Impero di Galbatorix. Mentre Eragon scopre di più sul passato dei Cavalieri dei Draghi e dei misteri della magia, deve affrontare scelte difficili che metteranno alla prova la sua lealtà e il suo coraggio. La ricerca di giustizia e libertà porterà Eragon a confrontarsi con potenti nemici e rivelazioni inaspettate.');
INSERT INTO biblioteca.libro VALUES ('978-88-17-06960-1', 'Inheritance', 'Rizzoli', 'Eragon e Saphira affrontano la loro più grande sfida mentre si preparano a confrontarsi con il malvagio re Galbatorix. Con lo aiuto di vecchi e nuovi alleati, il giovane Cavaliere dei Draghi deve trovare la forza per sconfiggere il tiranno e liberare Alagaësia. Tra rivelazioni sorprendenti e battaglie epiche, il destino del regno sarà deciso in un finale mozzafiato.');
INSERT INTO biblioteca.libro VALUES ('978-88-04-37655-2', 'La Spada di Shannara', 'Mondadori', 'Shea Ohmsford vive una vita tranquilla nel villaggio di Valle di Ombra finché scopre di essere lo ultimo discendente della casa reale di Shannara e lo unico in grado di brandire la Spada di Shannara. Con lo aiuto del druido Allanon, Shea deve intraprendere un pericoloso viaggio per trovare la spada leggendaria e sconfiggere il malvagio Signore degli Inganni, che minaccia il mondo delle Quattro Terre.');
INSERT INTO biblioteca.libro VALUES ('978-88-04-37832-7', 'Le Pietre Magiche di Shannara', 'Mondadori', 'Wil Ohmsford, nipote di Shea, è chiamato a proteggere la giovane Amberle Elessedil, una delle Eletti destinata a rigenerare lo Albero di Ellcrys. Con l oaiuto delle Pietre Magiche di Shannara, Wil deve affrontare demoni antichi e forze oscure per salvare il mondo dalla distruzione. La loro missione è complicata e pericolosa, ma il destino delle Quattro Terre dipende dal loro successo.');
INSERT INTO biblioteca.libro VALUES ('978-88-04-38404-5', 'La Canzone di Shannara', 'Mondadori', 'Brin Ohmsford, dotata del potere della Canzone Magica, deve intraprendere un viaggio per distruggere il libro malvagio conosciuto come Ildatch, che minaccia di corrompere e controllare tutte le Quattro Terre. Con lo aiuto del fratello Jair e del druido Allanon, Brin si trova ad affrontare sfide formidabili e nemici pericolosi, in una lotta per salvare il loro mondo dalla distruzione totale.');
INSERT INTO biblioteca.libro VALUES ('978-17-92-33301-9', 'Deathblow', 'Richardson Games', 'A rolepalying game of gang warfare in a lawless wasteland');
INSERT INTO biblioteca.libro VALUES ('978-17-92-34609-5', 'Deathblow Sourcebook', 'Richardson Games', 'Expand yor games of deathblow with this must-have universe guide and DeathMaster resource');
INSERT INTO biblioteca.libro VALUES ('978-88-84-74176-9', 'Opera Nova', 'Il Cerchio', 'Il primo trattato della Scuola Bolognese mai stampato (nel 1531, scritto però fra il 1522 e il 1523)), rarissimo e che anticamente si credeva perduto, viene riproposto oggi in un''edizione definitiva che ne svela finalmente tutti i segreti: completo di esaurienti note storiche e di note tecniche esplicative che ne rivelano il contenuto tecnico azione per azione, illustrazioni delle guardie e delle tecniche di combattimento principali (tratte dai principali manuali di scherma coevi o ricostruite in computer graphic), appendici schermistiche e sulle armi utilizzate. Questo volume presenta il lavoro interpretativo eseguito dai curatori, basato sull''impegno scientifico collettivo di anni della Sala d''Arme Achille Marozzo e sull''esperienza accumulata nella preparazione di altre pubblicazioni di inediti in materia di scherma storica: Fiore dei Liberi (per la prima volta l''analisi dei tre manoscritti esistenti del Flos Duellatorum) Filippo Vadi, Anonimo Bolognese, Francesco altoni. In particolare ai fini della comprensione risulta indispensabile la comparazione offerta ai lettori con gli altri autori della Scuola Bolognese, prima fra tutti e impresindibile quella con il Maestro piu'' antico e piu'' vicino a Manciolino: l''Anonimo Bolognese, testo essenziale ma inedito e sconosciuto fino alla recente pubblicazione da parte del Cerchio. Indice del volume: Introduzione "Opera Nova" Libro Primo Appendice al Libro primo Libro secondo Libro terzo Libro quarto Libro quinto Libro sesto Le armi della scherma antica Appendice tecnica Manciolino, la scuola bolognese e autori medievali Bibliografia Sitografia');
INSERT INTO biblioteca.libro VALUES ('978-88-08-72125-9', 'Il Gene Riluttante', 'Zanichelli', 'Titoloni incauti ci parlano del gene della timidezza, dell’intelligenza, della prosperità, ma perfino un carattere semplice come il colore degli occhi è influenzato da almeno una ventina di geni; e non basta individuare una variante del DNA per sapere che cosa sarà scritto su una cartella clinica fra un anno o fra dieci. Abbiamo sottovalutato i comprimari? Molecole che si attaccano e si staccano dal DNA; regolatori che accelerano o bloccano l’attività dei geni; zuccheri e grassi che “decorano” quasi ogni superficie biologica. Per non dire dei miliardi di microbi che albergano nel nostro corpo, e del mondo là fuori. Trascurando tutto questo, è facile farsi un’idea esagerata del potere dei geni e del destino di chi li porta. È impervia l’esplorazione della vita che sfugge al controllo dei geni: scarsi gli automatismi, ci si muove da artigiani goffi su impalcature disagevoli, da cui si intravedono però panorami che ampliano l’orizzonte biologico oltre la genetica.');
INSERT INTO biblioteca.libro VALUES ('123-45-67-89012-3', 'Lorem Ipsum', 'Dolor Sit Amet', 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.');


--
-- Data for Name: prestato; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.prestato VALUES ('BNCLSN80A01H501K', 'kDnyfXs20H', '2024-09-08');
INSERT INTO biblioteca.prestato VALUES ('CSTMRC90A01H501Z', '1yPtg0KHCu', '2024-09-04');
INSERT INTO biblioteca.prestato VALUES ('CNTFRC88D25H501X', 'eNtw9IsWvv', '2024-07-06');
INSERT INTO biblioteca.prestato VALUES ('CSTMRC90A01H501Z', '1PuHkRoMwg', '2024-07-10');
INSERT INTO biblioteca.prestato VALUES ('CNTFRC88D25H501X', 'ZuxEuWmiiu', '2024-07-18');
INSERT INTO biblioteca.prestato VALUES ('CSTMRC90A01H501Z', 'MN68KLNDU0', '2024-07-27');
INSERT INTO biblioteca.prestato VALUES ('RSSLRA85B60H501N', 'LAzUtZnlD6', '2024-10-11');
INSERT INTO biblioteca.prestato VALUES ('RSSLRA85B60H501N', 'sARl7WwbFA', '2024-10-11');


--
-- Data for Name: scritto; Type: TABLE DATA; Schema: biblioteca; Owner: giacomo_castellana
--

INSERT INTO biblioteca.scritto VALUES ('90952744', '978-88-17-06162-9');
INSERT INTO biblioteca.scritto VALUES ('21800658', '979-86-28-76262-2');
INSERT INTO biblioteca.scritto VALUES ('35572997', '978-88-84-74176-9');
INSERT INTO biblioteca.scritto VALUES ('56983713', '978-04-41-56959-5');
INSERT INTO biblioteca.scritto VALUES ('29429327', '978-14-47-28945-6');
INSERT INTO biblioteca.scritto VALUES ('63131341', '978-88-45-27240-0');
INSERT INTO biblioteca.scritto VALUES ('29429327', '978-88-06-23398-3');
INSERT INTO biblioteca.scritto VALUES ('63131341', '978-88-45-29000-2');
INSERT INTO biblioteca.scritto VALUES ('90952744', '978-88-17-06163-6');
INSERT INTO biblioteca.scritto VALUES ('90952744', '978-88-17-06164-3');
INSERT INTO biblioteca.scritto VALUES ('90952744', '978-88-17-06960-1');
INSERT INTO biblioteca.scritto VALUES ('83560072', '978-88-04-37655-2');
INSERT INTO biblioteca.scritto VALUES ('83560072', '978-88-04-37832-7');
INSERT INTO biblioteca.scritto VALUES ('83560072', '978-88-04-38404-5');
INSERT INTO biblioteca.scritto VALUES ('20386502', '978-17-92-33301-9');
INSERT INTO biblioteca.scritto VALUES ('20386502', '978-17-92-34609-5');
INSERT INTO biblioteca.scritto VALUES ('62858412', '978-88-08-72125-9');
INSERT INTO biblioteca.scritto VALUES ('24123327', '978-88-08-72125-9');
INSERT INTO biblioteca.scritto VALUES ('dpub1BBR', '123-45-67-89012-3');


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: giuseppe_difilippo
--



--
-- Data for Name: movie; Type: TABLE DATA; Schema: public; Owner: marco_montali
--



--
-- Name: autore autore_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.autore
    ADD CONSTRAINT autore_pkey PRIMARY KEY (id);


--
-- Name: bibliotecario bibiliotecario_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.bibliotecario
    ADD CONSTRAINT bibiliotecario_pkey PRIMARY KEY (cdf);


--
-- Name: biblioteca biblioteca_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.biblioteca
    ADD CONSTRAINT biblioteca_pkey PRIMARY KEY (sede);


--
-- Name: copia copia_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.copia
    ADD CONSTRAINT copia_pkey PRIMARY KEY (id);


--
-- Name: lettore lettore_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.lettore
    ADD CONSTRAINT lettore_pkey PRIMARY KEY (cdf);


--
-- Name: libro libro_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.libro
    ADD CONSTRAINT libro_pkey PRIMARY KEY (isbn);


--
-- Name: prestato prestato_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.prestato
    ADD CONSTRAINT prestato_pkey PRIMARY KEY (persona, volume);


--
-- Name: scritto scritto_pkey; Type: CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.scritto
    ADD CONSTRAINT scritto_pkey PRIMARY KEY (autore, libro);


--
-- Name: country country_name_key; Type: CONSTRAINT; Schema: public; Owner: giuseppe_difilippo
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_name_key UNIQUE (name);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: giuseppe_difilippo
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (iso3);


--
-- Name: movie movie_pkey; Type: CONSTRAINT; Schema: public; Owner: marco_montali
--

ALTER TABLE ONLY public.movie
    ADD CONSTRAINT movie_pkey PRIMARY KEY (id);


--
-- Name: prestato aggiornaritardo; Type: TRIGGER; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TRIGGER aggiornaritardo AFTER DELETE ON biblioteca.prestato FOR EACH ROW EXECUTE FUNCTION biblioteca.checkritardo();


--
-- Name: prestato controllaritardi; Type: TRIGGER; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TRIGGER controllaritardi AFTER INSERT ON biblioteca.prestato FOR EACH ROW EXECUTE FUNCTION biblioteca.controllaritardi();


--
-- Name: prestato controllodisponibilita; Type: TRIGGER; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TRIGGER controllodisponibilita AFTER INSERT ON biblioteca.prestato FOR EACH ROW EXECUTE FUNCTION biblioteca.checkdisponibilita();


--
-- Name: prestato estensionedata; Type: TRIGGER; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TRIGGER estensionedata AFTER UPDATE ON biblioteca.prestato FOR EACH ROW EXECUTE FUNCTION biblioteca.estendiprestito();


--
-- Name: prestato prestitiattivi; Type: TRIGGER; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TRIGGER prestitiattivi AFTER INSERT ON biblioteca.prestato FOR EACH ROW EXECUTE FUNCTION biblioteca.controllaattivi();


--
-- Name: prestato rimettidisponibile; Type: TRIGGER; Schema: biblioteca; Owner: giacomo_castellana
--

CREATE TRIGGER rimettidisponibile AFTER DELETE ON biblioteca.prestato FOR EACH ROW EXECUTE FUNCTION biblioteca.tornadisponibile();


--
-- Name: bibliotecario bibliotecario_ufficio_fkey; Type: FK CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.bibliotecario
    ADD CONSTRAINT bibliotecario_ufficio_fkey FOREIGN KEY (ufficio) REFERENCES biblioteca.biblioteca(sede);


--
-- Name: copia copia_dove_fkey; Type: FK CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.copia
    ADD CONSTRAINT copia_dove_fkey FOREIGN KEY (dove) REFERENCES biblioteca.biblioteca(sede);


--
-- Name: copia copia_libro_fkey; Type: FK CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.copia
    ADD CONSTRAINT copia_libro_fkey FOREIGN KEY (libro) REFERENCES biblioteca.libro(isbn);


--
-- Name: prestato prestato_persona_fkey; Type: FK CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.prestato
    ADD CONSTRAINT prestato_persona_fkey FOREIGN KEY (persona) REFERENCES biblioteca.lettore(cdf);


--
-- Name: prestato prestato_volume_fkey; Type: FK CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.prestato
    ADD CONSTRAINT prestato_volume_fkey FOREIGN KEY (volume) REFERENCES biblioteca.copia(id);


--
-- Name: scritto scritto_autore_fkey; Type: FK CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.scritto
    ADD CONSTRAINT scritto_autore_fkey FOREIGN KEY (autore) REFERENCES biblioteca.autore(id);


--
-- Name: scritto scritto_libro_fkey; Type: FK CONSTRAINT; Schema: biblioteca; Owner: giacomo_castellana
--

ALTER TABLE ONLY biblioteca.scritto
    ADD CONSTRAINT scritto_libro_fkey FOREIGN KEY (libro) REFERENCES biblioteca.libro(isbn);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;

--
-- PostgreSQL database dump complete
--

