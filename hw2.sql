/* Joy Payton
   IS 607
   Homework, Week 2 */

/*Question 1: 
How many airplanes have listed speeds? 
What is the minimum listed speed and the maximum listed speed? */

# Find out how many planes have a listed speed (speed not null)
SELECT COUNT(*) FROM PLANES WHERE speed IS NOT NULL;

# Get all the speeds that aren't null, order them from lowest to highest and 
# give me the first one from that list (effectively the minimum)

SELECT speed FROM PLANES WHERE speed IS NOT NULL ORDER BY speed asc LIMIT 1;

# I could do a similar command for max (but order by speed descending).
# Instead, another option is to take advantage of max / min. 
# Interestingly, this simpler command has a longer fetch time (in terms of microseconds)

SELECT max(speed) FROM PLANES;


/* Answer to Question 1:  
23 planes have a listed speed, among which the minimum speed is 90 and the maximum is 432. */

/*Question 2:
What is the total distance flown by all of the planes in January 2013? 
What is the total distance flown by all of the planes in January 2013 where the tailnum is missing? */

# Limit my selection to flights from Jan 2013, and sum them:
SELECT sum(distance) FROM flights WHERE year=2013 AND month=1;


# Now limit it further:  
SELECT sum(distance) FROM flights WHERE year=2013 AND month=1 AND tailnum IS NULL; 

/* Answer to Question 2:  The total distance flown by all of the planes in January 2013 is 27,188,805.
The total distance flown by all of the planes in January 2013 where the tailnum is missing is 81,763.


/* Question 3:
What is the total distance flown for all planes on July 5, 2013 grouped by aircraft manufacturer? 
Write this statement first using an INNER JOIN, then using a LEFT OUTER JOIN. How do your results compare? */

# OK, inner join first 
SELECT manufacturer, sum(distance) FROM flights INNER JOIN planes on 
flights.tailnum = planes.tailnum WHERE month=7 AND day=5 AND flights.year=2013 GROUP BY manufacturer;

/* Question 3 results for INNER join:
manufacturer			sum(distance)
AIRBUS				195089
AIRBUS INDUSTRIE		78786
AMERICAN AIRCRAFT INC		2199
BARKER JACK L			937
BOEING				335028
BOMBARDIER INC			31160
CANADAIR			1142
CESSNA				2898
DOUGLAS				1089
EMBRAER				77909
GULFSTREAM AEROSPACE		1157
MCDONNELL DOUGLAS		7486
MCDONNELL DOUGLAS AIRCRAFT CO	15690
MCDONNELL DOUGLAS CORPORATION	4767
*/

# And now with a left outer join (let's put each table on the left
# in successive queries to see if there's any difference...
SELECT manufacturer, sum(distance) FROM flights LEFT OUTER JOIN planes on 
flights.tailnum = planes.tailnum WHERE month=7 AND day=5 AND flights.year=2013 GROUP BY manufacturer;
# The results from this query include "null" manufacturers (stemming from null tail numbers)

SELECT manufacturer, sum(distance) FROM planes LEFT OUTER JOIN flights on 
flights.tailnum = planes.tailnum WHERE month=7 AND day=5 AND flights.year=2013 GROUP BY manufacturer;
# The results from this query don't include nulls, because there are no null tail numbers in the planes table.

/* Question 3 results for LEFT OUTER join where the planes table is on the left:
manufacturer			sum(distance)
AIRBUS				195089
AIRBUS INDUSTRIE		78786
AMERICAN AIRCRAFT INC		2199
BARKER JACK L			937
BOEING				335028
BOMBARDIER INC			31160
CANADAIR			1142
CESSNA				2898
DOUGLAS				1089
EMBRAER				77909
GULFSTREAM AEROSPACE		1157
MCDONNELL DOUGLAS		7486
MCDONNELL DOUGLAS AIRCRAFT CO	15690
MCDONNELL DOUGLAS CORPORATION	4767
/*

/* Question 4: 
Write and answer at least one question of your own choosing that joins 
information from at least three of the tables in the flights database. 

Joy's question: 
Find the 20 oldest planes with flights recorded in 2013 (excluding
flights with no known tail number or known age) as well as
 the FAA codes and names of the airports they flew from
 during that year. */

# First, find the 20 oldest planes and .  An inner join with flights limits flights to those in 2013.
SELECT DISTINCT planes.tailnum, planes.year FROM planes INNER JOIN flights on planes.tailnum = flights.tailnum
WHERE flights.year=2013 AND planes.year IS NOT NULL ORDER by planes.year asc LIMIT 20;

# Then use that prior SELECT as part of a JOIN to figure out where these 20 old planes
# flew out of... we want to match by tailnum and only include flights that originated in 2013 
# (Because a plane that flew in 2013 might have flown in any given airport earlier or later
# but not during 2013...

SELECT DISTINCT oldies.tailnum as tail_number, oldies.year as year_of_manufacture, flights.origin as originating_faa_code
from (SELECT DISTINCT planes.tailnum, planes.year FROM planes INNER JOIN flights on planes.tailnum = flights.tailnum
WHERE flights.year=2013 AND planes.year IS NOT NULL ORDER by planes.year asc LIMIT 20) as oldies INNER JOIN flights
ON flights.tailnum = oldies.tailnum AND flights.year = 2013 ORDER by oldies.year asc;

# Now, get the Airport name! 
SELECT DISTINCT old_planes_plus_faa.*, airports.name as originating_name from 
(SELECT DISTINCT oldies.tailnum as tail_number, oldies.year as year_of_manufacture, flights.origin as originating_faa_code
from (SELECT DISTINCT planes.tailnum, planes.year FROM planes INNER JOIN flights on planes.tailnum = flights.tailnum
WHERE flights.year=2013 AND planes.year IS NOT NULL ORDER by planes.year asc LIMIT 20) as oldies INNER JOIN flights
ON flights.tailnum = oldies.tailnum AND flights.year = 2013 ORDER by oldies.year asc) as old_planes_plus_faa 
INNER JOIN airports ON old_planes_plus_faa.originating_faa_code = airports.faa;

/* Answer:  Sorry, New Yorkers!!!

tail_number	year_of_manufacture	originating_faa_code	originating_name
N621AA	1975	EWR	Newark Liberty Intl
N567AA	1959	EWR	Newark Liberty Intl
N201AA	1959	EWR	Newark Liberty Intl
N508AA	1975	EWR	Newark Liberty Intl
N675MC	1975	EWR	Newark Liberty Intl
N575AA	1963	EWR	Newark Liberty Intl
N762NC	1976	EWR	Newark Liberty Intl
N615AA	1967	EWR	Newark Liberty Intl
N545AA	1976	EWR	Newark Liberty Intl
N425AA	1968	EWR	Newark Liberty Intl
N767NC	1977	EWR	Newark Liberty Intl
N381AA	1956	JFK	John F Kennedy Intl
N840MQ	1974	JFK	John F Kennedy Intl
N621AA	1975	JFK	John F Kennedy Intl
N378AA	1963	JFK	John F Kennedy Intl
N615AA	1967	JFK	John F Kennedy Intl
N711MQ	1976	JFK	John F Kennedy Intl
N383AA	1972	JFK	John F Kennedy Intl
N376AA	1978	JFK	John F Kennedy Intl
N364AA	1973	JFK	John F Kennedy Intl
N201AA	1959	LGA	La Guardia
N508AA	1975	LGA	La Guardia
N567AA	1959	LGA	La Guardia
N575AA	1963	LGA	La Guardia
N711MQ	1976	LGA	La Guardia
N545AA	1976	LGA	La Guardia
N14629	1965	LGA	La Guardia
N737MQ	1977	LGA	La Guardia
N425AA	1968	LGA	La Guardia
N840MQ	1974	LGA	La Guardia 
 */
