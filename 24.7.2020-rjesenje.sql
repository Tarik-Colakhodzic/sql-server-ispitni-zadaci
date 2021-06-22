--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.
*/

create database mojaBaza
go

use mojaBaza

/*
--Prilikom kreiranja tabela voditi racuna o medjusobnom odnosu izmedju tabela.

b) Kreirati tabelu radnik koja ce imati sljedecu strukturu:
	-radnikID, cjelobrojna varijabla, primarni kljuc
	-drzavaID, 15 unicode karaktera
	-loginID, 256 unicode karaktera
	-god_rod, cjelobrojna varijabla
	-spol, 1 unicode karakter 
*/

create table radnik
(
	radnikID int, --cjelobrojna varijabla, primarni kljuc
	drzavaID nvarchar(15), --15 unicode karaktera
	loginID nvarchar(256), --256 unicode karaktera
	god_rod int, --cjelobrojna varijabla
	spol nvarchar(1), --1 unicode karakter 	
	constraint PK_radnik primary key (radnikID)
)

/*
c) Kreirati tabelu nabavka koja ce imati sljedecu strukturu:
	-nabavkaID, cjelobrojna varijabla, primarni kljuc
	-status, cjelobrojna varijabla
	-radnikID, cjelobrojna varijabla
	-br_racuna, 15 unicode karaktera
	-naziv_dobavljaca, 50 unicode karaktera
	-kred_rejting, cjelobrojna varijabla
*/

create table nabavka
(
	nabavkaID int, --cjelobrojna varijabla, primarni kljuc
	status int, --cjelobrojna varijabla
	radnikID int, --cjelobrojna varijabla
	br_racuna nvarchar(15), --15 unicode karaktera
	naziv_dobavljaca nvarchar(50), --50 unicode karaktera
	kred_rejting int, --cjelobrojna varijabla	
	constraint PK_nabavka primary key (nabavkaID),
	constraint FK_nabavka_radnik foreign key (radnikID) references radnik(radnikID)
)

/*
c) Kreirati tabelu prodaja koja ce imati sljedecu strukturu:
	-prodajaID, cjelobrojna varijabla, primarni kljuc, inkrementalno punjenje sa pocetnom vrijednoscu 1, samo neparni brojevi
	-prodavacID, cjelobrojna varijabla
	-dtm_isporuke, datumsko-vremenska varijabla
	-vrij_poreza, novcana varijabla
	-ukup_vrij, novcana varijabla
	-online_narudzba, bit varijabla sa ogranicenjem kojim se mogu unijeti samo cifre 0 i 1
*/

create table prodaja
(
	prodajaID int identity(1,2), --cjelobrojna varijabla, primarni kljuc, inkrementalno punjenje sa pocetnom vrijednoscu 1, samo neparni brojevi
	prodavacID int, --cjelobrojna varijabla
	dtm_isporuke datetime, --datumsko-vremenska varijabla
	vrij_poreza money, --novcana varijabla
	ukup_vrij money, --novcana varijabla
	online_narudzba bit constraint CK_nulaIliJedan check (online_narudzba = 0 or online_narudzba = 1), 
	--bit varijabla sa ogranicenjem kojim se mogu unijeti samo cifre 0 i 1
	constraint PK_prodaja primary key (prodajaID),
	constraint FK_prodaja_radnik foreign key (prodavacID) references radnik(radnikID)
)

/*
--2
Import podataka

a) Iz tabele Employee iz šeme HumanResources baze AdventureWorks2017 u tabelu radnik importovati podatke po sljedecem pravilu:
	-BusinessEntityID -> radnikID
	-NationalIDNumber -> drzavaID
	-LoginID -> loginID
	-godina iz kolone BirthDate -> god_rod
	-Gender -> spol
*/

insert into radnik
select BusinessEntityID, NationalIDNumber, LoginID, YEAR(BirthDate), Gender 
from AdventureWorks2017.HumanResources.Employee

select *
from radnik

/*
b) Iz tabela PurchaseOrderHeader i Vendor šeme Purchasing baze AdventureWorks2017 u tabelu nabavka importovati podatke po sljedecem pravilu:
	-PurchaseOrderID -> dobavljanjeID
	-Status -> status
	-EmployeeID -> radnikID
	-AccountNumber -> br_racuna
	-Name -> naziv_dobavljaca
	-CreditRating -> kred_rejting
*/

insert into nabavka
select PurchaseOrderID, Status, EmployeeID, AccountNumber, Name, CreditRating
from AdventureWorks2017.Purchasing.PurchaseOrderHeader as poh inner join AdventureWorks2017.Purchasing.Vendor as v
on poh.PurchaseOrderID = v.BusinessEntityID

select *
from nabavka

/*
c) Iz tabele SalesOrderHeader šeme Sales baze AdventureWorks2017 u tabelu prodaja importovati podatke po sljedecem pravilu:
	-SalesPersonID -> prodavacID
	-ShipDate -> dtm_isporuke
	-TaxAmt -> vrij_poreza
	-TotalDue -> ukup_vrij
	-OnlineOrderFlag -> online_narudzba
*/

insert into prodaja
select SalesPersonID, ShipDate, TaxAmt, TotalDue, OnlineOrderFlag
from AdventureWorks2017.Sales.SalesOrderHeader

select *
from prodaja

/*
--3
a) U tabelu radnik dodati kolonu st_kat (starosna kategorija), tipa 3 karaktera.

b) Prethodno kreiranu kolonu popuniti po principu:
	starosna kategorija			uslov
	I							osobe do 30 godina starosti (ukljucuje se i 30)
	II							osobe od 31 do 49 godina starosti
	III							osobe preko 50 godina starosti

c) Neka osoba sa navrsenih 65 godina odlazi u penziju.
Prebrojati koliko radnika ima 10 ili manje godina do penzije.
Rezultat upita iskljucivo treba biti poruka:
'Broj radnika koji imaju 10 ili manje godina do penzije je' nakon cega slijedi prebrojani broj.
Nece se priznati rjesenje koje kao rezultat upita vraca vise kolona.
*/

alter table radnik
add st_kat char(3)

update radnik
set st_kat = 'I'
where YEAR(GETDATE()) - god_rod <= 30

update radnik
set st_kat = 'II'
where YEAR(GETDATE()) - god_rod > 30 and YEAR(GETDATE()) - god_rod <= 49

update radnik
set st_kat = 'III'
where YEAR(GETDATE()) - god_rod >= 50

select *
from radnik

select 'Broj radnika koji imaju 10 ili manje godina do penzije je ' + cast(COUNT(*) as varchar) as poruka
from radnik
where YEAR(GETDATE()) - god_rod >= 55


/*
--4
a) U tabeli prodaja kreirati kolonu stopa_poreza (10 unicode karaktera)

b) Prethodno kreiranu kolonu popuniti kao kolicnik vrij_poreza i ukup_vrij.
Stopu poreza izraziti kao cijeli broj s oznakom %, pri cemu je potrebno da izmedju brojcane vrijednosti i znaka % bude prazno mjesto.
(Npr: 14.00 %)
*/

alter table prodaja
add stopa_poreza nvarchar(10)

update prodaja
set stopa_poreza = cast(cast((vrij_poreza / ukup_vrij)*100 as int) as varchar) + ' %'

select *
from prodaja

/*
--5
a) Koristeci tabelu nabavka kreirati pogled view_slova sljedece strukture:
	-slova
	-prebrojano, prebrojani broj pojavljivanja slovnih dijelova podatka u koloni br_racuna.

b) Koristeci pogled view_slova odrediti razliku vrijednosti izmedju prebrojanih i srednje vrijednosti kolone.
Rezultat treba da sadrzi kolone slova, prebrojano i razliku.
Sortirati u rastucem redoslijedu prema razlici.
*/

create view view_slova 
as
select SUBSTRING(br_racuna, 0, CHARINDEX('0', br_racuna)) as slova, COUNT(*) as prebrojano
from nabavka
group by SUBSTRING(br_racuna, 0, CHARINDEX('0', br_racuna))

select slova, prebrojano, prebrojano - (select AVG(prebrojano) from view_slova) as razlika
from view_slova
order by 3 

/*
--6
a) Koristeci tabelu prodaja kreirati pogled view_stopa sljedece strukture:
	-prodajaID
	-stopa_poreza
	-stopa_num, u kojoj ce biti numericka vrijednost stope poreza

b) Koristeci pogled view_stopa, a na osnovu razlike izmedju vrijednosti u koloni stopa_num i srednje vrijednosti stopa poreza
za svaki proizvodID navesti poruku 'manji', odnosno, 'veci'.
*/

create view view_stopa
as
select prodajaID, stopa_poreza, CAST(left(stopa_poreza, 2) as int) as stopa_num
from prodaja

select *
from view_stopa

select prodajaID, 'veci' as poruka
from view_stopa
where stopa_num - (select AVG(cast(left(stopa_poreza, 2) as int)) from view_stopa) > 0
union
select prodajaID, 'manji' as poruka
from view_stopa
where stopa_num - (select AVG(cast(left(stopa_poreza, 2) as int)) from view_stopa) < 0


/*
--7 
Koristeci pogled view_stopa kreirati proceduru proc_stopa_poreza tako da je prilikom izvrsavanja moguce unijeti bilo koji broj
parametara (mozemo ostaviti bilo koji parametar bez unijete vrijednosti), pri cemu ce se prebrojati broj zapisa po stopi poreza uz 
uslov da se dohvate samo oni zapisi u kojima je stopa poreza veca od 10%.
Proceduru pokrenuti za sljedece vrijednosti:
	-stopa poreza = 12, 15 i 21
*/

select *
from view_stopa

create procedure proc_stopa_poreza
(
	@prodajaID int = null,
	@stopa_poreza varchar(10) = null,
	@stopa_num int = null
)
as
select stopa_poreza, COUNT(*) as prebrojano
from view_stopa
where (prodajaID = @prodajaID or stopa_poreza = @stopa_poreza or stopa_num = @stopa_num) and stopa_num > 10
group by stopa_poreza

exec proc_stopa_poreza @stopa_poreza = '12 %'
exec proc_stopa_poreza @stopa_poreza = '15 %'
exec proc_stopa_poreza @stopa_poreza = '21 %'


/*
--8
Kreirati proceduru proc_prodaja kojom ce se izvrsiti promjena vrijednosti u koloni online_narudzba tabele prodaja.
Promjena ce se vrsiti tako sto ce se 0 zamijeniti sa NO, a 1 sa YES.
Pokrenuti proceduru kako bi se izvrsile promjene, a nakon toga onemoguciti da se u koloni unosi bilo kakva druga 
vrijednost osim NO ili YES.
*/

alter table prodaja
drop constraint CK_nulaIliJedan

alter table prodaja
alter column online_narudzba varchar(3)

create procedure proc_prodaja
as
update prodaja
set online_narudzba = 'NO'
where online_narudzba = '0'
update prodaja
set online_narudzba = 'YES'
where online_narudzba = '1'

exec proc_prodaja

alter table prodaja
add constraint online_narudzba check(online_narudzba = 'YES' or online_narudzba = 'NO')

select *
from prodaja

/*
--9
a) Nad kolonom god_rod tabele radnik kreirati ogranicenje kojim ce se onemoguciti unos bilo koje 
godine iz buducnosti kao godina rodjenja.
Testirati funkcionalnost kreiranog ogranicenja navodjenjem koda za insert podataka kojim ce se kao 
godina rodjenja pokusati unijeti bilo koja godina iz buducnosti.
*/

select *
from radnik

alter table radnik
add constraint god_rod check(god_rod < Year(getdate()))

insert into radnik
values(300, 'test', 'test', 2025, 'M', 'I')


/*
b) Nad kolonom drzavaID tabele radnik kreirati ogranicenje kojim ce se ograniciti duzina podatka na 7 znakova.
Ako je prethodno potrebno, izvrsiti prilagodbu kolone, 
pri cemu nije dozvoljeno prilagodjavati podatke cija duzina iznosi 7 ili manje znakova.
Testirati funkcionalnost kreiranog ogranicenja navodjenjem koda za insert podataka kojim ce se u drzavaID pokusati 
unijeti podatak duzi od 7 znakova.
*/

update radnik
set drzavaID = LEFT(drzavaID, 7)
where LEN(drzavaID) > 7

alter table radnik
add constraint drzavaID check(len(drzavaID) <= 7)

select *
from radnik

insert into radnik
values(300, '12345678', 'test', 1999, 'M', 'I')

/*
--10
Kreirati backup baze na default lokaciju, obrisati bazu a zatim izvrsiti restore baze. 
Uslov prihvatanja koda je da se moze izvrsiti. */

backup database mojaBaza
to disk = 'mojaBaza.bak'

use master
go 
drop database mojaBaza

restore database mojaBaza
from disk = 'mojaBaza.bak'

use mojaBaza
go

select *
from radnik
