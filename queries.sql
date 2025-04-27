--------------------------------------------- STEP 4 ----------------------------------------
-- Подсчитывает общее коливество покупателей из таблицы
select
	COUNT(customer_id) as customers_count
from customers;



--------------------------------------------- STEP 5 ----------------------------------------
-- Подготовить отчет о десяти лучших продавцах. Сортировка по суммарной выручке по убыванию.
select
	e.first_name || ' ' || e.last_name  as seller,
	COUNT(s.sales_person_id) as operations,
	FLOOR(SUM(p.price * s.quantity)) as income
from sales s
inner join employees e 
on e.employee_id = s.sales_person_id
inner join products p 
on p.product_id = s.product_id
group by 1
order by 3 desc
limit 10;


-- Получить отчет о продавцах, чья средняя выручка за сделку меньше
-- чем средняя выручка за сделку по всем продавцам.
-- Вывод отсортирован по средней выручке в порядке возрастания.
with mytab as
	(select
		e.first_name || ' ' || e.last_name  as seller,
		*,
		p.price * s.quantity as cost
	from sales s
	inner join employees e 
	on e.employee_id = s.sales_person_id
	inner join products p 
	on p.product_id = s.product_id
)
select
	seller,
	FLOOR(AVG(cost)) as average_income
from mytab
group by 1
HAVING FLOOR(AVG(cost)) < (select AVG(cost) from mytab)
order by 2 ASC;


-- Получить отчет по каждому продавцу и его суммарной выручке по каждому дню недели
-- Вывод отсортирован по порядковому номеру дня недели, начиная с понедельника и
-- заканчивая воскресеньем, а так же имени продавца.
with my_table as
	(select
		e.first_name || ' ' || e.last_name as seller,
		extract(isodow from s.sale_date) as number_day,
		lower(to_char((s.sale_date), 'fmDay')) as day_of_week,
		floor(sum(p.price * s.quantity)) as income
	from sales s
	inner join products p
	on s.product_id = p.product_id
	inner join employees e
	on e.employee_id = s.sales_person_id
	group by 1, 2, 3
)
select
	seller,
	day_of_week,
	income
from my_table
order by number_day, 1;



--------------------------------------------- STEP 6 ----------------------------------------
-- Сформировать отчет, в котором разделить покупателей на 3 возрастные группы.
-- После чего посчитать количество покупателей в каждой возрастной группе.
select
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		else '40+'
	end as age_category,
	count(customer_id) as age_count	
from customers
group by age_category
order by 2;


--Сформировать отчет по количеству уникальных покупателей и выручке, которую они принесли
-- в каждом месяце. Данные сгруппированы по датеЮ представленной в виде ГОД-месяц.
--итоговая таблица отсортирована и выведена по дате возрастания.
with mytab as
	(select
		extract(year from s.sale_date) as years,
		--extract(month from s.sale_date) as months,
		to_char(sale_date, 'MM') as months,
		count(distinct s.customer_id) as total_customers,
		floor(sum(s.quantity * p.price)) as income
--		row_number() over (order by extract(month from s.sale_date)) as rn
	from sales s
	inner join products p
	on s.product_id = p.product_id
	group by 1, 2
)
select
	years || '-' || months as selling_month,
	total_customers,
	income
from mytab;
--order by rn;


--Сформировать отчет о покупателях, у которых их самая первая покупка была совершена в
-- ходе проведения акции, то есть цена товара была равна 0.
-- В итоговой таблицы выведены данные этих покупателей, дата совершения покупки, а так же 
-- данные продавца, который отпустил товар. Сортировка осуществляется по айди покупателя.
with mytable as
	(select
		*,
		row_number() over(partition by s.customer_id order by s.customer_id, s.sale_date) as rn
	from sales s
	inner join products p
	on s.product_id = p.product_id
)
select
	c.first_name || ' ' || c.last_name as customer,
	mt.sale_date,
	e.first_name || ' ' || e.last_name as seller
from mytable mt
inner join customers c
on c.customer_id = mt.customer_id
inner join employees e 
on e.employee_id = mt.sales_person_id
where rn = 1 and price = 0
order by mt.customer_id ASC;



	