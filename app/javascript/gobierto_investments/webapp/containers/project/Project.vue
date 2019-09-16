<template>
  <div class="column">
    <h4 class="investments-project--heading">
      Detalle de proyecto
    </h4>
    <div class="pure-g">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside />
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main :project="project" />
      </div>
    </div>
  </div>
</template>

<script>
import Aside from "./Aside.vue";
import Main from "./Main.vue";

export default {
  name: "Project",
  components: {
    Aside,
    Main
  },
  data() {
    return {
      project: {}
    };
  },
  created() {
    // fake data
    this.project.title = "EDXXX-1 Actuacions i millores col·lectives";
    this.project.description = `La remodelació i reurbanització de la C-245 integrarà una nou carril bici, i un carril bus segregat i continu de 13 quilòmetres entre Castelldefels i Cornellà. La plataforma segregada per als autobusos permetrà augmentar la velocitat comercial almenys en un 25% en els trams urbans i guanyar puntualitat en Mataró.
    Mataró est également un centre culturel important dans la comarque du Maresme, dont elle est la capitale. Il y a deux musées et un parc, le Parc Central ; ce dernier est très grand et dispose de zones pour les enfants et la famille.
    Le centre est composé de rues piétonnes, la Riera et la rue Barcelona constituent la principale zone marchande de la ville. Il y a aussi un centre commercial, le Mataró Park, à côté de l'hôpital. Dernièrement, cette ville a connu un net accroissement de sa population, ce qui a engendré la naissance d'un nouveau quartier avec des appartements modernes : La Via Europa.`;
    this.project.attributes = {};
    for (let i = 0; i < 5; i++) {
      if (i === 2) {
        this.project.attributes[`attr-${i}`] = [...Array(5)].map(
          (_, j) => `value-${i}-list-${j}`
        );
      } else {
        this.project.attributes[`attr-${i}`] = `value-${i}`;
      }
    }
  }
};
</script>