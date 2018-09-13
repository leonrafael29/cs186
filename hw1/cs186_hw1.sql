DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM master
  WHERE weight>300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM master
  WHERE namefirst LIKE '% %'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*) AS count
  FROM master
  GROUP BY birthyear
  ORDER BY birthyear ASC 

;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(playerid) AS count
  FROM master
  GROUP BY birthyear
  HAVING AVG(height)>70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT mas.namefirst, mas.namelast, mas.playerid, h.yearid
  FROM master AS mas, Halloffame AS h
  WHERE mas.playerid=h.playerid AND h.inducted='Y'
  ORDER BY h.yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT  mas.namefirst, mas.namelast, mas.playerid, c.schoolid, h.yearid
  FROM master AS mas, Halloffame AS h, CollegePlaying AS c, Schools AS s
  WHERE mas.playerid=h.playerid AND h.inducted='Y' AND mas.playerid=c.playerid AND s.schoolid=c.schoolid AND s.schoolstate='CA'
  ORDER BY h.yearid DESC, schoolid, playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT mas.playerid, mas.namefirst, mas.namelast, newtable.schoolid
  FROM master as mas,
       (SELECT h.playerid, schoolid
       FROM Halloffame AS h LEFT OUTER JOIN collegeplaying AS c ON h.playerid=c.playerid
       WHERE h.inducted ='Y') AS newtable
  WHERE mas.playerid=newtable.playerid
  ORDER BY mas.playerid DESC, schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT mas.playerid, mas.namefirst, mas.namelast, b.yearid,  ((b.h-b.h2b-b.h3b-b.hr)+ 2* b.h2b + 3*b.h3b + 4*b.hr)/CAST(b.ab AS FLOAT) AS  slg
  FROM master AS mas, Batting AS b
  WHERE mas.playerid=b.playerid AND b.ab>50
  ORDER BY slg DESC, yearid,  playerid ASC 
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT mas.playerid, mas.namefirst, mas.namelast, ((SUM(b.h)-SUM(b.h2b)-SUM(b.h3b)-SUM(b.hr))+ 2* SUM(b.h2b) + 3*SUM(b.h3b) + 4*SUM(b.hr))/CAST(SUM(b.ab) AS FLOAT) AS  lslg  FROM master AS mas, Batting AS b
  WHERE mas.playerid=b.playerid 
  GROUP BY mas.playerid
  HAVING SUM(b.ab)>50
  ORDER BY lslg DESC, playerid ASC 
  LIMIT 10

;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH playerlslg (playerid, lslg) AS
       (SELECT mas.playerid, ((SUM(b.h)-SUM(b.h2b)-SUM(b.h3b)-SUM(b.hr))+ 2* SUM(b.h2b) + 3*SUM(b.h3b) + 4*SUM(b.hr))/CAST(SUM(b.ab) AS FLOAT) AS  lslg
       FROM master AS mas, Batting AS b
       WHERE mas.playerid=b.playerid AND b.playerid='mayswi01' 
       GROUP BY mas.playerid),
       lslgplay(namefirst, namelast, playerid, lslg) AS  
       (SELECT mas.namefirst, mas.namelast, mas.playerid, ((SUM(b.h)-SUM(b.h2b)-SUM(b.h3b)-SUM(b.hr))+ 2* SUM(b.h2b) + 3*SUM(b.h3b) + 4*SUM(b.hr))/CAST(SUM(b.ab) AS FLOAT) AS  lslg
       FROM master AS mas, Batting AS b
       WHERE mas.playerid=b.playerid 
       GROUP BY mas.playerid
       HAVING SUM(b.ab)>50)
  SELECT l.namefirst, l.namelast, l.lslg
  FROM lslgplay AS l, playerlslg AS p
  WHERE l.lslg> p.lslg
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary) AS min, MAX(salary) AS max, AVG(salary) AS avg, STDDEV(salary) AS stddev 
  FROM Salaries
  GROUP BY yearid
  ORDER BY yearid ASC

;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH salaries2016(salary) AS
    (SELECT salary 
     FROM Salaries
     WHERE yearid=2016) 
  SELECT binid-1 AS binid, 507500+(binid-1)* (33000000-507500)/10 AS low, 507500+(binid)* (33000000-507500)/10 AS high, count
  FROM (
        SELECT WIDTH_BUCKET(salary, 507500, 33000001, 10) AS binid, COUNT(*) AS count
 FROM salaries2016
 GROUP BY binid
 ORDER BY binid) x
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT s2.yearid, MIN(s2.salary)-MIN(s.salary) AS mindiff, MAX(s2.salary)-MAX(s.salary) AS maxdiff, AVG(s2.salary)-AVG(s.salary) AS avgdiff
  FROM Salaries AS s2, Salaries AS s
  WHERE s2.yearid=s.yearid +1
  GROUP BY s2.yearid
  ORDER BY s2.yearid ASC

;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH salaries2000(maxsalary) AS
    (SELECT MAX(s.salary) AS  maxsalary
     FROM Salaries AS s
     WHERE s.yearid=2000
     GROUP BY s.yearid),
     salaries2001(maxsalary) AS
    (SELECT MAX(s.salary) AS  maxsalary
     FROM Salaries AS s
     WHERE s.yearid=2001
     GROUP BY s.yearid)  
        
  SELECT s.playerid, mas.namefirst, mas.namelast, s.salary, s.yearid
  FROM Salaries AS s, salaries2000 AS s1, salaries2001 AS s2, master AS mas
  WHERE s.playerid=mas.playerid AND s.salary= s1.maxsalary  AND s.yearid=2000
  UNION ALL
  SELECT s.playerid, mas.namefirst, mas.namelast, s.salary, s.yearid
  FROM Salaries AS s, salaries2000 AS s1, salaries2001 AS s2, master AS mas
  WHERE s.playerid=mas.playerid AND s.salary= s2.maxsalary  AND  s.yearid=2001
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  WITH allstarsalary2016(teamid, playerid) AS
   (SELECT a.teamid, a.playerid
    FROM allstarfull AS a
    WHERE a.yearid=2016)
  SELECT a.teamid AS team, MAX(a.salary)-MIN(a.salary) AS diffAvg
  FROM allstarsalary2016 AS a
  GROUP BY a.teamid
  ORDER BY teamid ASC
;
