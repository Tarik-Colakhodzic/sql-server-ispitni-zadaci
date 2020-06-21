/*
Napomena:

1. Prilikom bodovanja rješenja prioritet ima razultat koji treba upit da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, jer ni ta rješenja ne mogu vratiti tačan rezultat 
(broj zapisa, vrijednosti agregatnih funkcija...).

2. Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
Shodno navedenom na uvidu se ne prihvata prigovor da je neki dio koda posljedica previda ("nisam vidio", "slučajno sam to napisao"...) 
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
I. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID, cjelobrojna varijabla, primarni ključ
	dtm_narudzbe, datumska varijabla za unos samo datuma
	dtm_isporuke, datumska varijabla za unos samo datuma
	prevoz, novčana varijabla
	klijentID, 5 unicode karaktera
	klijent_naziv, 40 unicode karaktera
	prevoznik_naziv, 40 unicode karaktera
*/

create table narudzba
(
	narudzbaID int, --cjelobrojna varijabla, primarni ključ
	dtm_narudzbe date, --datumska varijabla za unos samo datuma
	dtm_isporuke date, --datumska varijabla za unos samo datuma
	prevoz money, --novčana varijabla
	klijentID nvarchar(5), --5 unicode karaktera
	klijent_naziv nvarchar(40), --40 unicode karaktera
	prevoznik_naziv nvarchar(40), --40 unicode karaktera	
	constraint PK_narudzba primary key (narudzbaID)
)


/*
II. Kreirati tabelu proizvod sljedeće strukture:
	- proizvodID, cjelobrojna varijabla, primarni ključ
	- mj_jedinica, 20 unicode karaktera
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_web, tekstualna varijabla
*/

create table proizvod
(
	proizvodID int, --cjelobrojna varijabla, primarni ključ
	mj_jedinica nvarchar(20), --20 unicode karaktera
	jed_cijena money, --novčana varijabla
	kateg_naziv nvarchar(15), --15 unicode karaktera
	dobavljac_naziv nvarchar(40), --40 unicode karaktera
	dobavljac_web text, --tekstualna varijabla
	constraint PK_proizvod primary key (proizvodID)
)


/*
III. Kreirati tabelu narudzba_proizvod sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- proizvodID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/

create table narudzba_proizvod
(
	narudzbaID int not null, --cjelobrojna varijabla, obavezan unos
	proizvodID int not null, --cjelobrojna varijabla, obavezan unos
	uk_cijena money,  --novčana varijabla	
	constraint PK_narudzba_proizvod primary key (narudzbaID, proizvodID),
	constraint FK_narudzba_proizvod__narudzba foreign key (narudzbaID) references narudzba(narudzbaID),
	constraint FK_narudzba_proizvod__proizvod foreign key (proizvodID) references proizvod(proizvodID)
)

-------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Customers, Orders i Shipers baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- Freight -> prevoz
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/

insert into narudzba
select OrderID, OrderDate, ShippedDate, Freight, c.CustomerID, c.CompanyName, s.CompanyName
from NORTHWND.dbo.Customers as c inner join NORTHWND.dbo.Orders as o
on c.CustomerID = o.CustomerID inner join NORTHWND.dbo.Shippers as s
on o.ShipVia = s.ShipperID

select *
from narudzba

/*
b) Iz tabela Categories, Product i Suppliers baze Northwind importovati podatke prema pravilu:
	- ProductID -> proizvodID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- HomePage -> dobavljac_web
*/

insert into proizvod
select ProductID, QuantityPerUnit, UnitPrice, CategoryName, CompanyName, HomePage
from NORTHWND.dbo.Categories as c inner join NORTHWND.dbo.Products as p
on c.CategoryID = p.CategoryID inner join NORTHWND.dbo.Suppliers as s
on p.SupplierID = s.SupplierID

select *
from proizvod

/*
c) Iz tabele Order Details baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> proizvodID
	- uk_cijena <- proizvod jedinične cijene i količine
uz uslov da nije odobren popust na proizvod.
*/

insert into narudzba_proizvod
select OrderID, ProductID, UnitPrice * Quantity
from NORTHWND.dbo.[Order Details]
where Discount = 0

select *
from narudzba_proizvod

--10 bodova


-------------------------------------------------------------------
/*
3. 
Koristeći tabele proizvod i narudzba_proizvod kreirati pogled view_kolicina koji će imati strukturu:
	- proizvodID
	- kateg_naziv
	- jed_cijena
	- uk_cijena
	- kolicina - količnik ukupne i jedinične cijene
U pogledu trebaju biti samo oni zapisi kod kojih količina ima smisao (nije moguće da je na stanju 1,23 proizvoda).
Obavezno pregledati sadržaj pogleda.
*/

create view view_kolicina
as
select p.proizvodID, kateg_naziv, mj_jedinica, uk_cijena, uk_cijena / jed_cijena as 'kolicina'
from proizvod as p inner join narudzba_proizvod as np
on p.proizvodID = np.proizvodID
where (uk_cijena / jed_cijena - FLOOR(uk_cijena / jed_cijena)) = 0

select *
from view_kolicina


--7 bodova


-------------------------------------------------------------------
/*
4. 
Koristeći pogled kreiran u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti 
bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće nazive kategorija:
1. Produce
2. Beverages
*/

create procedure proc_Vkolicina
(
@proizvodID int = null, 
@kateg_naziv nvarchar(15) = null, 
@mj_jedinica nvarchar(20) = null, 
@uk_cijena money = null,
@kolicina money = null
)
as
begin
select *
from view_kolicina
where proizvodID = @proizvodID or kateg_naziv = @kateg_naziv or mj_jedinica = @mj_jedinica or uk_cijena = @uk_cijena
or kolicina = @kolicina
end

exec proc_Vkolicina @kateg_naziv = 'Produce'

exec proc_Vkolicina @kateg_naziv = 'Beverages'


--8 bodova

------------------------------------------------
/*
5.
Koristeći pogled kreiran u 3. zadatku kreirati proceduru proc_br_kat_naziv koja će vršiti 
prebrojavanja po nazivu kategorije. 
Nakon kreiranja pokrenuti proceduru.
*/

create procedure proc_br_kat_naziv
as
select kateg_naziv, COUNT(kateg_naziv) as 'count_kateg_naziv'
from view_kolicina
group by kateg_naziv

exec proc_br_kat_naziv

-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba_proizvod kreirati pogled view_suma sljedeće strukture:
	- narudzbaID
	- suma - sume ukupne cijene po ID narudžbe
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati srednja vrijednost sume zaokružena na dvije decimale.
c) Iz pogleda kreiranog pod a) dati pregled zapisa čija je suma veća od prosječne sume. Osim kolona iz pogleda, 
potrebno je prikazati razliku sume i srednje vrijednosti. 
Razliku zaokružiti na dvije decimale.
*/

--15 bodova

create view view_suma
as
select narudzbaID, SUM(uk_cijena) as 'suma'
from narudzba_proizvod
group by narudzbaID

select *, round(suma - (select AVG(suma) from view_suma), 2) as 'razlika' 
from view_suma
where suma > (select AVG(suma) from view_suma)

select *
from view_suma

select round(AVG(suma), 2) as avg
from view_suma

-------------------------------------------------------------------
/*
7.
a) U tabeli narudzba dodati kolonu evid_br, 30 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone evid_br na sljedeći način:
	- ako u datumu isporuke nije unijeta vrijednost, evid_br se dobija generisanjem slučajnog niza znakova
	- ako je u datumu isporuke unijeta vrijednost, evid_br se dobija spajanjem datum narudžbe i datuma isprouke 
	uz umetanje donje crte između datuma
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/

alter table narudzba
add evid_br nvarchar(30)

select *
from narudzba

create procedure proc_evid_br
as
begin
update narudzba
set evid_br = left(NEWID(), 30)
where dtm_isporuke is null
update narudzba
set evid_br = CAST(dtm_narudzbe as nvarchar) + '_' + CAST(dtm_isporuke as nvarchar)
where dtm_isporuke is not null
end

exec proc_evid_br

select *
from narudzba

--15 bodova


-------------------------------------------------------------------
/*
8. Kreirati proceduru kojom će se dobiti pregled sljedećih kolona:
	- narudzbaID,
	- klijent_naziv,
	- proizvodID,
	- kateg_naziv,
	- dobavljac_naziv
Uslov je da se dohvate samo oni zapisi u kojima naziv kategorije sadrži samo 1 riječ.
Pokrenuti proceduru.
*/

create procedure proc_kateg_naziv
as
select n.narudzbaID, klijent_naziv, p.proizvodID, kateg_naziv, dobavljac_naziv
from narudzba as n inner join narudzba_proizvod as np
on n.narudzbaID = np.narudzbaID inner join proizvod as p
on np.proizvodID = p.proizvodID
where kateg_naziv not like '% %' and kateg_naziv not like '%/%'

exec proc_kateg_naziv

--10 bodova


-------------------------------------------------------------------
/*
9.
U tabeli proizvod izvršiti update kolone dobavljac_web tako da se iz kolone dobavljac_naziv uzme prva riječ, 
a zatim se formira web adresa u formi www.prva_rijec.com. 
Update izvršiti pomoću dva upita, vodeći računa o broju riječi u nazivu. 
*/

update proizvod
set dobavljac_web = 'www.' + SUBSTRING(dobavljac_naziv, 0, CHARINDEX(' ', dobavljac_naziv, 0)) + '.com'
where dobavljac_naziv like '% %'


update proizvod
set dobavljac_web = null
where dobavljac_naziv like '% %'

update proizvod
set dobavljac_web = 'www.' + dobavljac_naziv + '.com'
where dobavljac_naziv not like '% %'

select *
from proizvod

-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. 
Pokrenuti proceduru.
*/

backup database mojaBaza
to disk = 'mojaBaza.bak'


create procedure proc_brisanjePogledaProcedura
as
begin
drop view [dbo].[view_kolicina], [dbo].[view_suma]
drop procedure [dbo].[proc_Vkolicina], [dbo].[proc_br_kat_naziv], [dbo].[proc_evid_br], [dbo].[proc_kateg_naziv]
end

exec proc_brisanjePogledaProcedura