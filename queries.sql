-- Подсчитывает общее коливество покупателей из таблицы
select
	COUNT(customer_id) as customers_count
--	COUNT(distinct customer_id) as unique_customer_count
from customers;
