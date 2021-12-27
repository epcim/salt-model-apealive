pushprox:
  proxy: {}
  source:
    engine: http
    version: 0.1.0
  dir:
    {%- if grains.kernel == 'Windows' %}
    base: c:\apps\pushprox
    {%- endif %}
