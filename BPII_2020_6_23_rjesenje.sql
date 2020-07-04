----------------------------
--1.
----------------------------
/*
Kreirati bazu pod vlastitim brojem indeksa
*/

create database mojaBaza
go
use mojaBaza

-----------------------------------------------------------------------
--Prilikom kreiranja tabela voditi računa o njihovom međusobnom odnosu.
-----------------------------------------------------------------------
/*
a) 
Kreirati tabelu dobavljac sljedeće strukture:
	- dobavljac_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_br_rac - 50 unicode karaktera
	- naziv_dobavljaca - 50 unicode karaktera
	- kred_rejting - cjelobrojna vrijednost
*/

create table dobavljac
(
	dobavljac_id int, --cjelobrojna vrijednost, primarni ključ
	dobavljac_br_rac nvarchar(50), --50 unicode karaktera
	naziv_dobavljaca nvarchar(50), --50 unicode karaktera
	kred_rejting int, --cjelobrojna vrijednost
	constraint PK_dobavljac primary key (dobavljac_id)
)

/*
b)
Kreirati tabelu narudzba sljedeće strukture:
	- narudzba_id - cjelobrojna vrijednost, primarni ključ
	- narudzba_detalj_id - cjelobrojna vrijednost, primarni ključ
	- dobavljac_id - cjelobrojna vrijednost
	- dtm_narudzbe - datumska vrijednost
	- naruc_kolicina - cjelobrojna vrijednost
	- cijena_proizvoda - novčana vrijednost
*/

create table narudzba
(
	narudzba_id int, --cjelobrojna vrijednost, primarni ključ
	narudzba_detalj_id int, --cjelobrojna vrijednost, primarni ključ
	dobavljac_id int, --cjelobrojna vrijednost
	dtm_narudzbe date, --datumska vrijednost
	naruc_kolicina int, --cjelobrojna vrijednost
	cijena_proizvoda money,--novčana vrijednost
	constraint PK_narudzba primary key (narudzba_id, narudzba_detalj_id),
	constraint FK_narudzba_dobavljac foreign key (dobavljac_id) references dobavljac(dobavljac_id)
)

/*
c)
Kreirati tabelu dobavljac_proizvod sljedeće strukture:
	- proizvod_id cjelobrojna vrijednost, primarni ključ
	- dobavljac_id cjelobrojna vrijednost, primarni ključ
	- proiz_naziv 50 unicode karaktera
	- serij_oznaka_proiz 50 unicode karaktera
	- razlika_min_max cjelobrojna vrijednost
	- razlika_max_narudzba cjelobrojna vrijednost
*/

create table dobavljac_proizvod
(
	proizvod_id int, --cjelobrojna vrijednost, primarni ključ
	dobavljac_id int, --cjelobrojna vrijednost, primarni ključ
	proiz_naziv nvarchar(50), --50 unicode karaktera
	serij_oznaka_proiz nvarchar(50), --50 unicode karaktera
	razlika_min_max int, --cjelobrojna vrijednost
	razlika_max_narudzba int, --cjelobrojna vrijednost	
	constraint PK_dobavljac_proizvod primary key (proizvod_id, dobavljac_id),
	constraint FK_dobavljac_proizvod__dobavljac foreign key (dobavljac_id) references dobavljac(dobavljac_id)
)

--10 bodova

----------------------------
--2. Insert podataka
----------------------------
/*
a) 
U tabelu dobavljac izvršiti insert podataka iz tabele Purchasing.Vendor prema sljedećoj strukturi:
	BusinessEntityID -> dobavljac_id 
	AccountNumber -> dobavljac_br_rac 
	Name -> naziv_dobavljaca
	CreditRating -> kred_rejting
*/

insert into dobavljac
select BusinessEntityID, AccountNumber, Name, CreditRating
from AdventureWorks2017.Purchasing.Vendor

select *
from dobavljac

/*
b) 
U tabelu narudzba izvršiti insert podataka iz tabela Purchasing.PurchaseOrderHeader i 
Purchasing.PurchaseOrderDetail prema sljedećoj strukturi:
	PurchaseOrderID -> narudzba_id
	PurchaseOrderDetailID -> narudzba_detalj_id
	VendorID -> dobavljac_id 
	OrderDate -> dtm_narudzbe 
	OrderQty -> naruc_kolicina 
	UnitPrice -> cijena_proizvoda
*/

insert into narudzba 
select poh.PurchaseOrderID, PurchaseOrderDetailID, VendorID, OrderDate, OrderQty, UnitPrice 
from AdventureWorks2017.Purchasing.PurchaseOrderHeader as poh inner join 
AdventureWorks2017.Purchasing.PurchaseOrderDetail as pod
on poh.PurchaseOrderID = pod.PurchaseOrderID

select *
from narudzba

/*
c) 
U tabelu dobavljac_proizvod izvršiti insert podataka iz tabela Purchasing.ProductVendor i 
Production.Product prema sljedećoj strukturi:
	ProductID -> proizvod_id 
	BusinessEntityID -> dobavljac_id 
	Name -> proiz_naziv 
	ProductNumber -> serij_oznaka_proiz
	MaxOrderQty - MinOrderQty -> razlika_min_max 
	MaxOrderQty - OnOrderQty -> razlika_max_narudzba
uz uslov da se povuku samo oni zapisi u kojima ProductSubcategoryID nije NULL vrijednost.
*/

insert into dobavljac_proizvod
select p.ProductID, BusinessEntityID, Name, ProductNumber, MaxOrderQty - MinOrderQty, MaxOrderQty - OnOrderQty
from AdventureWorks2017.Purchasing.ProductVendor as pv inner join AdventureWorks2017.Production.Product as p
on pv.ProductID = p.ProductID
where ProductSubcategoryID is not null

select *
from dobavljac_proizvod

--10 bodova

----------------------------
--3.
----------------------------
/*
Koristeći sve tri tabele iz vlastite baze kreirati pogled view_dob_god sljedeće strukture:
	- dobavljac_id
	- proizvod_id
	- naruc_kolicina
	- cijena_proizvoda
	- ukupno, kao proizvod naručene količine i cijene proizvoda
Uslov je da se dohvate samo oni zapisi u kojima je narudžba obavljena 2013. ili 2014. godine i da se 
broj računa dobavljača završava cifrom 1.
*/

create view view_dob_god
as
select d.dobavljac_id, proizvod_id, naruc_kolicina, cijena_proizvoda, naruc_kolicina * cijena_proizvoda as ukupno
from dobavljac as d inner join dobavljac_proizvod as dp
on d.dobavljac_id = dp.dobavljac_id inner join narudzba as n
on n.dobavljac_id = d.dobavljac_id
where YEAR(dtm_narudzbe) between 2013 and 2014 and dobavljac_br_rac like '%1'

select *
from view_dob_god

--10 bodova

----------------------------
--4.
----------------------------
/*
Koristeći pogled view_dob_god kreirati proceduru proc_dob_god koja će sadržavati parametar 
naruc_kolicina i imati sljedeću strukturu:
	- dobavljac_id
	- proizvod_id
	- suma_ukupno, sumirana vrijednost kolone ukupno po dobavljac_id i proizvod_id
Uslov je da se dohvataju samo oni zapisi u kojima je naručena količina trocifreni broj.
Nakon kreiranja pokrenuti proceduru za vrijednost naručene količine 300.
*/

create procedure proc_dob_god
(@naruc_kolicina int)
as
begin
select dobavljac_id, proizvod_id, SUM(ukupno) as ukupno
from view_dob_god
where LEN(naruc_kolicina) = 3 and naruc_kolicina = @naruc_kolicina
group by dobavljac_id, proizvod_id
end

exec proc_dob_god 300

--10 bodova


----------------------------
--5.
----------------------------
/*
a)
Tabelu dobavljac_proizvod kopirati u tabelu dobavljac_proizvod_nova.
b) 
Iz tabele dobavljac_proizvod_nova izbrisati kolonu razlika_min_max.
c)
U tabeli dobavljac_proizvod_nova kreirati novu kolonu razlika. 
Kolonu popuniti razlikom vrijednosti kolone razlika_max_narudzba i srednje vrijednosti ove kolone, 
uz uslov da ako se u zapisu nalazi NULL vrijednost u kolonu razlika smjestiti 0.
*/

select *
into dobavljac_proizvod_nova
from dobavljac_proizvod

alter table dobavljac_proizvod_nova
drop column razlika_min_max

alter table dobavljac_proizvod_nova
add razlika float

update dobavljac_proizvod_nova
set razlika = isnull(razlika_max_narudzba - (select AVG(razlika_max_narudzba)
										from dobavljac_proizvod_nova), 0)

select *
from dobavljac_proizvod_nova

--15 bodova


----------------------------
--6.
----------------------------
/*
Prebrojati koliko u tabeli dobavljac_proizvod ima različitih serijskih oznaka proizvoda koje završavaju 
bilo kojim slovom engleskog alfabeta, a koliko ima onih koji ne završavaju bilo kojim slovom engleskog alfabeta. 
Upit treba da vrati poruke:
	'Različitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima:' iza čega slijedi broj zapisa 
	i
	'Različitih serijskih oznaka proizvoda koje NE završavaju slovom engleskog alfabeta ima:' iza čega slijedi broj zapisa
*/

select 'Razlicitih serijskih oznaka proizvoda koje završavaju slovom engleskog alfabeta ima: ' + 
cast(COUNT(*) as varchar) informacija
from dobavljac_proizvod
where isnumeric(RIGHT(serij_oznaka_proiz, 1)) = 0
union
select 'Različitih serijskih oznaka proizvoda koje NE završavaju slovom engleskog alfabeta ima: ' + 
cast(COUNT(*) as varchar) informacija
from dobavljac_proizvod
where isnumeric(RIGHT(serij_oznaka_proiz, 1)) = 1

--10 bodova


----------------------------
--7.
----------------------------
/*
a)
Dati informaciju o dužinama podatka u koloni serij_oznaka_proiz tabele dobavljac_proizvod. 
b)
Dati informaciju o broju različitih dužina podataka u koloni serij_oznaka_proiz tabele dobavljac_proizvod. 
Poruka treba biti u obliku: 'Kolona serij_oznaka_proiz ima ___ različite dužine podataka.' 
Na mjestu donje crte se nalazi izračunati brojčani podatak.
*/

select LEN(serij_oznaka_proiz) as duzina, COUNT(LEN(serij_oznaka_proiz)) as 'broj pojavljivanja'
from dobavljac_proizvod
group by LEN(serij_oznaka_proiz)
						    
--ili ova informacija, jer nije precizirano sta tacno treba
select serij_oznaka_proiz, LEN(serij_oznaka_proiz) as 'duzina podatka'
from dobavljac_proizvod

select 'Kolona serij_oznaka_proiz ima ' + 
cast(COUNT(distinct LEN(serij_oznaka_proiz)) as varchar) + ' različite dužine podataka.' as informacija
from dobavljac_proizvod

--10 bodova


----------------------------
--8.
----------------------------
/*
Prebrojati kod kolikog broja dobavljača je broj računa kreiran korištenjem više od jedne riječi iz naziva dobavljača. 
Jednom riječi se podrazumijeva skup slova koji nije prekinut blank (space) znakom. 
*/

select COUNT(*) as prebrojano
from dobavljac
where LEN(SUBSTRING(dobavljac_br_rac, 0, CHARINDEX('0', dobavljac_br_rac))) > 
LEN(SUBSTRING(naziv_dobavljaca, 0, CHARINDEX(' ', naziv_dobavljaca)))
and CHARINDEX(' ', naziv_dobavljaca) != 0

--10 bodova

----------------------------
--9.
----------------------------
/*
Koristeći pogled view_dob_god kreirati proceduru proc_djeljivi koja će sadržavati parametar prebrojano i kojom će se 
prebrojati broj pojavljivanja vrijednosti u koloni naruc_kolicina koje su djeljive sa 100. 
Sortirati po koloni prebrojano. Nakon kreiranja pokrenuti proceduru za sljedeću vrijednost parametra prebrojano = 10
*/
--13 bodova

create view prebrojano
as
select naruc_kolicina, COUNT(*) as prebrojano
from view_dob_god
where naruc_kolicina % 100 = 0 
group by naruc_kolicina

create procedure proc_djeljivi
(@prebrojano int)
as
begin
select *
from prebrojano
where prebrojano = @prebrojano
order by prebrojano
end

exec proc_djeljivi 10

----------------------------
--10.
----------------------------
/*
a) Kreirati backup baze na default lokaciju.
b) Napisati kod kojim će biti moguće obrisati bazu.
c) Izvršiti restore baze.
Uslov prihvatanja kodova je da se mogu pokrenuti.
*/

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
from dobavljac

--2 boda
