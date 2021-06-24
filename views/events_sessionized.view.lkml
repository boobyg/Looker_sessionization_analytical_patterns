################################################################
# Events View
################################################################

view: events_sessionized {
  view_label: "Events"

  derived_table: {
    sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE())) ;;
##    distribution: "event_id"
##    sortkeys: ["created_at"]
    sql: SELECT
      ROW_NUMBER() OVER (ORDER BY log.created_at) AS event_id
    , log.ip_address
    , log.user_id
    , log.os
    , log.uri
    , log.event_type
    , log.browser
    , log.traffic_source
    , log.created_at
    , sessions.unique_session_id
    , ROW_NUMBER () OVER (PARTITION BY unique_session_id ORDER BY log.created_at) AS event_sequence_within_session
    , ROW_NUMBER () OVER (PARTITION BY unique_session_id ORDER BY log.created_at desc) AS inverse_event_sequence_within_session
FROM `test-co-ramp.testco.events` AS log
INNER JOIN ${sessions.SQL_TABLE_NAME} AS sessions
  ON log.user_id = sessions.user_id
  AND log.ip_address = sessions.ip_address
  AND log.created_at >= sessions.session_start
  AND log.created_at < sessions.next_session_start
--bg WHERE DATE(log.created_at) >= DATE_ADD (DATE_TRUNC(CURRENT_DATE,DAY), INTERVAL -59 DAY)
-- bg                 AND DATE(log.created_at) <  DATE_ADD(DATE_ADD (DATE_TRUNC(CURRENT_DATE,DAY), INTERVAL -59 DAY ) , INTERVAL 60 DAY) -- optional limit of events table to only past 60 days

 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: event_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.event_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: unique_session_id {
    type: number
    value_format_name: id
    hidden: yes
    sql: ${TABLE}.unique_session_id ;;
  }

  dimension: page_name {
    type: string
    sql: ${TABLE}.uri ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }
  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
    suggest_explore: dynamic_filter
    suggest_dimension: dynamic.filter.traffic_source
  }

  dimension: event_sequence_within_session {
    type: number
    value_format_name: id
    sql: ${TABLE}.event_sequence_within_session ;;
  }

  dimension: inverse_event_sequence_within_session {
    type: number
    value_format_name: id
    sql: ${TABLE}.inverse_event_sequence_within_session ;;
  }

  dimension: page_name_custom_sort {
    label: "Page Name (Custom Sort)"
    alpha_sort: yes
    case: {
      when: {
        sql: ${page_name} = '/register' ;;
        label: "0.Registered"
      }
      when: {
        sql: ${page_name} = '/cart' ;;
        label: "2.Cart"
      }
      when: {
        sql: ${page_name} = '/purchase' ;;
        label: "3.Purchase"
      }
      else:   "1.Other"
      }
    suggest_explore: dynamic_filter
    suggest_dimension: dynamic_filter.page_name_custom_sort

    }

  dimension: is_cancelled {
    type: yesno
    sql: ${TABLE}.event_type = 'Cancel' ;;
  }


  set: detail {
    fields: [
      event_id,
      #ip_address,
      user_id,
      #os,
      traffic_source,
      #event_time_time,
      unique_session_id,
      event_sequence_within_session,
      inverse_event_sequence_within_session,
      #user_first_session_time,
      #session_landing_page,
      #session_exit_page
    ]
  }
}
