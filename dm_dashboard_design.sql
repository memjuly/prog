
1. dm_date: campaign mail date and measurement period

create table sandbox_hchen7.dm_date (
    campaign_month_dt date, 
    target_audience string, 
    campaign_product    string,
    mail_drop_id    string,
    mail_dt date, 
    measurement_start_dt date, 
    measurement_end_dt  date
)
insert into sandbox_hchen7.dm_value values 
( '2025-10-01', 'QBO', 'Capital', 'drop1', '2025-10-06', '2025-10-09', '2025-11-07'); 


campaign_month_dt: 1st of the month that campaign runs 

mail_drop_id: sometimes multiple batches of mailing in one campaign, possible value 'drop1', 'drop2'

mail_dt: supplied by the agency 

measurement_start_dt: normally mail_dt +3d, may adjust not to overlalp with before and after period; the reason not to overlap each measurement periods because it is easy to do several months' study without double counting; 

measurement_end_dt: measurement_start_dt +29d if measure for 30 days
                    +44d if measure for 45 days 

2. dm_campaign_audience: contains all companies in each mailing

create table xxxx as 
select campaign_month_dt
, 'xxx' target_audience
, 'xxxxx' campaign_product
, segment
, product_eligitbility
, tl_eligibility
, loc_eligibility
, campaign_name
, mail_dt
, measurement_start_dt
, measurement_end_dt
, company_id
, mailed_holdout
, envelope_creative
, letter_creative
, test_group
, propensty_score_percentile
, run_date  -- the date when pulling the score percentile, use to verify score, not need in my dashboard
from source_table aa 
left join dm_date bb on
    aa.campaign_month_dt = bb.campaign_month_dt
    and bb.target_audience = 'xxx'
    and bb.campaign_product = 'xxxxx'
    and aa.date_id = bb.mail_drop_id

- join on date_id ('drop1', 'drop2') to get the dates for each product for each month
- some source file provides propensity_score_percentile, which used to show the campaign performance by decile, also can use to verify whether the stratified randomization has been done right; 
- mailed_holdout: possible value: 'mailed', 'holdout', if the holdout test, can use this field as 'test_group' to split group in mailed vs. holdout'; if it is creative test, all values will be 'mailed', then use 'letter_creative' or 'envelope_creative' to denote the test_group; 
- letter_creative: if the test on different letter creative, all values in mailed_holdout will be 'mailed', this value could be 'letter version1', 'letter version2', then use this field to supply test_group;
- envelope_creative: same as letter_creative, if the same letter but test different envelopes; 
- each test (campaign_name) could include one or multiple segments 
- campaign_name: a meaningful name for the campaign, if there is no test set up, using 'TL Rollout', then the program will just run the performance during the measurement period; if there is test, embedded word 'Test' in campaign_name such as 'TL Test', the program not only run the performance, will also output the data in the format for the A/B test calculator

3. dm_campaign_audience_count: to report the mail size of each mailing; 

drop table xxxx
create table xxxx as 
select campaign_month_dt
, 'xxx' target_audience
, 'xxxxx' as campaign_product
, segment
, product_eligibility
, campaign_name
, envelope_creative
, letter_creative
, mail_dt
, measurement_start_dt
, meausrement_end_dt
, mailed_holdout 
, count(distinct company_id) as count
from dm_campaign_audience 
group by 1 - 12
order by 1 - 12

The acutal performance data will run freshly in each update. Some original accounts may be purged due to privacy policy. Customers may opt-out after the campaign runs. So if campaign size will change with the time passed. To add this static table to keep the original campaign size count for each campaign. It helps with planning.