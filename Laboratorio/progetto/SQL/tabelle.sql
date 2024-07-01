Biblioteca
CREATE TABLE biblioteca(
        sede varchar(5) unique not null primary key,
        indirizzo varchar(100) not null,
        citta varchar(30) not null,
);

Libro
CREATE TABLE libro(
        isbn varchar(17) unique not null primary key,
        titolo varchar(100) not null,
        casa_ed varchar(50),
	trama text
);

Lettore
CREATE TABLE lettore(
        cdf varchar(16) unique not null primary key,
        nome varchar(50) not null,
        cognome varchar(50) not null,
	tipo boolean not null,
	n_ritardi integer not null
);

Autore
CREATE TABLE autore(
        id varchar(8) unique not null primary key,
        nome varchar(50) not null,
        cognome varchar(50) not null,
	d_nascita date,
	d_morte date,
	bio text
);

Bibliotecario
CREATE TABLE bibliotecario(
	id varchar(16) unique not null primary key,
	nome varchar(50) not null,
	cognome varchar(50) not null
	ufficio varchar(5) not null references biblioteca(sede)
);

Scritto
CREATE TABLE scritto(
	autore varchar(8) references autore(id) not null,
	libro varchar(17) references libro(isbn) not null,
	primary key (autore,libro)
);

Copia
CREATE TABLE copia(
	id varchar(10) unique not null primary key,
	libro varchar(17) not null references libro(isbn),
	dove varchar(5) not null references biblioteca(sede)
);

Prestato
CREATE TABLE prestato(  
        persona varchar(16) not null references lettore(cdf),
        volume varchar(10) not null references copia(id),
	d_fine date not null,
	primary key (persona,volume)
);

Inserimento libri
insert into libro(isbn,titolo,casa_ed,trama) values 
('978-1-234-56789-7','Il Segreto del Presidente,'Marozzo','Il fosco Presidente
deve aprire il suo cuore per trovare lo amore'),
('978-0-123-45678-9','La Furia del Presidente','Marozzo','Il Presidente deve
vendicare la grande perdita causatagli dal Mago Meo: la perdita del suo amore'),
('978-8-845-27240-0','Il Silmarillion','Bompiani','"Il Silmarillion", iniziato
nel 1917 e la cui elaborazione è stata proseguita da Tolkien fino alla morte,
rappresenta il tronco da cui si sono diramate tutte le sue successive opere
narrative. "Opera prima", dunque, essa costituisce il repertorio mitico di
Tolkien, quello da cui è derivata la filiazione delle sue favole: "Lo Hobbit",
"Il Signore degli Anelli", "Il cacciatore di Draghi". "Il Silmarillion", che
comprende cinque racconti legati come i capitoli di un'unica storia sacra, narra
la parabola di una caduta: dalla "musica degli inizi", il momento cosmogonico,
alla guerra di Elfi e Uomini contro l'Avversario. L'ultimo dei racconti
costituisce l'antecedente immediato del "Signore degli Anelli"'),
('978-8-817-06162-9','Eragon','Rizzoli','Quando Eragon trova una liscia pietra blu nella foresta, è convinto che gli sia toccata una grande fortuna: potrà venderla e nutrire la sua famiglia per tutto l'inverno. Ma la pietra in realtà è un uovo. Quando si schiude rivelando il suo straordinario contenuto, un cucciolo di drago, Eragon scopre che gli è toccato in sorte un'eredità antica come l'Impero. Forte di una spada magica e dei consigli di un vecchio cantastorie, dovrà cavarsela in un universo denso di magia, mistero e insidie, imparare a distinguere l'amico dal nemico, dimostrare di essere il degno erede dei Cavalieri dei Draghi.')

Inserimento biblioteca
insert into biblioteca(sede,indirizzo,citta,provincia) values 
('00001','Via Della Stazione 44','Paderno Dugnano'),
('00002','Piazza Aspromonte 2','Milano'),
('00003','Viale Traiano 39','Montelupo Fiorentino')

Inserimento lettori
insert into lettore(cdf,nome,cognome,tipo,#ritardi) values
('BNCLSN80A01H501K','Alessandro','Bianchi',false,0),
('RSSLRA85B60H501N','Laura','Rossi',true,1),
('CNTFRC88D25H501X','Federica','Conti',false,0)

Inserimento bibliotecario
insert into bibliotecario(cdf,nome,cognome,ufficio) values
('MRNGLI90A01H501Z','Giulia','Marini','00002'),
('FRRLCA85B20H501M','Luca','Ferretti','00002'),
('BNCMRT82C30H501N','Marta','Bianchi','00001'),
('RSSDVD78D10H501Q','Davide','Rossi','00003')

Inserisci autore
insert into autore(id,nome,cognome,d_nascita,d_morte,bio) values
('00000001','Fizzi','Magistro','1986-03-23',NULL,'Magistro è un grande schermidore
storico e autore harmony di grande talento'),
('00000002','J.R.R.','Tolkien','1892-01-03','1973-09-02','Non necessita di una presentazione'),
('00000003','Christopher','Paolini','1983-11-17',NULL,'Ha scritto la saga di Eragon da ragazzino')

Inserisci copia
insert into copia(id,libro,dove) values
('000000001','978-1-234-56789-7','00001'),
('000000002','978-1-234-56789-7','00002'),
('000000003','978-1-234-56789-7','00001'),
('000000004','978-1-234-56789-7','00002'),
('000000005','978-0-123-45678-9','00002'),
('000000006','978-0-123-45678-9','00003'),
('000000007','978-0-123-45678-9','00002'),
('000000008','978-0-123-45678-9','00001'),
('000000009','978-0-123-45678-9','00003'),
('00000000A','978-0-123-45678-9','00001'),
('00000000B','978-8-845-27240-0','00002'),
('00000000C','978-8-845-27240-0','00002'),
('00000000D','978-8-845-27240-0','00003'),
('00000000E','978-8-845-27240-0','00003'),
('00000000F','978-8-817-06162-9','00001'),
('000000010','978-8-817-06162-9','00002')

Inserimento scritto
insert into scritto(autore,libro) values
('00000001','978-1-234-56789-7'),
('00000001','978-0-123-45678-9'),
('00000002','978-8-845-27240-0'),
('00000003','978-8-817-06162-9')

In serimento prestato
insert into prestato(persona,volume,d_fine) values
('BNCLSN80A01H501K','000000001','2024-07-08'),
('BNCLSN80A01H501K','000000005','2024-07-23'),
('BNCLSN80A01H501K','00000000A','2024-07-14'),
('RSSLRA85B60H501N','000000003','2024-06-23'),
('RSSLRA85B60H501N','00000000F','2024-04-02'),
('RSSLRA85B60H501N','000000010','2024-06-29'),
('RSSLRA85B60H501N','000000004','2024-06-07'),
('CNTFRC88D25H501X','00000000B','2024-07-20')


Vedere tutti i libri in prestito e a chi
select isbn, titolo, lettore.nome, lettore.cognome
from lettore inner join prestato on cdf=persona inner join copia on 
prestato.volume=copia.id inner join libro on copia.libro=libro.isbn;
