1) 
Отобразите количество привлечённых средств для новостных компаний США. 


SELECT 
    --name, 
    SUM(funding_total) as sum
FROM company
WHERE category_code = 'news' AND country_code = 'USA'
GROUP BY 
    name
ORDER BY 
   sum DESC
 
 
 
2)  Найти общую сумму сделок по покупке одних компаний другими в долларах.
 Сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.
 
 
SELECT SUM(price_amount) AS total_cost_companies 
   FROM acquisition a
    JOIN company c ON a.acquired_company_id=c.id
WHERE term_code = 'cash'  
    AND EXTRACT(year from acquired_at) in (2011,2012,2013)
    
    
3) Для каждой страны отобразить общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. 

SELECT country_code, SUM(funding_total) as sum
FROM COMPANY
GROUP BY country_code
ORDER BY sum desc

4) Вывести таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
 (минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению)

SELECT funded_at ,
    MAX(raised_amount) as max_cost, MIN(raised_amount) as min_cost
FROM funding_round 
GROUP BY funded_at
having MAX(raised_amount) <> MIN(raised_amount) AND MIN(raised_amount) != 0

5) Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.


SELECT *,
    CASE WHEN invested_companies>=100  THEN 'high_activity'
         WHEN invested_companies>=20 AND  invested_companies<100  THEN 'middle_activity'
         WHEN invested_companies<20 THEN 'low_activity' 
    END
FROM fund

6) Для каждой из категорий, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участиe

SELECT  ROUND(AVG(investment_rounds),0) as avg_category,
    CASE WHEN invested_companies>=100  THEN 'high_activity'
         WHEN invested_companies>=20 AND  invested_companies<100  THEN 'middle_activity'
         WHEN invested_companies<20 THEN 'low_activity' 
    END AS category
FROM fund
GROUP BY category
ORDER BY avg_category

7) Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы.
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. Выгрузите десять самых активных стран-инвесторов.

SELECT f.country_code,
    MIN(invested_companies) AS min_invest,
    MAX(invested_companies),
    AVG(invested_companies)
FROM 
    fund f
WHERE EXTRACT(YEAR FROM founded_at) IN (2010,2011,2012) 
GROUP BY f.country_code
HAVING MIN(invested_companies)<>0
ORDER BY  AVG(invested_companies) DESC,
    country_code ASC
LIMIT 10

8) Для каждой компании найдем количество учебных заведений, которые окончили её сотрудники. 
Получим название компаний и число уникальных названий учебных заведений. Составить топ-5 компаний по количеству университетов.

SELECT c.name, count(DISTINCT e.instituition) AS count_instituition
    FROM company c 
    JOIN people p ON p.company_id= c.id
    JOIN education e ON p.id = e.person_id 
GROUP BY c.name
ORDER BY  count_instituition DESC
LIMIT 5

9) Список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним. 
Список уникальных номеров сотрудников, которые работают в компаниях.

WITH people_company AS(
SELECT p.id, c.name
FROM people p 
    JOIN company c ON c.id = p.company_id
    ), 
company_dist AS (SELECT DISTINCT(name) as name_company
                FROM company
                    WHERE name iN (
        SELECT name
        FROM company c
        JOIN funding_round f ON f.company_id=c.id 
    WHERE is_first_round=is_last_round 
        AND is_first_round = 1  
        AND  c.status='closed')
)
SELECT p.id 
FROM people_company p 
    JOIN company_dist c
        ON p.name = c.name_company
        
 10) Посчитайте количество учебных заведений для каждого сотрудника
 При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды
 
 WITH people_company AS(
SELECT p.id, c.name, instituition
FROM education e
    JOIN people p ON e.person_id = p.id 
    JOIN company c ON c.id = p.company_id
    ), 
company_dist AS (SELECT DISTINCT(name) as name_company
                FROM company
                    WHERE name iN (
        SELECT name
        FROM company c
        JOIN funding_round f ON f.company_id=c.id 
    WHERE is_first_round=is_last_round 
        AND is_first_round = 1  
        AND  c.status='closed')
)
SELECT  p.id , COUNT(instituition) as count_instituition
FROM people_company p 
    JOIN company_dist c
        ON p.name = c.name_company
GROUP BY p.id


18) Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook*.

*(сервис, запрещённый на территории РФ)

WITH company_instituition AS (
SELECT p.id, c.name ,COUNT(instituition) as count_inst
FROM education e 
       JOIN people p ON e.person_id = p.id
       JOIN company c ON c.id = p.company_id
WHERE c.name='Facebook'       
GROUP BY c.name , p.id
)
SELECT SUM(count_inst)/COUNT(id) as avg_inst
FROM company_instituition

19) Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно.

SELECT fu.name AS name_of_fund,
       co.name AS name_of_company,
     fr.raised_amount AS amount
FROM investment i
   JOIN fund fu ON i.fund_id=fu.id
     JOIN company co ON i.company_id=co.id
         JOIN funding_round fr on i.funding_round_id=fr.id
WHERE EXTRACT(YEAR FROM fr.funded_at) in (2012,2013)  AND  co.milestones>6

20) Выгрузите таблицу, в которой будут такие поля:
    - название компании-покупателя;
    - сумма сделки;
    - название компании, которую купили;
    - сумма инвестиций, вложенных в купленную компанию;
    - доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
 
 WITH company_buyer  as (
SELECT c.name as company_buyer,
       a.price_amount as sum_buyer, a.id 
FROM ACQUISITION a 
    JOIN company c ON c.id = a.acquiring_company_id
WHERE  a.price_amount<>0),
company_seller as (
SELECT a.id ,c.name as company_seller,
    funding_total as sum_invest
FROM ACQUISITION a 
    JOIN company c ON c.id = a.acquired_company_id
WHERE funding_total<>0)

SELECT company_buyer, 
       sum_buyer,
       company_seller,
       sum_invest,
       round(sum_buyer/sum_invest,0) as part 
FROM company_buyer b
    JOIN company_seller s ON b.id=s.id
ORDER BY sum_buyer DESC, company_seller 
LIMIT 10
    
 20) Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
    - номер месяца, в котором проходили раунды;
    - количество уникальных названий фондов из США, которые инвестировали в этом месяце;
    - количество компаний, купленных за этот месяц;
    - общая сумма сделок по покупкам в этом месяце. 
    
WITH ac_bought  AS
(
SELECT
    EXTRACT(MONTH FROM ac.acquired_at) AS _month,
    COUNT(ac.acquired_company_id) AS _count_acquired,
    SUM(ac.price_amount) AS _price_amount
FROM acquisition ac
WHERE EXTRACT(YEAR FROM acquired_at) BETWEEN 2010 AND 2013
GROUP BY _month),
 
ac_fund_names AS
(
SELECT
EXTRACT(MONTH FROM fr.funded_at) AS _month,
COUNT(DISTINCT fu.name) AS _count
FROM investment i
     JOIN fund fu ON i.fund_id = fu.id
        JOIN funding_round fr ON i.funding_round_id = fr.id
WHERE fu.country_code = 'USA' AND  EXTRACT(YEAR
                 FROM fr.funded_at) BETWEEN 2010 AND 2013
GROUP BY _month --)
)
 
SELECT 
b._month AS month,
f._count AS count_usa_fund_names,
b._count_acquired AS count_acquired,
b._price_amount AS sum_price_amount
FROM ac_bought b
     JOIN ac_fund_names f ON f._month = b._month
ORDER BY MONTH 
