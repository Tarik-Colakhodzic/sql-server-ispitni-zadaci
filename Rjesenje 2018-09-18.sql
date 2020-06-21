/*1.Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea sa default postavkama*/

create database mojaBaza
go
use mojaBaza

/*2.
Unutar svoje baze podataka kreirati tabele sa sljedećem strukturom:
Autori
- AutorID, 11 UNICODE karaktera i primarni ključ
- Prezime, 25 UNICODE karaktera (obavezan unos)
- Ime, 25 UNICODE karaktera (obavezan unos)
- ZipKod, 5 UNICODE karaktera, DEFAULT je NULL
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL */

create table Autori
(
	AutorID nvarchar(11), --11 UNICODE karaktera i primarni ključ
	Prezime nvarchar(25) not null, --25 UNICODE karaktera (obavezan unos)
	Ime nvarchar(25) not null, --25 UNICODE karaktera (obavezan unos)
	ZipKod nvarchar(5) constraint DF_ZipKod default null, --5 UNICODE karaktera, DEFAULT je NULL
	DatumKreiranjaZapisa date not  null constraint DF_DatumKreiranjaZapisa default getdate(), 
	--datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
	DatumModifikovanjaZapisa date constraint DF_DatumModifikovanjaZapisa default null, 
	--polje za unos datuma izmjene zapisa , DEFAULT je NULL 
	constraint PK_Autori primary key (AutorID)
)

/*Izdavaci
- IzdavacID, 4 UNICODE karaktera i primarni ključ
- Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
- Biljeske, 1000 UNICODE karaktera, DEFAULT tekst je Lorem ipsum
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL */

create table Izdavaci
(
	IzdavacID nvarchar(4), --4 UNICODE karaktera i primarni ključ
	Naziv nvarchar(100) not null unique, --100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
	Biljeske nvarchar(1000) constraint DF_Biljeske default 'Lorem ipsum', 
	--1000 UNICODE karaktera, DEFAULT tekst je Lorem ipsum
	DatumKreiranjaZapisa date not null constraint DF_DatumKreiranja default getdate(), 
	--datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
	DatumModifikovanjaZapisa date constraint DF_DatumModifikovanja default null, 
	--polje za unos datuma izmjene zapisa , DEFAULT je NULL
	constraint PK_Izdavaci primary key (IzdavacID)
)

/*Naslovi
- NaslovID, 6 UNICODE karaktera i primarni ključ
- IzdavacID, spoljni ključ prema tabeli „Izdavaci“
- Naslov, 100 UNICODE karaktera (obavezan unos)
- Cijena, monetarni tip podatka
- Biljeske, 200 UNICODE karaktera, DEFAULT tekst je The quick brown fox jumps over the lazy dog
- DatumIzdavanja, datum izdanja naslova (obavezan unos) DEFAULT je datum unosa zapisa
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL */

create table Naslovi
(
	NaslovID nvarchar(6), --6 UNICODE karaktera i primarni ključ
	IzdavacID nvarchar(4), --spoljni ključ prema tabeli „Izdavaci“
	Naslov nvarchar(100) not null, --100 UNICODE karaktera (obavezan unos)
	Cijena money, --monetarni tip podatka
	Biljeske nvarchar(200) constraint DF_Biljske default 'The quick brown fox jumps over the lazy dog', 
	--200 UNICODE karaktera, DEFAULT tekst je The quick brown fox jumps over the lazy dog
	DatumIzdavanja date not null constraint DF_DatumIzdavanja default getdate(), 
	--datum izdanja naslova (obavezan unos) DEFAULT je datum unosa zapisa
	DatumKreiranjaZapisa date not null constraint DF_DtmKreiranja default getdate(), 
	--datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
	DatumModifikovanjaZapisa date constraint DF_DtmModifikovanja default null,
	--polje za unos datuma izmjene zapisa , DEFAULT je NULL	
	constraint PK_Naslovi primary key (NaslovID),
	constraint FK_Naslovi_Izdavaci foreign key (IzdavacID) references Izdavaci(IzdavacID)
)

/*NasloviAutori (Više autora može raditi na istoj knjizi)
- AutorID, spoljni ključ prema tabeli „Autori“
- NaslovID, spoljni ključ prema tabeli „Naslovi“
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/

create table NaslovAutori
(
	AutorID nvarchar(11), --spoljni ključ prema tabeli „Autori“
	NaslovID nvarchar(6), --spoljni ključ prema tabeli „Naslovi“
	DatumKreiranjaZapisa date not null constraint DF_dtmDodavanja default getdate(), 
	--datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
	DatumModifikovanjaZapisa date constraint DF_dtmModifikovanjaZap default null, 
	--polje za unos datuma izmjene zapisa , DEFAULT je NULL	
	constraint PK_NaslovAutori primary key (AutorID, NaslovID),
	constraint FK_NaslovAutori_Naslovi foreign key (NaslovID) references Naslovi(NaslovID),
	constraint FK_NaslovAutori_Autori foreign key (AutorID) references Autori(AutorID)
)

/*2b
Generisati testne podatake i obavezno testirati da li su podaci u tabelema za svaki korak zasebno :
- Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Autori“ importovati sve slučajno sortirane
zapise. Vodite računa da mapirate odgovarajuće kolone.*/

insert into Autori (AutorID, Prezime, Ime, ZipKod)
select a.au_id, a.au_lname, a.au_fname, a.zip
from
(
	select  au_id, au_lname, au_fname, zip
	from pubs.dbo.authors
) as a
order by NEWID()

select *
from Autori

/*- Iz baze podataka pubs i tabela („publishers“ i pub_info“), a putem podupita u tabelu „Izdavaci“ importovati sve
slučajno sortirane zapise. Kolonu pr_info mapirati kao bilješke i iste skratiti na 100 karaktera. Vodite računa da
mapirate odgovarajuće kolone i tipove podataka. */

insert into Izdavaci (IzdavacID, Naziv, Biljeske)
select *
from 
(
	select p.pub_id, p.pub_name, cast(pf.pr_info as varchar) as 'pr_info'
	from pubs.dbo.publishers as p inner join pubs.dbo.pub_info as pf
	on p.pub_id = pf.pub_id
) as tbl
order by NEWID()

select *
from Izdavaci

/*- Iz baze podataka pubs tabela „titles“, a putem podupita u tabelu „Naslovi“ importovati one naslove koji imaju
bilješke. Vodite računa da mapirate odgovarajuće kolone. */

insert into Naslovi (NaslovID, IzdavacID, Naslov ,Cijena, Biljeske, DatumIzdavanja)
select *
from 
(
	select title_id, pub_id, title, price, notes, pubdate
	from pubs.dbo.titles
	where notes is not null
) as tbl
order by NEWID()

select *
from Naslovi

/* - Iz baze podataka pubs tabela „titleauthor“, a putem podupita u tabelu „NasloviAutori“ zapise. Vodite računa da
mapirate odgovarajuće kolone.
*/

insert into NaslovAutori (AutorID, NaslovID)
select *
from 
(
	select au_id, title_id
	from pubs.dbo.titleauthor
) as tbl

select *
from NaslovAutori

/*2c
Kreiranje nove tabele, importovanje podataka i modifikovanje postojeće tabele:
Gradovi
- GradID, automatski generator vrijednosti koji generiše neparne brojeve, primarni ključ
- Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
- DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
- DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
- Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Gradovi“ importovati nazive gradove bez
duplikata.
- Modifikovati tabelu Autori i dodati spoljni ključ prema tabeli Gradovi:
*/

create table Gradovi
(
	GradID int identity (1, 2), --automatski generator vrijednosti koji generiše neparne brojeve, primarni ključ
	Naziv nvarchar(100) not null unique, --100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
	DatumKreiranjaZapisa date not null default getdate(), --datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
	DatumModifikovanjaZapisa date default null, --polje za unos datuma izmjene zapisa , DEFAULT je NULL	
	constraint PK_Gradovi primary key (GradID)
)

insert into Gradovi (Naziv)
select *
from 
(
	select distinct city
	from pubs.dbo.authors
) as tbl

select *
from Gradovi

alter table Autori
add GradID int

alter table Autori
add constraint FK_Autori_Gradovi foreign key (GradID) references Gradovi(GradID)

/*2d
Kreirati dvije uskladištene proceduru koja će modifikovati podataka u tabeli Autori:
- Prvih pet autora iz tabele postaviti da su iz grada: Salt Lake City
- Ostalim autorima podesiti grad na: Oakland
Vodite računa da se u tabeli modifikuju sve potrebne kolone i obavezno testirati da li su podaci u 
tabeli za svaku proceduru
posebno.
*/

create procedure proc_Aut_Salt_Lake_City
as
begin
update top (5) Autori
set GradID = (select GradID from Gradovi where Naziv = 'Salt Lake City')
end

create procedure proc_Aut_Oakland
as
begin
update Autori
set GradID = (select GradID from Gradovi where Naziv = 'Oakland')
where AutorID not in (select top 5 AutorID from Autori)
end

exec proc_Aut_Oakland

exec proc_Aut_Salt_Lake_City

select a.GradID, g.Naziv
from Autori as a inner join Gradovi as g
on a.GradID = g.GradID

/*3.
Kreirati pogled sa sljedećom definicijom: Prezime i ime autora (spojeno), grad, naslov, cijena, bilješke o naslovu i naziv
izdavača, ali samo za one autore čije knjige imaju određenu cijenu i gdje je cijena veća od 5. 
Također, naziv izdavača u sredini
imena ne smije imati slovo „&“ i da su iz autori grada Salt Lake City 
*/

create view view_aut_nasl_izdav
as
select a.Prezime + ' ' + a.Ime as 'prezime_ime', a.GradID, Naslov, Cijena, n.Biljeske, i.Naziv 
from Autori as a inner join NaslovAutori as na
on a.AutorID = na.AutorID inner join Naslovi as n
on na.NaslovID = n.NaslovID inner join Izdavaci as i
on n.IzdavacID = i.IzdavacID
where n.Cijena is not null and n.Cijena > 5 and i.Naziv not like '%&%' 
and a.GradID = (select GradID from Gradovi where Naziv like 'Salt Lake City')

select *
from view_aut_nasl_izdav

/*4.
Modifikovati tabelu Autori i dodati jednu kolonu:
- Email, polje za unos 100 UNICODE karaktera, DEFAULT je NULL
*/

alter table Autori
add Email nvarchar(100) default null

/*5.
Kreirati dvije uskladištene proceduru koje će modifikovati podatke u tabelu Autori i svim autorima generisati novu email
adresu:
- Prva procedura: u formatu: Ime.Prezime@fit.ba svim autorima iz grada Salt Lake City
- Druga procedura: u formatu: Prezime.Ime@fit.ba svim autorima iz grada Oakland
*/

create procedure proc_email_salt_lake_city
as
begin
update Autori
set Email = Ime + '.' + Prezime + '@fit.ba'
where GradID = (select GradID from Gradovi where Naziv = 'Salt Lake City')
end

create procedure proc_email_Oakland
as
begin
update Autori
set Email = Prezime + '.' + Ime + '@fit.ba'
where GradID = (select GradID from Gradovi where Naziv = 'Oakland')
end

exec proc_email_salt_lake_city

exec proc_email_Oakland

select *
from Autori

/*6.
z baze podataka AdventureWorks2014 u lokalnu, privremenu, tabelu u vašu bazi podataka importovati zapise o osobama, a
putem podupita. Lista kolona je: Title, LastName, FirstName, EmailAddress, PhoneNumber i CardNumber. Kreirate
dvije dodatne kolone: UserName koja se sastoji od spojenog imena i prezimena (tačka se nalazi između) i kolonu Password
za lozinku sa malim slovima dugačku 24 karaktera. Lozinka se generiše putem SQL funkciju za slučajne i jedinstvene ID
vrijednosti. Iz lozinke trebaju biti uklonjene sve crtice „-“ i zamijenjene brojem „7“. 
Uslovi su da podaci uključuju osobe koje
imaju i nemaju kreditnu karticu, a NULL vrijednost u koloni Titula zamjeniti sa podatkom 'N/A'. 
Sortirati prema prezimenu i
imenu istovremeno. Testirati da li je tabela sa podacima kreirana.
*/

select isnull(Title, 'N/A') as 'Title', LastName, FirstName, EmailAddress, PhoneNumber, cc.CardNumber
into #privremena
from AdventureWorks2014.Person.Person as p inner join AdventureWorks2014.Person.EmailAddress as e
on p.BusinessEntityID = e.BusinessEntityID inner join AdventureWorks2014.Person.PersonPhone as pp
on p.BusinessEntityID = pp.BusinessEntityID left join AdventureWorks2014.Sales.PersonCreditCard as pcc
on p.BusinessEntityID = pcc.BusinessEntityID left join AdventureWorks2014.Sales.CreditCard as cc
on pcc.CreditCardID = cc.CreditCardID

select *
from #privremena

select MAX(len(LastName)), max(len(FirstName))
from #privremena

alter table #privremena
add UserName nvarchar(47)

update #privremena
set UserName = FirstName + '.' + LastName

alter table #privremena
add Password nvarchar(24)

update #privremena
set Password = LEFT(lower(replace(newid(), '-', '7')), 24)

select *
from #privremena
order by LastName, FirstName

/*7.
Kreirati indeks koji će nad privremenom tabelom iz prethodnog koraka, primarno, maksimalno ubrzati upite koje koriste
kolone LastName i FirstName, a sekundarno nad kolonam UserName. Napisati testni upit.
*/

create nonclustered index IX_Names 
on #privremena (FirstName, LastName)
include (UserName)

select FirstName, LastName, UserName
from #privremena
order by FirstName, LastName

/*8.
Kreirati uskladištenu proceduru koja briše sve zapise iz privremene tabele koji imaju kreditnu karticu Obavezno testirati
funkcionalnost procedure.
*/

create procedure proc_del_cardNum_isnull
as
begin
delete #privremena
where CardNumber is null
end

exec proc_del_cardNum_isnull

select COUNT(*) from #privremena where CardNumber is null

/*9. Kreirati backup vaše baze na default lokaciju servera i nakon toga obrisati privremenu tabelu*/

backup database mojaBaza
to disk = 'mojaBaza.bak'

drop table #privremena

/*10a Kreirati proceduru koja briše sve zapise iz svih tabela unutar jednog izvršenja. Testirati da li su podaci obrisani*/

create procedure proc_del_SviZapisi
as
begin
alter table Autori
drop constraint FK_Autori_Gradovi
alter table NaslovAutori
drop constraint FK_NaslovAutori_Autori
alter table Naslovi
drop constraint FK_Naslovi_Izdavaci
delete from Autori
delete from Gradovi
delete from Izdavaci
delete from NaslovAutori
delete from Naslovi
end

exec proc_del_SviZapisi

/*10b Uraditi restore rezervene kopije baze podataka i provjeriti da li su svi podaci u izvornom obliku*/

use master
go

restore database mojaBaza
from disk = 'mojaBaza.bak'
with replace

use mojaBaza
go

select *
from Autori
select *
from Gradovi
select *
from Izdavaci
select *
from NaslovAutori
select *
from Naslovi
