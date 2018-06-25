![Gobierto](https://gobierto.es/assets/logo_gobierto.png)

# Gobierto charts

### rowchart(context, data, *options*)
![imagen](https://user-images.githubusercontent.com/817526/40486668-37d462e0-5f62-11e8-842c-925b83e8473c.png)
- **context**: Mandatory. HTML selector where to insert chart. Ej: `#rowchart`
- **data**: Mandatory. JSON object to be depicted.
    - The input object, must be an array of key-value objects. Sample:
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
    - tooltipContainer: where is placed the tooltip. String selector, e.g. "#some", ".some" (default: body)
- **usage**:
```HTML
<!-- The chart size is determined by its parent container-->
<div id="rowchart" class="rowchart"></div>
```
```js
$.getJSON("data/rowchart.json", (data) => {

  // prepare the data BEFORE the call, e.g. order higher to lower
  data.sort((a, b) => a.value - b.value)

  // Append any custom option you wish
  let opts = {
    itemHeight: 20
  }

  $(".rowchart").each((i, container) => {
    rowchart(`#${container.id}`, data, opts)
  })
});
```

### punchcard(context, data, *options*)
![imagen](https://user-images.githubusercontent.com/817526/40620537-766a521e-6299-11e8-94ca-c67790e4a46c.png)
- **context**: Mandatory. HTML selector where to insert chart. Ej: `#punchcard`
- **data**: Mandatory. JSON object to be depicted.
    - The input object, must be an array of key-value objects which value is, as well, another array of key-value objects. Sample:
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
    - tooltipContainer: where is placed the tooltip. String selector, e.g. "#some", ".some" (default: body)
- **usage**:
```HTML
<!-- The chart size is determined by its parent container-->
<div id="punchcard" class="punchcard"></div>
```
```js
$.getJSON("data/punchcard.json", (data) => {

  // prepare the data BEFORE the call, e.g. group by month
  for (var i = 0; i < data.length; i++) {
    let nest = d3.nest()
      .key(d => d3.timeMonth((new Date(d.key))))
      .rollup(d => _.sumBy(d, 'value'))
      .entries(data[i].value)
      .map(g => {
        g.key = d3.timeMonth(new Date(d3.timeFormat("%Y/%m/%d")(new Date(g.key))))
        return g
      })

    // update original data
    data[i].value = nest
  }

  // Append any custom option you wish
  let opts = {
    title: 'Cool Punchcard',
    xTickFormat: (d, i, arr) => ((arr.length + i) % 3) ? null : d3.timeFormat("%b %y")(d)
  }

  $(".punchcard").each((i, container) => {
    punchcard(`#${container.id}`, data, opts)
  })
});
```
