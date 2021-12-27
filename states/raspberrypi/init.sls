{% if "raspberrypi" in pillar %}

{%- for option in pillar.raspberrypi.cmdline_options %}
raspberrypi_cmdline_{{ option.option }}:
  cmd.run:
    - name: sed -i "s/$/ {{ option.option }}/" "/boot/cmdline.txt"
    - unless: grep -q "{{ option.option }}" "/boot/cmdline.txt";
{% endfor %}

{%- for option in pillar.raspberrypi.config_options %}
raspberrypi_config_{{ option.option }}:
  file.line:
    - name: /boot/config.txt
    - content: {{ option.option }}
    - after: ".*arm_freq=.*"
    - mode: ensure
    {%- if "match" in option %}
    - match: {{ option.match }}
    {%- endif %}
{% endfor %}

{% endif %}