<template>
  <div>
    <template v-for="item in fields">
      <div
        v-if="item.value"
        :key="item.id"
        class="project-description"
      >
        <template v-if="item.tpl_type === 'paragraphs'">
          <div
            class="description-title"
            :class="{ mb1: item.value.length < 200 }"
          >
            <span v-if="item.custom_field_name_translations">{{
              item.custom_field_name_translations | translate
            }}</span>
            <span v-else>{{ labelDesc }}</span>
          </div>

          <div
            :class="{ 'is-hidden': item.value.length > 200 }"
            v-html="item.value"
          />

          <button
            v-if="item.value.length > 200"
            class="description-more"
            @click="hideText"
          >
            <span v-if="readMoreButton">{{ labelReadMore }}</span>
            <span v-else>{{ labelReadLess }}</span>
          </button>
        </template>
        <template v-else>
          <div class="description-list mb1">
            <div class="description-title">
              {{ item.custom_field_name_translations | translate }}
            </div>

            <template v-if="item.custom_field_id === 'sdgs'">
              <div class="description-desc">
                <div class="ods-goal-container">
                  <div
                    v-for="id in item.external_id"
                    :key="id"
                    class="ods-goal-content"
                  >
                    <a
                      :href="`${baseUrl}/ods/${Number(id)}`"
                      :class="`ods-goal ods-goal__${id}__${item.locale}`"
                    />
                  </div>
                </div>
              </div>
            </template>

            <template v-else-if="Array.isArray(item.value)">
              <div class="description-desc">
                <div
                  v-for="value in item.value"
                  :key="value"
                >
                  {{ value }}
                </div>
              </div>
            </template>

            <template v-else>
              <div class="description-desc">
                {{ item.value }}
              </div>
            </template>
          </div>
        </template>
      </div>
    </template>
  </div>
</template>

<script>
import { translate } from "lib/shared";

export default {
  name: "ProjectCustomFields",
  filters: {
    translate
  },
  props: {
    customFields: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      fields: [],
      baseUrl: this.$root.$data.baseurl,
      labelReadMore: I18n.t("gobierto_plans.plan_types.show.read_more") || "",
      labelReadLess: I18n.t("gobierto_plans.plan_types.show.read_less") || "",
      labelDesc: I18n.t("gobierto_plans.plan_types.show.desc") || "",
      readMoreButton: true
    };
  },
  created() {
    this.parseCustomFields(this.customFields);
  },
  methods: {
    parseCustomFields(fields) {
      const fieldsParsed = [];

      fields.forEach(f => {
        const { custom_field_field_type: type } = f;
        if (
          type === "paragraph" ||
          type === "localized_paragraph" ||
          type === "string" ||
          type === "localized_string"
        ) {
          fieldsParsed.push({ ...f, tpl_type: "paragraphs" });
        } else {
          const { custom_field_id: id } = f;

          if (id === "sdgs") {
            f.external_id = (f.external_id || "")
              .split(",")
              .map(v => v.padStart(2, 0));
            f.locale = I18n.locale;
          }

          fieldsParsed.push({ ...f, tpl_type: "rest" });
        }
      });

      this.fields = fieldsParsed;
    },
    hideText(event) {
      const toggleClass = "is-hidden";
      const hiddenElementClasses =
        event.currentTarget.previousElementSibling.classList;

      hiddenElementClasses.contains(toggleClass)
        ? hiddenElementClasses.remove(toggleClass)
        : hiddenElementClasses.add(toggleClass);

      this.readMoreButton = hiddenElementClasses.contains(toggleClass);
    }
  }
};
</script>
