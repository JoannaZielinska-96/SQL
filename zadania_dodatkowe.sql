/* zad.1 
1) Wypiszmy wszystkich Klient�w firmy (tabela customers)
2) Wyfiltrujmy tylko tych, kt�rych firma zaczyna si� na F.
3) Dodatkowo dodamy do wynik�w firmy, gdzie ContactTitle = �owner�.
4) Przejd�my do tabeli z pracownikami firmy (tabela employees)
5) Stw�rzmy kolumn� login sk�adaj�c� si� z pierwszej litery imienia i ca�ego nazwiska
6) Zmodyfikujmy powy�sz� kolumn� tak aby wszystkie litery by�y zapisane z ma�ych liter i nazwijmy kolumn� login
7) Wypiszmy miesi�c urodzenia ka�dego z pracownik�w*/

--1
select *from customers c 

--2
select c.contact_name  from customers c 
where c.company_name like 'F%'

--3
select company_name, contact_title  from customers c 
where company_name like 'F%' and contact_title='Owner'

--4
select * from employees e 

--5
update employees set login = concat(first_name, LEFT(first_name, 2))

--6
select lower(login) from employees e 

--7
select e2.first_name, e2.last_name, extract(month from e2.birth_date) miesiac from employees e2 

/*zad.2 We�my dane z tabeli products i suppliers
1) Przygotujmy zestawienie, ile produkt�w dostarcza ka�dy z dostawc�w, oraz �redni� cen� jednostki
2) Dodajmy zmienn� exclusive przyjmuj�c� warto�� 1 gdy nazwa produktu  zaczyna si� od Chef lub Sir, oraz 0 w pozosta�ych przypadkach oraz zapiszmy dane do widoku
3) Pogrupujmy dane po kolumnie exclusive wykorzystuj�c widok
4) Stw�rzmy baz� firm na podstawie tabel suppliers i customers zawieraj�c� kolumny: nazwa firmy, telefon oraz �r�d�o danych*/

--1
select *
from products p 
join suppliers s 
on p.supplier_id = s.supplier_id 
group by s.supplier_id
order by s.supplier_id

select s.supplier_id, count(p.product_id) suma_produktow, avg(p.unit_price) srednia_cena_jednostki
from products p 
join suppliers s 
on p.supplier_id = s.supplier_id 
group by s.supplier_id
order by s.supplier_id

2--
select p.product_name,
case 
	when p.product_name like 'Chef%' or product_name like 'Sir%' then '1'
	else 0
end as exclusive1
from products p 
join suppliers s 
on p.supplier_id = s.supplier_id 

3--
create view vieww as
select p.product_name,
case 
	when p.product_name like 'Chef%' or product_name like 'Sir%' then '1'
	else 0
end as exclusive1
from products p 
join suppliers s 
on p.supplier_id = s.supplier_id 

select exclusive1, product_name  from vieww 
group by exclusive1, product_name
order by exclusive1 

4--
select company_name, phone from customers c 
union all
select company_name, phone from suppliers s2 