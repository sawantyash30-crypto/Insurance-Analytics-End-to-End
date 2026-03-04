CREATE DATABASE Insurance_Analytics;
Use Insurance_Analytics;

create table Individual_budgets(
branch varchar(50),
employee_name varchar(50),
account_exe_id int,
new_budget decimal(12,2),
cross_sell_budget decimal(12,2),
renewal_budget decimal(12,2));

SHOW VARIABLES LIKE 'secure_file_priv';


create table achievement
(account_executive varchar(50),
business_type varchar(50),
achievement_amount decimal(12,2));
DESCRIBE brokerage;

create table brokerage
(account_exe_id int,
branch_name varchar(20),
solution_group varchar(50),
amount int,
exe_name varchar(50),
revenue_transaction_type varchar(50));
truncate table brokerage;

create table fees
(account_exe_id int,
exe_name varchar(20),
branch_name varchar(20),
solution_group varchar(50),
amount int);

CREATE TABLE invoice (
    account_exe_id INT,
    exe_name VARCHAR(100),
    branch VARCHAR(50),
    solution_group VARCHAR(50),
    amount INT
);

CREATE TABLE meeting (
    account_exe_id INT,
    exe_name VARCHAR(100),
    branch VARCHAR(50),
    meeting_date DATE
);
SELECT COUNT(*) FROM meeting;
SELECT * FROM meeting;
TRUNCATE TABLE meeting;


CREATE TABLE opportunity (
    account_exe_id INT,
    exe_name VARCHAR(100),
    branch VARCHAR(50),
    stage VARCHAR(50),
    revenue_amount INT
);

DELETE FROM brokerage
WHERE account_exe_id IS NULL;

DELETE FROM fees
WHERE account_exe_id IS NULL;

DELETE FROM invoice
WHERE account_exe_id IS NULL;

DELETE FROM meeting
WHERE account_exe_id IS NULL;

DELETE FROM opportunity
WHERE account_exe_id IS NULL;

SELECT DISTINCT revenue_transaction_type
FROM brokerage;

CREATE OR REPLACE VIEW vw_placed_revenue AS
SELECT
    b.account_exe_id,
    b.exe_name,
    b.branch_name,
    b.revenue_transaction_type,
    SUM(b.amount) + COALESCE(SUM(f.amount), 0) AS placed_amount
FROM brokerage b
LEFT JOIN fees f
    ON b.account_exe_id = f.account_exe_id
GROUP BY
    b.account_exe_id,
    b.exe_name,
    b.branch_name,
    b.revenue_transaction_type;
    SELECT * FROM vw_placed_revenue LIMIT 10;
    
    create or replace view  vw_invoice_revenue as  
    select account_exe_id,
    exe_name,
    branch,
    sum(amount)as invoice_amount
    from invoice
    group by
    account_exe_id,
    exe_name,
    branch;
    
    select * from vw_invoice_revenue;
    
    create or replace view vw_target as
    select account_exe_id,
    employee_name,
    branch,
    (new_budget+cross_sell_budget+renewal_budget) as total_target,
    new_budget,
    cross_sell_budget,
    renewal_budget
    from individual_budgets;

select * from vw_target;

create or replace view vw_performance_kpi as
select t.branch,
t.account_exe_id,
t.employee_name,
t.total_target,
coalesce(sum(p.placed_amount),0) as placed_amount,
coalesce(sum(i.invoice_amount),0) as invoice_Amount,
round
(coalesce(sum(p.placed_amount),0)/t.total_target*100,2
)as place_achievment_pct,
round(coalesce(sum(i.invoice_amount),0)/t.total_target*100,2
)as invoice_achievment_pct
from vw_target t
left join vw_placed_revenue p
on t.account_exe_Id= p.account_exe_id
left join vw_invoice_revenue i
on t.account_exe_id = p.account_exe_Id
group by
t.branch,
t.account_exe_id,
t.employee_name,
t.total_target;

select * from vw_performance_kpi;

create or replace view vw_meeting_count as
select account_exe_id,
exe_name,
count(meeting_date) as meeting_count
from meeting
group by
account_exe_id,
exe_name;

select * from vw_meeting_count;

create or replace view  opportunity_funnel as
select stage,
count(*) as opportunity_count,
sum(revenue_amount) as Total_revenue
from opportunity
group by
stage;
select * from opportunity_funnel;

create or replace view conversation_ratio as
select account_exe_id,
exe_name,
 ROUND(
        SUM(CASE WHEN stage = 'Won' THEN 1 ELSE 0 END) * 1.0
        / COUNT(*),
        2
) as conversation_ratio
from opportunity
group by
account_exe_id,
exe_name;
select * from conversation_ratio;

create table Policy_data
(customer_id varchar(50),
gender varchar (20),
age int,
occupation varchar(50),
marrital_status varchar(20));

select * from policy_data;

create table policy_details
(customer_id  varchar(50),
policy_id varchar(50),
coverage_amount int,
premium_amount decimal(12,2),
policy_start_date date,
policy_end_date date,
payment_frequency varchar(20));

DROP TABLE IF EXISTS policy_details_raw;

CREATE TABLE policy_details_raw (
    policy_id VARCHAR(50),
    policy_type VARCHAR(50),
    coverage_amount VARCHAR(50),
    premium_amount VARCHAR(50),
    policy_start_date VARCHAR(50),
    policy_end_date VARCHAR(50),
    payment_frequency VARCHAR(50),
    status VARCHAR(50),
    customer_id VARCHAR(50)
);

DROP TABLE IF EXISTS policy_details;

CREATE TABLE policy_details (
    policy_id VARCHAR(50),
    policy_type VARCHAR(50),
    coverage_amount INT,
    premium_amount DECIMAL(10,2),
    policy_start_date DATE,
    policy_end_date DATE,
    payment_frequency VARCHAR(50),
    status VARCHAR(50),
    customer_id VARCHAR(50)
);

INSERT INTO policy_details
SELECT
    policy_id,
    policy_type,
    CAST(coverage_amount AS UNSIGNED),
    CAST(premium_amount AS DECIMAL(10,2)),
    STR_TO_DATE(policy_start_date, '%Y-%d-%m'),
    STR_TO_DATE(policy_end_date, '%Y-%d-%m'),
    payment_frequency,
    status,
    customer_id
FROM policy_details_raw;

SELECT COUNT(*) FROM policy_details;
SELECT * FROM policy_details LIMIT 5;

CREATE table policy_claims
(claim_id varchar(50),
date_of_claim varchar(50),
claim_amount int,
claim_status varchar(20),
policy_id varchar(20));
select * from policy_claims;

create table payment_history
(payment_id varchar(50),
date_of_payment varchar(50),
amount_paid decimal(12,2),
payment_method varchar(20),
payment_status varchar(20),
policy_id varchar (20));

DELETE FROM policy_details
WHERE policy_id IS NULL;

DELETE FROM opportunity
WHERE account_exe_id IS NULL;

DELETE FROM brokerage
WHERE account_exe_id IS NULL;

UPDATE policy_details
SET status = 'Active'
WHERE status IN ('active','ACTIVE');

UPDATE policy_details
SET status = 'Expired'
WHERE status IN ('expired','EXPIRED');

update policy_details
set payment_frequeNcy = 'monthly'
where payment_frequency in ('monthly','MONTHLY');

SELECT * FROM policy_details;
DELETE FROM policy_details
where premium_amount <=0
or coverage_amount <=0;

create or replace view dim_customer as
select distinct 
customer_id
from policy_details;

select * from dim_customer;

select count(*) FROM dim_customer;

create or replace view  fact_policy as
select policy_id,
customer_Id,
policy_type,
coverage_amount,
premium_amount,
policy_start_date,
policy_end_date,
payment_frequency,
status
from policy_details;

create or replace view fact_claims as
select claim_id,
 policy_id,
claim_status,
cast(claim_amount as decimal(12,2)),
date_of_claim
from policy_claims;


# KPI's
#NO OF INVOICES BY ACCOUNT EXECUTIVE
select account_exe_id,
exe_name,
count(*) as invoice_count
from invoice
group by account_exe_id,
exe_name;

create or replace view vw_inoices_count_by_exec as
select account_exe_id,
exe_name,
count(*) as invoice_count
from invoice
group by account_exe_id,
exe_name;

# yearly neeting count
SELECT
    YEAR(meeting_date) AS meeting_year,
    COUNT(*) AS meeting_count
FROM meeting
WHERE meeting_date IS NOT NULL
GROUP BY YEAR(meeting_date)
ORDER BY meeting_year;
CREATE OR REPLACE VIEW vw_yearly_meeting_total AS
SELECT
    YEAR(meeting_date) AS meeting_year,
    COUNT(*) AS meeting_count
FROM meeting
WHERE meeting_date IS NOT NULL
GROUP BY YEAR(meeting_date);
CREATE OR REPLACE VIEW vw_yearly_meeting_total AS
SELECT
    YEAR(meeting_date) AS meeting_year,
    COUNT(*) AS meeting_count
FROM meeting
WHERE meeting_date IS NOT NULL
GROUP BY YEAR(meeting_date);

#cross_sell_target_achieved_new
#cross sell target
select 
account_exe_id,
employee_name,
cross_sell_budget as cross_sell_target
from individual_budgets;

# Cross sell achieved
SELECT
    account_exe_id,
    SUM(amount) AS cross_sell_achieved
FROM brokerage
GROUP BY account_exe_id;

# cross sell new
select account_exe_id,
count(*) as cross_sell_new
from opportunity
where stage in ('propose solution','qualify opportunity')
group by account_exe_id;

#final cross sell kpi
SELECT
    i.account_exe_id,
    i.employee_name,
    i.cross_sell_budget AS cross_sell_target,
    COALESCE(b.cross_sell_achieved, 0) AS cross_sell_achieved,
    COALESCE(o.cross_sell_new, 0) AS cross_sell_new
FROM individual_budgets i
LEFT JOIN (
    SELECT
        account_exe_id,
        SUM(amount) AS cross_sell_achieved
    FROM brokerage
    GROUP BY account_exe_id
) b
    ON i.account_exe_id = b.account_exe_id
LEFT JOIN (
    SELECT
        account_exe_id,
        COUNT(*) AS cross_sell_new
    FROM opportunity
    WHERE stage IN ('Propose Solution', 'Qualify Opportunity')
    GROUP BY account_exe_id
) o
    ON i.account_exe_id = o.account_exe_id;

create or replace view cross_sell_achievement_new_target as
SELECT
    i.account_exe_id,
    i.employee_name,
    i.cross_sell_budget AS cross_sell_target,
    COALESCE(b.cross_sell_achieved, 0) AS cross_sell_achieved,
    COALESCE(o.cross_sell_new, 0) AS cross_sell_new
FROM individual_budgets i
LEFT JOIN (
    SELECT
        account_exe_id,
        SUM(amount) AS cross_sell_achieved
    FROM brokerage
    GROUP BY account_exe_id
) b
    ON i.account_exe_id = b.account_exe_id
LEFT JOIN (
    SELECT
        account_exe_id,
        COUNT(*) AS cross_sell_new
    FROM opportunity
    WHERE stage IN ('Propose Solution', 'Qualify Opportunity')
    GROUP BY account_exe_id
) o
    ON i.account_exe_id = o.account_exe_id;

#stage funnel by revenue
select 
stage,
sum(revenue_amount) as total_revenue
from opportunity
group by stage
order by total_revenue desc;

create or replace view vw_stage_funnel_revenue as
select 
stage,
sum(revenue_amount) as total_revenue
from opportunity
group by stage
order by total_revenue desc;

# total meeting by account executive
select account_exe_id,
exe_name,
count(*)as total_meeting_count
from meeting
where meeting_date is not null
group by account_exe_id,
exe_name
order by 
total_meeting_count desc;

CREATE OR REPLACE VIEW vw_total_meeting_by_exec AS
SELECT
    account_exe_id,
    exe_name,
    COUNT(*) AS total_meeting_count
FROM meeting
WHERE meeting_date IS NOT NULL
GROUP BY
    account_exe_id,
    exe_name;
    
# top open opportunity
select account_exe_id,
exe_name,
branch,
stage,revenue_amount
from opportunity
where stage in('propose solution','qualify opportunity')
order by revenue_amount desc
limit 10;

CREATE OR REPLACE VIEW vw_top_open_opportunity AS
SELECT
    account_exe_id,
    exe_name,
    branch,
    stage,
    revenue_amount
FROM opportunity
WHERE stage IN ('Propose Solution', 'Qualify Opportunity')
ORDER BY revenue_amount DESC
LIMIT 10;

# Total Policy
select count(distinct policy_id)as total_policies
from fact_policy;

create or replace view vw_Total_Policy as
select count(distinct policy_id)as total_policies
from fact_policy;

#Total Customers
select count(distinct customer_id) as total_customer
from fact_policy;

create or replace view vw_total_customer as
select count(distinct customer_id) as total_customer
from fact_policy;

# age bucket wise policy count
describe policy_data;
select min(age) as min_age,
 max(age) as max_age
 from policy_data;
 
 select 
 case
 when age between 18 and 25 then '18-25'
 when age between 26 and 35 then '26-35'
 when age between 36 and 45 then '36-45'
 when age between 46 and 60 then '46-60'
 else '60+'
 end as age_bucket,
 count(customer_id)as policy_count
 from policy_data
 where age is not null
 group by age_bucket
 order by age_bucket;
 
 create or replace view age_bucket_policy_count as
 select 
 case
 when age between 18 and 25 then '18-25'
 when age between 26 and 35 then '26-35'
 when age between 36 and 45 then '36-45'
 when age between 46 and 60 then '46-60'
 else '60+'
 end as age_bucket,
 count(customer_id)as policy_count
 from policy_data
 where age is not null
 group by age_bucket
 order by age_bucket;
 
 # gender wise policy count
 select distinct gender from policy_data;
 select gender ,
 count(customer_id) as policy_count
 from policy_data
 group by gender
 order by policy_count desc;
 
 create or replace view vw_gender_wise_policy_count as
  select gender ,
 count(customer_id) as policy_count
 from policy_data
 group by gender
 order by policy_count desc;
 
 create or replace view gender_wise_policy_count as 
 select distinct gender from policy_data;
 select gender ,
 count(customer_id) as policy_count
 from policy_data
 group by gender
 order by policy_count desc;
 
 
# policy type wise policy count
 select policy_type,
 count(policy_id)as policy_cout
 from policy_details
 group by policy_type;
 
 create or replace view vw_policy_type_wise_policy_count as
  select policy_type,
 count(policy_id)as policy_cout
 from policy_details
 group by policy_type;
 
 # policy expiring this year
 select 
 count(policy_id) as policy_count
 from policy_details
 where year(policy_end_Date)= year(curdate()); 
 
 create or replace view vw_policy_exoiring_this_year as 
  select 
 count(policy_id) as policy_count
 from policy_details
 where year(policy_end_Date)= year(curdate()); 
 
 # premiun growth rate
 select 
 policy_start_date as year,
 sum(premium_amount) as total_amount
 from policy_details
 group by policy_start_date
 order by year;
 
 # claim status wisepolicy count
 select claim_status,
 count(policy_id) as policy_count
 from policy_claims
 group by claim_status;
 
 create or replace view vw_claim_status_wisepolicy_count as
  select claim_status,
 count(policy_id) as policy_count
 from policy_claims
 group by claim_status;
 
 # payment status wise policy count
 select payment_status,
 count(policy_id )as policy_count
 from payment_history
 group by payment_status;
 
 #total claim amount
 select claim_id,
 sum(claim_amount) as total_claim_amount
 from policy_claims
 where claim_status ='approved'
 group by claim_id;
 
 create or replace view vw_total_claim_amount as
  select claim_id,
 sum(claim_amount) as total_claim_amount
 from policy_claims
 where claim_status ='approved'
 group by claim_id;
 
 SELECT * FROM vw_inoices_count_by_exec;
 SELECT * FROM vw_total_meeting_by_exec;
 SELECT * FROM vw_yearly_meeting_total;
 SELECT * FROM vw_stage_funnel_revenue;
 SELECT * FROM vw_top_open_opportunity;
 SELECT * FROM vw_gender_wise_policy_count;
 SELECT * FROM age_bucket_policy_count;







 
 