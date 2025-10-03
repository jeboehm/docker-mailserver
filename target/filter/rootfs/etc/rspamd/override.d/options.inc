{% if env.DNS_SERVERS %}
  dns {
    nameserver = "{= env.DNS_SERVERS =}";
  }
{% endif %}
