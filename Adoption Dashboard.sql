-- Queries ------------------------------------------------------------------
-- CBS  ------------------------------------------
WITH calender as
    (
    SELECT min(start_date)  AS start_date ,
           max(end_date)    AS end_Date
    FROM
    (SELECT date_trunc('week', rfcl_date) AS Week , count(distinct rfcl_date), min(rfcl_date) AS start_date, max(rfcl_date) as end_date
    FROM rfcl_calendar WHERE rfcl_date between current_date -35 and current_date -1 GROUP BY 1 HAVING count(distinct rfcl_date) = 7 ) calender
    )
, Campaign_List AS
    (
    SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
       facm_campaign_id                             AS Campaign_ID,
       SUM(facm_gross_revenue)                      AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1 , 2
    HAVING SUM(facm_gross_revenue) > 10
    )
,dima_small AS
    (
    SELECT dima_id,
           dima_type_name,
           dima_sales_rep_location_name
    FROM dima_marketer
    --join (select distinct marketer_id from Campaign_List) d on marketer_id = dima_id
    )
, con AS
    (
     SELECT  c.Week_Number,
             c.Marketer_ID,
             CASE WHEN Total_Conversions > 0 THEN 1 ELSE 0 END AS IS_CON
      FROM
          (
          SELECT DATE_TRUNC('WEEK',COALESCE(famc_event_date, famc_est_stats_date)) AS Week_Number,
                        famc_marketer_id                                           AS Marketer_ID,
                        SUM(famc_num_conversions)                                  AS Total_Conversions
          FROM famc_multiple_conversion_click_listing_traffic famc
          JOIN dimc_multiple_conversion ON dimc_id = famc_conversion_id
          JOIN Campaign_List cl on cl.Campaign_ID = famc_campaign_id
          WHERE DATE(COALESCE(famc_event_date, famc_est_stats_date))>= (SELECT start_date from calender)
           and DATE(COALESCE(famc_event_date, famc_est_stats_date)) <= (SELECT end_date from calender)
           AND dimc_count_as_conversion = 'true'
          GROUP BY 1 , 2
          ) c
    )
    , small_facm AS
    (
        select k.*, h.*,
               dima_type_name,
               dima_sales_rep_location_name
        from (
                 SELECT facm.facm_est_stats_date,
                        facm.facm_kpio_activation_mode,
                        facm.facm_marketer_id        AS Marketer_ID,
                        facm_campaign_id             AS Campaign_ID,
                        SUM(facm.facm_gross_revenue) AS Campaign_Weekly_GR
                 FROM facm_campaign_traffic_d facm
                 JOIN Campaign_List on Campaign_ID = facm_campaign_id and Campaign_List.Week_Number = DATE_TRUNC('Week',facm.facm_est_stats_date)
                 WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
                   and facm_est_stats_date <= (SELECT end_date from calender)
                 GROUP BY 1, 2, 3, 4
             ) k
        join dima_small on Marketer_ID = dima_id
        JOIN (
            SELECT hics.hics_stats_date,
                   hics.hics_campaign_id,
                   hics.hics_campaign_performance_optimization_type
            FROM hics_campaign_settings_d hics
            WHERE hics.hics_stats_date >= (SELECT start_date from calender)
              and hics_stats_date <= (SELECT end_date from calender)
            ) h
        on k.facm_est_stats_date = h.hics_stats_date
        and k.Campaign_ID = h.hics_campaign_id
    )


,ALL_Counts AS
    (
        SELECT DATE_TRUNC('WEEK', small_facm.facm_est_stats_date) AS Week_Number,
               dima_sales_rep_location_name                       AS Location,
               dima_type_name                                     AS Marketer_Type,
               NVL(IS_CON,0)                                      AS IS_CON,
               COUNT(DISTINCT small_facm.Marketer_ID)             AS Q_ALL,
               SUM(Campaign_Weekly_GR)                            AS S_ALL
        FROM small_facm
        left join con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
        GROUP BY 1, 2, 3 , 4
    )
SELECT DISTINCT ALL_COUNTS.Week_Number,
                ALL_Counts.Location,
                ALL_COUNTS.Marketer_Type,
                ALL_Counts.IS_CON,
                ALL_COUNTS.Q_all,
                ALL_COUNTS.S_all,
                Q_CBS,
                S_CBS,
                Q_Semi,
                S_Semi,
                Q_Fully,
                S_Fully,
                Q_CPA,
                S_CPA,
                Q_ROAS,
                S_ROAS
FROM ALL_COUNTS

LEFT JOIN
--CBS--------------------------------------------------------------------------------------------------------
 (
     SELECT traffic_CBS.Week_Number                         AS Week_Number,
            dima.dima_sales_rep_location_name   AS Location,
            dima.dima_type_name                 AS Marketer_Type,
            NVL(IS_CON,0)                       AS IS_CON,
            COUNT(DISTINCT traffic_CBS.Marketer_ID)         AS Q_CBS,
            SUM(Campaign_Weekly_GR)             AS S_CBS
     FROM (
              SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
                     facm.facm_marketer_id                        AS Marketer_ID,
                     SUM(facm.facm_gross_revenue)                 AS Campaign_Weekly_GR
              FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
              JOIN Campaign_List cl on cl.Campaign_ID = facm_campaign_id and cl.Week_Number = DATE_TRUNC('WEEK', facm.facm_est_stats_date)
              WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
                and facm_est_stats_date <= (SELECT end_date from calender)
                and facm_kpio_activation_mode > 0
              GROUP BY 1, 2
          ) traffic_CBS
      JOIN dima_small dima on dima.dima_id = traffic_CBS.Marketer_ID
      left JOIN con on con.Week_Number = traffic_CBS.Week_Number and con.Marketer_ID = traffic_CBS.Marketer_ID

     GROUP BY 1, 2, 3 , 4
 ) CBS
on CBS.Week_Number = ALL_COUNTS.Week_Number
and CBS.Marketer_Type = ALL_COUNTS.Marketer_Type
and cbs.Location = ALL_Counts.Location
and cbs.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Semi--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Semi,
            SUM(small_facm.Campaign_Weekly_GR)  AS S_Semi
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_campaign_performance_optimization_type = 'Conversion - CPC'
 and facm_kpio_activation_mode >0
 GROUP BY 1, 2, 3, 4
) as Semi
on Semi.Week_Number = ALL_COUNTS.Week_Number
and Semi.Marketer_Type = ALL_COUNTS.Marketer_Type
and Semi.Location = ALL_Counts.Location
and Semi.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Fully--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Fully,
        SUM(small_facm.Campaign_Weekly_GR)      AS S_Fully
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_campaign_performance_optimization_type = 'Max Convs-Fully Auto'
  and facm_kpio_activation_mode >0
 GROUP BY 1, 2, 3, 4
) as Fully
on Fully.Week_Number = ALL_COUNTS.Week_Number
and Fully.Marketer_Type = ALL_COUNTS.Marketer_Type
and Fully.Location = ALL_Counts.Location
and Fully.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--CPA--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_CPA,
        SUM(small_facm.Campaign_Weekly_GR)      AS S_CPA
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_campaign_performance_optimization_type = 'Target CPA-Fully Aut'
  and facm_kpio_activation_mode >0
 GROUP BY 1, 2, 3, 4
) as CPA
on  CPA.Week_Number = ALL_COUNTS.Week_Number
and CPA.Marketer_Type = ALL_COUNTS.Marketer_Type
and CPA.Location = ALL_Counts.Location
and CPA.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--ROAS--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_ROAS,
        SUM(small_facm.Campaign_Weekly_GR)      AS S_ROAS
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_campaign_performance_optimization_type = 'Target ROAS-Fully Au'
  and facm_kpio_activation_mode >0
 GROUP BY 1, 2, 3, 4
) as ROAS
on  ROAS.Week_Number = ALL_COUNTS.Week_Number
and ROAS.Marketer_Type = ALL_COUNTS.Marketer_Type
and ROAS.Location = ALL_Counts.Location
and ROAS.IS_CON = ALL_Counts.IS_CON
;


-- Bid Features Platform Breakdown ---------------
WITH calender as
    (
    SELECT min(start_date)  AS start_date ,
           max(end_date)    AS end_Date
    FROM
    (SELECT date_trunc('week', rfcl_date) AS Week , count(distinct rfcl_date), min(rfcl_date) AS start_date, max(rfcl_date) as end_date
    FROM rfcl_calendar WHERE rfcl_date between current_date -35 and current_date -1 GROUP BY 1 HAVING count(distinct rfcl_date) = 7 ) calender
    )
, Campaign_List AS
    (
    SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
       facm_campaign_id                             AS Campaign_ID,
       SUM(facm_gross_revenue)                      AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    WHERE facm.facm_est_stats_date>= (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1 , 2
    HAVING SUM(facm_gross_revenue) > 10
    )
,small_facm AS
    (
     SELECT facm.facm_est_stats_date,
            facm.facm_platform           AS Platform,
            facm.facm_marketer_id        AS Marketer_ID,
            facm_campaign_id             AS Campaign_ID,
            SUM(facm.facm_gross_revenue) AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    JOIN Campaign_List on Campaign_ID = facm_campaign_id and Campaign_List.Week_Number = DATE_TRUNC('WEEK', facm.facm_est_stats_date)
    WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1, 2, 3, 4
    )

,ALL_Counts AS
    (
        SELECT DATE_TRUNC('WEEK', small_facm.facm_est_stats_date) AS Week_Number,
               small_facm.Platform                                AS Platform,
               COUNT(DISTINCT small_facm.Marketer_ID)             AS Q_ALL,
               SUM(Campaign_Weekly_GR)                            AS S_ALL
        FROM small_facm
        GROUP BY 1, 2
    )
SELECT          ALL_COUNTS.Week_Number,
                ALL_COUNTS.Platform,
                ALL_COUNTS.Q_all,
                ALL_COUNTS.S_all,
                Q_Bid_By_Source,
                S_Bid_By_Source,
                Q_Bid_By_Ad,
                S_Bid_By_Ad,
                Q_Bid_By_Hour,
                S_Bid_By_Hour
FROM ALL_COUNTS
         LEFT JOIN

     --Bid_By_Ad-------------------------------------------------------------------------------------------------
         (
             SELECT DATE_TRUNC('WEEK',traffic.faad_est_stats_date)      AS Week_Number,
                    traffic.Platform                                    AS Platform,
                    COUNT(DISTINCT Marketer_ID)                         AS Q_Bid_By_Ad,
                    SUM(Campaign_Weekly_GR)                             AS S_Bid_By_Ad
             FROM (
                      SELECT faad.faad_est_stats_date,
                             faad.faad_platform                           AS Platform,
                             faad.faad_marketer_id                        AS Marketer_ID,
                             faad.faad_campaign_id                        AS Campaign_ID,
                             faad.faad_target_ad_id                       AS  AD_ID,
                             SUM(faad.faad_gross_revenue)                 AS Campaign_Weekly_GR
                      FROM db_outbrain.outbrain.faad_ad_traffic_d faad
                      join Campaign_List cl on cl.Campaign_ID = faad_campaign_id and cl.Week_Number = DATE_TRUNC('WEEK', faad.faad_est_stats_date)
                      WHERE faad.faad_est_stats_date >= (SELECT start_date from calender)
                      and faad_est_stats_date <= (SELECT end_date from calender)

                      GROUP BY 1,2,3,4,5
                  ) traffic
             JOIN (
                 SELECT diad.diad_marketer_id,
                        diad.diad_id
                 FROM diad_ad diad
                 WHERE diad.diad_cpc_adjustment != 0
                 and diad_cpc_adjustment is not null
                 ) ad
                    on ad.diad_marketer_id = traffic.Marketer_ID
                    and ad.diad_id = traffic.AD_ID
             GROUP BY 1, 2
         ) Bid_By_Ad
     on Bid_By_Ad.Week_Number = ALL_COUNTS.Week_Number
    and Bid_By_Ad.Platform = ALL_COUNTS.Platform

         LEFT JOIN

     --Bid_By_Source-------------------------------------------------------------------------------------------------

         (
             SELECT DATE_TRUNC('WEEK', traffic.facs_est_stats_date)           AS Week_Number,
                    traffic.Platform                                          AS Platform,
                    COUNT( DISTINCT traffic.facs_marketer_id)                 AS Q_Bid_By_Source,
                    SUM(traffic.GR)                                           AS S_Bid_By_Source
             FROM (SELECT facs.facs_est_stats_date,
                          facs.facs_platform    AS Platform,
                          facs.facs_source_section_id,
                          facs.facs_marketer_id,
                          facs.facs_campaign_id,
                          SUM(facs.facs_gross_revenue)          AS GR
                   FROM facs_campaign_section_traffic_d facs
                    JOIN Campaign_List cl on cl.Campaign_ID = facs.facs_campaign_id and cl.Week_Number = DATE_TRUNC('WEEK', facs.facs_est_stats_date)
                   WHERE facs.facs_est_stats_date >= (SELECT start_date from calender)
                    and facs_est_stats_date <= (SELECT end_date from calender)
                   GROUP BY 1,2,3,4,5
                  ) traffic
             JOIN (
                 SELECT hibs.hibs_stats_date,
                        hibs.hibs_campaign_id,
                        hibs.hibs_section_id
                 FROM hibs_bid_section_d hibs
                 WHERE hibs.hibs_stats_date >= (SELECT start_date from calender)
                   and hibs_stats_date <= (SELECT end_date from calender)
                   and hibs.hibs_bid_multiplier != 0
                   and hibs.hibs_bid_multiplier is not null
             ) hib
                           on traffic.facs_source_section_id = hib.hibs_section_id
                               and traffic.facs_campaign_id = hib.hibs_campaign_id
                               and traffic.facs_est_stats_date = hib.hibs_stats_date
             GROUP BY 1, 2
         ) Bid_By_Source
     on Bid_By_Source.Week_Number = ALL_COUNTS.Week_Number
    and Bid_By_Source.Platform = ALL_COUNTS.Platform

        LEFT JOIN
--Bid_By_Hour-----------------------------------------------------------------------------------------
         (
             SELECT Week_Number                                         AS Week_Number,
                    traffic.Platform                                    AS Platform,
                    COUNT(DISTINCT Marketer_ID)                         AS Q_Bid_By_Hour,
                    SUM(Campaign_Weekly_GR)                             AS S_Bid_By_Hour
             FROM (
                      SELECT DATE_TRUNC('WEEK',facm_est_stats_date)        AS Week_Number,
                             small_facm.platform                           AS Platform,
                             small_facm.marketer_id                        AS Marketer_ID,
                             SUM(Campaign_Weekly_GR)                       AS Campaign_Weekly_GR
                      FROM small_facm
                      JOIN (
                          SELECT
                                 hics.hics_stats_date,
                                 hics.hics_campaign_id
                          FROM hics_campaign_settings_d hics
                          WHERE hics.hics_stats_date >= (SELECT start_date from calender)
                            and hics_stats_date <= (SELECT end_date from calender)
                            and hics.hics_dayparting_enabled = 'true'
                          ) hic
                        on hic.hics_stats_date = small_facm.facm_est_stats_date
                        and hic.hics_campaign_id = small_facm.Campaign_ID
                      GROUP BY 1,2,3
                  ) traffic
             GROUP BY 1, 2
         ) Bid_By_Hour
     on Bid_By_Hour.Week_Number = ALL_COUNTS.Week_Number
    and Bid_By_Hour.Platform = ALL_COUNTS.Platform
;


-- live cbs camps daily --------------------------
SELECT facm_est_stats_date,
       dima_type_name AS Marketer_Type,
       CASE when hics_campaign_performance_optimization_type = 'Conversion - CPC'     then 'Semi Automated'
            when hics_campaign_performance_optimization_type = 'Max Convs-Fully Auto' then 'Fully Automated'
            when hics_campaign_performance_optimization_type = 'Target ROAS-Fully Au' then 'Target ROAS'
            when hics_campaign_performance_optimization_type = 'Target CPA-Fully Aut' then 'Target CPA' end AS optimization_type,
       COUNT(distinct facm_campaign_id)
FROM hics_campaign_settings_d
JOIN dima_marketer on dima_id = hics_marketer_id
JOIN facm_campaign_traffic_d on facm_campaign_id = hics_campaign_id and facm_est_stats_date = hics_stats_date
WHERE DATE(hics_stats_date) >= current_date-28
    and DATE(hics_stats_date) < current_date
    and facm_est_stats_date >= current_date -28
    and facm_est_stats_date < current_date
    and hics_campaign_performance_optimization_type in ('Conversion - CPC','Max Convs-Fully Auto','Target CPA-Fully Aut')
GROUP BY 1,2,3
;


-- cbs campaigns creation ------------------------
SELECT dima_type_name,
       DATE(hics_campaign_creation_date),
       CASE when hics_campaign_performance_optimization_type = 'Conversion - CPC' then 'Semi Automated' else 'Fully Automated' end AS optimization_type,
       count (distinct hics_campaign_id)
FROM hics_campaign_settings_d
JOIN dima_marketer on dima_id = hics_marketer_id
WHERE DATE(hics_campaign_creation_date) >= current_date-28
    and DATE(hics_campaign_creation_date) < current_date
    and hics_campaign_performance_optimization_type in ('Conversion - CPC','Max Convs-Fully Auto')
    and DATE(hics_campaign_creation_date) = hics_stats_date
Group by 1,2,3
;


-- Segments Adoption -----------------------------
WITH calender as
    (
    SELECT min(start_date)  AS start_date ,
           max(end_date)    AS end_Date
    FROM
    (SELECT date_trunc('week', rfcl_date) AS Week , count(distinct rfcl_date), min(rfcl_date) AS start_date, max(rfcl_date) as end_date
    FROM rfcl_calendar WHERE rfcl_date between current_date -35 and current_date -1 GROUP BY 1 HAVING count(distinct rfcl_date) = 7 ) calender
    )
,Campaign_List AS
    (
    SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
        facm.facm_marketer_id                       AS Marketer_ID,
       facm_campaign_id                             AS Campaign_ID,
       SUM(facm_gross_revenue)                      AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    WHERE facm.facm_est_stats_date >=  (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1 , 2, 3
    HAVING SUM(facm_gross_revenue) > 10
    )
,dima_small AS
    (
    SELECT dima_id,
           dima_type_name,
           dima_sales_rep_location_name
    FROM dima_marketer
    join (select distinct marketer_id from Campaign_List) d on marketer_id = dima_id
    )
, con AS
    (
     SELECT  c.Week_Number,
             c.Marketer_ID,
             CASE WHEN Total_Conversions > 0 THEN 1 ELSE 0 END AS IS_CON
      FROM
          (
          SELECT DATE_TRUNC('WEEK',COALESCE(famc_event_date, famc_est_stats_date)) AS Week_Number,
                        famc_marketer_id                                           AS Marketer_ID,
                        SUM(famc_num_conversions)                                  AS Total_Conversions
          FROM famc_multiple_conversion_click_listing_traffic famc
          JOIN dimc_multiple_conversion ON dimc_id = famc_conversion_id
          JOIN Campaign_List cl on cl.Campaign_ID = famc_campaign_id
          WHERE DATE(COALESCE(famc_event_date, famc_est_stats_date)) >= (SELECT start_date from calender)
           and DATE(COALESCE(famc_event_date, famc_est_stats_date)) <= (SELECT end_date from calender)
           AND dimc_count_as_conversion = 'true'
          GROUP BY 1 , 2
          ) c
    )
    , small_facm AS
    (
     SELECT facm.facm_est_stats_date,
            facm.facm_marketer_id        AS Marketer_ID,
            facm_campaign_id             AS Campaign_ID,
            dima_type_name,
            dima_sales_rep_location_name,
            SUM(facm.facm_gross_revenue) AS Campaign_Weekly_GR
     FROM facm_campaign_traffic_d facm
     JOIN Campaign_List on Campaign_ID = facm_campaign_id
                        and Campaign_List.Week_Number = DATE_TRUNC('Week', facm.facm_est_stats_date)
     JOIN dima_small on Marketer_ID = dima_id
     WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
       and facm_est_stats_date <= (SELECT end_date from calender)
     GROUP BY 1, 2, 3, 4 ,5
    )

,ALL_Counts AS
    (
        SELECT DATE_TRUNC('WEEK', small_facm.facm_est_stats_date) AS Week_Number,
               dima_sales_rep_location_name                       AS Location,
               dima_type_name                                     AS Marketer_Type,
               NVL(IS_CON,0)                                      AS IS_CON,
               --hisg_segment_type                                  AS Segment_Type,
               COUNT(DISTINCT small_facm.Marketer_ID)             AS Q_ALL,
               SUM(Campaign_Weekly_GR)                            AS S_ALL
        FROM small_facm
        LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
        GROUP BY 1, 2, 3 , 4--, 5
        ORDER BY 1,2,3,4--,5
    )

SELECT DISTINCT ALL_COUNTS.Week_Number,
                ALL_Counts.Location,
                ALL_COUNTS.Marketer_Type,
                ALL_Counts.IS_CON,
                ALL_COUNTS.Q_all,
                ALL_COUNTS.S_all,
                Q_Clickers,
                S_Clickers,
                Q_Conversion,
                S_Conversion,
                Q_Engaged,
                S_Engaged,
                Q_Pixel,
                S_Pixel,
                Q_Viewers,
                S_Viewers
FROM ALL_COUNTS
LEFT JOIN
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT CASE WHEN hisg_segment_type = 'Clickers'THEN small_facm.Marketer_ID END)     AS Q_Clickers,
        SUM(CASE WHEN hisg_segment_type = 'Clickers'THEN Campaign_Weekly_GR END )                   AS S_Clickers,
        COUNT(DISTINCT CASE WHEN hisg_segment_type = 'Conversion'THEN small_facm.Marketer_ID END)   AS Q_Conversion,
        SUM(CASE WHEN hisg_segment_type = 'Conversion'THEN Campaign_Weekly_GR END )                 AS S_Conversion,
        COUNT(DISTINCT CASE WHEN hisg_segment_type = 'Engaged'THEN small_facm.Marketer_ID END)      AS Q_Engaged,
        SUM(CASE WHEN hisg_segment_type = 'Engaged'THEN Campaign_Weekly_GR END )                    AS S_Engaged,
        COUNT(DISTINCT CASE WHEN hisg_segment_type = 'Pixel'THEN small_facm.Marketer_ID END)        AS Q_Pixel,
        SUM(CASE WHEN hisg_segment_type = 'Pixel'THEN Campaign_Weekly_GR END )                      AS S_Pixel,
        COUNT(DISTINCT CASE WHEN hisg_segment_type = 'Viewers'THEN small_facm.Marketer_ID END)      AS Q_Viewers,
        SUM(CASE WHEN hisg_segment_type = 'Viewers'THEN Campaign_Weekly_GR END )                    AS S_Viewers
 FROM small_facm
     LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
          JOIN (
                 SELECT hisg_stats_date,
                        hisg_campaign_id,
                        hisg_segment_type
                 FROM hisg_segment_campaign_d hisg
                 WHERE hisg.hisg_stats_date >=  (SELECT start_date from calender)
                   and hisg.hisg_stats_date <= (SELECT end_date from calender)
                   --and hisg.hisg_segment_type in
                ) his
            on his.hisg_stats_date = small_facm.facm_est_stats_date
            and his.hisg_campaign_id = small_facm.campaign_ID
 GROUP BY 1, 2 , 3, 4
) segments
on segments.Week_Number = ALL_COUNTS.Week_Number
and segments.Marketer_Type = ALL_COUNTS.Marketer_Type
and segments.Location = ALL_Counts.Location
and segments.IS_CON = ALL_Counts.IS_CON
;


-- Live CBS Campaigns ----------------------------
SELECT dima_type_name AS Marketer_Type ,
       CASE when hics_campaign_performance_optimization_type = 'Conversion - CPC' then 'Semi Automated'
            when hics_campaign_performance_optimization_type = 'Max Convs-Fully Auto' then 'Fully Automated'
            else 'Target CPA' end AS optimization_type,
       count(distinct facm_campaign_id) AS Live_Campaigns
FROM facm_campaign_traffic_d
JOIN (SELECT dima_id, dima_type_name FROM dima_marketer) dima on dima_id = facm_marketer_id
JOIN (SELECT hics_stats_date, hics_campaign_id, hics_campaign_performance_optimization_type FROM hics_campaign_settings_d WHERE hics_stats_date >= current_date -28) hics
    ON hics_campaign_id = facm_campaign_id and hics_stats_date = facm_est_stats_date
WHERE facm_est_stats_date >= current_date -7
and facm_est_stats_date < current_date
and facm_kpio_activation_mode > 0
and hics_campaign_performance_optimization_type in ('Conversion - CPC','Max Convs-Fully Auto','Target CPA-Fully Aut')
GROUP BY 1, 2
ORDER BY 1,2
;


-- General Features Platform Breakdown -----------
WITH calender as
    (
    SELECT min(start_date)  AS start_date ,
           max(end_date)    AS end_Date
    FROM
    (SELECT date_trunc('week', rfcl_date) AS Week , count(distinct rfcl_date), min(rfcl_date) AS start_date, max(rfcl_date) as end_date
    FROM rfcl_calendar WHERE rfcl_date between current_date -35 and current_date -1 GROUP BY 1 HAVING count(distinct rfcl_date) = 7 ) calender
    )
,Campaign_List AS
    (
    SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
       facm_campaign_id                             AS Campaign_ID,
       SUM(facm_gross_revenue)                      AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1 , 2
    HAVING SUM(facm_gross_revenue) > 10
    )
,small_facm AS
    (
     SELECT facm.facm_est_stats_date,
            facm.facm_platform           AS Platform,
            facm.facm_marketer_id        AS Marketer_ID,
            facm_campaign_id             AS Campaign_ID,
            SUM(facm.facm_gross_revenue) AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    JOIN Campaign_List on Campaign_ID = facm_campaign_id and Campaign_List.Week_Number = DATE_TRUNC('WEEK', facm.facm_est_stats_date)
    WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1, 2, 3, 4
    )
,small_hics as
    (
     SELECT hics.hics_stats_date,
            hics.hics_campaign_id,
            hics.hics_is_zip_code_targeted,
            hics.hics_is_interest_targeting,
            hics.hics_lookaLike_included_segments_id,
            hics.hics_lookaLike_excluded_segments_id,
            hics.hics_os_targeting,
            hics.hics_browser_targeting,
            hics.hics_creative_format,
            hics.hics_pixel_excluded_segments_id,
            hics.hics_pixel_included_segments_id,
            hics.hics_clickers_excluded_segments_id,
            hics.hics_clickers_included_segments_id,
            hics_is_wifi_targeting
     FROM hics_campaign_settings_d hics
     WHERE hics.hics_stats_date>= (SELECT start_date from calender)
       and hics_stats_date <= (SELECT end_date from calender)

     )
,ALL_Counts AS
     (
      SELECT DATE_TRUNC('WEEK', small_facm.facm_est_stats_date) AS Week_Number,
             small_facm.Platform                                AS Platform,
             COUNT(DISTINCT small_facm.Marketer_ID)             AS Q_ALL,
             SUM(Campaign_Weekly_GR)                            AS S_ALL
      FROM small_facm
      GROUP BY 1, 2
     )
SELECT DISTINCT ALL_COUNTS.Week_Number,
                ALL_COUNTS.Platform,
                ALL_COUNTS.Q_all,
                ALL_COUNTS.S_all,
                Q_CBS,
                S_CBS,
                Zipcode_Targeting.Q_Zipcode_Targeting,
                S_Zipcode_Targeting,
                Q_OS_Targeting,
                S_OS_Targeting,
                Q_Interest_Targeting,
                S_Interest_Targeting,
                Q_Browser_Targeting,
                S_Browser_Targeting,
                Q_Lookalikes,
                S_Lookalikes,
                Q_Carousel,
                S_Carousel,
                Q_App_Installs,
                S_App_Installs,
                Q_3rd_party_data_targeting,
                S_3rd_party_data_targeting,
                Q_Custom_Audiences,
                S_Custom_Audiences,
                Q_Dynamic_Titles,
                S_Dynamic_Titles,
                Q_Wifi_Targeting,
                S_Wifi_Targeting
FROM ALL_COUNTS

LEFT JOIN
--CBS--------------------------------------------------------------------------------------------------------
 (
     SELECT Week_Number                 AS Week_Number,
            traffic_CBS.Platform        AS Platform,
            COUNT(DISTINCT Marketer_ID) AS Q_CBS,
            SUM(Campaign_Weekly_GR)     AS S_CBS
     FROM (
              SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
                     facm.facm_platform                           AS Platform,
                     facm.facm_marketer_id                        AS Marketer_ID,
                     SUM(facm.facm_gross_revenue)                 AS Campaign_Weekly_GR
              FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
              join campaign_list cl on cl.Campaign_ID = facm.facm_campaign_id and DATE_TRUNC('WEEK', facm.facm_est_stats_date) = cl.Week_Number
              WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
                and facm_est_stats_date <= (SELECT end_date from calender)
                and facm_kpio_activation_mode > 0
              GROUP BY 1, 2, 3
            --HAVING SUM(facm.facm_gross_revenue)>10
          ) traffic_CBS
     GROUP BY 1, 2
 ) CBS
on CBS.Week_Number = ALL_COUNTS.Week_Number
and CBS.Platform = ALL_COUNTS.Platform

LEFT JOIN
--Zipcode_Targeting-----------------------------------------------------------------------------------------
    (
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_Zipcode_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Zipcode_Targeting
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE small_hics.hics_is_zip_code_targeted = 'true'
 GROUP BY 1, 2
    ) Zipcode_Targeting
    on Zipcode_Targeting.Week_Number = ALL_COUNTS.Week_Number
    and Zipcode_Targeting.Platform = ALL_COUNTS.Platform

LEFT JOIN
--OS_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_OS_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_OS_Targeting
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE small_hics.hics_os_targeting = 'true'
 GROUP BY 1, 2
) OS_Targeting
on OS_Targeting.Week_Number = ALL_COUNTS.Week_Number
and OS_Targeting.Platform = ALL_COUNTS.Platform
LEFT JOIN
--Interest_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_Interest_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Interest_Targeting
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE small_hics.hics_is_interest_targeting = 'true'
 GROUP BY 1, 2
) Interest_Targeting
on Interest_Targeting.Week_Number = ALL_COUNTS.Week_Number
and Interest_Targeting.Platform = ALL_COUNTS.Platform
LEFT JOIN
--Browser_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_Browser_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Browser_Targeting
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE small_hics.hics_browser_targeting = 'true'
 GROUP BY 1, 2
) Browser_Targeting
on Browser_Targeting.Week_Number = ALL_COUNTS.Week_Number
and Browser_Targeting.Platform = ALL_COUNTS.Platform
LEFT JOIN
--Lookalikes--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_Lookalikes,
        SUM(Campaign_Weekly_GR)                 AS S_Lookalikes
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE (small_hics.hics_lookaLike_excluded_segments_id is not null
        or small_hics.hics_lookaLike_included_segments_id is not null)
 GROUP BY 1, 2
) Lookalikes
on Lookalikes.Week_Number = ALL_COUNTS.Week_Number
and Lookalikes.Platform= ALL_COUNTS.Platform
LEFT JOIN
--Carousel--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_Carousel,
        SUM(Campaign_Weekly_GR)                 AS S_Carousel
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE small_hics.hics_creative_format = 'Carousel'
 GROUP BY 1, 2
) Carousel
on Carousel.Week_Number = ALL_COUNTS.Week_Number
and Carousel.Platform = ALL_COUNTS.Platform

    LEFT JOIN
--App_Installs--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_App_Installs,
        SUM(Campaign_Weekly_GR)                 AS S_App_Installs
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE small_hics.hics_creative_format = 'AppInstall'
 GROUP BY 1, 2
) App_Installs
on App_Installs.Week_Number = ALL_COUNTS.Week_Number
and App_Installs.Platform = ALL_COUNTS.Platform

LEFT JOIN
--3rd_Party_data_targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_3rd_party_data_targeting,
        SUM(Campaign_Weekly_GR)                 AS S_3rd_party_data_targeting
 FROM small_facm
          JOIN (
                 SELECT hisg.hisg_stats_date,
                        hisg.hisg_campaign_id
                 FROM hisg_segment_campaign_d hisg
                 WHERE hisg.hisg_stats_date>= (SELECT start_date from calender)
                   and hisg.hisg_stats_date <= (SELECT end_date from calender)
                   and hisg.hisg_segment_type in ('LiveRamp - Acxiom 3rd party data $0.10',
                                                  'Liveramp - B2B',
                                                  'LiveRamp - Connexity 3rd party data',
                                                  'LiveRamp - Crossix 3rd party data $1.35',
                                                  'LiveRamp - 3rd Party Data - Crossix - $0.85',
                                                  'LiveRamp - Acxiom 3rd party data $0.05',
                                                  'Bluekai',
                                                  'Liveramp',
                                                  'Adobe',
                                                  'Krux',
                                                  'Liveramp - Dun&Bradstreet',
                                                  'Liveramp - CRM')
                ) his
            on his.hisg_stats_date = small_facm.facm_est_stats_date
            and his.hisg_campaign_id = small_facm.campaign_ID
 GROUP BY 1, 2
) rd_party_data_targeting
on rd_party_data_targeting.Week_Number = ALL_COUNTS.Week_Number
and rd_party_data_targeting.Platform = ALL_COUNTS.Platform

LEFT JOIN
--Custom_Audiences--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_Custom_Audiences,
        SUM(Campaign_Weekly_GR)                 AS S_Custom_Audiences
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE (small_hics.hics_pixel_excluded_segments_id is not null
         or small_hics.hics_pixel_included_segments_id is not null
         or small_hics.hics_clickers_excluded_segments_id is not null
         or small_hics.hics_clickers_included_segments_id is not null)

 GROUP BY 1, 2
) Custom_Audiences
on Custom_Audiences.Week_Number = ALL_COUNTS.Week_Number
and Custom_Audiences.Platform = ALL_COUNTS.Platform

LEFT JOIN
--Dynamic_Titles-------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', traffic.faad_est_stats_date) AS Week_Number,
        traffic.Platform                                AS Platform,
        COUNT(DISTINCT Marketer_ID)                     AS Q_Dynamic_Titles,
        SUM(Campaign_Weekly_GR)                         AS S_Dynamic_Titles
 FROM (
          SELECT faad.faad_est_stats_date,
                 faad.faad_platform           AS Platform,
                 faad.faad_marketer_id        AS Marketer_ID,
                 faad.faad_campaign_id        AS Campaign_ID,
                 faad.faad_target_ad_id       AS AD_ID,
                 SUM(faad.faad_gross_revenue) AS Campaign_Weekly_GR
          FROM  db_outbrain.outbrain.faad_ad_traffic_d faad
          JOIN campaign_list cl on cl.Week_Number = DATE_TRUNC('WEEK', faad.faad_est_stats_date) and cl.Campaign_ID = faad.faad_campaign_id
          WHERE faad.faad_est_stats_date >= (SELECT start_date from calender)
            and faad_est_stats_date <= (SELECT end_date from calender)
          GROUP BY 1, 2, 3, 4 ,5
      ) traffic
          JOIN (
     SELECT diad.diad_marketer_id,
            diad.diad_id
     FROM diad_ad diad
     WHERE diad.diad_title like '%${%'
 ) ad
               on ad.diad_marketer_id = traffic.Marketer_ID
                   and ad.diad_id = traffic.AD_ID
 GROUP BY 1, 2
) Dynamic_Titles
on Dynamic_Titles.Week_Number = ALL_COUNTS.Week_Number
and Dynamic_Titles.Platform = ALL_COUNTS.Platform
LEFT JOIN
--Wifi_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        small_facm.Platform                     AS Platform,
        COUNT(DISTINCT Marketer_ID)             AS Q_Wifi_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Wifi_Targeting
 FROM small_facm
 JOIN small_hics
     on small_hics.hics_stats_date = small_facm.facm_est_stats_date
     and small_hics.hics_campaign_id = small_facm.Campaign_ID
 WHERE small_hics.hics_is_wifi_targeting = 'true'
  and hics_stats_date >= '2020-06-03'
 GROUP BY 1, 2
) Wifi_Targeting
on Wifi_Targeting.Week_Number = ALL_COUNTS.Week_Number
and Wifi_Targeting.Platform = ALL_COUNTS.Platform
ORDER BY 1
;


-- CBS camps with API ----------------------------

          
;


-- Bid Features Marketers Breakdown --------------
WITH calender as
    (
    SELECT min(start_date)  AS start_date ,
           max(end_date)    AS end_Date
    FROM
    (SELECT date_trunc('week', rfcl_date) AS Week , count(distinct rfcl_date), min(rfcl_date) AS start_date, max(rfcl_date) as end_date
    FROM rfcl_calendar WHERE rfcl_date between current_date -35 and current_date -1 GROUP BY 1 HAVING count(distinct rfcl_date) = 7 ) calender
    )
, Campaign_List AS
    (
    SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
           facm.facm_marketer_id                    AS Marketer_ID,
       facm_campaign_id                             AS Campaign_ID,
       SUM(facm_gross_revenue)                      AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1 , 2 , 3
    HAVING SUM(facm_gross_revenue) > 10
    )
,dima_small AS
    (
    SELECT dima_id,
           dima_type_name,
           dima_sales_rep_location_name
    FROM dima_marketer
    join (select distinct marketer_id from Campaign_List) d on marketer_id = dima_id
    )
, con AS
    (
        SELECT c.Week_Number,
               c.Marketer_ID,
               CASE WHEN Total_Conversions > 0 THEN 1 ELSE 0 END AS IS_CON
        FROM (
                 SELECT DATE_TRUNC('WEEK', COALESCE(famc_event_date, famc_est_stats_date)) AS Week_Number,
                        famc_marketer_id                                                   AS Marketer_ID,
                        SUM(famc_num_conversions)                                          AS Total_Conversions
                 FROM famc_multiple_conversion_click_listing_traffic famc
                          JOIN dimc_multiple_conversion ON dimc_id = famc_conversion_id
                          JOIN Campaign_List cl on cl.Campaign_ID = famc_campaign_id and cl.Week_Number = DATE_TRUNC('WEEK', COALESCE(famc_event_date, famc_est_stats_date))
                 WHERE DATE(COALESCE(famc_event_date, famc_est_stats_date))>= (SELECT start_date from calender)
                   and DATE(COALESCE(famc_event_date, famc_est_stats_date)) <= (SELECT end_date from calender)
                   AND dimc_count_as_conversion = 'true'
                 GROUP BY 1, 2
             ) c
    )
,small_facm AS
    (
     SELECT facm.facm_est_stats_date,
            facm.facm_marketer_id        AS Marketer_ID,
            facm_campaign_id             AS Campaign_ID,
            SUM(facm.facm_gross_revenue) AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    JOIN Campaign_List on Campaign_ID = facm_campaign_id and Campaign_List.Week_Number = DATE_TRUNC('week',facm.facm_est_stats_date)
    WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1, 2, 3
    )

,ALL_Counts AS
    (
        SELECT DATE_TRUNC('WEEK', small_facm.facm_est_stats_date) AS Week_Number,
               dima.dima_sales_rep_location_name                  AS Location,
               dima.dima_type_name                                AS Marketer_Type,
               NVL(IS_CON,0)                                      AS IS_CON,
               COUNT(DISTINCT small_facm.Marketer_ID)             AS Q_ALL,
               SUM(Campaign_Weekly_GR)                            AS S_ALL
        FROM small_facm
                 JOIN dima_small dima
                      on dima.dima_id = small_facm.Marketer_ID
         left join con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
        GROUP BY 1, 2, 3 , 4
    )
SELECT          ALL_COUNTS.Week_Number,
                ALL_Counts.Location,
                ALL_COUNTS.Marketer_Type,
                ALL_Counts.IS_CON,
                ALL_COUNTS.Q_all,
                ALL_COUNTS.S_all,
                Q_Bid_By_Source,
                S_Bid_By_Source,
                Q_Bid_By_Ad,
                S_Bid_By_Ad,
                Q_Bid_By_Hour,
                S_Bid_By_Hour
FROM ALL_COUNTS
         LEFT JOIN

     --Bid_By_Ad-------------------------------------------------------------------------------------------------
         (
             SELECT DATE_TRUNC('WEEK',traffic.faad_est_stats_date)      AS Week_Number,
                    dima.dima_sales_rep_location_name                   AS Location,
                    dima.dima_type_name                                 AS Marketer_Type,
                    NVL(IS_CON,0)                                       AS IS_CON,
                    COUNT(DISTINCT traffic.Marketer_ID)                 AS Q_Bid_By_Ad,
                    SUM(Campaign_Weekly_GR)                             AS S_Bid_By_Ad
             FROM (
                      SELECT faad.faad_est_stats_date,
                             faad.faad_marketer_id                        AS Marketer_ID,
                             faad.faad_campaign_id                        AS Campaign_ID,
                             faad.faad_target_ad_id                       AS  AD_ID,
                             SUM(faad.faad_gross_revenue)                 AS Campaign_Weekly_GR
                      FROM db_outbrain.outbrain.faad_ad_traffic_d faad
                       join campaign_list cl on cl.Campaign_ID = faad_campaign_id and cl.Week_Number = DATE_TRUNC('week',faad.faad_est_stats_date)
                      WHERE faad.faad_est_stats_date >= (SELECT start_date from calender)
                      and faad_est_stats_date <= (SELECT end_date from calender)
                      GROUP BY 1,2,3,4
                  ) traffic
            LEFT JOIN con on con.Marketer_ID = traffic.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', traffic.faad_est_stats_date)
             JOIN (
                 SELECT diad.diad_marketer_id,
                        diad.diad_id
                 FROM diad_ad diad
                 WHERE diad.diad_cpc_adjustment != 0
                 and diad_cpc_adjustment is not null
                 ) ad
                    on ad.diad_marketer_id = traffic.Marketer_ID
                    and ad.diad_id = traffic.AD_ID
             JOIN dima_small dima
                on dima.dima_id = traffic.Marketer_ID
             GROUP BY 1, 2, 3 , 4
         ) Bid_By_Ad
     on Bid_By_Ad.Week_Number = ALL_COUNTS.Week_Number
    and Bid_By_Ad.Marketer_Type = ALL_COUNTS.Marketer_Type
    and Bid_By_Ad.Location = ALL_Counts.Location
    and Bid_By_Ad.IS_CON = ALL_Counts.IS_CON

         LEFT JOIN

     --Bid_By_Source-------------------------------------------------------------------------------------------------

         (
             SELECT DATE_TRUNC('WEEK', traffic.facs_est_stats_date)           AS Week_Number,
                    dima.dima_sales_rep_location_name                         AS Location,
                    dima.dima_type_name                                       AS Marketer_Type,
                    NVL(IS_CON,0)                                             AS IS_CON,
                    COUNT( DISTINCT traffic.facs_marketer_id)                 AS Q_Bid_By_Source,
                    SUM(traffic.GR)                                           AS S_Bid_By_Source
             FROM (SELECT facs.facs_est_stats_date,
                          facs.facs_source_section_id,
                          facs.facs_marketer_id,
                          facs.facs_campaign_id,
                          SUM(facs.facs_gross_revenue)          AS GR
                   FROM facs_campaign_section_traffic_d facs
                    join campaign_list cl on cl.Campaign_ID = facs_campaign_id and cl.Week_Number = DATE_TRUNC('week',facs.facs_est_stats_date)
                   WHERE facs.facs_est_stats_date >= (SELECT start_date from calender)
                    and facs_est_stats_date <= (SELECT end_date from calender)
                   GROUP BY 1,2,3,4
                  ) traffic
             LEFT JOIN con on con.Marketer_ID = traffic.facs_marketer_id and con.Week_Number = DATE_TRUNC('WEEK', traffic.facs_est_stats_date)
             JOIN (
                 SELECT hibs.hibs_stats_date,
                        hibs.hibs_campaign_id,
                        hibs.hibs_section_id
                 FROM hibs_bid_section_d hibs
                 WHERE hibs.hibs_stats_date >= (SELECT start_date from calender)
                   and hibs_stats_date <= (SELECT end_date from calender)
                   and hibs.hibs_bid_multiplier != 0
                   and hibs.hibs_bid_multiplier is not null
             ) hib
                           on traffic.facs_source_section_id = hib.hibs_section_id
                               and traffic.facs_campaign_id = hib.hibs_campaign_id
                               and traffic.facs_est_stats_date = hib.hibs_stats_date
             JOIN dima_small dima
                on dima.dima_id = traffic.facs_marketer_id
             GROUP BY 1, 2, 3, 4
         ) Bid_By_Source
     on Bid_By_Source.Week_Number = ALL_COUNTS.Week_Number
    and Bid_By_Source.Marketer_Type = ALL_COUNTS.Marketer_Type
    and Bid_By_Source.Location = ALL_Counts.Location
    and Bid_By_Source.IS_CON = ALL_Counts.IS_CON

        LEFT JOIN
--Bid_By_Hour-----------------------------------------------------------------------------------------
         (
             SELECT traffic.Week_Number                                 AS Week_Number,
                    dima.dima_sales_rep_location_name                   AS Location,
                    dima.dima_type_name                                 AS Marketer_Type,
                    NVL(IS_CON,0)                                       AS IS_CON,
                    COUNT(DISTINCT traffic.Marketer_ID)                 AS Q_Bid_By_Hour,
                    SUM(Campaign_Weekly_GR)                             AS S_Bid_By_Hour
             FROM (
                      SELECT DATE_TRUNC('WEEK',facm_est_stats_date)        AS Week_Number,
                             small_facm.marketer_id                        AS Marketer_ID,
                             SUM(Campaign_Weekly_GR)                       AS Campaign_Weekly_GR
                      FROM small_facm
                      JOIN (
                          SELECT
                                 hics.hics_stats_date,
                                 hics.hics_campaign_id
                          FROM hics_campaign_settings_d hics
                          WHERE hics.hics_stats_date>= (SELECT start_date from calender)
                            and hics_stats_date <= (SELECT end_date from calender)
                            and hics.hics_dayparting_enabled = 'true'
                          ) hic
                        on hic.hics_stats_date = small_facm.facm_est_stats_date
                        and hic.hics_campaign_id = small_facm.Campaign_ID
                      GROUP BY 1,2
                  ) traffic
                      JOIN dima_small dima
                on dima.dima_id = traffic.Marketer_ID
              LEFT JOIN con on con.Marketer_ID = traffic.Marketer_ID and con.Week_Number =  traffic.Week_Number
             GROUP BY 1, 2 ,3, 4
         ) Bid_By_Hour
     on Bid_By_Hour.Week_Number = ALL_COUNTS.Week_Number
    and Bid_By_Hour.Marketer_Type = ALL_COUNTS.Marketer_Type
    and Bid_By_Hour.Location = ALL_Counts.Location
    and Bid_By_Hour.IS_CON = ALL_Counts.IS_CON
ORDER BY 1, 2, 3
;


-- General Features Marketers Breakdown ----------
WITH calender as
    (
    SELECT min(start_date)  AS start_date ,
           max(end_date)    AS end_Date
    FROM
    (SELECT date_trunc('week', rfcl_date) AS Week , count(distinct rfcl_date), min(rfcl_date) AS start_date, max(rfcl_date) as end_date
    FROM rfcl_calendar WHERE rfcl_date between current_date -35 and current_date -1 GROUP BY 1 HAVING count(distinct rfcl_date) = 7 ) calender
    )
,Campaign_List AS
    (
    SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
        facm.facm_marketer_id                       AS Marketer_ID,
       facm_campaign_id                             AS Campaign_ID,
       SUM(facm_gross_revenue)                      AS Campaign_Weekly_GR
    FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
    WHERE facm.facm_est_stats_date >=  (SELECT start_date from calender)
      and facm_est_stats_date <= (SELECT end_date from calender)
    GROUP BY 1 , 2, 3
    HAVING SUM(facm_gross_revenue) > 10
    )
,dima_small AS
    (
    SELECT dima_id,
           dima_type_name,
           dima_sales_rep_location_name
    FROM dima_marketer
    join (select distinct marketer_id from Campaign_List) d on marketer_id = dima_id
    )
, con AS
    (
     SELECT  c.Week_Number,
             c.Marketer_ID,
             CASE WHEN Total_Conversions > 0 THEN 1 ELSE 0 END AS IS_CON
      FROM
          (
          SELECT DATE_TRUNC('WEEK',COALESCE(famc_event_date, famc_est_stats_date)) AS Week_Number,
                        famc_marketer_id                                           AS Marketer_ID,
                        SUM(famc_num_conversions)                                  AS Total_Conversions
          FROM famc_multiple_conversion_click_listing_traffic famc
          JOIN dimc_multiple_conversion ON dimc_id = famc_conversion_id
          JOIN Campaign_List cl on cl.Campaign_ID = famc_campaign_id
          WHERE DATE(COALESCE(famc_event_date, famc_est_stats_date)) >= (SELECT start_date from calender)
           and DATE(COALESCE(famc_event_date, famc_est_stats_date)) <= (SELECT end_date from calender)
           AND dimc_count_as_conversion = 'true'
          GROUP BY 1 , 2
          ) c
    )
    , small_facm AS
    (
        select k.*, h.*,
               dima_type_name,
               dima_sales_rep_location_name
        from (
                 SELECT facm.facm_est_stats_date,
                        facm.facm_marketer_id        AS Marketer_ID,
                        facm_campaign_id             AS Campaign_ID,
                        SUM(facm.facm_gross_revenue) AS Campaign_Weekly_GR
                 FROM facm_campaign_traffic_d facm
                 JOIN Campaign_List on Campaign_ID = facm_campaign_id and Campaign_List.Week_Number = DATE_TRUNC('Week',facm.facm_est_stats_date)
                 WHERE facm.facm_est_stats_date >= (SELECT start_date from calender)
                   and facm_est_stats_date <= (SELECT end_date from calender)
                 GROUP BY 1, 2, 3
             ) k
        join dima_small on Marketer_ID = dima_id
        JOIN (
            SELECT hics.hics_stats_date,
               hics.hics_campaign_id,
               hics.hics_is_zip_code_targeted,
               hics.hics_is_interest_targeting,
               hics.hics_lookaLike_included_segments_id,
               hics.hics_lookaLike_excluded_segments_id,
               hics.hics_os_targeting,
               hics.hics_browser_targeting,
               hics.hics_creative_format,
               hics.hics_pixel_excluded_segments_id,
               hics.hics_pixel_included_segments_id,
               hics.hics_clickers_excluded_segments_id,
               hics.hics_clickers_included_segments_id,
               hics.hics_is_wifi_targeting
        FROM hics_campaign_settings_d hics
        WHERE hics.hics_stats_date >= (SELECT start_date from calender)
          and hics_stats_date <= (SELECT end_date from calender)
            ) h
        on k.facm_est_stats_date = h.hics_stats_date
        and k.Campaign_ID = h.hics_campaign_id
    )


,ALL_Counts AS
    (
        SELECT DATE_TRUNC('WEEK', small_facm.facm_est_stats_date) AS Week_Number,
               dima_sales_rep_location_name                       AS Location,
               dima_type_name                                     AS Marketer_Type,
               NVL(IS_CON,0)                                      AS IS_CON,
               COUNT(DISTINCT small_facm.Marketer_ID)             AS Q_ALL,
               SUM(Campaign_Weekly_GR)                            AS S_ALL
        FROM small_facm
        left join con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
        GROUP BY 1, 2, 3 , 4
    )
SELECT DISTINCT ALL_COUNTS.Week_Number,
                ALL_Counts.Location,
                ALL_COUNTS.Marketer_Type,
                ALL_Counts.IS_CON,
                ALL_COUNTS.Q_all,
                ALL_COUNTS.S_all,
                Q_CBS,
                S_CBS,
                Zipcode_Targeting.Q_Zipcode_Targeting,
                S_Zipcode_Targeting,
                Q_OS_Targeting,
                S_OS_Targeting,
                Q_Interest_Targeting,
                S_Interest_Targeting,
                Q_Browser_Targeting,
                S_Browser_Targeting,
                Q_Lookalikes,
                S_Lookalikes,
                Q_Carousel,
                S_Carousel,
                Q_App_Installs,
                S_App_Installs,
                Q_3rd_party_data_targeting,
                S_3rd_party_data_targeting,
                Q_Custom_Audiences,
                S_Custom_Audiences,
                Q_Dynamic_Titles,
                S_Dynamic_Titles,
                Q_Wifi_Targeting,
                S_Wifi_Targeting

FROM ALL_COUNTS

LEFT JOIN
--CBS--------------------------------------------------------------------------------------------------------
 (
     SELECT traffic_CBS.Week_Number                         AS Week_Number,
            dima.dima_sales_rep_location_name   AS Location,
            dima.dima_type_name                 AS Marketer_Type,
            NVL(IS_CON,0)                       AS IS_CON,
            COUNT(DISTINCT traffic_CBS.Marketer_ID)         AS Q_CBS,
            SUM(Campaign_Weekly_GR)             AS S_CBS
     FROM (
              SELECT DATE_TRUNC('WEEK', facm.facm_est_stats_date) AS Week_Number,
                     facm.facm_marketer_id                        AS Marketer_ID,
                     SUM(facm.facm_gross_revenue)                 AS Campaign_Weekly_GR
              FROM db_outbrain.outbrain.facm_campaign_traffic_d facm
              JOIN Campaign_List cl on cl.Campaign_ID = facm_campaign_id and cl.Week_Number = DATE_TRUNC('WEEK', facm.facm_est_stats_date)
              WHERE facm.facm_est_stats_date >=(SELECT start_date from calender)
                and facm_est_stats_date <= (SELECT end_date from calender)
                and facm_kpio_activation_mode > 0
              GROUP BY 1, 2
          ) traffic_CBS
      JOIN dima_small dima on dima.dima_id = traffic_CBS.Marketer_ID
      left JOIN con on con.Week_Number = traffic_CBS.Week_Number and con.Marketer_ID = traffic_CBS.Marketer_ID

     GROUP BY 1, 2, 3 , 4
 ) CBS
on CBS.Week_Number = ALL_COUNTS.Week_Number
and CBS.Marketer_Type = ALL_COUNTS.Marketer_Type
and cbs.Location = ALL_Counts.Location
and cbs.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Zipcode_Targeting-----------------------------------------------------------------------------------------
    (
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Zipcode_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Zipcode_Targeting
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_is_zip_code_targeted = 'true'
 GROUP BY 1, 2 , 3 ,4
    ) Zipcode_Targeting
    on Zipcode_Targeting.Week_Number = ALL_COUNTS.Week_Number
    and Zipcode_Targeting.Marketer_Type = ALL_COUNTS.Marketer_Type
    and Zipcode_Targeting.Location = ALL_Counts.Location
    and zipcode_Targeting.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--OS_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_OS_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_OS_Targeting
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_os_targeting = 'true'
 GROUP BY 1, 2 , 3 , 4
) OS_Targeting
on OS_Targeting.Week_Number = ALL_COUNTS.Week_Number
and OS_Targeting.Marketer_Type = ALL_COUNTS.Marketer_Type
and OS_Targeting.Location = ALL_Counts.Location
and OS_Targeting.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Interest_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Interest_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Interest_Targeting
 FROM small_facm
  LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_is_interest_targeting = 'true'
 GROUP BY 1, 2 , 3 , 4
) Interest_Targeting
on Interest_Targeting.Week_Number = ALL_COUNTS.Week_Number
and Interest_Targeting.Marketer_Type = ALL_COUNTS.Marketer_Type
and Interest_Targeting.Location = ALL_Counts.Location
and Interest_Targeting.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Browser_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Browser_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Browser_Targeting
 FROM small_facm
  LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_browser_targeting = 'true'
 GROUP BY 1, 2, 3 ,4
) Browser_Targeting
on Browser_Targeting.Week_Number = ALL_COUNTS.Week_Number
and Browser_Targeting.Marketer_Type = ALL_COUNTS.Marketer_Type
and Browser_Targeting.Location = ALL_Counts.Location
and Browser_Targeting.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Lookalikes--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Lookalikes,
        SUM(Campaign_Weekly_GR)                 AS S_Lookalikes
 FROM small_facm
LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE (hics_lookaLike_excluded_segments_id is not null
        or hics_lookaLike_included_segments_id is not null)

 GROUP BY 1, 2 , 3 , 4
) Lookalikes
on Lookalikes.Week_Number = ALL_COUNTS.Week_Number
and Lookalikes.Marketer_Type = ALL_COUNTS.Marketer_Type
and Lookalikes.Location = ALL_Counts.Location
and Lookalikes.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Carousel--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Carousel,
        SUM(Campaign_Weekly_GR)                 AS S_Carousel
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_creative_format = 'Carousel'
 GROUP BY 1, 2, 3, 4
) Carousel
on Carousel.Week_Number = ALL_COUNTS.Week_Number
and Carousel.Marketer_Type = ALL_COUNTS.Marketer_Type
and Carousel.Location = ALL_Counts.Location
and Carousel.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--App_Installs--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_App_Installs,
        SUM(Campaign_Weekly_GR)                 AS S_App_Installs
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_creative_format = 'AppInstall'
 GROUP BY 1, 2, 3, 4
) App_Installs
on App_Installs.Week_Number = ALL_COUNTS.Week_Number
and App_Installs.Marketer_Type = ALL_COUNTS.Marketer_Type
and App_Installs.Location = ALL_Counts.Location
and App_Installs.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--3rd_Party_data_targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_3rd_party_data_targeting,
        SUM(Campaign_Weekly_GR)                 AS S_3rd_party_data_targeting
 FROM small_facm
     LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
          JOIN (
                 SELECT hisg.hisg_stats_date,
                        hisg.hisg_campaign_id
                 FROM hisg_segment_campaign_d hisg
                 WHERE hisg.hisg_stats_date >=  (SELECT start_date from calender)
                   and hisg.hisg_stats_date <= (SELECT end_date from calender)
                   and hisg.hisg_segment_type in ('LiveRamp - Acxiom 3rd party data $0.10',
                                                  'Liveramp - B2B',
                                                  'LiveRamp - Connexity 3rd party data',
                                                  'LiveRamp - Crossix 3rd party data $1.35',
                                                  'LiveRamp - 3rd Party Data - Crossix - $0.85',
                                                  'LiveRamp - Acxiom 3rd party data $0.05',
                                                  'Bluekai',
                                                  'Liveramp',
                                                  'Adobe',
                                                  'Krux',
                                                  'Liveramp - Dun&Bradstreet',
                                                  'Liveramp - CRM')
                ) his
            on his.hisg_stats_date = small_facm.facm_est_stats_date
            and his.hisg_campaign_id = small_facm.campaign_ID
 GROUP BY 1, 2 , 3, 4
) rd_party_data_targeting
on rd_party_data_targeting.Week_Number = ALL_COUNTS.Week_Number
and rd_party_data_targeting.Marketer_Type = ALL_COUNTS.Marketer_Type
and rd_party_data_targeting.Location = ALL_Counts.Location
and rd_party_data_targeting.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Custom_Audiences--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Custom_Audiences,
        SUM(Campaign_Weekly_GR)                 AS S_Custom_Audiences
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE (hics_pixel_excluded_segments_id is not null
         or hics_pixel_included_segments_id is not null
         or hics_clickers_excluded_segments_id is not null
         or hics_clickers_included_segments_id is not null)
 GROUP BY 1, 2 , 3, 4
) Custom_Audiences
on Custom_Audiences.Week_Number = ALL_COUNTS.Week_Number
and Custom_Audiences.Marketer_Type = ALL_COUNTS.Marketer_Type
and Custom_Audiences.Location = ALL_Counts.Location
and Custom_Audiences.IS_CON = ALL_Counts.IS_CON

LEFT JOIN
--Dynamic_Titles-------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', traffic.faad_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name                    AS Location,
        dima.dima_type_name                             AS Marketer_Type,
        NVL(IS_CON,0)                                   AS IS_CON,
        COUNT(DISTINCT traffic.Marketer_ID)             AS Q_Dynamic_Titles,
        SUM(Campaign_Weekly_GR)                         AS S_Dynamic_Titles
 FROM (
          SELECT faad.faad_est_stats_date,
                 faad.faad_marketer_id        AS Marketer_ID,
                 faad.faad_campaign_id        AS Campaign_ID,
                 faad.faad_target_ad_id       AS AD_ID,
                 SUM(faad.faad_gross_revenue) AS Campaign_Weekly_GR
          FROM  db_outbrain.outbrain.faad_ad_traffic_d faad
          WHERE faad.faad_est_stats_date >= (SELECT start_date from calender)
            and faad_est_stats_date <= (SELECT end_date from calender)
            and faad_campaign_id in (
                                    SELECT Campaign_Id
                                    FROM Campaign_List
                                    )
          GROUP BY 1, 2, 3, 4
      ) traffic
      LEFT JOIN con on con.Marketer_ID = traffic.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', traffic.faad_est_stats_date)
          JOIN (
     SELECT diad.diad_marketer_id,
            diad.diad_id
     FROM diad_ad diad
     WHERE diad.diad_title like '%${%'
               ) ad
               on ad.diad_marketer_id = traffic.Marketer_ID
                   and ad.diad_id = traffic.AD_ID
          JOIN dima_small dima
               on dima.dima_id = traffic.Marketer_ID
 GROUP BY 1, 2 , 3 ,4
) Dynamic_Titles
on Dynamic_Titles.Week_Number = ALL_COUNTS.Week_Number
and Dynamic_Titles.Marketer_Type = ALL_COUNTS.Marketer_Type
and Dynamic_Titles.Location = ALL_Counts.Location
and Dynamic_Titles.IS_CON = ALL_Counts.IS_CON
LEFT JOIN
--Wifi_Targeting--------------------------------------------------------------------------------------------------
(
 SELECT DATE_TRUNC('WEEK', facm_est_stats_date) AS Week_Number,
        dima_sales_rep_location_name            AS Location,
        dima_type_name                          AS Marketer_Type,
        NVL(IS_CON,0)                           AS IS_CON,
        COUNT(DISTINCT small_facm.Marketer_ID)  AS Q_Wifi_Targeting,
        SUM(Campaign_Weekly_GR)                 AS S_Wifi_Targeting
 FROM small_facm
 LEFT JOIN con on con.Marketer_ID = small_facm.Marketer_ID and con.Week_Number = DATE_TRUNC('WEEK', small_facm.facm_est_stats_date)
 WHERE hics_is_wifi_targeting = 'true'
 and hics_stats_date >= '2020-06-03'
 GROUP BY 1, 2, 3, 4
) Wifi_Targeting
on Wifi_Targeting.Week_Number = ALL_COUNTS.Week_Number
and Wifi_Targeting.Marketer_Type = ALL_COUNTS.Marketer_Type
and Wifi_Targeting.Location = ALL_Counts.Location
and Wifi_Targeting.IS_CON = ALL_Counts.IS_CON
ORDER BY 1
;


