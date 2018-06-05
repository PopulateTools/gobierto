$(document).on('turbolinks:load', function() {
  (function () {
    var tablist = document.querySelectorAll('[role="tablist"]')[0];
    var tabs;
    var panels;

    generateArrays();

    function generateArrays () {
      tabs = document.querySelectorAll('[role="tab"]');
      panels = document.querySelectorAll('[role="tabpanel"]');
    }

    // For easy reference
    var keys = {
      end: 35,
      home: 36,
      left: 37,
      up: 38,
      right: 39,
      down: 40,
      enter: 13,
      space: 32
    };

    // Add or substract depenign on key pressed
    var direction = {
      37: -1,
      38: -1,
      39: 1,
      40: 1
    };

    // Bind listeners
    for (var i = 0; i < tabs.length; ++i) {
      addListeners(i);
    }

    function addListeners (index) {
      tabs[index].addEventListener('click', clickEventListener);
      tabs[index].addEventListener('keydown', keydownEventListener);
      tabs[index].addEventListener('keyup', keyupEventListener);

      // Build an array with all tabs (<button>s) in it
      tabs[index].index = index;
    }

    // When a tab is clicked, activateTab is fired to activate it
    function clickEventListener (event) {
      var tab = event.target;
      activateTab(tab, false);
    }

    // Handle keydown on tabs
    function keydownEventListener (event) {
      var key = event.keyCode;

      switch (key) {
        case keys.end:
          event.preventDefault();
          // Activate last tab
          focusLastTab();
          break;
        case keys.home:
          event.preventDefault();
          // Activate first tab
          focusFirstTab();
          break;

        // Up and down are in keydown
        // because we need to prevent page scroll >:)
        case keys.up:
        case keys.down:
          determineOrientation(event);
          break;
      }
    }

    // Handle keyup on tabs
    function keyupEventListener (event) {
      var key = event.keyCode;

      switch (key) {
        case keys.left:
        case keys.right:
          determineOrientation(event);
          break;
        case keys.enter:
        case keys.space:
          activateTab(event.target);
          break;
      }
    }

    // When a tablist’s aria-orientation is set to vertical,
    // only up and down arrow should function.
    // In all other cases only left and right arrow function.
    function determineOrientation (event) {
      var key = event.keyCode;
      var vertical = tablist.getAttribute('aria-orientation') == 'vertical';
      var proceed = false;

      if (vertical) {
        if (key === keys.up || key === keys.down) {
          event.preventDefault();
          proceed = true;
        }
      }
      else {
        if (key === keys.left || key === keys.right) {
          proceed = true;
        }
      }

      if (proceed) {
        switchTabOnArrowPress(event);
      }
    }

    // Either focus the next, previous, first, or last tab
    // depening on key pressed
    function switchTabOnArrowPress (event) {
      var pressed = event.keyCode;

      if (direction[pressed]) {
        var target = event.target;
        if (target.index !== undefined) {
          if (tabs[target.index + direction[pressed]]) {
            tabs[target.index + direction[pressed]].focus();
          }
          else if (pressed === keys.left || pressed === keys.up) {
            focusLastTab();
          }
          else if (pressed === keys.right || pressed == keys.down) {
            focusFirstTab();
          }
        }
      }
    }

    // Activates any given tab panel
    function activateTab (tab, setFocus) {
      setFocus = setFocus || true;
      // Deactivate all other tabs

      var currentTabpanel = $(tab).closest('[role="tabpanel"]');

      deactivateTabs(currentTabpanel);

      // Remove tabindex attribute
      tab.removeAttribute('tabindex');

      // Set the tab as selected
      tab.setAttribute('aria-selected', 'true');

      // Get the value of aria-controls (which is an ID)
      var controls = tab.getAttribute('aria-controls');

      // Remove hidden attribute from tab panel to make it visible
      var tabPanel = document.getElementById(controls);

      if (tabPanel) {
        tabPanel.removeAttribute('hidden');
      }

      // Set focus when required
      if (setFocus) {
        tab.focus();
      }
    }

    // Deactivate all tabs and tab panels
    function deactivateTabs (currentTabpanel) {
      var tabsInCurrentTabpanel = $(currentTabpanel).find('[role="tab"]');

      for (var t = 0; t < tabsInCurrentTabpanel.length; t++) {
        tabsInCurrentTabpanel[t].setAttribute('tabindex', '-1');
        tabsInCurrentTabpanel[t].setAttribute('aria-selected', 'false');
      }
    }

    // Make a guess
    function focusFirstTab () {
      tabs[0].focus();
    }

    // Make a guess
    function focusLastTab () {
      tabs[tabs.length - 1].focus();
    }

    // Determine whether there should be a delay
    // when user navigates with the arrow keys
    function determineDelay () {
      var hasDelay = tablist.hasAttribute('data-delay');
      var delay = 0;

      if (hasDelay) {
        var delayValue = tablist.getAttribute('data-delay');
        if (delayValue) {
          delay = delayValue;
        }
        else {
          // If no value is specified, default to 300ms
          delay = 300;
        }
      }

      return delay;
    }
  })();
});
