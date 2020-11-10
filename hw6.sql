--Cody Claxton
--REMARK: QUERY 1
select * from (select aid,meet,event,score,rank() over( order by score desc) rank
from gymnastics.performances)
where rank <= 5;
--REMARK: QUERY 2
select * from (select aid,meet,event,score,rank() over( partition by event  order by score desc) rank
from gymnastics.performances)
where rank <=3;
--REMARK: QUERY 3
select * from (select aid,fname,lname,team,event,meet,score,rank() over( partition by team order by score desc) teamrank
from gymnastics.athletes
NATURAL JOIN gymnastics.performances)
where teamrank <= 3;
--Remark:  QUERY 4
select firstname,lastname,playerinfo.team,position,weight,teamweight from (select firstname,lastname,team,position,weight
from nfl.players
where position = 'RB') playerinfo
INNER JOIN
(select team,avg(weight) as teamweight
from nfl.players
group by team) teamweights
on playerinfo.team = teamweights.team
where weight > teamweight;
--Remark: QUERY 5
with dolphin_scores as (select team,gamedate,opponent,location,pointsscored,pointsagainst,
LAG(SUM(pointsscored),1) OVER(PARTITION BY team ORDER BY gamedate) as previous_gm_diff
from nfl.dolphinschedule
group by team,gamedate,opponent,location,pointsscored,pointsagainst
order by gamedate)
select team,gamedate,opponent,location,pointsscored,pointsagainst,pointsscored-previous_gm_diff as prev_point_diff
from dolphin_scores;
--Remark: QUERY 6
with dolphin_scores as (select team,gamedate,opponent,location,pointsscored,pointsagainst,
LAG(SUM(pointsscored),1) OVER(PARTITION BY team ORDER BY gamedate) as previous_gm_diff
from nfl.dolphinschedule
group by team,gamedate,opponent,location,pointsscored,pointsagainst
order by gamedate)
select team,gamedate,opponent,location,pointsscored,pointsagainst,pointsscored-previous_gm_diff as prev_point_diff,
CASE when pointsscored>pointsagainst then 'Win' when pointsscored<pointsagainst then 'Loss' else 'Tie' end as result
from dolphin_scores;
--Remark: QUERY 7
select level,employee_id,first_name,last_name,manager_id
from hr.employees
start with employee_id = 105
connect by prior manager_id = employee_id;
--Remark: Query 8 gives you each branch that was on a given mission
select mission,count(servicebranch) as unique_branches from
(select distinct mission,servicebranch from (select mission,apollo.crewassignments.aid,servicebranch from apollo.crewassignments
INNER JOIN apollo.astronauts
on apollo.crewassignments.aid = apollo.astronauts.aid)
order by mission
)
group by mission;
