--Biblioteca
CREATE TABLE biblioteca(
        sede varchar(5) unique not null primary key,
        indirizzo varchar(100),
        citta varchar(30),
        nome varchar(100) not null
);

--Libro
CREATE TABLE libro(
        isbn varchar(17) unique not null primary key,
        titolo varchar(100) not null,
        casa_ed varchar(50),
	trama text
);

--Lettore
CREATE TABLE lettore(
        cdf varchar(16) unique not null primary key,
        nome varchar(100) not null,
	tipo boolean not null,
	n_ritardi integer not null,
	pass varchar(16) not null
);

--Autore
CREATE TABLE autore(
        id varchar(8) unique not null primary key,
        nome varchar(100) not null,
	d_nascita date,
	d_morte date,
	bio text,

);

--Bibliotecario
CREATE TABLE bibliotecario(
	id varchar(16) unique not null primary key,
	nome varchar(100) not null,
	ufficio varchar(5) not null references biblioteca(sede),
	pass varchar(16) not null
);

--Scritto
CREATE TABLE scritto(
	autore varchar(8) references autore(id) not null,
	libro varchar(17) references libro(isbn) not null,
	primary key (autore,libro)
);

--Copia
CREATE TABLE copia(
	id varchar(10) unique not null primary key,
	libro varchar(17) not null references libro(isbn),
	dove varchar(5) not null references biblioteca(sede),
	disp boolean
);

--Prestato
CREATE TABLE prestato(  
        persona varchar(16) not null references lettore(cdf),
        volume varchar(10) not null references copia(id),
	d_fine date not null,
	primary key (persona,volume)
);

create materialized view statistichesedi as
	with nP as (
		select s.id as posto, count(distinct c.id) as nPr
		from biblioteca b left join copia c on b.sede = c.dove and c.disp = FALSE
		group by b.sede
	)
	select b.sede as dove, count(distinct c.id) as qid, count(distinct c.libro) as qis, COALESCE (n.nPr, 0) as qpr
	from biblioteca b left join copia c on b.sede = c.dove left join nP n on b.sede = n.posto
	group by b.sede, n.nPr
	order by b.sede;

--Inserimento libri
insert into libro values 
('978-8-817-06162-9','Eragon','Rizzoli','Quando Eragon trova una liscia pietra blu nella foresta, è convinto che gli sia toccata una grande fortuna: potrà venderla e nutrire la sua famiglia per tutto lo inverno. Ma la pietra in realtà è un uovo. Quando si schiude rivelando il suo straordinario contenuto, un cucciolo di drago, Eragon scopre che gli è toccato in sorte una eredità antica come lo Impero. Forte di una spada magica e dei consigli di un vecchio cantastorie, dovrà cavarsela in un universo denso di magia, mistero e insidie, imparare a distinguere chi gli è amico da chi gli è nemico, dimostrare di essere il degno erede dei Cavalieri dei Draghi.'),
('978-1-447-28945-6','Blood Meridian','Picador','Through the hostile landscape of the Texas-Mexico border wanders the Kid, a fourteen year-old Tennessean who is quickly swept-up in the relentless tide of blood. But the apparent chaos is not without its order: while Americans hunt Indians – collecting scalps as their bloody trophies – they too are stalked as prey.'),
('978-0-441-56959-5','Neuromancer','Penguin','"Neuromancer" by William Gibson is a seminal science fiction novel set in a cyberpunk future where cyberspace, artificial intelligence, and megacorporations dominate society. The story follows Case, a washed-up computer hacker who is hired by a mysterious employer for a final, dangerous job. As he navigates a world of high-tech espionage and virtual realities, Case confronts themes of identity, technology, and power. The novel"s gritty, fast-paced narrative and richly imagined setting have made it a cornerstone of the cyberpunk genre.'),
('979-8-467-03682-3','self-published','La Ultima Impresa','La ombra nera della tempesta incombe minacciando di gettare nello oblio la luce di una intera epoca.
Un manipolo di uomini è impegnato nel salvare dallo abisso la memoria delle proprie gesta prima che finisca il tempo del loro mondo.
Non sono le imprese dei grandi protagonisti, ma le azioni quotidiane degli sconosciuti comprimari, i mattoni che compongono il tempio della storia.
Senza concessioni al romanticismo, fatti e misfatti vengono rivissuti attraverso gli occhi nostalgici di coloro che ne sono stati protagonisti, con tutta la crudezza e il realismo che resta una volta tolta la coperta fiorita della celebrazione.
Le famose e famigerate Bande Nere del Gran Diavolo, il signor Giovanni de Medici, si ritrovano tutto altro che vinte per avviare una ultima impresa che possa incidere il loro nome nella Storia.
Il vento del tempo ha ormai spazzato via il loro mondo fatto di riti antichi e sapienze marziali. Ultimi custodi della voce di Marte, gli uomini in cremisi tramano nella tempesta decisi a non varcare la soglia dello Averno con la vergogna di esser periti fallendo.
Non vi è esitazione nel loro animo, né crudeltà innecessaria nei loro gesti.
I loro avversari si indaffarano a cancellare dalla memoria le storie di questi uomini, a far scordare al mondo lo ardore e la fierezza dei Diavoli delle Bande Nere.
Queste sono le loro storie, la loro memoria affidata ai pochi che la sapranno portare, e la cronaca della loro Ultima Impresa.'),
('978-8-845-27240-0','Il Silmarillion','Bompiani','"Il Silmarillion", iniziato nel 1917 e la cui elaborazione è stata proseguita da Tolkien fino alla morte, rappresenta il tronco da cui si sono diramate tutte le sue successive opere narrative. "Opera prima", dunque, essa costituisce il repertorio mitico di Tolkien, quello da cui è derivata la filiazione delle sue favole: "Lo Hobbit", "Il Signore degli Anelli", "Il cacciatore di Draghi". "Il Silmarillion", che comprende cinque racconti legati come i capitoli di una unica storia sacra, narra la parabola di una caduta: dalla "musica degli inizi", il momento cosmogonico, alla guerra di Elfi e Uomini contro lo Avversario. Lo ultimo dei racconti costituisce lo antecedente immediato del "Signore degli Anelli"'),
('978-8-884-74176-9','Opera Nova','Il Cerchio','Il primo trattato della Scuola Bolognese mai stampato (nel 1531, scritto però fra il 1522 e il 1523)), rarissimo e che anticamente si credeva perduto, viene riproposto oggi in una edizione definitiva che ne svela finalmente tutti i segreti: completo di esaurienti note storiche e di note tecniche esplicative che ne rivelano il contenuto tecnico azione per azione, illustrazioni delle guardie e delle tecniche di combattimento principali (tratte dai principali manuali di scherma coevi o ricostruite in computer graphic), appendici schermistiche e sulle armi utilizzate. Questo volume presenta il lavoro interpretativo eseguito dai curatori, basato sullo impegno scientifico collettivo di anni della Sala di Arme Achille Marozzo e sulla esperienza accumulata nella preparazione di altre pubblicazioni di inediti in materia di scherma storica: Fiore dei Liberi (per la prima volta la analisi dei tre manoscritti esistenti del Flos Duellatorum) Filippo Vadi, Anonimo Bolognese, Francesco altoni. In particolare ai fini della comprensione risulta indispensabile la comparazione offerta ai lettori con gli altri autori della Scuola Bolognese, prima fra tutti e impresindibile quella con il Maestro più antico e più vicino a Manciolino: lo Anonimo Bolognese, testo essenziale ma inedito e sconosciuto fino alla recente pubblicazione da parte del Cerchio. Indice del volume: Introduzione "Opera Nova" Libro Primo Appendice al Libro primo Libro secondo Libro terzo Libro quarto Libro quinto Libro sesto Le armi della scherma antica Appendice tecnica Manciolino, la scuola bolognese e autori medievali Bibliografia Sitografia.'),
('978-8-884-74023-6','Flos Duellatorum','Il Cerchio','Il FLOS DUELLATORUM è senza altro il più noto, importante e studiato manuale di combattimento medievale. Esso contiene la istruzione completa del cavaliere, dalla lotta a mani nude alla daga, alla lancia, a diversi tipi di bastoni, in armatura e senza, a piedi e a cavallo. Questo volume presenta per la prima volta uno studio comparato fra i tre manoscritti esistenti del Flos Duellatorum, con riproduzione integrale del testo di tutte le versioni e di numerose immagini finora mancanti e trovate nei manoscritti conservati negli Stati Uniti. Completo di trascrizione, di una biografia del Maestro Fiore e di una appendice tecnica, il libro riporta inoltre lo studio del Pisani-Dossi per la edizione del 1902, completato con le informazioni derivate dagli studi più recenti. Indice del libro: INTRODUZIONE GLOSSARIO LA INTRODUZIONE DI FIORE DEI LIBERI LA STRUTTURA DEL TRATTATO: LO INDICE LOGICO DELLE IMMAGINI LOTTA BASTONCELLO DAGA I COLPI DELLA SPADA SPADA A UNA MANO SPADA A DUE MANI SPADA A DUE MANI IN ARME AZZA IN ARME LANCIA DAGA CONTRO SPADA E VICEVERSA TECNICHE VARIE SPADA A DUE MANI CONTRO ARMI LANCIATE BASTONE LUNGO E DAGA CONTRO LANCIA DUE BASTONI E DAGA E CONTRO LANCIA DIFESA SENZA ARMI CONTRO LA LANCIA ARMI DI ASTA CONTRO AVVERSARIO A CAVALLO LANCIA A CAVALLO SPADA CONTRO LANCIA E VICEVERSA, A CAVALLO SPADA A CAVALLO LOTTA A CAVALLO ARMI E TATTICHE SPECIALI A CAVALLO LA CONCLUSIONE DEL TRATTATO IMMAGINI DAI TRATTATI BIBLIOGRAFIA');

--Inserimento biblioteca
insert into biblioteca values 
('00000','Via del Pozzo 46','Pavia','Magazzino Centrale'),
('60297','Via Della Stazione 44','Paderno Dugnano','Biblioteca della Stazione'),
('26620','Via Liberazione 33','Roma','Biblioteca Libera'),
('9787','Viale Traiano 39','Roma','Biblioteca del Viale'),
('13576','Via Caproni 94','Bolzano','Biblioteca Civica Caproni');

--Inserimento lettori
insert into lettore values
('BNCLSN80A01H501K','Alessandro Bianchi',false,4,'ReArtu'),
('RSSLRA85B60H501N','Laura Rossi',true,5,'ReTheoden'),
('CNTFRC88D25H501X','Federica Conti',false,0,'ReOberon'),
('MRNGLI90A01H501Z','Marco Castellana',false,0,'ReMufasa');

--Inserimento bibliotecario
insert into bibliotecario values
('MRNGLI90A01H501Z','Giulia Marini','13576','OrsoYogi'),
('FRRLCA85B20H501M','Luca Ferretti','60297','OrsoBubu'),
('BNCMRT82C30H501N','Marta Bianchi','60297','OrsoBalu'),
('RSSDVD78D10H501Q','Davide Rossi','9787','OrsoKoda'),
('VRDCSR95R47D612X','Cassandra Verdi','26620','OrsoTed');

--Inserisci autore
insert into autore values
('90952744','Christopher Paolini','','','Christopher Paolini è un autore statunitense noto soprattutto per la serie fantasy "Ciclo della Eredità". Paolini ha iniziato a scrivere il primo libro della serie, "Eragon", quando aveva solo quindici anni. La storia, che segue le avventure di un giovane allevatore di draghi, è diventata un bestseller internazionale e ha dato origine a tre seguiti: "Eldest", "Brisingr" e "Inheritance". Dopo il successo del ciclo, Paolini ha continuato a lavorare su nuovi progetti, espandendo il mondo che ha creato con racconti aggiuntivi e altre opere di fantasia.'),
('21800658','Fiore Dei Liberi','1350-01-01','1410-01-01','Fiore dei Liberi è stato un maestro di scherma italiano e autore del celebre manuale di arti marziali "Fior di Battaglia" (Il Fiore di Battaglia). Nato a Cividale del Friuli, Fiore ha viaggiato in tutta Europa, apprendendo e insegnando le tecniche di combattimento con la spada e altre armi. Il suo manuale, scritto in volgare italiano, è uno dei più antichi e completi trattati di scherma medievale e include tecniche di combattimento a mani nude, con spada, daga, lancia e cavallo.'),
('35572997','Antonio Manciolino','','','Antonio Manciolino è stato un maestro di scherma italiano, noto per il suo manuale "Opera Nova", pubblicato intorno al 1531. Questo trattato è uno dei primi libri stampati sulla scherma e descrive dettagliatamente le tecniche di combattimento con la spada e il pugnale. Manciolino apparteneva alla tradizione della scherma bolognese, una delle scuole più influenti del Rinascimento italiano, e il suo lavoro ha contribuito a diffondere le tecniche di questa scuola in tutta Europa.'),
('56983713','William Gibson','1948-03-17','','William Gibson è un autore di fantascienza canadese-americano, considerato uno dei padri del genere cyberpunk. Ha raggiunto la fama con il suo romanzo di esordio "Neuromante" (1984), che ha vinto i premi Hugo, Nebula e Philip K. Dick. Il romanzo ha introdotto molti concetti innovativi, tra cui il cyberspazio, e ha influenzato profondamente la cultura pop e la tecnologia. Gibson ha continuato a scrivere numerosi romanzi e racconti, esplorando temi come la interazione tra tecnologia e società.'),
('29429327','Cormac McCarty','1933-07-20','2023-06-13','Cormac McCarthy è stato un autore statunitense noto per i suoi romanzi di grande intensità e oscurità. Tra le sue opere più celebri ci sono "La strada" (vincitore del Premio Pulitzer per la narrativa nel 2007), "Non è un paese per vecchi" e "Meridiano di sangue". I suoi scritti spesso esplorano temi di violenza, redenzione e la inesorabile durezza della vita umana. Le sue opere sono state adattate con successo in film acclamati dalla critica.'),
('63131341','J.R.R. Tolkien','1892-01-03','1973-09-02','John Ronald Reuel Tolkien è stato un autore, filologo e accademico britannico, noto soprattutto per i suoi celebri romanzi fantasy "Lo Hobbit" e "Il Signore degli Anelli". Nato in Sudafrica e cresciuto in Inghilterra, Tolkien è stato professore di anglosassone e di letteratura inglese medievale alla Università di Oxford. Le sue opere hanno creato mondi complessi e dettagliati, popolati da razze fantastiche e miti elaborati, e hanno avuto un enorme impatto sulla letteratura fantasy moderna. Oltre ai suoi romanzi, Tolkien ha scritto numerosi saggi e opere accademiche, ed è stato uno dei membri del gruppo letterario degli Inklings.');

--Inserimento scritto
insert into scritto values
('90952744','978-8-817-06162-9'),
('21800658','979-8-628-76262-2'),
('35572997','978-8-884-74176-9'),
('56983713','978-0-441-56959-5'),
('29429327','978-1-447-28945-6'),
('63131341','978-8-845-27240-0');

--Inserisci copia
insert into copia values
('WzHLwe8dV0', '978-1-447-28945-6', '9787', true);
('BPnOiNxj2p', '978-1-447-28945-6', '9787', true);
('eNtw9IsWvv', '978-8-845-27240-0', '9787', true);
('J04GR1pmgy', '978-8-845-27240-0', '9787', true);
('LJbVIOY9VO', '978-8-845-27240-0', '9787', true);
('EWJ1lvYlRt', '978-8-845-27240-0', '9787', true);
('00000000D', '978-8-845-27240-0', '13576', true);
('LAzUtZnlD6', '978-1-447-28945-6', '26620', true);
('1PuHkRoMwg', '979-8-628-76262-2', '60297', true);
('ohPo1RE1LI', '979-8-628-76262-2', '60297', true);
('25V9y4QcDE', '979-8-467-03682-3', '26620', true);
('AO7gffceBy', '978-8-817-06162-9', '9787', true);
('n5TvJRNfs8', '978-8-817-06162-9', '9787', true);
('eEGPb2AGTc', '978-8-884-74176-9', '13576', true);
('ZuxEuWmiiu', '978-8-884-74176-9', '13576', true);
('1yPtg0KHCu', '979-8-628-76262-2', '60297', true);
('kDnyfXs20H', '978-8-817-06162-9', '9787', true);
('PFswvHAiSz', '978-8-884-74176-9', '13576', true);
('MN68KLNDU0', '979-8-467-03682-3', '26620', true);
('V8me7lU5Aa', '978-1-447-28945-6', '9787', true);

--Inserimento prestato
insert into prestato values
('BNCLSN80A01H501K','WzHLwe8dV0',''),
('CNTFRC88D25H501X','eNtw9IsWvv',''),
('MRNGLI90A01H501Z','1PuHkRoMwg',''),
('CNTFRC88D25H501X','ZuxEuWmiiu',''),
('MRNGLI90A01H501Z','MN68KLNDU0',''),
('BNCLSN80A01H501K','kDnyfXs20H','');
