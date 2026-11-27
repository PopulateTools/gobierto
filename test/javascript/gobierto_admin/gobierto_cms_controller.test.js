/**
 * @jest-environment jsdom
 */

import $ from "jquery";
import Turbolinks from "turbolinks";

window.$ = window.jQuery = $;
window.GobiertoAdmin = {};
window.I18n = { t: key => key };
require("../../../app/javascript/gobierto_admin/modules/gobierto_cms_controller.js");

describe("CMS page section loading", () => {
  let requests;
  let controller;

  const sections = {
    sections: [{ id: 7, title: "News" }, { id: 8, title: "About" }]
  };
  const parents = {
    section_items: [{ id: 12, name: "Parent", children: [{ id: 13, name: "Current page" }] }]
  };

  function submitEvent() {
    const event = new Event("submit", { bubbles: true, cancelable: true });
    document.querySelector("#page-form").dispatchEvent(event);
    return event;
  }

  function completeInitialRequests() {
    requests[0].deferred.resolve(sections);
    requests[1].deferred.resolve(parents);
  }

  beforeEach(() => {
    document.body.innerHTML = `
      <form id="page-form">
        <input type="submit" value="Update">
        <button type="submit" disabled>Disabled action</button>
        <div class="open_level_1"><input type="checkbox" id="permission_1"></div>
        <div class="level_1"><select id="page_section" name="page[section]"><option value=""></option></select></div>
        <div class="level_2"><select id="page_parent" name="page[parent]"></select></div>
      </form>
      <form id="other-form"><input type="submit" value="Save"></form>
    `;
    requests = [];
    jest.spyOn($, "getJSON").mockImplementation((url, callback) => {
      const deferred = $.Deferred();
      deferred.done(callback);
      requests.push({ url, deferred });
      return deferred.promise();
    });
    controller = new window.GobiertoAdmin.GobiertoCmsController();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  test.each([[0, 1], [1, 0]])("waits for both requests when request %i finishes first", (first, second) => {
    controller.edit("7", "12", "13");

    expect(requests.map(request => request.url)).toEqual([
      "/admin/cms/sections",
      "/admin/cms/sections/7/section_items/"
    ]);
    expect($("#page-form").serializeArray()).not.toContainEqual({ name: "page[parent]", value: "12" });
    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    expect($("#other-form input:submit").prop("disabled")).toBe(false);

    const responses = [sections, parents];
    requests[first].deferred.resolve(responses[first]);
    expect($("#page-form input:submit").prop("disabled")).toBe(true);

    requests[second].deferred.resolve(responses[second]);
    expect($("#page-form input:submit").prop("disabled")).toBe(false);
    expect($("#page-form button:submit").prop("disabled")).toBe(true);
    expect($("#page-form").serializeArray()).toEqual([
      { name: "page[section]", value: "7" },
      { name: "page[parent]", value: "12" }
    ]);
    expect($('#page_parent option[value="13"]').prop("disabled")).toBe(true);
  });

  test.each(["pending", "partially loaded", "failed"])("restores a cached form with %s requests", state => {
    controller.edit("7", "12", "13");
    if (state === "partially loaded") requests[0].deferred.resolve(sections);
    if (state === "failed") requests[0].deferred.reject();
    expect($("#page-form input:submit").prop("disabled")).toBe(true);

    document.dispatchEvent(new Event("turbolinks:before-cache"));
    expect(submitEvent().defaultPrevented).toBe(true);
    const snapshot = Turbolinks.Snapshot.fromHTMLElement(document.documentElement).clone();
    document.body.replaceWith(snapshot.bodyElement);
    expect($("#page-form").data("section-options-loading")).toBeUndefined();

    controller = new window.GobiertoAdmin.GobiertoCmsController();
    controller.edit("7", "12", "13");
    expect(requests).toHaveLength(4);
    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    expect(submitEvent().defaultPrevented).toBe(true);

    requests[2].deferred.resolve(sections);
    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    requests[3].deferred.resolve(parents);

    expect($("#page-form").data("section-options-loading")).toBeUndefined();
    expect($("#page-form").serializeArray()).toEqual([
      { name: "page[section]", value: "7" },
      { name: "page[parent]", value: "12" }
    ]);
    expect($("#page-form input:submit").prop("disabled")).toBe(false);
    expect($("#page-form button:submit").prop("disabled")).toBe(true);
    expect(submitEvent().defaultPrevented).toBe(false);
  });

  test("blocks form submission, including Enter, until all options are loaded", () => {
    const delegatedSubmit = jest.fn();
    $(document).on("submit.cmsTest", delegatedSubmit);
    controller.edit("7", "12", "13");

    try {
      expect(submitEvent().defaultPrevented).toBe(true);
      requests[0].deferred.resolve(sections);
      expect(submitEvent().defaultPrevented).toBe(true);
      expect(delegatedSubmit).not.toHaveBeenCalled();
      requests[1].deferred.resolve(parents);
      expect(submitEvent().defaultPrevented).toBe(false);
      expect(delegatedSubmit).toHaveBeenCalledTimes(1);
    } finally {
      $(document).off("submit.cmsTest");
    }
  });

  test.each([0, 1])("keeps submission blocked when request %i fails", failed => {
    controller.edit("7", "12", "13");

    requests[failed].deferred.reject();
    const successful = 1 - failed;
    requests[successful].deferred.resolve([sections, parents][successful]);

    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    expect(submitEvent().defaultPrevented).toBe(true);
  });

  test("blocks submission while loading parents after a section change", () => {
    controller.edit("7", "12", "13");
    completeInitialRequests();

    $("#page_section").val("8").trigger("change");

    expect(requests[2].url).toBe("/admin/cms/sections/8/section_items/");
    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    expect(submitEvent().defaultPrevented).toBe(true);

    requests[2].deferred.resolve({ section_items: [] });

    expect($("#page-form input:submit").prop("disabled")).toBe(false);
    expect(submitEvent().defaultPrevented).toBe(false);
    expect($("#page_section").val()).toBe("8");
    expect($("#page_parent").val()).toBe("0");
    expect($("#page-form button:submit").prop("disabled")).toBe(true);
  });

  test("does not re-enable an incomplete form when a later request succeeds", () => {
    controller.edit("7", "12", "13");
    completeInitialRequests();

    $("#page_section").val("8").trigger("change");
    requests[2].deferred.reject();
    $("#page_section").val("7").trigger("change");
    requests[3].deferred.resolve(parents);

    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    expect(submitEvent().defaultPrevented).toBe(true);
  });

  test("waits for overlapping parent requests after multiple section changes", () => {
    controller.edit("7", "12", "13");
    completeInitialRequests();

    $("#page_section").val("8").trigger("change");
    $("#page_section").val("7").trigger("change");
    requests[2].deferred.resolve({ section_items: [] });

    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    expect(submitEvent().defaultPrevented).toBe(true);

    requests[3].deferred.resolve(parents);
    expect($("#page-form input:submit").prop("disabled")).toBe(false);
    expect(submitEvent().defaultPrevented).toBe(false);
  });

  test("does not block a page without a section, but guards newly selected sections", () => {
    controller.edit("null", "null", "");

    expect(requests).toHaveLength(0);
    expect($("#page-form input:submit").prop("disabled")).toBe(false);
    expect(submitEvent().defaultPrevented).toBe(false);

    $("#permission_1").prop("checked", true).trigger("change");
    expect(requests).toHaveLength(1);
    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    requests[0].deferred.resolve(sections);
    expect($("#page-form input:submit").prop("disabled")).toBe(false);

    $("#page_section").val("7").trigger("change");
    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    requests[1].deferred.resolve(parents);
    expect($("#page-form input:submit").prop("disabled")).toBe(false);
    expect($("#page_parent").val()).toBe("0");
  });

  test("waits for sections and parents when loading a newly created section", () => {
    controller.edit("null", "null", "");
    controller.loadSections(7);

    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    requests[1].deferred.resolve({ section_items: [] });
    expect($("#page-form input:submit").prop("disabled")).toBe(true);
    requests[0].deferred.resolve(sections);
    expect($("#page-form input:submit").prop("disabled")).toBe(false);
    expect($("#page_section").val()).toBe("7");
    expect($("#page_parent").val()).toBe("0");
  });
});
