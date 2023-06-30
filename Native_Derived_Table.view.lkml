view: native_derived_table {
 # If necessary, uncomment the line below to include explore_source.
# include: "sessionization_analytical_patterns.model.lkml"

     derived_table: {
      explore_source: events_sessionized {
        column: traffic_source {}
        column: count { field: sessions.count }
        column: average_session_length_seconds { field: session_facts.average_session_length_seconds }
        column: abandon_sessions_count { field: session_facts.abandon_sessions_count }
        filters: {
          field: events_sessionized.page_name_custom_sort
          value: ""
        }
        filters: {
          field: session_facts.is_abondoned
          value: "Yes"
        }
        filters: {
          field: session_facts.session_landing_page
          value: "Cart"
        }
        filters: {
          field: session_facts.session_exit_page
          value: ""
        }
      }
      datagroup_trigger: example_datagroup
    }

  dimension:  primary_key{
    primary_key:yes
    sql:GENERATE_UUID ();;

  }

    dimension: traffic_source {
      label: "Events Traffic Source"
    }
    dimension: count {
      type: number
    }
    dimension: average_session_length_seconds {
      label: "Sessions Average Session Length Seconds"
      value_format: "#,##0"
      type: number
    }
    dimension: abandon_sessions_count {
      label: "Sessions Abandon Sessions Count"
      type: number
    }
  }
