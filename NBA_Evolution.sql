
----------------------- AGE -------------------

-- 1. Average age, oldest age, and youngest age in each season:

SELECT 
    season,
    ROUND(cast(AVG(age)as numeric), 2) AS average_age,
    MIN(age) AS youngest_age,
    MAX(age) AS oldest_age
FROM 
    all_seasons
GROUP BY 
    season
ORDER BY 
    season;


-- 2. First and last names of the youngest and oldest players

SELECT 
    Season, 
    player_name, 
    Age
FROM 
    all_seasons as2 
WHERE 
    Age = (SELECT MIN(Age) FROM all_seasons as3 WHERE as3.Season = Season)
   OR 
    Age = (SELECT max(Age) FROM all_seasons as3 WHERE as3.Season = Season);
 
   
   
-- 3. Select teams with the highest and lowest average age:
 
 WITH team_ages AS (
	 SELECT 
	    Season, 
	    team_abbreviation , 
	    ROUND(CAST(avg(age) AS NUMERIC), 2) as avg_team_age
	FROM 
	    all_seasons as2 
	GROUP BY 
	    Season, team_abbreviation 
	ORDER BY 
	    Season, team_abbreviation DESC
)
SELECT 
    *
FROM 
    team_ages
WHERE 
    avg_team_age = (SELECT MAX(avg_team_age) FROM team_ages ta WHERE ta.Season = ta.Season)
   OR 
    avg_team_age = (SELECT MIN(avg_team_age) FROM team_ages ta WHERE ta.Season = ta.Season)
ORDER BY 
    Season, avg_team_age DESC;
 
-- Percentage of total points scored in each season by age groups: Young (<24), Prime (24–30), Veteran (>30)
 
 WITH AgeGroupPoints AS (
    SELECT 
        season,
        CASE 
            WHEN age < 24 THEN 'Young'
            WHEN age BETWEEN 24 AND 30 THEN 'Prime'
            ELSE 'Veteran'
        END AS age_group,
        SUM(pts) AS total_points
    FROM 
        all_seasons
    GROUP BY 
        season, 
        CASE 
            WHEN age < 24 THEN 'Young'
            WHEN age BETWEEN 24 AND 30 THEN 'Prime'
            ELSE 'Veteran'
        END
),
SeasonTotalPoints AS (
    SELECT 
        season,
        SUM(pts) AS total_season_points
    FROM 
        all_seasons
    GROUP BY 
        season
)
SELECT 
    A.season,
    A.age_group,
    A.total_points,
    ROUND(cast((A.total_points * 100.0) / S.total_season_points as numeric), 2) AS percentage_points
FROM 
    AgeGroupPoints A
JOIN 
    SeasonTotalPoints S
ON 
    A.season = S.season
ORDER BY 
    A.season, 
    A.age_group;
 
-- 4. Percentage share of each age group:
 
SELECT 
    Season,
    round(cast(COUNT(CASE WHEN Age < 24 THEN 1 END) * 100.0 / COUNT(*) as numeric),2) AS Young_Percent,
    round(cast(COUNT(CASE WHEN age BETWEEN 24 AND 30 THEN 1 END) * 100.0 / COUNT(*) as numeric),2) AS prime_Percent,
    round(cast(COUNT(CASE WHEN Age > 30 THEN 1 END) * 100.0 / COUNT(*) as numeric),2) AS Veteran_Percent
FROM 
    all_seasons as2 
GROUP BY 
    Season
ORDER BY 
    Season;


-- 5. Highest percentage of young, prime, and veteran players:

WITH AgeGroups AS (
    SELECT 
        Season,
        CASE 
            WHEN Age < 24 THEN 'Young (<24)'
            WHEN Age BETWEEN 24 AND 30 THEN 'Prime (24-30)'
            ELSE 'Veteran (>30)'
        END AS Age_Group,
        COUNT(*) AS PlayerCount,
        round(cast(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM all_seasons as3  
        	WHERE as2.Season = as3.Season) as numeric ),2) AS Percentage
    FROM 
        all_seasons as2 
    GROUP BY 
        Season, Age_Group
)
SELECT 
    Age_Group, 
    Season, 
    agegroups.percentage,
    ROUND(CAST( MAX(Percentage) AS NUMERIC), 2) AS Max_Percentage
   
FROM 
    AgeGroups
group by 
1,2,3
HAVING 
    Percentage = (SELECT MAX(Percentage) 
                  FROM AgeGroups AS AG 
                  WHERE AG.Age_Group = AgeGroups.Age_Group);

-- 6. Which age group scored the highest average points per season:

 WITH AgeGroupStats AS (
    SELECT 
        season,
        CASE 
            WHEN age < 24 THEN 'Young'
            WHEN age BETWEEN 24 AND 30 THEN 'Prime'
            ELSE 'Veteran'
        END AS age_group,
        SUM(pts) AS total_points,
        COUNT(*) AS player_count,
        SUM(pts) * 1.0 / COUNT(*) AS avg_points_per_player
    FROM 
        all_seasons
    GROUP BY 
        season, 
        CASE 
            WHEN age < 24 THEN 'Young'
            WHEN age BETWEEN 24 AND 30 THEN 'Prime'
            ELSE 'Veteran'
        END
),
BestPerformingGroup AS (
    SELECT 
        season,
        age_group,
        avg_points_per_player
    FROM 
        AgeGroupStats
    WHERE 
        avg_points_per_player = (SELECT MAX(avg_points_per_player)
                                 FROM AgeGroupStats AS AGS
                                 WHERE AGS.season = AgeGroupStats.season)
)
SELECT 
    season,
    age_group AS best_age_group,
ROUND(cast(avg_points_per_player as numeric), 2) AS avg_points_per_player
FROM 
    BestPerformingGroup
ORDER BY 
    season;



-- 7. Age group with the highest overall average points:
WITH AgeGroupStats AS (
    SELECT 
        CASE 
            WHEN age < 24 THEN 'Young'
            WHEN age BETWEEN 24 AND 30 THEN 'Prime'
            ELSE 'Veteran'
        END AS age_group,
        SUM(pts) AS total_points,
        COUNT(*) AS player_count,
        SUM(pts) * 1.0 / COUNT(*) AS avg_points_per_player
    FROM 
        all_seasons
    GROUP BY 
        CASE 
            WHEN age < 24 THEN 'Young'
            WHEN age BETWEEN 24 AND 30 THEN 'Prime'
            ELSE 'Veteran'
        END
)
SELECT 
    age_group,
    ROUND(cast(avg_points_per_player as numeric), 2) AS avg_points_per_player
FROM 
    AgeGroupStats
WHERE 
    avg_points_per_player = (SELECT MAX(avg_points_per_player) 
                             FROM AgeGroupStats);


-- 8. Top player in each season (based on points per game)
-- Finds the player with the highest points per game in each season.

SELECT 
    Season, 
    player_name , 
    pts 
FROM 
    all_seasons as2 
WHERE 
    pts = (SELECT MAX(pts) 
                     FROM all_seasons as3 
                     WHERE as3.Season = as2.Season)
ORDER BY 
    Season;


----------------------- COUNTRIES -------------------

-- Most represented countries in NBA history excluding USA


select 
	country,
	count(*) as number_of_players
from all_seasons as2 
where country != 'USA'
group by 1
order by 2 desc ;


-- Players from the USA:
select 
	country,
	count(*) as number_of_players
from all_seasons as2 

group by 1
order by 2 desc ;



-- Which country is the most popular after the USA?
select 
	country,
	count(*) as number_of_players
from all_seasons as2 
where country != 'USA'
group by 1
order by 2 desc 
limit 1;

-- Share of international players each season
-- Percentage of international players (non-USA) across seasons

select 
season, 
count(*) as number_of_players,
sum(case when country != 'USA' then 1 else 0 end) as international_players,
sum(case when country != 'USA' then 1 else 0 end) * 100 / count(*) as international_percentage
from all_seasons as2 
group by 1
order by 1;




----------------------- EDUCATION (COLLEGE) -------------------


-- Most popular schools in different seasons


WITH SchoolPlayerCount AS (
    SELECT 
        Season, 
        College AS School, 
        COUNT(*) AS number_of_players
    FROM 
        all_seasons as2    
    where college is not null AND College != 'None'
    GROUP BY 
        Season, College
)
SELECT 
    Season, 
    School, 
    number_of_players
FROM 
    SchoolPlayerCount
WHERE 
    number_of_players = (SELECT MAX(number_of_players) 
                   FROM SchoolPlayerCount AS SPC 
                   WHERE SPC.Season = SchoolPlayerCount.Season)
ORDER BY 
    Season;

-- Do players with a college background score more?

SELECT 
    CASE 
        WHEN College IS NULL OR College = 'None' THEN 'No School'
        ELSE 'With School'
    END AS School_Category,
    COUNT(*) AS number_of_players,
    round(cast(AVG(pts) as numeric),2) AS Avg_Points_Per_Player,
    round(cast(SUM(pts)as numeric),2) AS Total_Points
    
FROM 
    all_seasons as2 
GROUP BY 
    1;
	

-- Average number of points per player by college:

SELECT 
    college, 
    ROUND(cast(AVG(pts) as numeric), 2) AS avg_points
FROM 
    all_seasons
WHERE 
    all_seasons.college IS NOT NULL AND college != 'None' -- Exclude missing values
GROUP BY 
    college
ORDER BY 
    avg_points DESC
limit 15;

-- What percentage of players went to college and what percentage didn’t:

SELECT 
    CASE 
        WHEN college IS NULL OR college = 'None' THEN 'No School'
        ELSE 'With School'
    END AS education_status,
    COUNT(*) AS player_count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM all_seasons) AS percentage
FROM 
    all_seasons
GROUP BY 
    education_status
ORDER BY 
    education_status;


-- And breakdown by season:


WITH EducationCounts AS (
    SELECT 
        season,
        CASE 
            WHEN college IS NULL OR college = 'None' THEN 'No School'
            ELSE 'With School'
        END AS education_status,
        COUNT(*) AS player_count
    FROM 
        all_seasons
    GROUP BY 
        season,
        CASE 
            WHEN college IS NULL OR college = 'None' THEN 'No School'
            ELSE 'With School'
        END
),
SeasonTotalCounts AS (
    SELECT 
        season,
        COUNT(*) AS total_players
    FROM 
        all_seasons
    GROUP BY 
        season
)
SELECT 
    S.season,
    total_players,
    ROUND(cast(sUM(CASE WHEN E.education_status = 'With School' THEN E.player_count ELSE 0 END) * 100.0 / S.total_players as numeric),2) AS school_percent,
     ROUND(cast(SUM(CASE WHEN E.education_status = 'No School' THEN E.player_count ELSE 0 END) * 100.0 / S.total_players as numeric),2) AS no_school_percent
FROM 
    EducationCounts E
JOIN 
    SeasonTotalCounts S
ON 
    E.season = S.season
GROUP BY 
    1,2
ORDER BY 
    S.season;



----------------------- HEIGHT & WEIGHT-------------------

-- Average height and weight per season
SELECT 
    season,
    ROUND(cast (AVG(player_height)as numeric), 2) AS average_height,
    ROUND(CAST(AVG(player_weight)as numeric), 2) AS average_weight
 
FROM 
    all_seasons
GROUP BY 
    season
ORDER BY 
    season;



----------------------- SUMMARY – CORRELATIONS-------------------
-- Correlation between height, weight, age and average points per season:

WITH SeasonStats AS (
    SELECT 
        season,
        AVG(player_height) AS average_height,
        AVG(player_weight) AS average_weight,
        AVG(age) as avarage_age,
        AVG(pts) AS average_points
    FROM 
        all_seasons
    GROUP BY 
        season
)
SELECT 
    ROUND(cast(CORR(average_height, average_points)as numeric),2) AS correlation_height_points,
    ROUND(cast(CORR(average_weight, average_points)as numeric),2) AS correlation_weight_points,
     ROUND(cast(CORR(avarage_age, average_points)as numeric),2) AS correlation_age_points
FROM 
    SeasonStats;





-- Top scorer in each season (based on points per game)


SELECT 
    Season, 
    player_name , 
    pts 
FROM 
    all_seasons as2 
WHERE 
    pts = (SELECT MAX(pts) 
                     FROM all_seasons as3 
                     WHERE as3.Season = as2.Season)
ORDER BY 
    Season;


-- Average points per game trend across seasons


SELECT 
    Season, 
    round(cast(AVG(pts) as numeric),2) AS Avg_Points_Per_Game
FROM 
    all_seasons as2 
GROUP BY 
    Season
ORDER BY 
    Season;
