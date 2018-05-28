![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto charts

##### rowchart(context, data, *options*)
- **context**: Mandatory. HTML selector where to insert chart. Ej: `#rowchart`
- **data**: Mandatory. JSON object to be depicted.
-- The input object, must be an array of key-value objects. Sample:
```json
[
  {
    "key": "Baird Hampton",
    "value": 24
  },
  {
    "key": "Holmes Mckay",
    "value": 83
  },
  ...
]
```
- **options**: Optional. Custom configurations
    - itemHeight: Row height. Number (default: 50)
    - gutter: Base padding. Number (default: 20)
    - margins: Set custom SVG margins. Based on gutter value. Object (default: `{
    	    top: gutter / 1.5,
    	    right: gutter,
    	    bottom: gutter * 1.5,
    	    left: gutter
    	  }`)
    - xTickFormat: how to format the X-axis ticks. Function (default: d => d)
    - yTickFormat: how to format the Y-axis ticks. Function (default: d => d)

##### punchcard(context, data, *options*)
- **context**: Mandatory. HTML selector where to insert chart. Ej: `#punchcard`
- **data**: Mandatory. JSON object to be depicted.
-- The input object, must be an array of key-value objects which value is, as well, another array of key-value objects. Sample:
```json
[
  {
    "key": "Unia",
    "value": [
      {
        "key": "2017/12/04",
        "value": 110
      },
      {
        "key": "2017/07/14",
        "value": 159
      },
      ...
    ]
  },
  {
    "key": "Grupoli",
    "value": [
      {
        "key": "2018/03/18",
        "value": 39
      },
      ...
    ]
  },
  ...
]
```
- **options**: Optional. Custom configurations
    - itemHeight: Row height. Number (default: 50)
    - gutter: Base padding. Number (default: 20)
    - margins: Set custom SVG margins. Based on gutter value. Object (default: `{
	    top: gutter * 1.5,
	    right: gutter,
	    bottom: gutter * 1.5,
	    left: gutter * 15
	  }`)
    - xTickFormat: how to format the X-axis ticks. Function (default: d => d)
    - yTickFormat: how to format the Y-axis ticks. Function (default: d => d)
