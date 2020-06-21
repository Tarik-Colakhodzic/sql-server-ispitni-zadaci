----------------------------------------------------------------1.
/*
Koristeći isključivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
*/

create database mojaBaza
go
use mojaBaza


/*
Unutar svoje baze podataka kreirati tabele sa sljedećom struktorom:
--NARUDZBA
a) Narudzba
NarudzbaID, primarni ključ
Kupac, 40 UNICODE karaktera
PunaAdresa, 80 UNICODE karaktera
DatumNarudzbe, datumska varijabla, definirati kao datum
Prevoz, novčana varijabla
Uposlenik, 40 UNICODE karaktera
GradUposlenika, 30 UNICODE karaktera
DatumZaposlenja, datumska varijabla, definirati kao datum
BrGodStaza, cjelobrojna varijabla
*/

create table Narudzba
(
	NarudzbaID int, --primarni ključ
	Kupac nvarchar(40), --40 UNICODE karaktera
	PunaAdresa nvarchar(80), --80 UNICODE karaktera
	DatumNarudzbe date, --datumska varijabla, definirati kao datum
	Prevoz money, --novčana varijabla
	Uposlenik nvarchar(40), --40 UNICODE karaktera
	GradUposlenika nvarchar(30), --30 UNICODE karaktera
	DatumZaposlenja date, --datumska varijabla, definirati kao datum
	BrGodStaza int, --cjelobrojna varijabla
	constraint PK_Narudzba primary key (NarudzbaID)
)


--PROIZVOD
/*
b) Proizvod
ProizvodID, cjelobrojna varijabla, primarni ključ
NazivProizvoda, 40 UNICODE karaktera
NazivDobavljaca, 40 UNICODE karaktera
StanjeNaSklad, cjelobrojna varijabla
NarucenaKol, cjelobrojna varijabla
*/

create table Proizvod
(
	ProizvodID int, --cjelobrojna varijabla, primarni ključ
	NazivProizvoda nvarchar(40), --40 UNICODE karaktera
	NazivDobavljaca nvarchar(40), --40 UNICODE karaktera
	StanjeNaSklad int, --cjelobrojna varijabla
	NarucenaKol int, --cjelobrojna varijabla
	constraint PK_Proizvod primary key (ProizvodID)
)

--DETALJINARUDZBE
/*
c) DetaljiNarudzbe
NarudzbaID, cjelobrojna varijabla, obavezan unos
ProizvodID, cjelobrojna varijabla, obavezan unos
CijenaProizvoda, novčana varijabla
Kolicina, cjelobrojna varijabla, obavezan unos
Popust, varijabla za realne vrijednosti
Napomena: Na jednoj narudžbi se nalazi jedan ili više proizvoda.
*/

create table DetaljiNarudzbe
(
	NarudzbaID int not null, --cjelobrojna varijabla, obavezan unos
	ProizvodID int not null, --cjelobrojna varijabla, obavezan unos
	CijenaProizvoda money, --novčana varijabla
	Kolicina int not null, --cjelobrojna varijabla, obavezan unos
	Popust real, --varijabla za realne vrijednosti
	--Napomena: Na jednoj narudžbi se nalazi jedan ili više proizvoda.
	constraint PK_DetaljiNarudzbe primary key (NarudzbaID, ProizvodID),
	constraint FK_DetaljiNarudzbe_Narudzba foreign key (NarudzbaID) references Narudzba(NarudzbaID),
	constraint FK_DetaljiNarudzbe_Proizvod foreign key (ProizvodID) references Proizvod(ProizvodID)
)

----------------------------------------------------------------2.
--2a) narudzbe
/*
Koristeći bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedećem pravilu:
OrderID -> ProizvodID
ComapnyName -> Kupac
PunaAdresa - spojeno adresa, poštanski broj i grad, pri čemu će se između riječi staviti srednja crta sa 
razmakom prije i poslije nje
OrderDate -> DatumNarudzbe
Freight -> Prevoz
Uposlenik - spojeno prezime i ime sa razmakom između njih
City -> Grad iz kojeg je uposlenik
HireDate -> DatumZaposlenja
BrGodStaza - broj godina od datum zaposlenja
*/

insert into Narudzba
select OrderID, CompanyName, c.Address + '_' + c.PostalCode + '_' + c.City, OrderDate, Freight, e.FirstName + ' ' + e.LastName,
e.City, HireDate, YEAR(getdate()) - YEAR(HireDate)
from NORTHWND.dbo.Orders as o inner join NORTHWND.dbo.Customers as c
on o.CustomerID = c.CustomerID inner join NORTHWND.dbo.Employees as e
on o.EmployeeID = e.EmployeeID

select *
from Narudzba

--proizvod
/*
Koristeći bazu Northwind iz tabela Products i Suppliers podupitom importovati podatke po sljedećem pravilu:
ProductID -> ProizvodID
ProductName -> NazivProizvoda 
CompanyName -> NazivDobavljaca 
UnitsInStock -> StanjeNaSklad 
UnitsOnOrder -> NarucenaKol 
*/

insert into Proizvod
select *
from (select ProductID, ProductName, CompanyName, UnitsInStock ,UnitsOnOrder
from NORTHWND.dbo.Products as p inner join NORTHWND.dbo.Suppliers as s
on p.SupplierID = s.SupplierID ) as tbl

select *
from Proizvod

--detaljinarudzbe
/*
Koristeći bazu Northwind iz tabele Order Details importovati podatke po sljedećem pravilu:
OrderID -> NarudzbaID
ProductID -> ProizvodID
CijenaProizvoda - manja zaokružena vrijednost kolone UnitPrice, npr. UnitPrice = 3,60 CijenaProizvoda = 3,00
*/

alter table DetaljiNarudzbe
alter column Kolicina int null

insert into DetaljiNarudzbe (NarudzbaID, ProizvodID, CijenaProizvoda)
select OrderID, ProductID, floor(UnitPrice)
from NORTHWND.dbo.[Order Details]


----------------------------------------------------------------3.
--3a
/*
U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. 
Postaviti uslov da podatak mora biti dužine tačno 15 karaktera.
*/

alter table Narudzba
add SifraUposlenika nvarchar(20) constraint CK_Sifra check (len(SifraUposlenika) = 15)

--3b
/*
Kolonu SifraUposlenika popuniti na način da se obrne string koji se dobije spajanjem grada uposlenika i prvih 
10 karaktera datuma zaposlenja pri 
čemu se između grada i 10 karaktera nalazi jedno prazno mjesto. Provjeriti da li je izvršena izmjena.
*/

update Narudzba
set SifraUposlenika = left(reverse(GradUposlenika + ' ' + cast(DatumZaposlenja as nvarchar)), 15)

select *
from Narudzba

--3c
/*
U tabeli Narudzba u koloni SifraUposlenika izvršiti zamjenu svih zapisa kojima grad uposlenika završava slovom "d" 
tako da se umjesto toga ubaci 
slučajno generisani string dužine 20 karaktera. Provjeriti da li je izvršena zamjena.
*/

alter table Narudzba
drop constraint CK_Sifra

update Narudzba
set SifraUposlenika = LEFT(newid(), 20)
where GradUposlenika like '%d'

select *
from Narudzba

----------------------------------------------------------------4.
/*
Koristeći svoju bazu iz tabela Narudzba i DetaljiNarudzbe kreirati pogled koji će imati sljedeću strukturu: 
Uposlenik, SifraUposlenika, 
ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je dužina sifre uposlenika 20 karaktera, 
te da je ukupan broj proizvoda veći od 2. 
Provjeriti sadržaj pogleda, pri čemu se treba izvršiti sortiranje po ukupnom broju proizvoda u opadajućem redoslijedu.*/

create view view_ukupnoProizvoda
as
select Uposlenik, SifraUposlenika, COUNT(NazivProizvoda) as 'Ukupan broj proizvoda'
from Narudzba as n inner join DetaljiNarudzbe as dn
on n.NarudzbaID = dn.NarudzbaID inner join Proizvod as p
on dn.ProizvodID = p.ProizvodID
where LEN(SifraUposlenika) = 20
group by Uposlenik, SifraUposlenika
having COUNT(NazivProizvoda) > 2

select *
from view_ukupnoProizvoda
order by [Ukupan broj proizvoda] desc

----------------------------------------------------------------5. 
/*
Koristeći vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom će se dužina podatka u koloni SifraUposlenika 
smanjiti sa 20 na 4 slučajno generisana karaktera. Pokrenuti proceduru. */

create procedure proc_izmjenaSifre
as
begin
update Narudzba
set SifraUposlenika = LEFT(newid(), 4)
where LEN(SifraUposlenika) = 20
end

exec proc_izmjenaSifre

select *
from Narudzba


----------------------------------------------------------------6.
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: NazivProizvoda, 
Ukupno - ukupnu sumu prodaje proizvoda uz uzimanje u obzir i popusta. 
Suma mora biti zakružena na dvije decimale. U pogled uvrstiti one proizvode koji su naručeni,
uz uslov da je suma veća od 10000. 
Provjeriti sadržaj pogleda pri čemu ispis treba sortirati u opadajućem redoslijedu po vrijednosti sume.
*/

create view view_proizvodUkupno
as
select NazivProizvoda, Round(SUM(CijenaProizvoda - CijenaProizvoda * ISNULL(Popust, 0)), 2) as 'Suma'
from DetaljiNarudzbe as dn inner join Proizvod as p
on dn.ProizvodID = p.ProizvodID
group by NazivProizvoda
having SUM(CijenaProizvoda - CijenaProizvoda * ISNULL(Popust, 0)) > 1000

select *
from view_proizvodUkupno
order by Suma desc

----------------------------------------------------------------7.
--7a
/*
Koristeći vlastitu bazu podataka kreirati pogled koji će imati sljedeću strukturu: Kupac, NazivProizvoda, 
suma po cijeni proizvoda pri čemu će se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda 
veća od srednje vrijednosti 
cijene proizvoda. Provjeriti sadržaj pogleda pri čemu izlaz treba sortirati u rastućem redoslijedu izračunatoj sumi.
*/

create view view_KupacProizvodSuma
as
select Kupac, NazivProizvoda, SUM(CijenaProizvoda) as 'Suma'
from Narudzba as n inner join DetaljiNarudzbe as dn
on n.NarudzbaID = dn.NarudzbaID inner join Proizvod as p
on dn.ProizvodID = p.ProizvodID
group by Kupac, NazivProizvoda
having SUM(CijenaProizvoda) > (select AVG(CijenaProizvoda) from DetaljiNarudzbe)

select *
from view_KupacProizvodSuma
order by Suma asc

/*
Koristeći vlastitu bazu podataka kreirati proceduru kojom će se, 
koristeći prethodno kreirani pogled, definirati parametri: kupac,
NazivProizvoda i SumaPoCijeni. Proceduru kreirati tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara
(možemo ostaviti bilo koji parametar bez unijete vrijednosti), 
uz uslov da vrijednost sume bude veća od srednje vrijednosti suma koje
su smještene u pogled. Sortirati po sumi cijene. 
Procedura se treba izvršiti ako se unese vrijednost za bilo koji parametar.
Nakon kreiranja pokrenuti proceduru za sljedeće vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Côte de Blaye
*/

create procedure proc_SumaPoCijeni
(
	@kupac varchar(40) = null,
	@NazivProizvoda varchar(40) = null,
	@SumaPoCijeni money = null
)
as
begin
select *
from view_KupacProizvodSuma
where (@kupac = Kupac or @NazivProizvoda = NazivProizvoda or @SumaPoCijeni = Suma) 
and @SumaPoCijeni > (select AVG(Suma) from view_KupacProizvodSuma)
end

exec proc_SumaPoCijeni @kupac = 'Hanari Carnes', @NazivProizvoda = 'Côte de Blaye', @SumaPoCijeni = 123

----------------------------------------------------------------8.
/*
a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. 
Uključiti i kolone StanjeNaSklad i NarucenaKol. 
Napisati proizvoljni upit nad tabelom Proizvod koji u potpunosti koristi prednosti kreiranog indeksa.*/

create nonclustered index IX_Dobavljac 
on Proizvod (NazivDobavljaca)
include (StanjeNaSklad, NarucenaKol)

select NazivDobavljaca
from Proizvod
order by NazivDobavljaca asc

/*b) Uraditi disable indeksa iz prethodnog koraka.*/

alter index IX_Dobavljac on Proizvod disable

----------------------------------------------------------------9.
/*Napraviti backup baze podataka na default lokaciju servera.*/

backup database mojaBaza
to disk = 'mojaBaza.bak'

----------------------------------------------------------------10.
/*Kreirati proceduru kojom će se u jednom pokretanju izvršiti brisanje svih pogleda 
i procedura koji su kreirani u Vašoj bazi.*/

create procedure proc_brisanjePogledaProcedura
as
begin
drop view view_KupacProizvodSuma, view_proizvodUkupno, view_ukupnoProizvoda
drop procedure proc_SumaPoCijeni, proc_izmjenaSifre
end

exec proc_brisanjePogledaProcedura
