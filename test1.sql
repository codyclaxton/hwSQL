--Cody Claxton
--Query 1
with golfers_info as(
select country,name,age,events,cutsmade,top10s,wins,avgdrive,drivingacc,greensinreg,puttingavg,sum(earnings) as career_earnings, ROW_NUMBER() OVER(partition by country order by sum(earnings) desc) as country_rank
from pga.golfers
group by country,name,age,events,cutsmade,top10s,wins,avgdrive,drivingacc,greensinreg,puttingavg
order by country asc
)select * from golfers_info
where country_rank <= 2;
--Query 2
with country_info as(
select country,count(*) as num_golfers,sum(earnings) as country_earnings,RANK() over(order by sum(earnings) desc) as rank
from pga.golfers
group by country)
select * from country_info
where rank <= 3;
--Query 3
with good_performances as(
select distinct aid,event from gymnastics.performances
where score > 8
),all_events as(
select distinct event from gymnastics.performances)
,aid_count as(select aid,count(*) as dif_events from good_performances
group by aid)
select aid from aid_count
 where dif_events = (select count(*) from all_events);
--Query 4
with combined as(select * from university.enrollments
NATURAL JOIN university.students
NATURAL JOIN university.courses)
,info_needed as(select first,last,gpa,coursenum,credits,sid,term,grade,gradevalue
FROM combined
NATURAL JOIN
university.gradevalues
where grade is not null)
,final_info as(select sid,first,last,gpa,sum(credits*gradevalue) as total_credits,sum(credits) as hours_attempted
from info_needed
group by sid,first,last,gpa
) select sid,first,last,gpa,ROUND((total_credits/hours_attempted),2) as computed_gpa,(gpa-ROUND((total_credits/hours_attempted),2)) as difference
from final_info;
