
$(function () {

  var POPULATION_RANGE = [0, 5000000];
  var TOTAL_RANGE = [0, 5000000000];
  var PER_INHABITANT_RANGE = [0, 20000];

  if ($('.filters').length > 0) {

    setAARRFilterToParams();

    $(window).on('popstate', function(e) {
      setAARRFilterToParams();

      $(['population','total', 'per_inhabitant']).each(function(index, filter_name) {
        var the_filter = document.getElementById('filter_' + filter_name);
        if (getFilterParams(filter_name) != null) {
          the_filter.noUiSlider.set(getFilterParams(filter_name));
        } else {
          the_filter.noUiSlider.set(eval(filter_name.toUpperCase() + '_RANGE'));
        }
      });
      updateRanking(false);
    })

    function setAARRFilterToParams() {
      var params = decodeURIComponent(window.location.search);
      var aarr_re = /f\[aarr\]=(\d+)/
      if (aarr_re.test(params)) {
        $('#filter_per_aarr #aarr').val(aarr_re.exec(params)[1]);
      } else {
        $('#filter_per_aarr #aarr').val('');
      }
    }

    function getFilterParams(filter_name) {
      var params = decodeURIComponent(window.location.search);
      var from_re = new RegExp("f\\[" + filter_name + "\\]\\[from\\]=(\\d+)")
      var to_re = new RegExp("f\\[" + filter_name + "\\]\\[to\\]=(\\d+)")

      var results = null
      if (from_re.test(params) && to_re.test(params)) {
        results = [from_re.exec(params)[1], to_re.exec(params)[1]];
      }
      return results;
    }

    function updateRanking(push_the_state) {
      var ranking_url = $('[data-ranking-url]').data('ranking-url');
      var params = (ranking_url.indexOf('?') > 0) ? '' : '?';
      $('#filter_population, #filter_total, #filter_per_inhabitant').each(function() {
        var values = this.noUiSlider.get();
        var filter_name = this.id.replace('filter_','');
        params+= "&f[" + filter_name + "][from]=" + parseInt(values[0]);
        params+= "&f[" + filter_name + "][to]=" + parseInt(values[1]);
      })
      if ($('#aarr').val() != '') {
        params+= "&f[aarr]=" + $('#aarr').val();
      }
      ranking_url += params;

      $.ajax(ranking_url, {
        headers: {          
                 Accept : "application/json, text/javascript"
        },
        beforeSend: function() {
          $('.spinner').addClass('show');
          if(push_the_state) {
            history.pushState({},'',ranking_url.replace('.js?','?'));
          }
        },
        complete: function() {
          $('.spinner').removeClass('show');
        }
      });
    }

    var pop_slider = document.getElementById('filter_population');
    noUiSlider.create(pop_slider, {
      start: getFilterParams('population') || POPULATION_RANGE,
      snap: true,
      animate: false,
      connect: true,
      range: {
        'min': 0,
        '10%':1000,
        '20%':5000,
        '30%':10000,
        '40%':25000,
        '50%':50000,
        '60%':100000,
        '70%':200000,
        '80%':500000,
        'max': 5000000
      }
    });

    pop_slider.noUiSlider.on('update', function( values, handle ) {
      $('#size_value_' + handle).text(accounting.formatNumber(values[handle], 0, "."));
    });

    pop_slider.noUiSlider.on('change', function( values, handle ) {
      updateRanking(true);
    });

    var tot_slider = document.getElementById('filter_total');
    noUiSlider.create(tot_slider, {
      start: getFilterParams('total') || TOTAL_RANGE,
      snap: true,
      animate: false,
      connect: true,
      range: {
        'min':0,
        '2.5%':50000,
        '5%':100000,
        '7.5%':200000,
        '10%':300000,
        '12.5%':400000,
        '15%':500000,
        '17.5%':600000,
        '20%':700000,
        '22.5%':800000,
        '25%':900000,
        '27.5%':1000000,
        '30%':2500000,
        '40%':5000000,
        '50%':10000000,
        '65%':25000000,
        '80%':200000000,
        'max':5000000000
      }
    });

    tot_slider.noUiSlider.on('update', function( values, handle ) {
      $('#total_value_' + handle).text(accounting.formatNumber(values[handle], 0, "."));
    });

    tot_slider.noUiSlider.on('change', function( values, handle ) {
      updateRanking(true);
    });

    var inh_slider = document.getElementById('filter_per_inhabitant');
    noUiSlider.create(inh_slider, {
      start: getFilterParams('per_inhabitant') || PER_INHABITANT_RANGE,
      animate: false,
      snap: true,
      connect: true,
      range: {
        'min':0,
        '11%':500,
        '18%':600,
        '25%':700,
        '31%':800,
        '38%':900,
        '45%':1000,
        '50%':1500,
        '60%':2000,
        '70%':5000,
        '80%':7500,
        '90%':10000,
        'max':20000
      }
    });

    inh_slider.noUiSlider.on('update', function( values, handle ) {
      $('#per_inhabitant_value_' + handle).text(accounting.formatNumber(values[handle], 0, "."));
    });

    inh_slider.noUiSlider.on('change', function( values, handle ) {
      updateRanking(true);
    });

    $('body').on('change','#aarr', function(v) {
      updateRanking(true);
    })
  }
});
