 #To preview a survey table
 SELECT *
 FROM survey
 LIMIT 5;

#To see a quiz funnel
SELECT question,
   COUNT(DISTINCT user_id) AS 'total'
FROM survey
GROUP BY question;

#To preview quiz, home_try_on and purchase tables
SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

#To create a purchase funnel
WITH funnel AS (
  SELECT DISTINCT q.user_id,
   CASE
    WHEN h.user_id IS NOT NULL 
    THEN 'True'
    ELSE 'False'
    END AS 'is_home_try_on',
   CASE
    WHEN h.number_of_pairs IS NULL
    THEN 'Null'
    ELSE h.number_of_pairs
    END AS 'number_of_pairs',
   CASE 
    WHEN p.user_id IS NOT NULL
    THEN 'True'
    ELSE 'False'
    END AS 'is_purchase'
FROM quiz AS 'q'
LEFT JOIN home_try_on AS 'h'
 ON q.user_id = h.user_id
LEFT JOIN purchase AS 'p'
 ON p.user_id = q.user_id)
SELECT *
FROM funnel
LIMIT 10;

#To check conversion rates from quiz to home_try_on and from home_try_on to purchase
WITH q AS (
  SELECT '1_quiz' AS stage, COUNT(DISTINCT user_id) as 'total'
  FROM quiz
),
h AS (
  SELECT '2_home_try_on' AS stage, COUNT(DISTINCT user_id) AS 'total'
  FROM home_try_on
),
p AS (
  SELECT '3_purchase' AS stage, COUNT(DISTINCT user_id) AS 'total'
  FROM purchase
)
SELECT *
FROM q
UNION ALL SELECT *
FROM h
UNION ALL SELECT *
FROM p;

#To check conversion rate of A/B test
WITH base_table AS (
  SELECT DISTINCT q.user_id,
  h.user_id IS NOT NULL AS 'is_home_try_on',
  h.number_of_pairs AS 'AB_variant',
  p.user_id IS NOT NULL AS 'is_purchase'
 FROM quiz q
 LEFT JOIN home_try_on h
  ON q.user_id = h.user_id
 LEFT JOIN purchase p
  ON p.user_id = q.user_id
)
SELECT AB_variant,
 SUM(CASE 
     WHEN is_home_try_on = 1
     THEN 1
     ELSE 0
     END) 'home_trial',
  SUM(CASE
      WHEN is_purchase = 1
      THEN 1
      ELSE 0
      END) 'purchase'
  FROM base_table
  GROUP BY AB_variant
  HAVING home_trial > 0;

#Most common response in the survey
SELECT DISTINCT question,
MAX(answer) as "total",
response AS " most popular reponse"
FROM(SELECT question,
response,
COUNT(response) AS "answer"
FROM survey
GROUP BY 2)
GROUP BY 1;

#Most common style quiz responses
SELECT style, COUNT(DISTINCT user_id) AS 'total'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

SELECT shape, COUNT(DISTINCT user_id) AS 'total'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

SELECT fit, COUNT(DISTINCT user_id) AS 'total'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

#Most common purchase
SELECT style, 
 model_name,
 color,
 COUNT(*) AS 'total'
FROM purchase
GROUP BY 2
ORDER BY total DESC;

#Purchases by price category
SELECT price, COUNT(*) AS 'total'
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;

#The most popular color among women
SELECT 
 CASE
  WHEN color LIKE '%Tortoise%'
  THEN 'Tortoise'
  WHEN color LIKE '%Black%'
  THEN 'Black'
  WHEN color LIKE '%Crystal%' 
  THEN 'Crystal'
  WHEN color LIKE '%Gray%'
  THEN 'Gray'
  WHEN color LIKE '%Fade%'
  THEN 'Fade'
  ELSE 'Other'
  END AS 'colors',
COUNT(*) AS 'total'
FROM purchase
WHERE style LIKE 'Women%'
GROUP BY colors
ORDER BY total DESC;

#The most popular color among men
SELECT 
 CASE
  WHEN color LIKE '%Tortoise%'
  THEN 'Tortoise'
  WHEN color LIKE '%Black%'
  THEN 'Black'
  WHEN color LIKE '%Crystal%' 
  THEN 'Crystal'
  WHEN color LIKE '%Gray%'
  THEN 'Gray'
  WHEN color LIKE '%Fade%'
  THEN 'Fade'
  ELSE 'Other'
  END AS 'colors',
COUNT(*) AS 'total'
FROM purchase
WHERE style LIKE 'Men%'
GROUP BY colors
ORDER BY total DESC;

#The most expensive models
SELECT model_name, color, style, price
FROM purchase
WHERE price = '150'
GROUP BY 1,2,3;
