"use strict";

describe("my app", function() {
  beforeEach(function() {
    return browser().navigateTo("/");
  });
  it("should automatically redirect to /todo when location hash/fragment is empty", function() {
    return expect(browser().location().url()).toBe("/todo");
  });
  it("should navigate to /view1 when the View 1 link in nav is clicked", function() {
    element(".nav a[href=\"#/view1\"]").click();
    return expect(browser().location().url()).toBe("/view1");
  });
  describe("todo", function() {
    it("should list 2 items", function() {
      return expect(repeater("[ng-view] ul li").count()).toEqual(2);
    });
    it("should display checked items with a line-through", function() {
      return expect(element("[ng-view] ul li input:checked + span").css("text-decoration")).toEqual("line-through");
    });
    it("should sync done status with checkbox state", function() {
      element("[ng-view] ul li input:not(:checked)").click();
      expect(element("[ng-view] ul li span").attr("class")).toEqual("donetrue");
      element("[ng-view] ul li input:checked").click();
      return expect(element("[ng-view] ul li span").attr("class")).toEqual("donefalse");
    });
    it("should remove checked items when the archive link is clicked", function() {
      element("[ng-view] a[ng-click=\"archive()\"]").click();
      return expect(repeater("[ng-view] ul li").count()).toEqual(1);
    });
    return it("should add a newly submitted item to the end of the list and empty the text input", function() {
      var newItemLabel;
      newItemLabel = "test newly added item";
      input("todoText").enter(newItemLabel);
      element("[ng-view] input[type=\"submit\"]").click();
      expect(repeater("[ng-view] ul li").count()).toEqual(3);
      expect(element("[ng-view] ul li:last span").text()).toEqual(newItemLabel);
      return expect(input("todoText").val()).toEqual("");
    });
  });
  describe("view1", function() {
    beforeEach(function() {
      return browser().navigateTo("#/view1");
    });
    return it("should render view1 when user navigates to /view1", function() {
      return expect(element("[ng-view] p:first").text()).toMatch(/partial for view 1/);
    });
  });
  return describe("view2", function() {
    beforeEach(function() {
      return browser().navigateTo("#/view2");
    });
    return it("should render view2 when user navigates to /view2", function() {
      return expect(element("[ng-view] p:first").text()).toMatch(/partial for view 2/);
    });
  });
});

