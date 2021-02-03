-- Queries ------------------------------------------------------------------
-- custom_sql_query (outbrain) (3) ---------------
with created_in_month AS
(
    SELECT
        YEAR(dimf_marketer_creation_date) as year_,
        MONTH(dimf_marketer_creation_date) as month_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_marketer_creation_date) as marketers_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ) , 
        
ad_created_in_month AS
(
    SELECT
        YEAR(dimf_first_ad_creation_date) as year_,
        MONTH(dimf_first_ad_creation_date) as month_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_ad_creation_date) as ads_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_ad_creation_date) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_ad_creation_date) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ) , 
        
ad_pending_in_month AS
(
    SELECT
        YEAR(dimf_first_date_pending) as year_,
        MONTH(dimf_first_date_pending) as month_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_date_pending) as ads_pending
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_date_pending) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_pending) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ) , 
        
ad_approved_in_month AS
(
    SELECT
        YEAR(dimf_first_date_approved) as year_,
        MONTH(dimf_first_date_approved) as month_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_date_approved) as ads_approved
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_date_approved) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_approved) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ),
        
first_listing_in_month AS
(
    SELECT
        YEAR(dimf_first_listing)  as year_,
        MONTH(dimf_first_listing) as month_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_listing) as listings
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_listing) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_listing) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ), 
        
        
first_click_in_month AS
(
    SELECT
        YEAR(dimf_first_click) as year_,
        MONTH(dimf_first_click) as month_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_click) as clicks
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_click) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_click) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ), 
        
        
first_spend_in_month AS
(
    SELECT
        YEAR(dimf_first_spend) as year_,
        MONTH(dimf_first_spend) as month_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_spend) as spend
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_spend) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_spend) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 )
        
select a.* , ads_created , ads_pending , ads_approved, listings, clicks, spend
from created_in_month a 
left join ad_created_in_month b on a.Self_Serve = b.Self_Serve and a.year_=b.year_ and a.month_ = b.month_
left join ad_pending_in_month c on a.Self_Serve = c.Self_Serve and a.year_=c.year_ and a.month_ = c.month_
left join ad_approved_in_month d on a.Self_Serve = d.Self_Serve and a.year_=d.year_ and a.month_ = d.month_
left join first_listing_in_month e on a.Self_Serve = e.Self_Serve and a.year_=e.year_ and a.month_ = e.month_
left join first_click_in_month f on a.Self_Serve = f.Self_Serve and a.year_=f.year_ and a.month_ = f.month_
left join first_spend_in_month g on a.Self_Serve = g.Self_Serve and a.year_=g.year_ and a.month_ = g.month_
;


-- custom_sql_query (outbrain) (5) ---------------
with created_in_month AS
(
    SELECT
        'month' as period, 
        date(date_trunc('month',dimf_marketer_creation_date))         as dates,
        
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_marketer_creation_date) as marketers_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6) , 
        
ad_created_in_month AS
(
    SELECT
        'month' as period, 
        date(date_trunc('month',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_ad_creation_date) as ads_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_ad_creation_date) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_ad_creation_date) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6) , 
        
ad_pending_in_month AS
(
    SELECT
        'month' as period, 
        date(date_trunc('month',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_date_pending) as ads_pending
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_date_pending) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_pending) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3 ,4,5,6) , 
        
ad_approved_in_month AS
(
    SELECT
        'month' as period, 
        date(date_trunc('month',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_date_approved) as ads_approved
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_date_approved) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_approved) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3 , 4,5,6),
        
first_listing_in_month AS
(
    SELECT
        'month' as period, 
        date(date_trunc('month',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_listing) as listings
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_listing) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_listing) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ), 
              
        
first_spend_in_month AS
(
    SELECT
        'month' as period, 
        date(date_trunc('month',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_spend) as spend
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        MONTH(dimf_first_spend) = MONTH(dimf_marketer_creation_date)
    AND YEAR(dimf_first_spend) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,6 ),
---------------------------       
created_in_week AS
(
    SELECT
  'week' as period, 
    date(date_trunc('week',dimf_marketer_creation_date + interval '1 day')- interval '1 day')       as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                          dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,  
            
            
            
        COUNT(dimf_marketer_creation_date) as marketers_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ) , 
        
ad_created_in_week AS
(
    SELECT
  'week' as period, 
     date(date_trunc('week',dimf_marketer_creation_date + interval '1 day')- interval '1 day')       as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_ad_creation_date) as ads_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_ad_creation_date) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_ad_creation_date) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6            
    ORDER BY
        1,2,3,4,5,6 ) , 
        
ad_pending_in_week AS
(
    SELECT
  'week' as period, 
     date(date_trunc('week',dimf_marketer_creation_date + interval '1 day')- interval '1 day')       as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_date_pending) as ads_pending
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_date_pending) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_pending) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ) , 
        
ad_approved_in_week AS
(
    SELECT
  'week' as period, 
    date(date_trunc('week',dimf_marketer_creation_date + interval '1 day')- interval '1 day')       as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_date_approved) as ads_approved
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_date_approved) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_approved) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ),
        
first_listing_in_week AS
(
    SELECT
  'week' as period, 
       date(date_trunc('week',dimf_marketer_creation_date + interval '1 day')- interval '1 day')       as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_listing) as listings
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_listing) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_listing) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ), 
        
        

        
first_spend_in_week AS
(
    SELECT
  'week' as period, 
 date(date_trunc('week',dimf_marketer_creation_date + interval '1 day')- interval '1 day')       as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_spend) as spend
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_spend) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_spend) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3 ,4,5,6),

---------------------------       
created_in_quarter AS
(
    SELECT
  'quarter' as period, 
        date(date_trunc('quarter',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_marketer_creation_date) as marketers_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3 ,4,5,6) , 
        
ad_created_in_quarter AS
(
    SELECT
  'quarter' as period, 
        date(date_trunc('quarter',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_ad_creation_date) as ads_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        quarter(dimf_first_ad_creation_date) = quarter(dimf_marketer_creation_date)
    AND YEAR(dimf_first_ad_creation_date) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ) , 
        
ad_pending_in_quarter AS
(
    SELECT
  'quarter' as period, 
        date(date_trunc('quarter',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_date_pending) as ads_pending
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        quarter(dimf_first_date_pending) = quarter(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_pending) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3 ,4,5,6) , 
        
ad_approved_in_quarter AS
(
    SELECT
  'quarter' as period, 
        date(date_trunc('quarter',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_date_approved) as ads_approved
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
       quarter(dimf_first_date_approved) = quarter(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_approved) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ),
        
first_listing_in_quarter AS
(
    SELECT
  'quarter' as period, 
        date(date_trunc('quarter',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_listing) as listings
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        quarter(dimf_first_listing) = quarter(dimf_marketer_creation_date)
    AND YEAR(dimf_first_listing) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 ), 
        
        

        
first_spend_in_quarter AS
(
    SELECT
  'quarter' as period, 
        date(date_trunc('quarter',dimf_marketer_creation_date))         as dates,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
                            dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(dimf_first_spend) as spend
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
       quarter(dimf_first_spend) = quarter(dimf_marketer_creation_date)
    AND YEAR(dimf_first_spend) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        1,2,3,4,5,6 )











select a.* , ads_created , ads_pending , ads_approved, listings,  spend
from created_in_month a 
left join ad_created_in_month b on a.Self_Serve = b.Self_Serve and a.dates=b.dates and a.country_name = b.country_name
and a.country_sales = b.country_sales
and a.type_ = b.type_
left join ad_pending_in_month c on a.Self_Serve = c.Self_Serve and a.dates=c.dates and a.country_name = c.country_name
and a.country_sales = c.country_sales
and a.type_ = c.type_
left join ad_approved_in_month d on a.Self_Serve = d.Self_Serve and a.dates=d.dates and a.country_name = d.country_name
and a.country_sales = d.country_sales
and a.type_ = d.type_
left join first_listing_in_month e on a.Self_Serve = e.Self_Serve and a.dates=e.dates and a.country_name = e.country_name
and a.country_sales = e.country_sales
and a.type_ = e.type_
left join first_spend_in_month g on a.Self_Serve = g.Self_Serve and a.dates=g.dates and a.country_name = g.country_name
and a.country_sales = g.country_sales
and a.type_ = g.type_


union 


select a.* , ads_created , ads_pending , ads_approved, listings, spend
from created_in_week a 
left join ad_created_in_week b on a.Self_Serve = b.Self_Serve and a.dates=b.dates and a.country_name = b.country_name
and a.country_sales = b.country_sales
and a.type_ = b.type_
left join ad_pending_in_week c on a.Self_Serve = c.Self_Serve and a.dates=c.dates and a.country_name = c.country_name
and a.country_sales = c.country_sales
and a.type_ = c.type_
left join ad_approved_in_week d on a.Self_Serve = d.Self_Serve and a.dates=d.dates and a.country_name = d.country_name
and a.country_sales = d.country_sales
and a.type_ = d.type_
left join first_listing_in_week e on a.Self_Serve = e.Self_Serve and a.dates=e.dates and a.country_name = e.country_name
and a.country_sales = e.country_sales
and a.type_ = e.type_
left join first_spend_in_week g on a.Self_Serve = g.Self_Serve and a.dates=g.dates and a.country_name = g.country_name
and a.country_sales = g.country_sales
and a.type_ = g.type_


union 



select a.* , ads_created , ads_pending , ads_approved, listings, spend
from created_in_quarter a 
left join ad_created_in_quarter b on a.Self_Serve = b.Self_Serve and a.dates=b.dates and a.country_name = b.country_name
and a.country_sales = b.country_sales
and a.type_ = b.type_
left join ad_pending_in_quarter c on a.Self_Serve = c.Self_Serve and a.dates=c.dates and a.country_name = c.country_name
and a.country_sales = c.country_sales
and a.type_ = c.type_
left join ad_approved_in_quarter d on a.Self_Serve = d.Self_Serve and a.dates=d.dates and a.country_name = d.country_name
and a.country_sales = d.country_sales
and a.type_ = d.type_
left join first_listing_in_quarter e on a.Self_Serve = e.Self_Serve and a.dates=e.dates and a.country_name = e.country_name
and a.country_sales = e.country_sales
and a.type_ = e.type_
left join first_spend_in_quarter g on a.Self_Serve = g.Self_Serve and a.dates=g.dates and a.country_name = g.country_name
and a.country_sales = g.country_sales
and a.type_ = g.type_
;


-- custom_sql_query (outbrain) -------------------
WITH ad_creation_over_28_days AS
(
    SELECT
        28 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_created
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    AND DATE(dimf_first_ad_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')


    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_pending_over_28_days AS
(
    SELECT
        28 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_pending
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    AND DATE(dimf_first_date_pending) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_approved_over_28_days AS
(
    SELECT
        28 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_approved
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    AND DATE(dimf_first_date_approved) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , spend_over_28_days AS
(
    SELECT
        28 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_spend
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    AND DATE(dimf_first_spend) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , listing_over_28_days AS
(
    SELECT
        28 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        COUNT(DISTINCT dimf_marketer_id)            AS num_listing
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    AND DATE(dimf_first_listing) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , click_over_28_days AS
(
    SELECT
        28 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        d.rfcl_date                                 AS date_,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_click
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    AND DATE(dimf_first_click) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , created_over_28_days AS
(
    SELECT
        28                AS days_back,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        d.rfcl_date       AS date_,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_created
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 27 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_creation_over_14_days AS
(
    SELECT
        14 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_created
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    AND DATE(dimf_first_ad_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_pending_over_14_days AS
(
    SELECT
        14 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_pending
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    AND DATE(dimf_first_date_pending) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_approved_over_14_days AS
(
    SELECT
        14 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_approved
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    AND DATE(dimf_first_date_approved) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , spend_over_14_days AS
(
    SELECT
        14 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_spend
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    AND DATE(dimf_first_spend) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , listing_over_14_days AS
(
    SELECT
        14 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        COUNT(DISTINCT dimf_marketer_id)            AS num_listing
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    AND DATE(dimf_first_listing) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , click_over_14_days AS
(
    SELECT
        14 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        d.rfcl_date                                 AS date_,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_click
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    AND DATE(dimf_first_click) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , created_over_14_days AS
(
    SELECT
        14                AS days_back,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        d.rfcl_date       AS date_,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_created
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 13 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_creation_over_7_days AS
(
    SELECT
        7 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_created
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    AND DATE(dimf_first_ad_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_pending_over_7_days AS
(
    SELECT
        7 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_pending
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    AND DATE(dimf_first_date_pending) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_approved_over_7_days AS
(
    SELECT
        7 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_approved
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    AND DATE(dimf_first_date_approved) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , spend_over_7_days AS
(
    SELECT
        7 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_spend
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    AND DATE(dimf_first_spend) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , listing_over_7_days AS
(
    SELECT
        7 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        COUNT(DISTINCT dimf_marketer_id)            AS num_listing
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    AND DATE(dimf_first_listing) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , click_over_7_days AS
(
    SELECT
        7 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        d.rfcl_date                                 AS date_,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_click
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    AND DATE(dimf_first_click) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1     AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , created_over_7_days AS
(
    SELECT
        7                 AS days_back,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        d.rfcl_date       AS date_,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_created
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) BETWEEN d.rfcl_date - 6 AND d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_creation_over_1_days AS
(
    SELECT
        1 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_created
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) = d.rfcl_date
    AND DATE(dimf_first_ad_creation_date) = d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_pending_over_1_days AS
(
    SELECT
        1 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_pending
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) = d.rfcl_date
    AND DATE(dimf_first_date_pending) = d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , ad_approved_over_1_days AS
(
    SELECT
        1 AS days_back,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        d.rfcl_date                                 AS date_,
        COUNT(DISTINCT dimf_marketer_id)            AS num_ad_approved
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        DATE(dimf_marketer_creation_date) = d.rfcl_date
    AND DATE(dimf_first_date_approved) = d.rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        rfcl_date >'2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    GROUP BY
        1,2,3,4,5,6
    ORDER BY
        2 ) , spend_over_1_days AS
(
    SELECT
        1         AS days_back,
        rfcl_date AS date_,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        COUNT(DISTINCT dimf_marketer_id)            AS num_spend
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        dimf_marketer_creation_date = rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        dimf_marketer_creation_date = rfcl_date
    AND dimf_first_spend = rfcl_date
    AND rfcl_date >='2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    GROUP BY
        1,2,3,4,5,6 ) , listing_over_1_days AS
(
    SELECT
        1         AS days_back,
        rfcl_date AS date_,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        COUNT(DISTINCT dimf_marketer_id)            AS num_listing
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        dimf_marketer_creation_date = rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        dimf_marketer_creation_date = rfcl_date
    AND dimf_first_listing = rfcl_date
    AND rfcl_date >='2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    GROUP BY
        1,2,3,4,5,6 ) , click_over_1_days AS
(
    SELECT
        1         AS days_back,
        rfcl_date AS date_,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        COUNT(DISTINCT dimf_marketer_id)            AS num_click
    FROM
        dimf_marketer_first_event
    JOIN
        rfcl_calendar d
    ON
        dimf_marketer_creation_date = rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        dimf_marketer_creation_date = rfcl_date
    AND dimf_first_click = rfcl_date
    AND rfcl_date >='2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    GROUP BY
        1,2,3,4,5,6 ) , created_over_1_days AS
(
    SELECT
        1         AS days_back,
        rfcl_date AS date_,
        CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve'
        END                                         AS Self_Serve,
        dima_country_name AS country_name, dima_sales_rep_location_name AS country_sales,
        dima_type_name || '_' || dima_sub_type_name AS type_,
        COUNT(DISTINCT a.dimf_marketer_id)          AS num_created
    FROM
        dimf_marketer_first_event a
    JOIN
        rfcl_calendar d
    ON
        a.dimf_marketer_creation_date = rfcl_date
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        a.dimf_marketer_creation_date = rfcl_date
    AND rfcl_date >='2010-01-01'
    AND rfcl_date <=CURRENT_DATE-1
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3,4,5,6 )
SELECT
    a.days_back,
    a.date_ ,
    a.Self_Serve,
    a.country_name,
    a.country_sales,
    a.type_,
    ifnull(a.num_created/28,0)     AS num_created,
    ifnull(e.num_ad_created/28,0)  AS num_ad_created,
    ifnull(f.num_ad_pending/28,0)  AS num_ad_pending,
    ifnull(g.num_ad_approved/28,0) AS num_ad_approved,
    ifnull(c.num_listing/28,0)     AS num_listing,
    ifnull(b.num_spend/28,0)       AS num_spend,
    ifnull(d.num_click/28,0)       AS num_click
FROM
    created_over_28_days a
LEFT JOIN
    ad_creation_over_28_days e
ON
    a.days_back = e.days_back
AND a.date_ = e.date_
AND a.Self_Serve = e.Self_Serve
AND a.country_name = e.country_name
AND a.type_ = e.type_
LEFT JOIN
    ad_pending_over_28_days f
ON
    a.days_back = f.days_back
AND a.date_ = f.date_
AND a.Self_Serve = f.Self_Serve
AND a.country_name = f.country_name
AND a.type_ = f.type_
AND a.country_sales = f.country_sales

LEFT JOIN
    ad_approved_over_28_days g
ON
    a.days_back = g.days_back
AND a.date_ = g.date_
AND a.Self_Serve = g.Self_Serve
AND a.country_name = g.country_name
AND a.type_ = g.type_
AND a.country_sales = g.country_sales

LEFT JOIN
    spend_over_28_days b
ON
    a.days_back = b.days_back
AND a.date_ = b.date_
AND a.Self_Serve = b.Self_Serve
AND a.country_name = b.country_name
AND a.type_ = b.type_
AND a.country_sales = b.country_sales

LEFT JOIN
    listing_over_28_days c
ON
    a.days_back = c.days_back
AND a.date_ = c.date_
AND a.Self_Serve = c.Self_Serve
AND a.country_name = c.country_name
AND a.type_ = c.type_
AND a.country_sales = c.country_sales

LEFT JOIN
    click_over_28_days d
ON
    a.days_back = d.days_back
AND a.date_ = d.date_
AND a.Self_Serve = d.Self_Serve
AND a.country_name = d.country_name
AND a.type_ = d.type_
AND a.country_sales = d.country_sales

WHERE
    a.type_ NOT ILIKE '%OPA%'
UNION
SELECT
    a.days_back,
    a.date_ ,
    a.Self_Serve,
    a.country_name,
    a.country_sales,
    a.type_,
    ifnull(a.num_created/14,0)     AS num_created,
    ifnull(e.num_ad_created/14,0)  AS num_ad_created,
    ifnull(f.num_ad_pending/14,0)  AS num_ad_pending,
    ifnull(g.num_ad_approved/14,0) AS num_ad_approved,
    ifnull(c.num_listing/14,0)     AS num_listing,
    ifnull(b.num_spend/14,0)       AS num_spend,
    ifnull(d.num_click/14,0)       AS num_click
FROM
    created_over_14_days a
LEFT JOIN
    ad_creation_over_14_days e
ON
    a.days_back = e.days_back
AND a.date_ = e.date_
AND a.Self_Serve = e.Self_Serve
AND a.country_name = e.country_name
AND a.type_ = e.type_
AND a.country_sales = e.country_sales

LEFT JOIN
    ad_pending_over_14_days f
ON
    a.days_back = f.days_back
AND a.date_ = f.date_
AND a.Self_Serve = f.Self_Serve
AND a.country_name = f.country_name
AND a.country_sales = f.country_sales

AND a.type_ = f.type_
LEFT JOIN
    ad_approved_over_14_days g
ON
    a.days_back = g.days_back
AND a.date_ = g.date_
AND a.Self_Serve = g.Self_Serve
AND a.country_name = g.country_name
AND a.type_ = g.type_
AND a.country_sales = g.country_sales

LEFT JOIN
    spend_over_14_days b
ON
    a.days_back = b.days_back
AND a.date_ = b.date_
AND a.Self_Serve = b.Self_Serve
AND a.country_name = b.country_name
AND a.type_ = b.type_
AND a.country_sales = b.country_sales

LEFT JOIN
    listing_over_14_days c
ON
    a.days_back = c.days_back
AND a.date_ = c.date_
AND a.Self_Serve = c.Self_Serve
AND a.country_name = c.country_name
AND a.type_ = c.type_
AND a.country_sales = c.country_sales

LEFT JOIN
    click_over_14_days d
ON
    a.days_back = d.days_back
AND a.date_ = d.date_
AND a.Self_Serve = d.Self_Serve
AND a.country_name = d.country_name
AND a.type_ = d.type_
AND a.country_sales = d.country_sales

WHERE
    a.type_ NOT ILIKE '%OPA%'
UNION
SELECT
    a.days_back,
    a.date_ ,
    a.Self_Serve,
    a.country_name,
    a.country_sales,
    a.type_,
    ifnull(a.num_created/7,0)     AS num_created,
    ifnull(e.num_ad_created/7,0)  AS num_ad_created,
    ifnull(f.num_ad_pending/7,0)  AS num_ad_pending,
    ifnull(g.num_ad_approved/7,0) AS num_ad_approved,
    ifnull(c.num_listing/7,0)     AS num_listing,
    ifnull(b.num_spend/7,0)       AS num_spend,
    ifnull(d.num_click/7,0)       AS num_click
FROM
    created_over_7_days a
LEFT JOIN
    ad_creation_over_7_days e
ON
    a.days_back = e.days_back
AND a.date_ = e.date_
AND a.Self_Serve = e.Self_Serve
AND a.country_name = e.country_name
AND a.type_ = e.type_
AND a.country_sales = e.country_sales

LEFT JOIN
    ad_pending_over_7_days f
ON
    a.days_back = f.days_back
AND a.date_ = f.date_
AND a.Self_Serve = f.Self_Serve
AND a.country_name = f.country_name
AND a.type_ = f.type_
AND a.country_sales = f.country_sales

LEFT JOIN
    ad_approved_over_7_days g
ON
    a.days_back = g.days_back
AND a.date_ = g.date_
AND a.Self_Serve = g.Self_Serve
AND a.country_name = g.country_name
AND a.type_ = g.type_
AND a.country_sales = g.country_sales

LEFT JOIN
    spend_over_7_days b
ON
    a.days_back = b.days_back
AND a.date_ = b.date_
AND a.Self_Serve = b.Self_Serve
AND a.country_name = b.country_name
AND a.type_ = b.type_
AND a.country_sales = b.country_sales

LEFT JOIN
    listing_over_7_days c
ON
    a.days_back = c.days_back
AND a.date_ = c.date_
AND a.Self_Serve = c.Self_Serve
AND a.country_name = c.country_name
AND a.type_ = c.type_
AND a.country_sales = c.country_sales

LEFT JOIN
    click_over_7_days d
ON
    a.days_back = d.days_back
AND a.date_ = d.date_
AND a.Self_Serve = d.Self_Serve
AND a.country_name = d.country_name
AND a.type_ = d.type_
AND a.country_sales = d.country_sales

WHERE
    a.type_ NOT ILIKE '%OPA%'
UNION
SELECT
    a.days_back,
    a.date_ ,
    a.Self_Serve,
    a.country_name,
a.country_sales,
    a.type_,
    ifnull(a.num_created,0)     AS num_created,
    ifnull(e.num_ad_created,0)  AS num_ad_created,
    ifnull(f.num_ad_pending,0)  AS num_ad_pending,
    ifnull(g.num_ad_approved,0) AS num_ad_approved,
    ifnull(c.num_listing,0)     AS num_listing,
    ifnull(b.num_spend,0)       AS num_spend,
    ifnull(d.num_click,0)       AS num_click
FROM
    created_over_1_days a
LEFT JOIN
    ad_creation_over_1_days e
ON
    a.days_back = e.days_back
AND a.date_ = e.date_
AND a.Self_Serve = e.Self_Serve
AND a.country_name = e.country_name
AND a.type_ = e.type_
AND a.country_sales = e.country_sales

LEFT JOIN
    ad_pending_over_1_days f
ON
    a.days_back = f.days_back
AND a.date_ = f.date_
AND a.Self_Serve = f.Self_Serve
AND a.country_name = f.country_name
AND a.type_ = f.type_
AND a.country_sales = f.country_sales

LEFT JOIN
    ad_approved_over_1_days g
ON
    a.days_back = g.days_back
AND a.date_ = g.date_
AND a.Self_Serve = g.Self_Serve
AND a.country_name = g.country_name
AND a.type_ = g.type_
AND a.country_sales = g.country_sales

LEFT JOIN
    spend_over_1_days b
ON
    a.days_back = b.days_back
AND a.date_ = b.date_
AND a.Self_Serve = b.Self_Serve
AND a.country_name = b.country_name
AND a.type_ = b.type_
AND a.country_sales = b.country_sales

LEFT JOIN
    listing_over_1_days c
ON
    a.days_back = c.days_back
AND a.date_ = c.date_
AND a.Self_Serve = c.Self_Serve
AND a.country_name = c.country_name
AND a.type_ = c.type_
AND a.country_sales = c.country_sales

LEFT JOIN
    click_over_1_days d
ON
    a.days_back = d.days_back
AND a.date_ = d.date_
AND a.Self_Serve = d.Self_Serve
AND a.country_name = d.country_name
AND a.type_ = d.type_
AND a.country_sales = d.country_sales

WHERE
    a.type_ NOT ILIKE '%OPA%'
ORDER BY
    1 DESC,
    2 ,
    3
;


-- custom_sql_query (outbrain) (6) ---------------
select *, 
datediff('day',creation_date,spend_date) as days_between,
case when   revenue>0 then SUM(COALESCE(revenue,0)) 
            OVER( PARTITION BY date_trunc('month',creation_date) ORDER BY days_group asc)
            else 0 end
            as cumulative_spend
from
(select *,
case when datediff('day',creation_date,spend_date)<=4 then '1'
when datediff('day',creation_date,spend_date)>4 and datediff('day',creation_date,spend_date)<=9 then '2'
when datediff('day',creation_date,spend_date)>9 and datediff('day',creation_date,spend_date)<=14 then '3' 
when datediff('day',creation_date,spend_date)>14 and datediff('day',creation_date,spend_date)<=29 then '4' 
when datediff('day',creation_date,spend_date)>29 and datediff('day',creation_date,spend_date)<=59 then '5'
when datediff('day',creation_date,spend_date)>59 and datediff('day',creation_date,spend_date)<=89 then '6'
else '7' end as days_group
from
(SELECT
    dima_id,
    --date(DATE_TRUNC('MONTH', dima_creation_date))             as creation_date,
    date(facm_est_stats_date)                                   as spend_date,
    date(dima_creation_date)                                    as creation_date,
    dima_vertical                                               AS vertical,
    DIMA_MARKETER.DIMA_ACCOUNT_MANAGER_NAME,
    DIMA_MARKETER.DIMA_TYPE_NAME                                as account_tier,                 
    DIMA_sales_rep_location_name,
    dima_marketer.dima_country_name                             AS marketer_location,
    dima_marketer.dima_sales_rep_name                           AS sales_rep_name,
    min(first_day)                                              as first_day,
    SUM(facm_campaign_traffic_d.facm_gross_revenue)             AS revenue,
    SUM(facm_campaign_traffic_d.facm_num_paid_clicks)           AS clicks,
    SUM(facm_campaign_traffic_d.facm_num_served_paid_listings)  AS listings
    
FROM
    outbrain.facm_campaign_traffic_d
JOIN
    outbrain.dima_marketer
 ON
    facm_campaign_traffic_d.facm_marketer_id=dima_id
join (select facm_campaign_traffic_d.facm_marketer_id, 
             date(min(facm_campaign_traffic_d.facm_est_stats_date)) as first_day
      from facm_campaign_traffic_d
      where facm_gross_revenue>0
      group by 1) first
on facm_campaign_traffic_d.facm_marketer_id=first.facm_marketer_id
WHERE
     dima_marketer.dima_acquisition_channel_name ilike 
      '%Self-Serve%' 
      and date_trunc('month',dima_creation_date)>='2018-01-01' 
GROUP BY
    1,2,3,4,5,6,7,8,9
having SUM(facm_campaign_traffic_d.facm_gross_revenue)>0

    ) a  
--where 
--datediff('day',creation_date,spend_date)<=360

) a
;


-- custom_sql_query (outbrain) (2) ---------------
with

created as ( SELECT
    dimf_marketer_creation_date,
    CASE
        WHEN dima_acquisition_channel_name != 'Self-Serve'
        THEN 'Managed'
        ELSE 'Self-Serve'
    END                                         AS Self_Serve,
    dima_country_name                           AS country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
    COUNT(dimf_marketer_id)                     AS marketer_created
FROM
    dimf_marketer_first_event
LEFT JOIN
    dima_marketer
ON
    dima_id = dimf_marketer_id
WHERE
    (
        dima_sub_type_name NOT ILIKE '%OPA%'
    AND dima_operational_type != 8
    AND dima_name NOT ilike '%zemanta%')
GROUP BY
    1,2,3,4,5) , 

ad_created as (SELECT
    dimf_first_ad_creation_date,
    CASE
        WHEN dima_acquisition_channel_name != 'Self-Serve'
        THEN 'Managed'
        ELSE 'Self-Serve'
    END                                         AS Self_Serve,
   dima_country_name as country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,

    COUNT(dimf_marketer_id)                     AS ads_created
FROM
    dimf_marketer_first_event
left JOIN
    dima_marketer
ON
    dima_id = dimf_marketer_id
WHERE
    (
        dima_sub_type_name NOT ILIKE '%OPA%'
    AND dima_operational_type != 8
    AND dima_name NOT ilike '%zemanta%')
GROUP BY
    1,2,3 ,4,5), 

ad_approved as ( select dimf_first_date_approved,   CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve,    dima_country_name as country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
            
            count(dimf_marketer_id) as ads_approuved 
            

from dimf_marketer_first_event
right join rfcl_calendar on rfcl_date = dimf_first_date_approved
join dima_marketer on dima_id = dimf_marketer_id
where     (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

group by 1,2,3,4,5 ), 

ad_spend as  ( select dimf_first_spend,   CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve,   dima_country_name as country_name,
    dima_sales_rep_location_name                AS country_sales,
    dima_type_name || '_' || dima_sub_type_name AS type_,
            
             count(dimf_marketer_id) as ads_spend
            

from dimf_marketer_first_event
right join rfcl_calendar on rfcl_date = dimf_first_spend
join dima_marketer on dima_id = dimf_marketer_id
where     (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')

group by 1,2,3,4,5 )

SELECT
    a.*,
    ads_created,
    ads_approuved,
    ads_spend
FROM
    created a
LEFT JOIN
    ad_created b
ON
    a.dimf_marketer_creation_date = b.dimf_first_ad_creation_date
AND a.Self_Serve = b.Self_Serve
and a.country_name = b.country_name
and a.country_sales = b.country_sales
and a.type_ = b.type_
LEFT JOIN
    ad_approved c
ON
    a.dimf_marketer_creation_date = c.dimf_first_date_approved
    and a.country_name = c.country_name
and a.country_sales = c.country_sales
and a.type_ = c.type_
AND a.Self_Serve = c.Self_Serve
LEFT JOIN
    ad_spend d
ON
    a.dimf_marketer_creation_date = d.dimf_first_spend
    and a.country_name = d.country_name
and a.country_sales = d.country_sales
and a.type_ = d.type_
AND a.Self_Serve = d.Self_Serve
;


-- custom_sql_query (outbrain) (4) ---------------
with created_in_week AS
(
    SELECT
        YEAR(dimf_marketer_creation_date) as year_,
        WEEK(dimf_marketer_creation_date) as week_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_marketer_creation_date) as marketers_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ) , 
        
ad_created_in_week AS
(
    SELECT
        YEAR(dimf_first_ad_creation_date) as year_,
        WEEK(dimf_first_ad_creation_date) as week_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_ad_creation_date) as ads_created
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_ad_creation_date) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_ad_creation_date) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ) , 
        
ad_pending_in_week AS
(
    SELECT
        YEAR(dimf_first_date_pending) as year_,
        WEEK(dimf_first_date_pending) as week_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_date_pending) as ads_pending
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_date_pending) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_pending) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ) , 
        
ad_approved_in_week AS
(
    SELECT
        YEAR(dimf_first_date_approved) as year_,
        WEEK(dimf_first_date_approved) as week_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_date_approved) as ads_approved
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_date_approved) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_date_approved) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ),
        
first_listing_in_week AS
(
    SELECT
        YEAR(dimf_first_listing)  as year_,
        WEEK(dimf_first_listing) as week_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_listing) as listings
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_listing) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_listing) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ), 
        
        
first_click_in_week AS
(
    SELECT
        YEAR(dimf_first_click) as year_,
        WEEK(dimf_first_click) as week_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_click) as clicks
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_click) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_click) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 ), 
        
        
first_spend_in_week AS
(
    SELECT
        YEAR(dimf_first_spend) as year_,
        WEEK(dimf_first_spend) as week_,
         CASE
            WHEN dima_acquisition_channel_name != 'Self-Serve'
            THEN 'Managed'
            ELSE 'Self-Serve' end as Self_Serve, 
        COUNT(dimf_first_spend) as spend
    FROM
        dimf_marketer_first_event
    JOIN
        dima_marketer
    ON
        dima_id = dimf_marketer_id
    WHERE
        WEEK(dimf_first_spend) = WEEK(dimf_marketer_creation_date)
    AND YEAR(dimf_first_spend) = YEAR(dimf_marketer_creation_date)
    AND (
            dima_sub_type_name NOT ILIKE '%OPA%'
        AND dima_operational_type != 8
        AND dima_name NOT ilike '%zemanta%')
    GROUP BY
        1,2,3
    ORDER BY
        1,2,3 )
        
select a.* , ads_created , ads_pending , ads_approved, listings, clicks, spend
from created_in_week a 
left join ad_created_in_week b on a.Self_Serve = b.Self_Serve and a.year_=b.year_ and a.week_ = b.week_
left join ad_pending_in_week c on a.Self_Serve = c.Self_Serve and a.year_=c.year_ and a.week_ = c.week_
left join ad_approved_in_week d on a.Self_Serve = d.Self_Serve and a.year_=d.year_ and a.week_ = d.week_
left join first_listing_in_week e on a.Self_Serve = e.Self_Serve and a.year_=e.year_ and a.week_ = e.week_
left join first_click_in_week f on a.Self_Serve = f.Self_Serve and a.year_=f.year_ and a.week_ = f.week_
left join first_spend_in_week g on a.Self_Serve = g.Self_Serve and a.year_=g.year_ and a.week_ = g.week_
;


