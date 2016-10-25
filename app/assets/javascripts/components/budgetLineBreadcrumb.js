function limit_length(input, length) {
  return input.length > length ? input.substring(0, length - 3) + '...' : input
}

(function(window, undefined){
  'use strict';

  window.budgetLineBreadcrumb = flight.component(function(){
    this.attributes({
      areaNamesDict: {
        'G-economic': 'En qué se gasta',
        'G-functional': 'Para qué se gasta',
        'I-economic': 'En qué se ingresa'
      }
    });

    this.after('initialize', function() {
      this.areaName = this.$node.data('budget-line-area');
      this.state = this.$node.data('budget-line-breadcrumb');
      this.states = this.state.split('/');
      this.currentKind = this.states[1];
      this.currentYear = this.states[0];
      this.categoriesUrl = this.$node.data('budget-line-categories');
      this.$lineBreadcrumb = this.$node.find('[data-line-breadcrumb]');
      this.selectedCategories = [];

      // Select current Year
      $('[data-level="0"] table td[data-code="'+this.currentYear+'"]').addClass('selected');

      $.getJSON(this.categoriesUrl, function(categories){
        this.renderLineBreadcrumb(this.$lineBreadcrumb, this.state, categories[this.areaName]);
        this.renderLevel1();
        this.assignHandlers(0);

        this.states.slice(2, this.states.length - 1).forEach(function(code, level){
          var currentCode = code.slice(0, code.length-1);
          if(level == 0) {
            currentCode = this.currentKind;
          }
          this.renderLevel(level + 2, currentCode);
        }.bind(this));

      }.bind(this));
    });

    this.renderLineBreadcrumb = function($el, state, categories){
      var html = "";
      html += '<a href="/presupuestos/partidas/'+this.currentYear+'/'+this.areaName+'/' + this.states[1] + '">' + this.currentYear + '</a> »';
      this.selectedCategories.push(this.currentYear);
      html += '<a href="/presupuestos/partidas/'+this.currentYear+'/'+this.areaName+'/' + this.states[1] + '">' + this.attr.areaNamesDict[this.currentKind + '-' + this.areaName] + '</a> »';
      this.selectedCategories.push(this.attr.areaNamesDict[this.currentKind + '-' + this.areaName]);

      this.states.slice(2, this.states.length - 1).forEach(function(segment){
        if(segment.indexOf('-') === -1 || segment.length == 6) {
          var categoryName = categories[this.states[1]][segment];
          this.selectedCategories.push(categoryName);
          html += '<a href="/presupuestos/partidas/'+segment+'/'+this.currentYear+'/'+this.areaName+'/' + this.states[1] + '">' + categoryName + '</a> »';
        }
      }.bind(this));
      $el.html(html);
    };

    this.renderLevel1 = function(){
      var html = "";
      var $el = $('[data-level="1"] table');
      var selectedItem;

      if(this.selectedCategories.indexOf(this.attr.areaNamesDict['I-economic']) !== -1){ selectedItem = 'class="selected"'; }
      html += '<tr><td data-area-name="economic" data-kind="I" '+selectedItem+'><a href="#">' + this.attr.areaNamesDict['I-economic'] + '</a></td></tr>';
      selectedItem = '';

      if(this.selectedCategories.indexOf(this.attr.areaNamesDict['G-economic']) !== -1){ selectedItem = 'class="selected"'; }
      html += '<tr><td data-area-name="economic" data-kind="G" '+selectedItem+'><a href="#">' + this.attr.areaNamesDict['G-economic'] + '</a></td></tr>';
      selectedItem = '';

      if(this.selectedCategories.indexOf(this.attr.areaNamesDict['G-functional']) !== -1){ selectedItem = 'class="selected"'; }
      html += '<tr><td data-area-name="functional" data-kind="G" '+selectedItem+'><a href="#">' + this.attr.areaNamesDict['G-functional'] + '</a></td></tr>';

      $el.html(html);
      $el.data('current-code', this.currentKind);
      // $el.parent().velocity('fadeIn', {duration: 250});
      $el.parent().show();
      this.assignHandlersLevel1();
    };

    this.assignHandlersLevel1 = function(level){
      var that = this;
      var timeout;

      $('[data-level="1"] [data-area-name]').on('mouseenter', function(e){
        e.preventDefault();
        var level = 1;

        var $this = $(this);

        if (timeout != null) { clearTimeout(timeout); }

        timeout = setTimeout(function(){
          for(var i=+2; i < 5; i++){
            $('[data-level="' + i + '"]').hide();
          }

          $('[data-level="1"] [data-area-name]').removeClass('selected');
          that.currentKind = $this.data('kind');
          that.areaName = $this.data('area-name');

          that.renderLevel(2, that.currentKind + '-' + that.areaName, function(result){
            $this.addClass('selected');
          });
        }, 200);
      });

      $('[data-level="1"] [data-area-name]').on('mouseleave', function(e){
        if (timeout != null) {
          clearTimeout(timeout);
          timeout = null;
        }
      });
    };

    this.assignHandlers = function(level){
      var that = this;
      var timeout;

      $('[data-level="' + level + '"] [data-code]').on('mouseenter', function(e){
        e.preventDefault();

        var $this = $(this);

        if (timeout != null) { clearTimeout(timeout); }

        timeout = setTimeout(function(){
          for(var i=(level+2); i < 5; i++){
            //$('[data-level="' + i + '"]').velocity('fadeOut', {duration: 100});
            $('[data-level="' + i + '"]').hide();
          }

          var currentCode = $this.data('code');
          $('[data-level="' + level + '"] [data-code]').removeClass('selected');
          $('[data-level="' + level + '"] [data-code]').removeClass('selected_no_children');
          var nextLevel = parseInt($this.parents('[data-level]').data('level')) + 1;
          if(level == 0){ that.currentYear = currentCode; }

          if(nextLevel > 1){
            that.renderLevel(nextLevel, currentCode, function(result){
              if(result.length === 0)
                $('[data-level="' + level + '"] [data-code="'+currentCode+'"]').addClass('selected_no_children');
              else
                $('[data-level="' + level + '"] [data-code="'+currentCode+'"]').addClass('selected');
            });
          } else {
            // $('[data-level=' + nextLevel + ']').velocity("fadeIn", { duration: 250 });
            $('[data-level=' + nextLevel + ']').show();
          }
        }, 200);
      });

      $('[data-level="' + level + '"] [data-code]').on('mouseleave', function(e){
        if (timeout != null) {
          clearTimeout(timeout);
          timeout = null;
        }
      });
    };

    this.renderLevel = function(level, currentCode, callback){
      var url = '/budget_line_descendants/' + this.currentYear + '/' + this.areaName + '/' + this.currentKind + '.json';
      if(level > 2){
        url += '?parent_code=' + currentCode;
      }

      var that = this;
      var $el = $('[data-level="'+level+'"] table');
      if($el.data('current-code') != currentCode){
        $.getJSON(url, function(data){
          var html = "";
          data.forEach(function(budgetLine){
            var selectedItem = '';
            if(this.selectedCategories.indexOf(budgetLine.name) !== -1){
              selectedItem = 'class="selected"';
            }
            html += '<tr><td data-code="'+budgetLine.code+'"  ' + selectedItem + '><a href="/presupuestos/partidas/'+budgetLine.code+'/'+that.currentYear+'/'+that.areaName+'/' + that.currentKind + '">' + limit_length(budgetLine.name, 35) + '</a></td></tr>';
          }.bind(this));
          $el.html(html);
          $el.data('current-code', currentCode);

          // $('[data-level=' + level + ']').velocity("fadeIn", { duration: 250 });
          $('[data-level=' + level + ']').show();
          this.assignHandlers(level);
          if(callback !== undefined)
            callback(data);
        }.bind(this));
      } else {
        if(!$el.parent().is(':visible'))
          // $el.parent().velocity('fadeIn', {duration: 250});
          $el.parent().show();
      }
    };
  });

  $(function() {
    window.budgetLineBreadcrumb.attachTo('[data-budget-line-breadcrumb]');
  });

})(window);
