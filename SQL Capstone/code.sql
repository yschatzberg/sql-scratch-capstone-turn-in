with months as(
SELECT
  '2016-12-01' AS first_day,
  '2016-12-31' AS last_day
UNION
  SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
  SELECT
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
UNION
  SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
cross_join as (
select * from subscriptions
cross join
months
),
status as (
select 
  id,
  first_day as month, 
  segment,
  CASE
  WHEN (subscription_start <= first_day)
    THEN 1
    ELSE 0
  END as is_active,
  CASE
  WHEN (subscription_end is not null) AND (subscription_end BETWEEN first_day AND last_day)
    THEN 1
    ELSE 0
  END as is_canceled
  from cross_join
),
status_aggregate as (
select 
  month,
  segment,
  SUM(is_active) as sum_active,
  SUM(is_canceled) as sum_canceled
from
  status group by month,segment order by month,segment
)

select segment, count(*) from subscriptions group by segment order by segment;

select Round(((sum_canceled*1.0)/sum_active),2) as churn from status_aggregate group by segment order by segment;

select segment, Round(((sum_canceled*1.0)/sum_active),2) as churn from status_aggregate group by segment order by segment;

select month, segment,
Round(((sum_canceled*1.0)/sum_active),2) as churn from status_aggregate group by month,segment order by month,segment;


select month,
Round(((sum_canceled*1.0)/sum_active),2) as churn from status_aggregate group by month order by month;


select month, SUM(is_active), SUM(is_canceled) from status group by month order by month;
