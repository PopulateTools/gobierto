const dashboards = {
  data: [{
    id: 0,
    type: "gobierto_dashboards-dashboards",
    attributes: {
      title:
        "Voluptate amet quis eu ipsum dolor veniam esse eiusmod ea labore.",
      visibility_level: "draft",
      context: null,
      widget_configuration: [
        {
          i: "203888c6-338d-4c82-9053-2e5ce0d80391",
          type: "HTML",
          x: 0,
          y: 0,
          w: 12,
          h: 4,
          raw:
            "<h1>Culpa amet quis voluptate cillum.</h1><p>Lorem anim elit tempor consectetur labore consectetur eiusmod cupidatat mollit sit labore incididunt minim. Et anim quis quis do veniam. Excepteur ipsum anim id consectetur duis nisi ullamco velit eiusmod cupidatat. Dolore fugiat voluptate duis ex irure sunt dolor excepteur nulla. Nisi ea non sint excepteur duis occaecat. Voluptate dolore do duis labore tempor deserunt ex occaecat veniam esse id est dolor.\r\n</p>"
        },
        {
          i: "768f8ed8-d08a-4048-bc67-b5dadaeb09bd",
          type: "INDICATOR",
          x: 0,
          y: 3,
          w: 6,
          h: 7,
          indicator: "indicator-0",
          subtype: "individual"
        },
        {
          i: "768f8ed8-d08a-4048-bc67-b50909eb09bd",
          type: "INDICATOR",
          x: 6,
          y: 3,
          w: 6,
          h: 9,
          indicator: "indicator-0",
          subtype: "table"
        }
      ],
      links: {
        foo: null
      }
    }
  },{
    id: 1,
    type: "gobierto_dashboards-dashboards",
    attributes: {
      title:
        "Ullamco ullamco ipsum nisi sit do labore fugiat ipsum consectetur.",
      visibility_level: "active",
      context: null,
      widget_configuration: [
        {
          type: "HTML",
          w: 6,
          h: 9,
          i: "7210b284-f42d-4dc5-a3d9-a3e76d540e43",
          x: 0,
          y: 0,
          raw:
            "<h1>Nulla irure minim minim aliqua ex occaecat aliqua laborum minim laborum anim aute id magna.</h1><p>Sunt minim dolore occaecat ut consequat non mollit. Ea non eiusmod anim laborum sint aute tempor nisi adipisicing ex consectetur consequat. Ex ullamco Lorem aliqua incididunt culpa labore dolor dolor dolor magna sit. Laborum sint sit nostrud nostrud laboris quis eiusmod duis exercitation magna consequat ex cupidatat exercitation. Elit fugiat aliqua est elit proident veniam commodo commodo qui cupidatat fugiat esse. Mollit velit indicator-0 commodo proident nisi excepteur labore laboris. Enim et aute elit nulla elit laborum sit laboris eiusmod voluptate consequat dolor laborum laborum.\r\n</p>"
        },
        {
          x: 6,
          y: 0,
          i: "INDICATOR-67y6q7",
          type: "INDICATOR",
          w: 6,
          h: 9,
          indicator: "indicator-1",
          subtype: "table"
        }
      ],
      links: { foo: null }
    }
  },{
    id: 2,
    type: "gobierto_dashboards-dashboards",
    attributes: {
      title:
        "Ullamco ullamco ipsum nisi sit do labore fugiat ipsum consectetur.",
      visibility_level: "active",
      context: null,
      widget_configuration: [
        {
          w: 6,
          h: 9,
          i: "7210b284-f42d-4dc5-a3d9-a3e76d540e43",
          x: 0,
          y: 0,
          type: "HTML",
          raw:
            "<h1>Nulla irure minim minim aliqua ex occaecat aliqua laborum minim laborum anim aute id magna.</h1><p>Sunt minim dolore occaecat ut consequat non mollit. Ea non eiusmod anim laborum sint aute tempor nisi adipisicing ex consectetur consequat. Ex ullamco Lorem aliqua incididunt culpa labore dolor dolor dolor magna sit. Laborum sint sit nostrud nostrud laboris quis eiusmod duis exercitation magna consequat ex cupidatat exercitation. Elit fugiat aliqua est elit proident veniam commodo commodo qui cupidatat fugiat esse. Mollit velit indicator-0 commodo proident nisi excepteur labore laboris. Enim et aute elit nulla elit laborum sit laboris eiusmod voluptate consequat dolor laborum laborum.\r\n</p>",
        },
        {
          x: 6,
          y: 0,
          i: "INDICATOR-67y6q7",
          type: "INDICATOR",
          w: 6,
          h: 9,
          indicator: "indicator-1",
          subtype: "table"
        }
      ],
      links: { foo: null }
    }
  }],
  links: {
    self: null
  }
};

const dashboardData = {
  "data": [
    {
      "name": "indicator-0",
      "values": [
        {
          "value": 28,
          "objective": 55,
          "date": "2018-07-30"
        },
        {
          "value": 13,
          "objective": 95,
          "date": "2017-08-10"
        },
        {
          "value": 37,
          "objective": 74,
          "date": "2016-08-04"
        },
        {
          "value": 32,
          "objective": 98,
          "date": "2015-05-08"
        },
        {
          "value": 48,
          "objective": 57,
          "date": "2019-12-07"
        }
      ]
    },
    {
      "name": "indicator-1",
      "values": [
        {
          "value": 19,
          "objective": 97,
          "date": "2015-08-15"
        },
        {
          "value": 30,
          "objective": 87,
          "date": "2016-09-13"
        },
        {
          "value": 32,
          "objective": 76,
          "date": "2020-08-28"
        },
        {
          "value": 16,
          "objective": 58,
          "date": "2015-01-01"
        },
        {
          "value": 45,
          "objective": 59,
          "date": "2020-09-05"
        },
        {
          "value": 27,
          "objective": 68,
          "date": "2017-03-24"
        }
      ]
    }
  ]
}

export class Mock {
  constructor() {
    const { data } = dashboards
    this.dashboard = data[0]
    // this.dashboard = dashboards.data[Math.floor(Math.random() * dashboards.data.length)]

    // const randomElements = data.slice(0, Math.floor(Math.random() * data.length) + 1)
    // dashboards.data = randomElements
    dashboards.data = this.dashboard

    this.dashboards = dashboards
    this.dashboardData = dashboardData
  }
}