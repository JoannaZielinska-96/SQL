/* zad.1 
1) Wypiszmy wszystkich Klientów firmy (tabela customers)
2) Wyfiltrujmy tylko tych, których firma zaczyna siê na F.
3) Dodatkowo dodamy do wyników firmy, gdzie ContactTitle = ’owner’.
4) PrzejdŸmy do tabeli z pracownikami firmy (tabela employees)
5) Stwórzmy kolumnê login sk³adaj¹c¹ siê z pierwszej litery imienia i ca³ego nazwiska
6) Zmodyfikujmy powy¿sz¹ kolumnê tak aby wszystkie litery by³y zapisane z ma³ych liter i nazwijmy kolumnê login
7) Wypiszmy miesi¹c urodzenia ka¿dego z pracowników*/

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

/*zad.2 WeŸmy dane z tabeli products i suppliers
1) Przygotujmy zestawienie, ile produktów dostarcza ka¿dy z dostawców, oraz œredni¹ cenê jednostki
2) Dodajmy zmienn¹ exclusive przyjmuj¹c¹ wartoœæ 1 gdy nazwa produktu  zaczyna siê od Chef lub Sir, oraz 0 w pozosta³ych przypadkach oraz zapiszmy dane do widoku
3) Pogrupujmy dane po kolumnie exclusive wykorzystuj¹c widok
4) Stwórzmy bazê firm na podstawie tabel suppliers i customers zawieraj¹c¹ kolumny: nazwa firmy, telefon oraz Ÿród³o danych*/

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