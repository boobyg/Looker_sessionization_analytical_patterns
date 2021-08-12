project_name: "\models\sessionization_analytical_patterns"

constant: currency_html {

  value: "
  {% if currency_parameter._parameter_value == 'EURO' %}
  €
  {% else %}
  {% if copa.COUNTRY._in_query or copa.filter_on_country._in_query %}
  {{ dim_compass_bu.currency_code._value }}
  {% else %}
  €
  {% endif %}
  {% endif %}"
}

constant: environment {
  value: "{% if _user_attributes['gcp_environment'] == 'qa' %}np{% elsif _user_attributes['gcp_environment'] == 'np'%}pd{% else %}pd{% endif %}"
}

application: MyApp {
  label: "My Dashboard"
  # url: "http://localhost:8080/dist/data-portal.js"
  file: "apps/data-portal.js"

  entitlements: {
    use_embeds: yes
    use_form_submit: yes
    core_api_methods: [
      "me",
      "all_user_attributes",
      "user_attribute_user_values",
      "create_user_attribute",
      "update_user_attribute",
      "user_roles",
      "all_boards",
      "board"
    ]
  }
}

constant: CONNECTION_NAME {
  value: "google_analytics_sample"
  export: override_required
}
