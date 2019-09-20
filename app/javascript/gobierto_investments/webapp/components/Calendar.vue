<template>
  <div class="investments-home-aside--calendar-button">
    <div>
      <strong>{{ labelDate }}</strong>
      <i class="fas fa-caret-down" />
    </div>
    <small>{{ startDateFmt }}{{ endDate ? " - " : "" }}{{ endDateFmt }}</small>
    <input
      type="text"
      class="investments-home-aside--calendar-input datepicker-here"
    >
  </div>
</template>

<script>
import { datepicker } from "lib/shared";

export default {
  name: "Calendar",
  data() {
    return {
      labelDate: "",
      startDate: new Date(),
      endDate: new Date()
    };
  },
  dateFmt: { day: "numeric", month: "short", year: "numeric" },
  computed: {
    startDateFmt() {
      return this.startDate ? this.startDate.toLocaleDateString(I18n.locale, this.$options.dateFmt) : undefined
    },
    endDateFmt() {
      return this.endDate ? this.endDate.toLocaleDateString(I18n.locale, this.$options.dateFmt) : undefined
    }
  },
  created() {
    this.labelDate = I18n.t("gobierto_investments.projects.date");
  },
  mounted() {
    datepicker(this.$el.querySelector("input"), {
      language: I18n.locale,
      autoClose: true,
      range: true,
      inline: false,
      clearButton: true,
      onSelect: (_, date) => {
        const [start, end] = date;
        this.startDate = start;
        this.endDate = end;

        this.$emit("calendar-change", start, end)
      },
      onHide(inst, animationCompleted) {
        console.log(1);

      }
    });
  }
};
</script>
