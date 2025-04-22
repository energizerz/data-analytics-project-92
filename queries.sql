-- Подсчитывает общее коливество покупателей из таблицы
select
	COUNT(customer_id) as customers_count
from customers;


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
		to_char((s.sale_date), 'fmDay') as day_of_week,
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
	