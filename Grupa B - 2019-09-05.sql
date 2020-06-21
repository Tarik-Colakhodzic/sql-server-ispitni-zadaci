/*Napomena:


1. Prilikom  bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti 
tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).

2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili 
je pogrešno urađeno predstavlja grešku. Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda 
("nisam vidio", "slučajno sam to napisao"...) 
*/


/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/

create database mojaBaza
go
use mojaBaza

/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu produkt sljedeće strukture:
	- produktID, cjelobrojna varijabla, primarni ključ
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- mj_jedinica, 20 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_post_br, 10 unicode karaktera
*/

create table produkt
(
	produktID int, --cjelobrojna varijabla, primarni ključ
	jed_cijena money, --novčana varijabla
	kateg_naziv nvarchar(15), --15 unicode karaktera
	mj_jedinica nvarchar(20), --20 unicode karaktera
	dobavljac_naziv nvarchar(40), --40 unicode karaktera
	dobavljac_post_br nvarchar(10), --10 unicode karaktera
	constraint PK_produkt primary key (produktID)
)

/*
II. Kreirati tabelu narudzba sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, primarni ključ
	- dtm_narudzbe, datumska varijabla za unos samo datuma
	- dtm_isporuke, datumska varijabla za unos samo datuma
	- grad_isporuke, 15 unicode karaktera
	- klijentID, 5 unicode karaktera
	- klijent_naziv, 40 unicode karaktera
	- prevoznik_naziv, 40 unicode karaktera
*/

create table narudzba
(
	narudzbaID int, --cjelobrojna varijabla, primarni ključ
	dtm_narudzbe date, --datumska varijabla za unos samo datuma
	dtm_isporuke date, --datumska varijabla za unos samo datuma
	grad_isporuke nvarchar(15), --15 unicode karaktera
	klijentID nvarchar(5), --5 unicode karaktera
	klijent_naziv nvarchar(40), --40 unicode karaktera
	prevoznik_naziv nvarchar(40), --40 unicode karaktera	
	constraint PK_narudzba primary key (narudzbaID)
)

/*
III. Kreirati tabelu narudzba_produkt sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- produktID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/

create table narudzba_produkt
(
	narudzbaID int not null,
	produktID int not null,
	uk_cijena money,
	constraint PK_narudzba_produkt primary key (narudzbaID, produktID),
	constraint FK_narudzba_produkt__narudzba foreign key (narudzbaID) references narudzba(narudzbaID),
	constraint FK_narudzba_proukt__produkt foreign key (produktID) references produkt(produktID)
)

--10 bodova



----------------------------------------------------------------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Categories, Product i Suppliers baze Northwind u tabelu produkt importovati podatke prema pravilu:
	- ProductID -> produktID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- PostalCode -> dobavljac_post_br
*/

insert into produkt (produktID, mj_jedinica, jed_cijena, kateg_naziv, dobavljac_naziv, dobavljac_post_br)
select ProductID, QuantityPerUnit, UnitPrice, CategoryName, CompanyName, PostalCode
from NORTHWND.dbo.Categories as c inner join NORTHWND.dbo.Products as  p
on c.CategoryID = p.CategoryID inner join NORTHWND.dbo.Suppliers as s
on p.SupplierID = s.SupplierID

select *
from produkt

/*
a) Iz tabela Customers, Orders i Shipers baze Northwind u tabelu narudzba importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- ShipCity -> grad_isporuke
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/

insert into narudzba
select OrderID, OrderDate, ShippedDate, ShipCity, c.CustomerID, c.CompanyName, s.CompanyName
from NORTHWND.dbo.Customers as c inner join NORTHWND.dbo.Orders as o
on c.CustomerID = o.CustomerID inner join NORTHWND.dbo.Shippers as s
on o.ShipVia = s.ShipperID

select *
from narudzba

/*
c) Iz tabele Order Details baze Northwind u tabelu narudzba_produkt importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> produktID
	- uk_cijena <- produkt jedinične cijene i količine
uz uslov da je odobren popust 5% na produkt.
*/

insert into narudzba_produkt
select OrderID, ProductID, UnitPrice * Quantity
from NORTHWND.dbo.[Order Details]
where Discount = 0.05

select *
from narudzba_produkt

--10 bodova


----------------------------------------------------------------------------------------------------------------------------
/*
3. 
a) Koristeći tabele narudzba i narudzba_produkt kreirati pogled view_uk_cijena koji će imati strukturu:
	- narudzbaID
	- klijentID
	- uk_cijena_cijeli_dio
	- uk_cijena_feninzi - prikazati kao cijeli broj  
Obavezno pregledati sadržaj pogleda.
b) Koristeći pogled view_uk_cijena kreirati tabelu nova_uk_cijena uz uslov da se preuzmu samo oni zapisi u 
kojima su feninzi veći od 49. 
U tabeli trebaju biti sve kolone iz pogleda, te nakon njih kolona uk_cijena_nova u kojoj će ukupna cijena 
biti zaokružena na veću vrijednost. 
Npr. uk_cijena = 10, feninzi = 90 -> uk_cijena_nova = 11
*/

create view view_uk_cijena
as
select n.narudzbaID, klijentID, uk_cijena, cast((uk_cijena - FLOOR(uk_cijena)) * 100 as int) as uk_cijena_feninzi
from narudzba as n inner join narudzba_produkt as np
on n.narudzbaID = np.narudzbaID

select *, ROUND(uk_cijena, 0) as uk_cijena_nova
into nova_uk_cijena
from view_uk_cijena
where uk_cijena_feninzi > 49

select *
from nova_uk_cijena

----------------------------------------------------------------------------------------------------------------------------
/*
4. 
Koristeći tabelu nova_uk_cijena kreiranu u 3. zadatku kreirati proceduru tako da je prilikom 
izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće vrijednosti varijabli:
1. narudzbaID - 10730
2. klijentID  - ERNSH
*/

create procedure proc_uk_cijena_nova
(
	@narudzbaID int = null,
	@klijentID nvarchar(5) = null,
	@uk_cijena money = null,
	@uk_cijena_feninzi int = null,
	@uk_cijena_nova money = null
)
as
begin
select *
from nova_uk_cijena
where @narudzbaID = narudzbaID or @klijentID = klijentID or @uk_cijena = uk_cijena or @uk_cijena_feninzi = uk_cijena_feninzi
or @uk_cijena_nova = @uk_cijena_nova
end

exec proc_uk_cijena_nova 10730, 'ERNSH'

--10 bodova



----------------------------------------------------------------------------------------------------------------------------
/*
5.
Koristeći tabelu produkt kreirati proceduru proc_post_br koja će prebrojati zapise u kojima poštanski broj 
dobavljača počinje cifrom. 
Potrebno je dati prikaz poštanskog broja i ukupnog broja zapisa po poštanskom broju. 
Nakon kreiranja pokrenuti proceduru.
*/
 
create procedure proc_post_br
as
begin
select dobavljac_post_br, COUNT(*) as 'count_of_post_br'
from produkt
where dobavljac_post_br like '[0123456789]%'
group by dobavljac_post_br
end

exec proc_post_br

--5 bodova


-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba kreirati pogled view_prebrojano sljedeće strukture:
	- klijent_naziv
	- prebrojano - ukupan broj narudžbi po nazivu klijent
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati maksimalna vrijednost kolone prebrojano.
a) dati pregled zapisa u kojem će osim kolona iz pogleda prikazati razlika maksimalne vrijednosti i kolone prebrojano 
uz uslov da se ne prikazuje zapis u kojem se nalazi maksimlana vrijednost.
*/

create view view_prebrojano
as
select klijent_naziv, COUNT(*) as 'prebrojano'
from narudzba
group by klijent_naziv

select MAX(prebrojano) as 'max'
from view_prebrojano

select klijent_naziv, prebrojano, prebrojano - (select MAX(prebrojano) from view_prebrojano) razlika_max
from view_prebrojano
where prebrojano != (select MAX(prebrojano) from view_prebrojano)

--12 bodova

-------------------------------------------------------------------
/*
7.
a) U tabeli produkt dodati kolonu lozinka, 20 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone lozinka na sljedeći način:
	- ako je u dobavljac_post_br podatak sačinjen samo od cifara, lozinka se kreira 
	obrtanjem niza znakova koji se dobiju spajanjem zadnja četiri 
	znaka kolone mj_jedinica i kolone dobavljac_post_br
	- ako podatak u dobavljac_post_br podatak sadrži jedno ili više slova na bilo kojem mjestu, 
	lozinka se kreira obrtanjem slučajno generisanog niza znakova
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/

alter table produkt
add lozinka nvarchar(20)

create procedure proc_lozinka
as
begin
update produkt
set lozinka = REVERSE(right(mj_jedinica, 4) + RIGHT(dobavljac_post_br, 4))
where ISNUMERIC(dobavljac_post_br) = 1
update produkt
set lozinka = LEFT(newid(), 20)
where ISNUMERIC(dobavljac_post_br) = 0
end

exec proc_lozinka

select *
from produkt

--10 bodova


-------------------------------------------------------------------
/*
8. 
a) Kreirati pogled kojim sljedeće strukture:
	- produktID,
	- dobavljac_naziv,
	- grad_isporuke
	- period_do_isporuke koji predstavlja vremenski period od datuma narudžbe do datuma isporuke
Uslov je da se dohvate samo oni zapisi u kojima je narudzba realizirana u okviru 4 sedmice.
Obavezno pregledati sadržaj pogleda.

b) Koristeći pogled view_isporuka kreirati tabelu isporuka u koju će biti smještene sve kolone iz pogleda. 
*/

create view view_isporuka
as
select p.produktID, dobavljac_naziv, grad_isporuke, dtm_narudzbe, dtm_isporuke,
DATEDIFF(WEEK, dtm_narudzbe, dtm_isporuke) as 'period_do_isporuke'
from narudzba as n inner join narudzba_produkt as np
on n.narudzbaID = np.narudzbaID inner join produkt as p
on np.produktID = p.produktID
where DATEDIFF(WEEK, dtm_narudzbe, dtm_isporuke) <= 4

select *
from view_isporuka

select *
into isporuka
from view_isporuka

-------------------------------------------------------------------
/*
9.
a) U tabeli isporuka dodati kolonu red_br_sedmice, 10 unicode karaktera.
b) U tabeli isporuka izvršiti update kolone red_br_sedmice ( prva, druga, treca, cetvrta) u zavisnosti od vrijednosti 
u koloni period_do_isporuke. 
Pokrenuti proceduru
c) Kreirati pregled kojim će se prebrojati broj zapisa po rednom broju sedmice. 
Pregled treba da sadrži redni broj sedmice i ukupan broj zapisa po rednom broju.
*/

alter table isporuka
add red_br_sedmice nvarchar(10)

create procedure proc_br_sedmice
as
begin
update isporuka
set red_br_sedmice = 'prva'
where period_do_isporuke = 0 or period_do_isporuke = 1
update isporuka
set red_br_sedmice = 'druga'
where period_do_isporuke = 2
update isporuka
set red_br_sedmice = 'treca'
where period_do_isporuke = 3
update isporuka 
set red_br_sedmice = 'cetvrta'
where period_do_isporuke = 4
end

exec proc_br_sedmice

select *
from isporuka

select red_br_sedmice, COUNT(*) count
from isporuka
group by red_br_sedmice

--15 bodova

-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/

backup database mojaBaza
to disk = 'mojaBaza.bak'

create procedure proc_brisanjePoglediProcedure
as
begin
drop view [dbo].[view_isporuka], [dbo].[view_prebrojano], [dbo].[view_uk_cijena]
drop procedure [dbo].[proc_br_sedmice], [dbo].[proc_lozinka], [dbo].[proc_post_br], [dbo].[proc_uk_cijena_nova]
end

exec proc_brisanjePoglediProcedure

--5 BODOVA
