view: dynamic_filter {
    derived_table: {
      sql:
     SELECT
        CASE
        WHEN events_sessionized.uri = '/register'  THEN '0.Registered'
        WHEN events_sessionized.uri = '/cart'  THEN '2.Cart'
        WHEN events_sessionized.uri = '/purchase'  THEN '3.Purchase'
        ELSE '1.Other'
        END AS page_name_custom_sort,
            events_sessionized.traffic_source  AS traffic_source
        FROM `test-co-ramp.TestcoScratch.LR_JSNUL1623932295480_events_sessionized` AS events_sessionized
        WHERE ((events_sessionized.traffic_source ) = 'Adwords'
            OR (events_sessionized.traffic_source ) = 'Email') AND (CASE
        WHEN events_sessionized.uri = '/register'  THEN '0.Registered'
        WHEN events_sessionized.uri = '/cart'  THEN '2.Cart'
        WHEN events_sessionized.uri = '/purchase'  THEN '3.Purchase'
        ELSE '1.Other'
        END) = '0.Registered'
        GROUP BY
            1,
            2
    UNION ALL
     SELECT
      CASE
      WHEN events_sessionized.uri = '/register'  THEN '0.Registered'
      WHEN events_sessionized.uri = '/cart'  THEN '2.Cart'
      WHEN events_sessionized.uri = '/purchase'  THEN '3.Purchase'
      ELSE '1.Other'
      END,
      events_sessionized.traffic_source
      FROM `test-co-ramp.TestcoScratch.LR_JSNUL1623932295480_events_sessionized` AS events_sessionized
      WHERE ((events_sessionized.traffic_source ) = 'Facebook' OR (events_sessionized.traffic_source ) = 'Organic' OR (events_sessionized.traffic_source ) = 'YouTube') AND (CASE
      WHEN events_sessionized.uri = '/register'  THEN '0.Registered'
      WHEN events_sessionized.uri = '/cart'  THEN '2.Cart'
      WHEN events_sessionized.uri = '/purchase'  THEN '3.Purchase'
      ELSE '1.Other'
      END) = '2.Cart'
      GROUP BY
          1,
          2;;

            }

          dimension: page_name_custom_sort {
            label: "Events Page Name (Custom Sort)"
#          suggest_explore: user
#           suggest_dimension: page_name_custom_sort

          }
          dimension: traffic_source {
            label: "Traffic Source"
#            suggest_dimension: traffic_source
          }


      }
