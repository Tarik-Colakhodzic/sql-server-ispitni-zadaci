	--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

create database mojaBaza
go
use mojaBaza


/*
Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
b) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	radnikID, cjelobrojna varijabla, primarni ključ
	drzavaID, 15 unicode karaktera
	loginID, 30 unicode karaktera
	sati_god_odmora, cjelobrojna varijabla
	sati_bolovanja, cjelobrojna varijabla
*/

create table radnik
(
	radnikID int, --cjelobrojna varijabla, primarni ključ
	drzavaID nvarchar(15), --15 unicode karaktera
	loginID nvarchar(30), --30 unicode karaktera
	sati_god_odmora int, --cjelobrojna varijabla
	sati_bolovanja int, --cjelobrojna varijabla
	constraint PK_radnik primary key (radnikID)
)

/*
c) Kreirati tabelu kupovina koja će imati sljedeću strukturu:
	kupovinaID, cjelobrojna varijabla, primarni ključ
	status, cjelobrojna varijabla
	radnikID, cjelobrojna varijabla
	br_racuna, 15 unicode karaktera
	naziv_dobavljaca, 50 unicode karaktera
	kred_rejting, cjelobrojna varijabla
*/

create table kupovina
(
	kupovinaID int, --cjelobrojna varijabla, primarni ključ
	status int, --cjelobrojna varijabla
	radnikID int, --cjelobrojna varijabla
	br_racuna nvarchar(15), --15 unicode karaktera
	naziv_dobavljaca nvarchar(50), --50 unicode karaktera
	kred_rejting int, --cjelobrojna varijabla	
	constraint PK_kupovina primary key (kupovinaID),
	constraint FK_kupovina_radnik foreign key (radnikID) references radnik(radnikID)
)

/*
d) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	prodavacID, cjelobrojna varijabla, primarni ključ
	prod_kvota, novčana varijabla
	bonus, novčana varijabla
	proslogod_prodaja, novčana varijabla
	naziv_terit, 50 unicode karaktera
*/

create table prodaja
(
	prodavacID int, --cjelobrojna varijabla, primarni ključ
	prod_kvota money, --novčana varijabla
	bonus money, --novčana varijabla
	proslogod_prodaja money, --novčana varijabla
	naziv_terit nvarchar(50), --50 unicode karaktera	
	constraint PK_prodaja primary key (prodavacID),
	constraint FK_prodaja_radnik foreign key (prodavacID) references radnik(radnikID)
)

--2. Import podataka
/*
a) Iz tabela humanresources.employee baze AdventureWorks2014 u tabelu radnik importovati podatke po sljedećem pravilu:
	BusinessEntityID -> radnikID
	NationalIDNumber -> drzavaID
	LoginID -> loginID
	VacationHours -> sati_god_odmora
	SickLeaveHours -> sati_bolovanja
*/

insert into radnik 
select BusinessEntityID, NationalIDNumber, LoginID, VacationHours, SickLeaveHours
from AdventureWorks2014.HumanResources.Employee

select *
from radnik

/*
b) Iz tabela purchasing.purchaseorderheader i purchasing.vendor baze AdventureWorks2014 u tabelu 
kupovina importovati podatke po sljedećem pravilu:
	PurchaseOrderID -> kupovinaID
	Status -> status
	EmployeeID -> radnikID
	AccountNumber -> br_racuna
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/

insert into kupovina
select PurchaseOrderID, Status, EmployeeID, AccountNumber, Name, CreditRating
from AdventureWorks2014.Purchasing.PurchaseOrderHeader as pod inner join AdventureWorks2014.Purchasing.Vendor as v
on pod.VendorID = v.BusinessEntityID

select *
from kupovina

/*
c) Iz tabela sales.salesperson i sales.salesterritory baze AdventureWorks2014 u tabelu prodaja importovati podatke po sljedećem pravilu:
	BusinessEntityID -> prodavacID
	SalesQuota -> prod_kvota
	Bonus -> bonus
	SalesLastYear -> proslogod_prodaja
	Name -> naziv_terit
*/

insert into prodaja
select BusinessEntityID, SalesQuota, Bonus, st.SalesLastYear, Name
from AdventureWorks2014.Sales.SalesPerson as sp inner join AdventureWorks2014.Sales.SalesTerritory as st
on sp.TerritoryID = st.TerritoryID

select *
from prodaja

--napomena:
--SalesLastYear se uzima iz tabele SalesTerritory


--3.
/*
Iz tabela radnik i kupovina kreirati pogled view_drzavaID koji će imati sljedeću strukturu: 
	- naziv dobavljača,
	- drzavaID
Uslov je da u pogledu budu samo oni zapisi čiji ID države počinje ciframa u rasponu od 40 do 49, 
te da se kombinacije dobavljača i drzaveID ne ponavljaju.
*/

create view view_drzavaID
as
select distinct naziv_dobavljaca, drzavaID
from radnik as r inner join kupovina as k
on r.radnikID = k.radnikID
where LEFT(drzavaID, 2) between 40 and 49

select *
from view_drzavaID

--4.
/*
Koristeći tabele radnik i prodaja kreirati pogled view_klase_prihoda koji će sadržavati ID radnika, 
ID države, količnik prošlogodišnje prodaje i prodajne kvote, te oznaku klase koje će biti formirane prema pravilu: 
	- <10			- klasa 1 
	- >=10 i <20	- klasa 2 
	- >=20 i <30	- klasa 3
*/

create view view_klase_prihoda
as
select radnikID, drzavaID, proslogod_prodaja / prod_kvota  kolicnik, 'klasa1' oznaka_klase
from radnik as r inner join prodaja as p
on r.radnikID = p.prodavacID
where proslogod_prodaja / prod_kvota < 10
union
select radnikID, drzavaID, proslogod_prodaja / prod_kvota  kolicnik, 'klasa 2' oznaka_klase
from radnik as r inner join prodaja as p
on r.radnikID = p.prodavacID
where proslogod_prodaja / prod_kvota >= 10 and proslogod_prodaja / prod_kvota < 20
union
select radnikID, drzavaID, proslogod_prodaja / prod_kvota  kolicnik, 'klasa 3' oznaka_klase
from radnik as r inner join prodaja as p
on r.radnikID = p.prodavacID
where proslogod_prodaja / prod_kvota >=20 and proslogod_prodaja / prod_kvota < 30

select *
from view_klase_prihoda

--5.
/*
Koristeći pogled view_klase_prihoda kreirati proceduru proc_klase_prihoda koja će prebrojati broj klasa. 
Procedura treba da sadrži naziv klase i ukupan broj pojavljivanja u pogledu view_klase_prihoda. 
Sortirati prema broju pojavljivanja u opadajućem redoslijedu.
*/

create procedure proc_klase_prihoda
as
begin
select oznaka_klase, COUNT(*) as count
from view_klase_prihoda
group by oznaka_klase
order by 2 desc
end

exec proc_klase_prihoda

--6.
/*
Koristeći tabele radnik i kupovina kreirati pogled view_kred_rejting koji će sadržavati kolone drzavaID, 
kreditni rejting i prebrojani broj pojavljivanja kreditnog rejtinga po ID države.
*/

create view view_kred_rejting
as
select drzavaID, kred_rejting, COUNT(kred_rejting) as count
from radnik as r inner join kupovina as  k
on r.radnikID = k.radnikID
group by drzavaID, kred_rejting

select *
from view_kred_rejting

--7.
/*
Koristeći pogled view_kred_rejting kreirati proceduru proc_kred_rejting koja će davati informaciju o najvećem
prebrojanom broju pojavljivanja kreditnog rejtinga. 
Procedura treba da sadrži oznaku kreditnog rejtinga i najveći broj pojavljivanja za taj kreditni rejting. 
Proceduru pokrenuti za sve kreditne rejtinge (1, 2, 3, 4, 5). 
*/

create procedure proc_kred_rejting
(@kred_rejting int)
as
begin
select kred_rejting, MAX(count)
from view_kred_rejting
where @kred_rejting = kred_rejting
group by kred_rejting
end

exec proc_kred_rejting 1

exec proc_kred_rejting 2

exec proc_kred_rejting 3

exec proc_kred_rejting 4

exec proc_kred_rejting 5

--8.
/*
Kreirati tabelu radnik_nova i u nju prebaciti sve zapise iz tabele radnik.
Nakon toga, svim radnicima u tabeli radnik_nova čije se ime u koloni loginID sastoji od 3 i manje slova, 
loginID promijeniti u slučajno generisani niz znakova.
*/

select *
into radnik_nova
from radnik

update radnik_nova
set loginID = left(NEWID(), 30)
where LEN(loginID) - 1 - CHARINDEX('\', loginID) <= 3

--9.
/*
a) Kreirati pogled view_sume koji će sadržavati sumu sati godišnjeg odmora i sumu sati bolovanja 
za radnike iz tabele radnik_nova kojima je loginID promijenjen u slučajno generisani niz znakova 
b) Izračunati odnos (količnik) sume bolovanja i sume godišnjeg odmora. Ako je odnos veći od 0.5 
dati poruku 'Suma bolovanja je prevelika. Odnos iznosi: ______'. U suprotnom dati poruku 
'Odnos je prihvaljiv i iznosi: _____'
*/

create view view_sume
as
select radnikID, SUM(sati_god_odmora) as suma_odmora, sum(sati_bolovanja) as suma_bolovanja,
'Suma bolovanja je prevelika. Odnos iznosi ' + cast(cast(SUM(sati_god_odmora) as real) / sum(sati_bolovanja) as varchar)
as kolicnik
from radnik_nova
where loginID not like 'adventure-works%'
group by radnikID
having cast(SUM(sati_god_odmora) as real) / sum(sati_bolovanja) > 0.5
union
select radnikID, SUM(sati_god_odmora) as suma_odmora, sum(sati_bolovanja) as suma_bolovanja,
'Odnos je prihvatljiv i iznosi: ' + cast(cast(SUM(sati_god_odmora) as real) / sum(sati_bolovanja) as varchar)
as kolicnik
from radnik_nova
where loginID not like 'adventure-works%'
group by radnikID
having cast(SUM(sati_god_odmora) as real) / sum(sati_bolovanja) < 0.5

select *
from view_sume

--10.
/*
a) Kreirati backup baze na default lokaciju.
b) Obrisati bazu.
c) Napraviti restore baze.
*/

backup database mojaBaza
to disk = 'mojaBaza.bak'

use master
go
drop database mojaBaza

restore database mojaBaza
from disk = 'mojaBaza.bak'

use mojaBaza

select *
from radnik

/*
Kreirati bazu podataka BrojIndeksa sa sljedećim parametrima:
a) primarni i sekundarni data fajl:
- veličina: 		5 MB
- maksimalna veličina: 	neograničena
- postotak rasta:	10%
b) log fajl
- veličina: 		2 MB
- maksimalna veličina: 	neograničena
- postotak rasta:	5%
Svi fajlovi trebaju biti smješteni u folder c:\BP2\data\ koji je potrebno prethodno kreirati.
*/

create database BrojIndeksa
on (name = BrojIndeksa_dat, filename = 'c:\BP2\data\BrojIndeksa.mdf', size = 5MB, maxsize = unlimited, filegrowth = 10%)
Log on (name = BrojIndeksa_log, filename = 'c:\BP2\data\BrojIndeksa.ldf', size = 2MB, maxsize = unlimited, filegrowth = 5%)