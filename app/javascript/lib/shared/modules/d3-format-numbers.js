import * as d3 from 'd3';
import { d3locale } from '../../../lib/shared';

export const formatNumbers = (value) => {
  const lang = I18n.locale || "es";
  return value.toString().length >= 7 ? d3.format(".2s")(value) : d3.formatDefaultLocale(d3locale[lang]).format(',.0f')(value)
};
