<template>
  <div class="gobierto-calendar">
    <div>
      <strong>{{ labelDate }}</strong>
      <i class="fas fa-caret-down" />
    </div>
    <small>{{ startDateFmt }}{{ endDate ? " - " : "" }}{{ endDateFmt }}</small>
    <input
      type="text"
      class="datepicker-here"
    >
  </div>
</template>

<script>
import { Datepicker } from '../../../../lib/shared';

export default {
  name: "Calendar",
  props: {
    savedStartDate: {
      type: Date,
      default: null
    },
    savedEndDate: {
      type: Date,
      default: null
    }
  },
  data() {
    return {
      labelDate: I18n.t("gobierto_common.vue_components.calendar.date") || "",
      startDate: this.savedStartDate,
      endDate: this.savedEndDate
    };
  },
  dateFmt: { day: "numeric", month: "short", year: "numeric" },
  computed: {
    startDateFmt() {
      return this.startDate
        ? this.startDate.toLocaleDateString(I18n.locale, this.$options.dateFmt)
        : undefined;
    },
    endDateFmt() {
      return this.endDate
        ? this.endDate.toLocaleDateString(I18n.locale, this.$options.dateFmt)
        : undefined;
    }
  },
  watch: {
    savedStartDate(n) {
      this.startDate = n;
    },
    savedEndDate(n) {
      this.endDate = n;
    }
  },
  mounted() {
    this.setDatePicker();
  },
  updated() {
    this.startDate = this.savedStartDate;
    this.endDate = this.savedEndDate;
    this.setDatePicker();
  },
  beforeUnmount() {
    // https://vuejs.org/v2/cookbook/avoiding-memory-leaks.html
    this.datepicker.destroy();
  },
  methods: {
    setDatePicker() {
      this.datepicker = new Datepicker(this.$el.querySelector("input"), {
        language: I18n.locale,
        autoClose: true,
        range: true,
        inline: false,
        clearButton: true,
        onSelect: (_, date) => {
          const [start, end] = date;
          this.startDate = start;
          this.endDate = end;

          this.$emit("calendar-change", { start, end });
        }
      });
    }
  }
};
</script>
