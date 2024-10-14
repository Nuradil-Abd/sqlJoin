-- 1.Эң жогорку айлыгы бар иштеп чыгуучуларды табуу:
-- Найти разработчиков с максимальной зарплатой:
select *
from developers;

select first_name, last_name, round(salary)
from developers
where salary = (select max(salary) from developers);

select *
from developers
order by salary desc
limit 1;

-- 2.Белгилүү проектте иштеген разработчикти табуу:
-- Найти разработчиков, работающих над определённым проектом:

--  with join
select first_name, last_name, programming_language
from developers d
         join projects p on p.dev_id = d.id
where p.title = 'Project Alpha';

select first_name, last_name
from developers d
where d.id in (select p.dev_id from projects p where title = 'Project Alpha');


-- 3.Нью-Йорктогу компанияларда иштеген разработчиктерди табуу:
-- Найти разработчиков, работающих в компаниях, расположенных в Нью-Йорке:

select *
from developers d
where d.address_id = (select c.id from city c where c.name = 'New York');

select d.*, c.*
from developers d
         join city c on d.address_id = c.id
where c.name ilike 'new york';

-- 4.Орточо айлыктан жогору айлык алган иштеп чыгуучуларды табуу:
-- Найти разработчиков с зарплатой выше среднего:
select *
from developers d
where d.salary > (select avg(salary) from developers);

select avg(salary)
from developers;

-- 5.Python программалоо тилин билген разработчиктердин проектерин табуу:
-- Найти проекты разработчиков, знающих Python:

select *
from projects p
where p.dev_id in
      (select d.id from developers d where d.programming_language = 'Python');

select p.id         as project_id,
       p.title      as poroject_name,
       d.id         as develeoper_id,
       d.first_name as name,
       d.programming_language
from projects p
         join developers d on d.id = p.dev_id
where d.programming_language like ('Python');

-- 6.Аянты 1 000 000 км² ашкан өлкөлөрдө иштеген разработчиктерди табуу:
-- Найти разработчиков в странах с площадью более 1 000 000 км²:

select *
from developers d
where d.address_id
          in (select c.id
              from city c
              where c.country_id in
                    (select count.id
                     from countries count
                     where count.area > '1000000'));

select d.first_name as developer_name,
       c.name       as country_name,
       c.area       as country_area
from developers d
         join city on d.address_id = city.id
         join countries c on c.id = city.country_id
where c.area > 1000000;


-- 7.Ар бир разработчиктердин эң акыркы долбоорун табуу:
-- Найти самый последний проект для каждого разработчика:
alter table projects
    add column issue_date date;

select d.id, d.first_name, p.id, p.title, p.issue_date
from projects p
         join developers d on d.id = p.dev_id
where p.issue_date in
      (select max(pr.issue_date) from projects pr group by pr.dev_id);


-- 8. TechCorp' компаниясы менен бир шаарда жайгашкан компанияларда иштеген иштеп разработчиктерди табуу:
-- Найти разработчиков, работающих в компаниях, расположенных в том же городе, что и 'TechCorp':

select
    d.first_name,
    d.address_id as dev_adr_id
    from developers d
    where d.address_id =
          ( select c.id from city c  where c.id =
                ( select com.address_id from companies com  where com.name like 'TechCorp'));

select
    concat(d.first_name, ' ', d.last_name) as full_name,
    d.address_id as dev_adr_id,
    c.name as city,
    c.id as city_id,
    com.name as company,
    com.address_id as company_adr_id
    from developers d
        join city c on d.address_id = c.id
        join companies com on c.id = com.address_id where com.name like 'TechCorp';


-- 9.Шаарындагы орточо айлыктан жогору айлык алган разработчиктерди табуу:
-- Найти разработчиков с зарплатой выше средней по их городу:

select d.first_name, d.salary from developers d
    join  city ci on d.address_id = ci.id
        where d.salary > (select avg(dev.salary) from developers dev
         where dev.address_id = d.address_id ); -- Atai эле чыгат калган шаарда бирден эле developer

-- 10. $90 000 ашык айлык алган разработчиктер жашаган өлкөлөрдү табуу:
-- Найти страны, где разработчики зарабатывают более $90 000:

select c.name  as country  from countries c
    where c.id in ( select ci.country_id from city ci
                                         join developers d on ci.id = d.address_id
                                         where d.salary >  90000);



-- JOIN --

-- 1.Разработчиктердин ысымдарын жана алардын үстүндө иштеп жаткан долбоорлорунун аттарын чыгаруучу суроо жаз.
-- Напишите запрос, который выведет имена разработчиков и названия проектов, над которыми они работают.

select d.first_name, p.title
from developers d
         join projects p on d.id = p.dev_id;

-- 2. Компаниялардын аттарын жана алардын долбоорлорунун аттарын чыгаруучу суроо жаз.
-- Эгерде компаниянын долбоорлору жок болсо, компанияны дагы көрсөтүш керек.
-- Напишите запрос, который покажет названия компаний и названия проектов.
-- Если у компании нет проектов, все равно вывести компанию.

select c.id, c.name, p.id, p.title as project_name
from companies c
         left join projects p on c.id = p.company_id;

-- 3. Долбоорлорду жана аларга тиешелүү компанияларды чыгаруучу суроо жаз.
-- Эгерде долбоор компанияга байланыштуу болбосо дагы, аны көрсөтүү керек.
-- Напишите запрос, который покажет проекты и компании.
-- Если проект не связан с компанией, все равно вывести проект.

select *
from projects p
         right join companies c on c.id = p.company_id;

-- 4.Разработчиктердин аттарын жана алардын жашаган шаарларынын аттарын чыгаруучу суроо жаз.
--  Напишите запрос, который выведет имена разработчиков и названия городов, в которых они живут.
select d.first_name, c.name
from developers d
         join city c on d.address_id = c.id;



-- 5.Шаарлардын аттарын жана ошол шаарларда жашаган разработчиктердин аттарын чыгаруучу суроо жаз.
-- Эгерде шаарда разработчиктер жок болсо дагы, шаарды көрсөтүү керек.
-- Напишите запрос, который покажет города и разработчиков, которые живут в этих городах.
-- Если в городе нет разработчиков, все равно вывести город.

select d.first_name, c.name, c2.name from city c
                                              join developers d on c.id = d.address_id
                                              join countries c2 on c.country_id = c2.id;



-- 6.Бардык долбоорлорду жана аларды жүргүзгөн компанияларды чыгаруучу суроо жаз.
-- Эгерде долбоор компанияга тиешелүү болбосо дагы, аны көрсөтүү керек.
-- Напишите запрос, который покажет проекты и компании, которые их ведут.
-- Если проект не связан с компанией, все равно вывести проект.

select p.title  as project_name, com.name as company_name, c.name from companies com
                                                                           right join  projects p on com.id = p.company_id
                                                                           join city ci  on com.address_id = ci.id
                                                                           join countries c on ci.country_id = c.id;

-- 7.Компаниялардын аттарын жана алардын жайгашкан шаарларын чыгаруучу суроо жаз.
-- Напишите запрос, который выведет названия компаний и названия городов, в которых они расположены.

select com.name,ci.name  from companies com
    join city ci on  com.address_id = ci.id
    join countries c on ci.country_id = c.id;

-- 8.Разработчиктердин аттарын, алардын долбоорлорун жана ошол долбоорлорду жүргүзгөн компанияларды чыгаруучу суроо жаз.
--  Напишите запрос, который покажет имена разработчиков, их проекты и компании, которые ведут эти проекты.

select d.first_name as developer_name ,p.title as project_name, com.name as company_name from developers d
    join projects p on d.id = dev_id
    join companies com on p.company_id = com.id;


-- 9.Бардык разработчиктерди жана алардын компанияларын чыгаруучу суроо жаз.
-- Эгерде разработчик долбоорго дайындалбаган болсо дагы, аны көрсөтүү керек.
-- Напишите запрос, который покажет всех разработчиков и их компании.
-- Если разработчик не назначен на проект в компании, все равно вывести его.

select d.first_name ,  com.name from developers d
    left join public.projects p on d.id = p.dev_id
    left join companies com on p.company_id = com.id;

-- 10.Бардык долбоорлорду жана ошол долбоорлордун үстүндө иштеген разработчиктердин аттарын чыгаруучу суроо жаз.
-- Эгерде долбоордо разработчиктер жок болсо дагы, долбоорду көрсөтүү керек.
--  Напишите запрос, который покажет все проекты и разработчиков, которые работают над ними.
-- Если проект не имеет разработчика, все равно вывести его.

select p.title  as project_name, d.first_name as dev_name from projects p
    join companies c on p.company_id = c.id
    left join developers d on p.dev_id = d.id;

-- 11. Долбоорлорду жана алардын жайгашкан өлкөлөрүн чыгаруучу суроо жаз. Бул суроо шаарлар аркылуу байланыш жүргүзөт.
-- Напишите запрос, который покажет проекты и страны, в которых они находятся, через города.

select p.title , c.name from companies com
    join  projects p on com.id = p.company_id
    join city ci  on com.address_id = ci.id
    join countries c on ci.country_id = c.id;


-- 12.
-- Ар бир компания үчүн долбоорлордун санын эсептеген суроону түзүңүз.
-- Суроо компаниянын атын жана жалпы долбоорлордун санын көрсөтүшү керек.
-- Эгерде долбоорлору жок компанияларды дагы камтууну унутпаңыз.
-- ____
-- Создайте запрос, который подсчитывает количество проектов для каждой компании.
-- Запрос должен отображать название компании и общее количество проектов.
-- Убедитесь, что вы включили компании, у которых нет проектов.

select c.name as company_name , count(p) as total_count_projects from companies c
   left join projects p on c.id = p.company_id
    group by c.name;



-- 13.
-- Иштеп чыгуучулардын аты-жөндөрүн, жашаган шаарларынын аттарын жана тиешелүү өлкөлөрдүн аттарын тандоочу суроону жазыңыз.
-- Шаар тууралуу маалымат жок болсо да, бардык иштеп чыгуучуларды камтыңыз.
-- ----
-- Напишите запрос, чтобы выбрать имя и фамилию разработчиков вместе с названиями городов, в которых они живут,
-- и названиями соответствующих стран. Убедитесь, что вы включили всех разработчиков, даже если информация о городе недоступна.


select concat(d.first_name, ' ', d.last_name) as full_name, ci.name as city_name , c.name as country_name from countries c
    join city ci  on c.id = ci.country_id
   right join developers d on ci.id = d.address_id;


-- 14.
-- Долбоорлорду, ошол долбоорлорго дайындалган иштеп чыгуучулардын аттарын жана компанияларын көрсөтүүчү суроону түзүңүз.
-- Эгерде долбоордо иштеп чыгуучулар жок болсо, дагы эле көрсөтүлүшү керек.
-- ------
-- Составьте запрос, который покажет все проекты вместе с именами разработчиков, назначенных на каждый проект,
-- и компаниями, которые управляют этими проектами.
-- Если проект не имеет назначенных разработчиков, он все равно должен быть отображен.

select p.title as project_name ,concat( d.first_name, ' ', d.last_name) as dev_full_name ,
       c.name as companies_name
from developers d
    right join projects p on d.id = p.dev_id
    left join companies c on p.company_id = c.id;


-- 15.
-- Бардык өлкөлөрдү жана алардын тиешелүү шаарларын,
-- ошол шаарларда жашаган иштеп чыгуучулардын аттарын көрсөтүүчү суроону түзүңүз.
-- Эгер шаарда иштеп чыгуучулар жок болсо да, шаарларды камтыңыз.
------
-- Создайте запрос, чтобы отобразить все страны и их соответствующие города вместе с именами разработчиков,
-- проживающих в этих городах. Включите города, даже если в них нет проживающих разработчиков.

select c.name as country ,ci.name  as city, d.first_name from city ci
    join countries c on ci.country_id = c.id
   left join developers d on ci.id = d.address_id;

