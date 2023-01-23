/*zad.1
1) Stw�rzmy widok z tabeli z klientami, w kt�rym dodamy dwie, nowe kolumny: dat� pierwszego
zam�wienia, oraz dat� ostatniego zam�wienia.
2) Wypiszmy dane z widoku, dodaj�c numer klienta w kolejno�ci daty pierwszego zam�wienia.
3) Dokonajmy partycjonowania numeru po latach a nast�pnie miesi�cach.
4) Wypiszmy wszystkich klient�w, kt�rzy z�o�yli pierwsze zam�wienie w poszczeg�lnych latach*/

-- 1

create view klienci_zamowienia__ as
select 
distinct c.customer_id,
c.company_name,
min(o.order_date) over (partition by c.customer_id order by c.customer_id) as pierwsze_zam,
max(order_date) over (partition by c.customer_id order by c.customer_id) as ostatnie_zam
from customers c
join orders o 
on c.customer_id=o.customer_id 

-- 2 
select customer_id,
dense_rank() over (order by pierwsze_zam)
from klienci_zamowienia__

-- 3

select *,
dense_rank() over (partition by to_char(pierwsze_zam, 'YYYY') order by pierwsze_zam) ranking_zamowien_lata
from klienci_zamowienia__

select *,
dense_rank() over (partition by to_char(pierwsze_zam, 'YYYY-MM') order by pierwsze_zam) ranking_zamowien_miesiac
from klienci_zamowienia__

-- 4

create view ranking_zamowien_klientow_lata as
select *,
dense_rank() over (partition by to_char(pierwsze_zam, 'YYYY') order by pierwsze_zam) ranking_zamowien_lata
from klienci_zamowienia__

select * from ranking_zamowien_klientow_lata
where ranking_zamowien_lata=1

/*zad.2
1) Do wynik�w tabeli orders dodaj numer zam�wienia w miesi�cu (partycjonowanie po miesi�cach) kolejno�� wed�ug daty.
2) Dodaj analogiczne pole, ale w kolejno�ci malej�cej.
3) Wypisz dat� pierwszego i ostatniego zam�wienia.
4) Dodaj do wynik�w kwot� zam�wienia.
5) Podziel zbi�r za pomoc� funkcji ntile na 5 podzbior�w wed�ug kwoty zam�wienia.
6) Wyznacz minimaln� i maksymaln� warto�� z wynik�w poprzedniego punktu dla ka�dego klienta.
7) Sprawd�, czy istniej� klienci premium (kt�rzy zawsze wyst�puj� w kwnatylu(w grupie) 4 lub 5).*/

-- 1

select *,
dense_rank () over (partition by to_char(order_date, 'YYYY-MM') order by order_date) 
from orders

-- 2

select *,
dense_rank () over (partition by to_char(order_date, 'YYYY-MM') order by order_date),
dense_rank () over (partition by to_char(order_date, 'YYYY-MM') order by order_date desc) 
from orders

-- 3

select *,
dense_rank () over (partition by to_char(order_date, 'YYYY-MM') order by order_date),
dense_rank () over (partition by to_char(order_date, 'YYYY-MM') order by order_date desc),
min(order_date) over (partition by to_char(order_date, 'YYYY-MM')),
max(order_date) over (partition by to_char(order_date, 'YYYY-MM'))
from orders

-- 4

select *,
dense_rank () over (partition by to_char(o.order_date, 'YYYY-MM') order by o.order_date),
dense_rank () over (partition by to_char(o.order_date, 'YYYY-MM') order by o.order_date desc),
min(o.order_date) over (partition by to_char(o.order_date, 'YYYY-MM')),
max(o.order_date) over (partition by to_char(o.order_date, 'YYYY-MM')),
(od.unit_price*od.quantity*(1-od.discount))
from orders o
join order_details od 
on o.order_id=od.order_id 

-- 5

create view zamowienia_1 as
select 
o.order_date data_zam, 
o.order_id id_zamowienie,
o.customer_id id_klient, 
dense_rank () over (partition by to_char(o.order_date, 'YYYY-MM') order by o.order_date) rank_1,
dense_rank () over (partition by to_char(o.order_date, 'YYYY-MM') order by o.order_date desc) rank_2,
min(o.order_date) over (partition by to_char(o.order_date, 'YYYY-MM')) min_1,
max(o.order_date) over (partition by to_char(o.order_date, 'YYYY-MM')) max_1,
(od.unit_price*od.quantity*(1-od.discount))  kwota
from orders o
join order_details od 
on o.order_id=od.order_id 

select *,
ntile(5) over (order by kwota)
from zamowienia_1

-- 6

create view zamowienia__ as
select *,
ntile(5) over (order by kwota) ntitile_5
from zamowienia_1


select id_klient,
min(ntitile_5),
max(ntitile_5)
from zamowienia__
group by id_klient 

-- 7

select id_klient,
min(ntitile_5),
max(ntitile_5)
from zamowienia__
group by id_klient 
having min(ntitile_5)>=4


/* zad.3
1) Dokonajmy analizy przewo�nik�w w poszczeg�lnych latach. Sprawd�my za jak� kwot� i jak�
wielko�� �adunku przewozili w poszczeg�lnych latach. � Wykorzystamy group by. Czy w�r�d
przewo�nik�w wida� trend rosn�cy lub malej�cy?
2) Dla ka�dego zam�wienia dodajmy informacj� o �rednim �adunku i kwocie przewo�onego
zam�wienia w bie��cym roku. Dodajmy komunikat o tym czy �adunek jest powy�ej czy poni�ej
�redniej. Sprawd�my ile mamy �adunk�w powy�ej a poni�ej �redniej w poszczeg�lnych latach.*/


-- 1

select s.company_name,
extract(year from o.order_date),
sum(od.unit_price*od.quantity*(1-od.discount)) kwota,
sum(freight) wielkosc_ladunku
from orders o 
join order_details od 
on o.order_id =od.order_id 
join shippers s 
on s.shipper_id =o.ship_via 
group by  s.company_name, extract(year from o.order_date)
order by  s.company_name, extract(year from o.order_date)

-- 2

select od.order_id, extract(year from o.order_date),
avg(od.unit_price*od.quantity*(1-od.discount)) over (partition by od.order_id) srednia_kwota_zam
from order_details od  
join orders o 
on od.order_id=o.order_id 

create view srednia_kwota_zam as
select od.order_id, extract(year from o.order_date),
avg(od.unit_price*od.quantity*(1-od.discount)) over (partition by od.order_id) srednia_kwota_zam
from order_details od  
join orders o 
on od.order_id=o.order_id 

select order_id, date_part,
avg(srednia_kwota_zam) over (partition by date_part)
from srednia_kwota_zam

select *,
avg(freight) over (partition by extract(year from order_Date)) sredni_ladunek
from orders o 

select 
*, 
avg(freight) over (partition by extract(year from order_Date)) sredni_ladunek,
case
	when freight>avg(freight) over (partition by extract(year from order_Date))  then 'powyzej srednije'
	when freight=avg(freight) over (partition by extract(year from order_Date))  then 'ten sam'
	else 'ponizej'
end komunikat
from orders o 

/* zad.4
1) Za pomoc� group by wyznacz liczb� produkt�w zakupionych w poszczeg�lnych zam�wieniach.
2) Za pomoc� funkcji rankuj�cych stw�rz ranking produkt�w w zam�wieniu, tak �e warto��
najwy�sz� w rankingu powinien mie� produkt, kt�ry przyni�s� firmie najwi�cej pieni�dzy.
3) Wyznacz sum� sprzeda�y dla poszczeg�lnych ranking�w.*/

--1 

select 
od.order_id,
count(product_id) 
from order_details od 
group by od.order_id

--2

select
order_id,
product_id,
unit_price*quantity*(1-discount) wartosc_produktu,
rank () over (partition by order_id order by unit_price*quantity*(1-discount) desc) ranking 
from order_details od 

create view ranking as 
select
order_id,
product_id,
unit_price*quantity*(1-discount) wartosc_produktu,
rank () over (partition by order_id order by unit_price*quantity*(1-discount) desc) ranking 
from order_details od 


-- pierwszy sposob
select distinct ranking,
sum(wartosc_produktu) over (partition by ranking)
from ranking -- nie wiem czy to jest dobrze

-- drugi sposob
select ranking,
sum(wartosc_produktu)
from ranking 
group by ranking -- nie wiem czy to jest dobrze
order by ranking asc

/* zad 5. 
Stw�rzmy analiz� przewo�nik�w. 
1) Wyznaczmy liczb� przewo�onych zam�wie� w ka�dym roku
wraz z ich kwot� oraz sum� �adunk�w i liczb� przewiezionych produkt�w. 
2) Wyznaczymy tez te warto�ci dla poprzedniego okresu. */

--1

create view v_analiza_przewoznikow as
select s.company_name,
date_part('year',o.order_date)::VARCHAR rok,
count(od.order_id) liczba_przewiezionych_zam,
sum(od.unit_price*od.quantity*(1-od.discount)) kwota,
sum(freight) suma_ladunkow,
count(od.product_id) liczba_przewiezionych_produktow
from orders o 
join order_details od 
on o.order_id =od.order_id 
join shippers s 
on s.shipper_id =o.ship_via 
group by  s.company_name, extract(year from o.order_date)
order by  s.company_name, extract(year from o.order_date)

select *, 
lag(liczba_przewiezionych_zam, 1) over(partition by company_name order by rok),
lag(kwota, 1) over(partition by company_name order by rok),
lag(suma_ladunkow, 1) over(partition by company_name order by rok),
lag(liczba_przewiezionych_produktow, 1) over(partition by company_name order by rok)
from v_analiza_przewoznikow 


/*zad.6.
1) We� dane pracownik�w i dla ka�dego z nich wyznacz dat� pierwszego zam�wienia oraz jego
kwot�. Wyznacz liczb� miesi�cy od pierwszego zam�wienia.
2) Sprawd� czy kwota kolejnych zam�wie� jest wi�ksza ni� pierwszego zam�wienia i dodaj zmienn� z odpowiednim komunikatem.*/

-- 1
create view dane_pracownikow as
select distinct 
e.first_name,
e.last_name,
first_value(o.order_date) over (partition by e.employee_id order by o.order_date) data_pierwszego_zam,
first_value(od.unit_price*od.quantity*(1-od.discount)) over (partition by e.employee_id order by o.order_date) kwota_pierwszego_zam
from orders o
join order_details od 
on o.order_id =od.order_id 
join employees e 
on o.employee_id =e.employee_id 

select distinct 
first_name,
last_name,
(date_part('year',current_date)- date_part('year',data_pierwszego_zam))*12 + (DATE_PART('month', current_date) - DATE_PART('month', data_pierwszego_zam)) roznica_w_mies
from dane_pracownikow

-- 2

select *,
first_value(od.unit_price*od.quantity*(1-od.discount)) over (order by o.order_date) kwota_pierwszego_zam,
case 
	when first_value(od.unit_price*od.quantity*(1-od.discount)) over (order by o.order_date)>od.unit_price*od.quantity*(1-od.discount) then 'wieksze jest pierwsze zam'
	when first_value(od.unit_price*od.quantity*(1-od.discount)) over (order by o.order_date)>od.unit_price*od.quantity*(1-od.discount) then 'mniejsze jest pierwsze zam'
	else 'sa rowne'
end komunikat
from orders o
join order_details od 
on o.order_id =od.order_id 
