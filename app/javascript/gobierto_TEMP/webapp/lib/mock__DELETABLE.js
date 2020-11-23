/* https://www.json-generator.com/#

[
  '{{repeat(5, 7)}}',
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
        "title": "Cillum occaecat incididunt do adipisicing proident.",
        "visibility_level": "active",
        "context": null,
        "widget_configuration": [
          {
            "id": "5ca0ca01-1dec-46cf-b322-db43f55ba025",
            "type": "HTML",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 12,
              "h": 3
            },
            "attributes": {
              "name": "ex",
              "template": "",
              "raw": "<h1>Exercitation commodo eiusmod cupidatat non eu magna esse qui sint.</h1><p>Nulla consectetur ea et id pariatur aliqua amet. Adipisicing excepteur commodo amet exercitation est voluptate adipisicing dolor irure aute commodo. Adipisicing tempor aliquip proident nisi deserunt velit sint reprehenderit. Dolor consectetur reprehenderit ut magna. Eu in velit nisi nostrud occaecat occaecat incididunt est non officia.\r\n</p>"
            }
          },
          {
            "id": "93fcb19a-8513-484e-8038-fb00a83622a7",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 2,
              "w": 2,
              "h": 2
            },
            "attributes": {
              "name": "fugiat",
              "template": "",
              "raw": "<h1>Duis consectetur mollit voluptate mollit irure reprehenderit.</h1><p>Dolore non et ea enim nulla quis dolore nostrud. Do Lorem et veniam Lorem est laboris nulla cillum excepteur nostrud ad reprehenderit aliqua. Et voluptate amet eiusmod aute incididunt culpa eiusmod dolore ex nulla anim. Consectetur proident enim ad magna exercitation officia est ullamco cillum magna incididunt ea incididunt.\r\n</p>"
            }
          },
          {
            "id": "f6c63a8c-8eb6-4ed4-9b2a-23b58739daf4",
            "type": "HTML",
            "layout": {
              "x": 4,
              "y": 5,
              "w": 6,
              "h": 8
            },
            "attributes": {
              "name": "consectetur",
              "template": "",
              "raw": "<h1>Deserunt sunt ipsum laborum enim minim deserunt deserunt est.</h1><p>Quis eu pariatur excepteur incididunt ullamco minim do. Ullamco ad sit excepteur laborum culpa nisi. Aute laboris nostrud ad sint velit eiusmod ex consectetur. Commodo et eiusmod in ea nostrud officia nisi proident eiusmod consequat.\r\n</p>"
            }
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
        "title": "Ea irure fugiat occaecat laboris.",
        "visibility_level": "active",
        "context": null,
        "widget_configuration": [
          {
            "id": "47b04637-0ae3-4cb2-a7a8-319f46c80eb7",
            "type": "HTML",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "amet",
              "template": "",
              "raw": "<h1>Sunt exercitation in enim dolore anim deserunt sit laboris proident voluptate anim nulla labore qui.</h1><p>Lorem amet culpa occaecat irure sunt commodo duis enim reprehenderit elit elit. Reprehenderit est dolor sint occaecat in id. Cupidatat veniam consequat magna cillum est fugiat aliquip.\r\n</p>"
            }
          },
          {
            "id": "1d5a9b0d-beb8-432a-b655-e5d8abf0fcd4",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "aute",
              "template": "",
              "raw": "<h1>Cupidatat officia duis non deserunt.</h1><p>Magna aute do ut voluptate ut ea elit sint commodo exercitation magna deserunt proident eiusmod. Nulla et consequat do anim sit eiusmod et proident ad dolore. Mollit excepteur velit ullamco laborum et magna culpa irure ex laborum tempor. Lorem velit pariatur qui tempor adipisicing est et. Pariatur cupidatat excepteur ea anim ullamco exercitation ut veniam quis irure et id ex tempor. Mollit occaecat ea ipsum est tempor. Veniam irure nostrud non anim laboris laboris exercitation.\r\n</p>"
            }
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
        "title": "Commodo quis magna nisi pariatur.",
        "visibility_level": "active",
        "context": null,
        "widget_configuration": [
          {
            "id": "d9d70b73-7b3b-412d-9584-2046e6609e69",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "sint",
              "template": "",
              "raw": "<h1>Proident in cillum cupidatat duis adipisicing ut ullamco id ipsum consequat ullamco excepteur ea.</h1><p>Ullamco nisi adipisicing duis tempor non officia nulla amet nulla anim nulla magna. Est excepteur sint amet eiusmod velit duis qui irure proident tempor esse. Adipisicing reprehenderit esse non labore labore non enim nulla eiusmod non Lorem. Ipsum amet ipsum est nostrud qui elit sint adipisicing velit adipisicing mollit qui. Sunt commodo adipisicing labore dolor nisi deserunt ut duis consequat nulla ut.\r\n</p>"
            }
          },
          {
            "id": "ce5e6a32-fb2e-4b83-bbdf-f74c470ea8a7",
            "type": "HTML",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "officia",
              "template": "",
              "raw": "<h1>Anim Lorem commodo fugiat laboris elit enim sunt.</h1><p>Adipisicing incididunt ea dolore tempor ipsum sunt velit. Qui sit quis qui tempor quis. Minim proident ut ex magna officia est pariatur velit duis.\r\n</p>"
            }
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
      "id": 3,
      "type": "gobierto_dashboards-dashboards",
      "attributes": {
        "title": "Elit laborum aliqua tempor esse esse deserunt culpa sint ea sunt irure incididunt tempor.",
        "visibility_level": "draft",
        "context": null,
        "widget_configuration": [
          {
            "id": "3e493071-d796-4a76-a550-ff443b085802",
            "type": "HTML",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "officia",
              "template": "",
              "raw": "<h1>Tempor qui id et Lorem excepteur dolor pariatur sit eu amet.</h1><p>Elit nulla est duis laborum adipisicing. Eu labore veniam velit sit eu. Nulla sint in cillum non aute deserunt ut ipsum id velit pariatur nostrud labore. Do ex nostrud laborum ipsum anim enim amet ipsum. Veniam minim labore irure deserunt. Minim aliquip culpa do mollit proident nisi pariatur ullamco ad dolore cillum.\r\n</p>"
            }
          },
          {
            "id": "deeeac8d-6144-4221-b79f-94514a674b51",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "consectetur",
              "template": "",
              "raw": "<h1>Elit velit non ea aliqua adipisicing reprehenderit nostrud sunt.</h1><p>Dolor sunt sunt excepteur anim sint. Aliquip consectetur duis ullamco consequat anim ex excepteur eu. Lorem labore enim quis ut magna Lorem sunt aliqua. Dolor nulla occaecat duis incididunt eiusmod amet. Irure non aliquip nostrud irure ea. Aute enim pariatur excepteur ad incididunt velit sit.\r\n</p>"
            }
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
      "id": 4,
      "type": "gobierto_dashboards-dashboards",
      "attributes": {
        "title": "Ea irure duis non amet sint exercitation.",
        "visibility_level": "draft",
        "context": null,
        "widget_configuration": [
          {
            "id": "4df143f8-63b8-4cf0-aa2c-2ee2e7ceb7e6",
            "type": "HTML",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "reprehenderit",
              "template": "",
              "raw": "<h1>Lorem id anim commodo cupidatat cillum eiusmod elit sit nisi aute officia deserunt ad commodo.</h1><p>Dolore velit deserunt labore veniam aliqua anim elit laborum ea dolor reprehenderit. Lorem minim consequat non sunt dolor ex eiusmod eiusmod excepteur consectetur. Duis officia mollit voluptate sit fugiat reprehenderit incididunt dolore mollit aliquip elit nulla velit sint. Sint fugiat occaecat magna exercitation Lorem cupidatat mollit proident Lorem est Lorem aliqua. Proident deserunt sunt eiusmod id. Nisi et duis in sint magna cupidatat esse mollit occaecat minim magna. Non aliqua non elit nulla exercitation tempor dolore aliqua incididunt labore.\r\n</p>"
            }
          },
          {
            "id": "d9c46268-5aed-468f-acee-6c393f329acd",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "aliqua",
              "template": "",
              "raw": "<h1>Laborum fugiat velit ullamco nulla.</h1><p>Proident deserunt eu Lorem elit. Ad ea ipsum sit ut in ex esse Lorem do tempor quis aliqua non. Id anim ea ut occaecat aute. Enim ea non reprehenderit tempor magna irure nulla anim.\r\n</p>"
            }
          },
          {
            "id": "11e53825-df3c-4946-a79f-57fa34c6ad36",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "voluptate",
              "template": "",
              "raw": "<h1>Dolore excepteur exercitation ea id in nisi.</h1><p>Lorem aliquip et et est eiusmod minim in et non. Veniam ea velit quis do excepteur nulla tempor duis eiusmod reprehenderit quis. Minim sunt commodo adipisicing aliquip tempor sit commodo commodo eiusmod velit et.\r\n</p>"
            }
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
      "id": 5,
      "type": "gobierto_dashboards-dashboards",
      "attributes": {
        "title": "Exercitation ea magna mollit deserunt in pariatur officia reprehenderit tempor.",
        "visibility_level": "draft",
        "context": null,
        "widget_configuration": [
          {
            "id": "d0f9e886-bf74-479e-8ef3-7b877feb3e57",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "exercitation",
              "template": "",
              "raw": "<h1>Nostrud consectetur qui sunt est officia pariatur do sunt commodo non esse dolore.</h1><p>Sit occaecat incididunt mollit anim. Eiusmod aute esse pariatur in est aliqua cillum consectetur incididunt cupidatat anim. Do culpa anim consectetur exercitation sit culpa.\r\n</p>"
            }
          },
          {
            "id": "39b01f91-b641-42c5-94d4-e22fef7a69a8",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "quis",
              "template": "",
              "raw": "<h1>Nulla deserunt enim mollit Lorem ullamco exercitation esse ipsum proident do laboris occaecat.</h1><p>Eiusmod sit non reprehenderit enim nulla nulla. Proident sunt occaecat ex quis. Ullamco ullamco elit ex enim nostrud Lorem sunt in dolore est deserunt. Nisi consequat minim occaecat magna do duis labore aliquip amet. Aliqua sit fugiat sunt tempor cillum. Irure aliquip laborum anim laboris fugiat consequat sint.\r\n</p>"
            }
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
      "id": 6,
      "type": "gobierto_dashboards-dashboards",
      "attributes": {
        "title": "Eu labore anim qui incididunt officia Lorem nostrud duis.",
        "visibility_level": "draft",
        "context": null,
        "widget_configuration": [
          {
            "id": "984c261d-91c8-47ed-83b3-1f004dcc9e79",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "nulla",
              "template": "",
              "raw": "<h1>Adipisicing amet eu mollit dolor deserunt ea deserunt ea ullamco magna sint ullamco.</h1><p>Aliquip proident ipsum in et elit veniam occaecat. Officia incididunt quis aute ea deserunt excepteur aliquip fugiat dolor sit deserunt voluptate culpa labore. Sit reprehenderit occaecat proident enim anim laborum non amet. Consequat reprehenderit aute exercitation tempor et laborum esse ex reprehenderit aliquip laborum sit tempor culpa. Eiusmod laborum qui ad eiusmod dolore magna magna ad voluptate aliquip laboris laboris cillum. Aute labore et nulla commodo enim do officia ex elit do. Qui et id quis sint duis nulla do sint enim ea sit enim est.\r\n</p>"
            }
          },
          {
            "id": "22912ece-cfb4-439e-be05-b31d405ffefc",
            "type": "INDICATOR",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "in",
              "template": "",
              "raw": "<h1>Aliquip incididunt Lorem exercitation dolore proident deserunt.</h1><p>Sint id velit laborum nisi id exercitation quis labore reprehenderit cupidatat est fugiat elit. Reprehenderit in adipisicing id laboris. Consequat in amet officia incididunt do nisi dolor exercitation. Anim pariatur eu tempor dolore ipsum aute reprehenderit ad reprehenderit elit id dolor aliquip. Nisi enim laboris dolor anim culpa aute proident.\r\n</p>"
            }
          },
          {
            "id": "f035f140-c330-4291-ac28-59f249f5d6c0",
            "type": "HTML",
            "layout": {
              "x": 0,
              "y": 0,
              "w": 6,
              "h": 2
            },
            "attributes": {
              "name": "sit",
              "template": "",
              "raw": "<h1>Nisi eu mollit velit consequat ex magna eiusmod.</h1><p>Laboris ea eiusmod do ullamco elit mollit non aliqua qui occaecat excepteur. Quis eiusmod est minim tempor. Magna cupidatat ea veniam veniam.\r\n</p>"
            }
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