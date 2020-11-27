/* https://www.json-generator.com/#

[
  '{{repeat(1, 3)}}',
  {
    data: {
      id: '{{index()}}',
      type: "gobierto_dashboards-dashboards",
      attributes: {
        title: '{{lorem()}}',
        visibility_level: '{{random("active", "draft")}}',
        context: null,
        widget_configuration: [
          '{{repeat(1, 4)}}',
          {
            id: '{{guid()}}',
            type: '{{random("HTML", "INDICATOR")}}',
            layout: {
              x: 0,
              y: 0,
              w: 6,
              h: 2
            },
            attributes: {
              name: '{{lorem(1, "word")}}',
              template: '',
              raw: '<h1>{{lorem()}}</h1><p>{{lorem(1, "paragraph")}}</p>'
            }
          }
        ],
        links: {
          foo: null
        }
      }
    },
    links: {
      self: null
    }
  }
] */

const dashboards = [
  {
    "data": {
      "id": 0,
      "type": "gobierto_dashboards-dashboards",
      "attributes": {
        "title": "Voluptate amet quis eu ipsum dolor veniam esse eiusmod ea labore.",
        "visibility_level": "draft",
        "context": null,
        "widget_configuration": [
          {
            "i": "203888c6-338d-4c82-9053-2e5ce0d80391",
            "type": "HTML",
            "x": 0,
            "y": 0,
            "w": 12,
            "h": 4,
            "raw": "<h1>Culpa amet quis voluptate cillum.</h1><p>Lorem anim elit tempor consectetur labore consectetur eiusmod cupidatat mollit sit labore incididunt minim. Et anim quis quis do veniam. Excepteur ipsum anim id consectetur duis nisi ullamco velit eiusmod cupidatat. Dolore fugiat voluptate duis ex irure sunt dolor excepteur nulla. Nisi ea non sint excepteur duis occaecat. Voluptate dolore do duis labore tempor deserunt ex occaecat veniam esse id est dolor.\r\n</p>",
          },
          {
            "i": "768f8ed8-d08a-4048-bc67-b5dadaeb09bd",
            "type": "INDICATOR",
            "x": 0,
            "y": 3,
            "w": 6,
            "h": 7,
            "indicator": "aliquip",
            "subtype": "individual"
          },
          {
            "i": "768f8ed8-d08a-4048-bc67-b50909eb09bd",
            "type": "INDICATOR",
            "x": 6,
            "y": 3,
            "w": 6,
            "h": 9,
            "indicator": "aliquip",
            "subtype": "table"
          }
        ],
        "links": {
          "foo": null
        }
      }
    },
    "links": {
      "self": null
    }
  },
  {
    "data": {
      "id": 1,
      "type": "gobierto_dashboards-dashboards",
      "attributes": {
        "title": "Ullamco ullamco ipsum nisi sit do labore fugiat ipsum consectetur.",
        "visibility_level": "active",
        "context": null,
        "widget_configuration": [
          {
            "i": "7210b284-f42d-4dc5-a3d9-a3e76d540e43",
            "type": "HTML",
            "x": 0,
            "y": 0,
            "w": 6,
            "h": 2,
            "indicator": "irure",
            "raw": "<h1>Nulla irure minim minim aliqua ex occaecat aliqua laborum minim laborum anim aute id magna.</h1><p>Sunt minim dolore occaecat ut consequat non mollit. Ea non eiusmod anim laborum sint aute tempor nisi adipisicing ex consectetur consequat. Ex ullamco Lorem aliqua incididunt culpa labore dolor dolor dolor magna sit. Laborum sint sit nostrud nostrud laboris quis eiusmod duis exercitation magna consequat ex cupidatat exercitation. Elit fugiat aliqua est elit proident veniam commodo commodo qui cupidatat fugiat esse. Mollit velit aliquip commodo proident nisi excepteur labore laboris. Enim et aute elit nulla elit laborum sit laboris eiusmod voluptate consequat dolor laborum laborum.\r\n</p>",
            "subtype": "table"
          }
        ],
        "links": {
          "foo": null
        }
      }
    },
    "links": {
      "self": null
    }
  },
  {
    "data": {
      "id": 2,
      "type": "gobierto_dashboards-dashboards",
      "attributes": {
        "title": "Sint sit est aliquip ullamco minim commodo.",
        "visibility_level": "draft",
        "context": null,
        "widget_configuration": [
          {
            "i": "16fafd28-f033-4dcf-b92f-f217ec8b2c96",
            "type": "INDICATOR",
            "x": 0,
            "y": 0,
            "w": 6,
            "h": 2,
            "indicator": "commodo",
            "raw": "<h1>Qui amet reprehenderit quis cupidatat.</h1><p>Sunt ullamco consectetur in eiusmod. Esse tempor cupidatat ad sit nostrud ut ut fugiat ex officia pariatur sit tempor occaecat. Laboris in velit pariatur aliquip proident reprehenderit. Occaecat ea velit aliquip deserunt non sunt eiusmod dolor. Nulla sunt cupidatat pariatur veniam id labore consequat occaecat. Cupidatat eu sint id ut consectetur nostrud esse aliquip pariatur.\r\n</p>",
            "subtype": "individual"
          },
          {
            "i": "3bdcff95-5bed-401f-8e31-de54e5da4004",
            "type": "INDICATOR",
            "x": 0,
            "y": 0,
            "w": 6,
            "h": 2,
            "indicator": "eu",
            "raw": "<h1>Lorem ex consequat deserunt enim irure ad laboris veniam dolore do veniam culpa esse.</h1><p>Nisi sunt laboris ullamco Lorem sint voluptate quis nostrud aliquip. In veniam exercitation ut do exercitation non laboris anim nisi veniam enim veniam consequat. Amet nisi nisi culpa dolore sit labore incididunt et do quis ea qui reprehenderit. Sint sint fugiat qui laborum. Voluptate culpa commodo ut minim reprehenderit sint nulla elit. Sit id aliquip do sunt aliqua qui anim pariatur ut aute.\r\n</p>",
            "subtype": "table"
          },
          {
            "i": "a2921fbb-bb1e-4e62-bec8-5530e48c58b3",
            "type": "HTML",
            "x": 0,
            "y": 0,
            "w": 6,
            "h": 2,
            "indicator": "eiusmod",
            "raw": "<h1>In veniam elit mollit exercitation labore culpa pariatur labore deserunt.</h1><p>Cillum cillum qui ullamco laboris deserunt velit fugiat aliquip. Et veniam aliqua irure pariatur pariatur dolor aliquip. Do amet fugiat ea esse laboris officia ea deserunt nulla veniam. Proident dolore amet ipsum minim voluptate veniam sint. Esse adipisicing anim laboris elit ipsum occaecat minim aliquip anim. Nulla do commodo dolore quis irure proident. Fugiat quis duis elit quis culpa minim labore laborum fugiat.\r\n</p>",
            "subtype": "table"
          },
          {
            "i": "3658648f-4468-44c3-9f63-472aaebe3b5a",
            "type": "HTML",
            "x": 0,
            "y": 0,
            "w": 6,
            "h": 2,
            "indicator": "ad",
            "raw": "<h1>Aliquip enim reprehenderit anim ad commodo ut cillum.</h1><p>Duis laborum pariatur duis amet cillum minim elit amet ea laboris est ullamco esse. Ipsum officia aliquip amet aliquip cillum proident magna. Incididunt do dolor nostrud ipsum minim fugiat mollit incididunt occaecat sit adipisicing nulla. Eiusmod nisi voluptate esse minim. Est enim laborum id proident velit id eiusmod. Enim ex labore cillum exercitation ut non laboris esse incididunt officia minim quis cupidatat. Aliquip minim consequat ex sunt sit tempor dolore amet aliquip.\r\n</p>",
            "subtype": "table"
          }
        ],
        "links": {
          "foo": null
        }
      }
    },
    "links": {
      "self": null
    }
  }
]

export class Mock {
  constructor() {
    this.dashboard = dashboards[0]
  }
}