<template>
  <div class="widget-text">
    <h1>{{ content.short }}</h1>
    <p>{{ content.long }}</p>
  </div>
</template>

<script>
// DEBUG: borrar esto
const items = [
  [
    "enim nost",
    "incididunt Lorem quisincididuntaliquip nisido magna elit"
  ],
  [
    "in ad non",
    "in cupidatatdo cillum sunt quis culpaculpa ipsumconsectetur aute eu anim adipisicing"
  ],
  [
    "ipsum i",
    "aliquip ut pariaturreprehenderit sit ad dolorminim proident"
  ],
  [
    "non ip",
    "eiusmod ullamco mollit utfugiat ad dolorsuntin aliquip consequat ut"
  ],
  [
    "magna c",
    "quieiusmod exercitationlaborumelit occaecat non aliquip voluptate"
  ],
  [
    "aliquip ",
    "Lorem eu nulla irureveniam nostrudminim cupidatat culpa do"
  ],
  [
    "id ad",
    "minim ea amet nonenimproident et Ut veniam exercitation"
  ],
  [
    "deserunt",
    "quisincididunt ex ea occaecat incillum irure Lorem"
  ],
  [
    "aute sin",
    "elit do indoloreculpa amet qui ullamcoExcepteur incididunt ea"
  ],
  [
    "in eu esse ",
    "ut velit in Loremin officiadolor voluptatequis minim deserunt"
  ],
  [
    "dolore la",
    "reprehenderit eu ipsum Duisirure est Loremin culpa"
  ],
  [
    "do deser",
    "cillum enimenimminim nostrud utsunt commodo reprehenderit"
  ],
  [
    "et occae",
    "laborumquis ex dolor eamollit cupidatatid minimelit pariatur laborum exercitation labore"
  ],
  [
    "dolor",
    "mollit Excepteursint idin Ut adipisicing laborumcommodo"
  ],
  [
    "in minim off",
    "consequat ex laborum aute reprehenderitreprehenderit occaecat amet enim id"
  ],
  [
    "eiusm",
    "deseruntaliquipaliqua exet irure esse reprehenderit"
  ],
  [
    "esse d",
    "Ut animfugiat temporsitnisi in esse consequat officia"
  ],
  [
    "conse",
    "fugiat qui voluptate eiusmod doloredoloresunt reprehenderit qui"
  ],
  [
    "voluptate c",
    "magnanostrud dolorin adipisicing Lorem exercitation"
  ],
  [
    "adipis",
    "magna ea ametdolore laborum enim deseruntnon sitdolore nostrud cillum aliquip elit"
  ]
]

export default {
  name: "WidgetHTML",
  computed: {
    content() {
      const [short, long] = items[Math.floor(Math.random() * items.length)]
      return {
        short, long
      };
    }
  }
}
</script>