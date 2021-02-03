create table TableauCatalogData
( report_name varchar(100),
  stats_date datetime,
  query text,
  PRIMARY KEY (report_name, stats_date)
);