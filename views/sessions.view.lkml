################################################################
# Sessions View
################################################################

view: sessions {
  derived_table: {
 #   sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE())) ;;
##    distribution: "user_id"
##    sortkeys: ["session_start"]
    sql: WITH lag AS
        (SELECT
                  logs.created_at AS created_at
                , logs.user_id AS user_id
                , logs.ip_address AS ip_address
                , TIMESTAMP_DIFF( logs.created_at,
                    LAG(logs.created_at) OVER ( PARTITION BY logs.user_id, logs.ip_address ORDER BY logs.created_at)
                  ,  minute) AS idle_time
              FROM `test-co-ramp.testco.events` as logs
              WHERE DATE(logs.created_at) >= DATE_ADD (DATE_TRUNC(CURRENT_DATE,DAY), INTERVAL -59 DAY)
                AND DATE(logs.created_at) <  DATE_ADD(DATE_ADD (DATE_TRUNC(CURRENT_DATE,DAY), INTERVAL -59 DAY ) , INTERVAL 60 DAY) -- optional limit of events table to only past 60 days
              )
        SELECT
          lag.created_at AS session_start
          , lag.idle_time AS idle_time
          , lag.user_id AS user_id
          , lag.ip_address AS ip_address
          , ROW_NUMBER () OVER (ORDER BY lag.created_at) AS unique_session_id
          , ROW_NUMBER () OVER (PARTITION BY COALESCE(CAST(lag.user_id as STRING), CAST(lag.ip_address as STRING)) ORDER BY lag.created_at) AS session_sequence
           , COALESCE(
                LEAD(lag.created_at) OVER (PARTITION BY lag.user_id, lag.ip_address ORDER BY lag.created_at)
              , '6000-01-01') AS next_session_start
        FROM lag
        WHERE (lag.idle_time > 60 OR lag.idle_time IS NULL)  -- session threshold (currently set at 60 minutes)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: session_start_at {
    type: time
    hidden: yes
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: ${TABLE}.session_start ;;
  }

  dimension: idle_time {
    type: number
    value_format: "0"
    sql: ${TABLE}.idle_time ;;
  }

  dimension: unique_session_id {
    type: number
    value_format_name: id
    primary_key: yes
    sql: ${TABLE}.unique_session_id ;;
  }

  dimension: session_sequence {
    type: number
    value_format_name: id
    sql: ${TABLE}.session_sequence ;;
  }

  dimension_group: next_session_start_at {
    type: time
    convert_tz: no
    timeframes: [time, date, week, month]
    sql: ${TABLE}.next_session_start ;;
  }

  measure: count_distinct_sessions {
    type: count_distinct
    sql: ${unique_session_id} ;;
  }

  set: detail {
    fields: [
      session_start_at_time,
      idle_time,
      unique_session_id,
      session_sequence,
      next_session_start_at_time
    ]
  }
}
