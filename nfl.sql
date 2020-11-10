 select homeWs.homeTeam, homeWins+visitingWins as totalWins,homeDraws,awayDraws from
  (select homeTeam,count(*) as homeWins
  from nfl.games
  where homePoints > visitorPoints
  group by homeTeam) homeWs
  full outer join
  (select visitor, count(*) as visitingWins
  from nfl.games
  where visitorPoints > homePoints group by visitor) visitingWs
  on homeWs.homeTeam = visitingWs.visitor
  full outer join
  (select homeTeam, count(*) as homeDraws
  from nfl.games
  where homePoints = visitorPoints
  group by homeTeam) hDraws
  on visitingWs.visitor = hDraws.homeTeam
  full outer join
  (select visitor, count(*) as awayDraws
  from nfl.games
  where visitorPoints = homePoints
  group by visitor)vDraws
  on hDraws.homeDraws = vDraws.awayDraws;
