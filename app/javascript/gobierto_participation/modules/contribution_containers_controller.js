import * as d3 from 'd3'

window.GobiertoParticipation.ContributionContainersController = (function() {
  function ContributionContainersController() {}

  ContributionContainersController.prototype.show = function(contribution_container_data){
      _initContributionContainer(contribution_container_data);
    };

  function _initContributionContainer(contribution_container_data){
    var data_origin = contribution_container_data['data_origin'];
    var data = data_origin;
    var data_best_ratings = contribution_container_data['data_best_ratings'];
    var data_worst_ratings = contribution_container_data['data_worst_ratings'];
    var data_recent = contribution_container_data['data_recent'];

    var data_self = [];
    var user = "";

    if (contribution_container_data['data_self']) {
      data_self = contribution_container_data['data_self'];
      user = contribution_container_data['user'];
    }

    var users_ideas_origin = contribution_container_data['users_ideas_origin'];
    var users_best_ratings = contribution_container_data['users_best_ratings'];
    var users_worst_ratings = contribution_container_data['users_worst_ratings'];
    var users_recent = contribution_container_data['users_recent']
    var users_ideas = users_ideas_origin;

    var cardnumber = 12;
    var page_max = Math.round(data.length/cardnumber);
    var format_date = d3.timeFormat("%Y-%m-%d");

    var page = 1;
    var viewdata = data.slice((page-1)*cardnumber,page*cardnumber);

    var px, py, vx, vy, offsetX, offsetY, maxVelocity = 8;

    var container = d3.select('.contributions_content').node();
    var width = container !== null ? container.clientWidth : 0,
        height = container !== null ? container.clientHeight : 0,
        cardWidth = 330,
        cardHeight = 130;

    var x = d3.scaleLinear()
      .range([0, width])
      .domain([0, data.length]);

    var y = d3.scaleLinear()
      .range(0, height)
      .domain([0, data.length]);

    var z = d3.scaleLinear()
      .range([-5, 5])
      .domain([0, data.length]);

    var nodes = createNodes(viewdata);

    createPagination(page_max);

    var collisionForce = rectCollide()
      .size(function (d) { return [d.width, d.height] });

    var boxForce = boundedBox()
      .bounds([[0, 0], [width, height]])
      .size(function (d) { return [d.width, d.height] });

    var simulation = d3.forceSimulation(nodes)
      .velocityDecay(0.6) // Speed of the simulation: https://github.com/d3/d3-force/blob/master/README.md#simulation_velocityDecay
      .alphaTarget(1)
      .force('box', boxForce)
      .force('collision', collisionForce);

    var drag = d3.drag()
      .on('start', started)
      .on('drag', dragged)
      .on('end', ended);

    var contributions = d3.select('.contributions_container');

    contributions.select('.contributions_content')
      .append('div')
      .attr('class', 'contribution_legend')
      .attr('id', 'contribution_legend')
      .text(users_ideas);

    contributions.select('.contributions_content')
      .append('i')
      .attr('id', 'next')
      .attr('data-toggle', 'next')
      .attr('class', 'fas fa-angle-right fa-3x arrow next_contribution')
      .on('click', updateContributions);

    contributions.select('.contributions_content')
      .append('i')
      .attr('id', 'previous')
      .attr('data-toggle', 'previous')
      .attr('class', 'fas fa-angle-left fa-3x arrow previous_contribution disabled')
      .on('click', updateContributions);

    createCards(nodes);

    var urlHash = window.location.hash;
    if (urlHash.length) {

      var selected_cards = data.filter(function(c) { return c.slug == urlHash.substr(1); });
      if (selected_cards.length > 0) {
        $.ajax({
          type: "GET",
          dataType: "script",
          url: selected_cards[0].to_path
        });
      }
    }

    $('#next').click(function() {
        page++;
        viewdata = data.slice((page-1)*cardnumber,page*cardnumber);
        var nodes = createNodes(viewdata);
        createCards(nodes);
        if (page === page_max ) {
          d3.select('.next_contribution')
            .classed('disabled', true);
        }

        var simulation = d3.forceSimulation(nodes)
          .velocityDecay(0.6) // Speed of the simulation: https://github.com/d3/d3-force/blob/master/README.md#simulation_velocityDecay
          .alphaTarget(1)
          .force('box', boxForce)
          .force('collision', collisionForce);
    });

    $('#previous').click(function() {
        page--;
        viewdata = data.slice((page-1)*cardnumber,page*cardnumber);
        var nodes = createNodes(viewdata);
        createCards(nodes);
        checkPreviousNextPagination(page, page_max);

        var simulation = d3.forceSimulation(nodes)
          .velocityDecay(0.6) // Speed of the simulation: https://github.com/d3/d3-force/blob/master/README.md#simulation_velocityDecay
          .alphaTarget(1)
          .force('box', boxForce)
          .force('collision', collisionForce);
    });

    /* Pagination links */
    $('li[data-page]').click(function(e) {
      e.preventDefault();
      page = $(this).data('page');
      viewdata = data.slice((page-1)*cardnumber,page*cardnumber);
      var nodes = createNodes(viewdata);
      createCards(nodes);

      $('li[data-page]').removeClass('active');
      $(this).addClass('active');

      checkPreviousNextPagination(page, page_max);

      var simulation = d3.forceSimulation(nodes)
        .velocityDecay(0.6) // Speed of the simulation: https://github.com/d3/d3-force/blob/master/README.md#simulation_velocityDecay
        .alphaTarget(1)
        .force('box', boxForce)
        .force('collision', collisionForce);
    });

    /* Buttons */
    contributions.select('.toggleLayout')
      .on('click', updateLayout);

    contributions.selectAll('.cardControl')
      .on('click', updateCards);

    function updateLayout() {
      var isChecked = eval(d3.select(this).attr('data-toggle'));

      if (isChecked) {
        d3.select(this).attr('data-toggle', false);
        d3.select('.contributions_content').classed('toggled', false);
      } else {
        d3.select(this).attr('data-toggle', true);
        d3.select('.contributions_content').classed('toggled', true);
      }
    }

    function updateCards() {
      var toggleFilter = d3.select(this).attr('data-filter');

      contributions.selectAll('.cardControl').classed('checked', false);
      d3.select(this).classed('checked', true);

      page = 1;

      switch(toggleFilter) {
        case 'all':
          data = data_origin;
          $('#contribution_legend').html(users_ideas_origin);
          page_max = Math.round(data.length/cardnumber);
          break;
        case 'best_ratings':
          data = data_best_ratings;
          $('#contribution_legend').html(users_best_ratings);
          page_max = Math.round(data.length/cardnumber);
          break;
        case 'worst_ratings':
          data = data_worst_ratings;
          $('#contribution_legend').html(users_worst_ratings);
          page_max = Math.round(data.length/cardnumber);
          break;
        case 'recent':
          data = data_recent;
          $('#contribution_legend').html(users_recent);
          page_max = Math.round(data.length/cardnumber);
          break;
        case 'self':
          data = data_self;
          $('#contribution_legend').html(user);
          page_max = Math.round(data.length/cardnumber);
          break;
      }

      if (page_max > 1 ) {
        d3.select('.next_contribution')
          .classed('disabled', false);
      }

      if ((page_max === 0 ) || (page_max === 1 )) {
        d3.select('.next_contribution')
          .classed('disabled', true);
      }

      $(".circles_progress").empty();
      createPagination(page_max);

      viewdata = data.slice((page-1)*cardnumber,page*cardnumber);
      var nodes = createNodes(viewdata);
      createCards(nodes);

      var simulation = d3.forceSimulation(nodes)
        .velocityDecay(0.6) // Speed of the simulation: https://github.com/d3/d3-force/blob/master/README.md#simulation_velocityDecay
        .alphaTarget(1)
        .force('box', boxForce)
        .force('collision', collisionForce);
    }

    function updateContributions() {
      var toggle = d3.select(this).attr('data-toggle');

      // Current contribution pool tracker
      d3.select('.circles_progress .active')
        .classed('trackToggle', true);

      if (toggle === 'next') {
        d3.selectAll('.circles_progress .active + li')
          .classed('active', 'true');

        d3.select('.previous_contribution')
          .classed('disabled', false);
      } else {
        d3.select('.circles_progress .active')
          .select(function() {
            return this.previousElementSibling;
          })
          .classed('active', true);
      }

      d3.selectAll('.trackToggle')
        .classed('active', false)
        .classed('trackToggle', false);

      // Transition cards
      d3.selectAll('.card')
        .transition(500)
        .delay(function(d, i) { return i * 20 })
        .style('opacity', 0)
        .on('end', ended);

      // TODO: Create new nodes & cards
      function ended() {
        d3.selectAll('.card')
          .transition(500)
          .delay(function(d, i) { return i * 20 })
          .style('opacity', 1)
      }
    }

    function ticked() {
      // Position the cards with a force simulation
      d3.selectAll('.card').style('transform', function(d) { return 'translate('+ d.x + 'px,' + d.y + 'px' + ') rotate(' + d.z + 'deg) translateZ(0)'; });
    }

    // Drag functions
    function started(d) {
      d3.select(this).style('z-index', 1);

      vx = 0;
      vy = 0;
      offsetX = (px = d3.event.x) - (d.fx = d.x);
      offsetY = (py = d3.event.y) - (d.fy = d.y);
    }

    function dragged(d) {
      vx = d3.event.x - px;
      vy = d3.event.y - py;
      d.fx = Math.max(Math.min((px = d3.event.x) - offsetX, width - d.width), 0);
      d.fy = Math.max(Math.min((py = d3.event.y) - offsetY, height - d.height), 0);

      d3.select(this)
        .style('transform', 'translate('+ d.fx + 'px,' + d.fy + 'px' + ') rotate(' + d.z + 'deg) translateZ(0)');
    }

    function ended(d) {
      d3.select(this).style('z-index', 0);

      var vScalingFactor = maxVelocity / Math.max(Math.sqrt(vx * vx + vy * vy), maxVelocity);

      d.fx = null;
      d.fy = null;
      d.vx = vx * vScalingFactor;
      d.vy = vy * vScalingFactor;
    }

    // Bounding box collision for rectangles
    // https://bl.ocks.org/cmgiven/547658968d365bcc324f3e62e175709b
    function rectCollide() {
      var nodes, sizes, masses;
      var size = constant([0, 0]);
      var strength = 1;
      var iterations = 1;

      function force() {
        var node, size, mass, xi, yi
        var i = -1
        while (++i < iterations) { iterate() }

        function iterate() {
          var j = -1
          var tree = d3.quadtree(nodes, xCenter, yCenter).visitAfter(prepare)

          while (++j < nodes.length) {
            node = nodes[j]
            size = sizes[j]
            mass = masses[j]
            xi = xCenter(node)
            yi = yCenter(node)

            tree.visit(apply)
          }
        }

        function apply(quad, x0, y0, x1, y1) {
          var data = quad.data
          var xSize = (size[0] + quad.size[0]) / 2
          var ySize = (size[1] + quad.size[1]) / 2
          if (data) {
            if (data.index <= node.index) { return }

            var x = xi - xCenter(data)
            var y = yi - yCenter(data)
            var xd = Math.abs(x) - xSize
            var yd = Math.abs(y) - ySize

            if (xd < 0 && yd < 0) {
              var l = Math.sqrt(x * x + y * y)
              var m = masses[data.index] / (mass + masses[data.index])

              if (Math.abs(xd) < Math.abs(yd)) {
                node.vx -= (x *= xd / l * strength) * m
                data.vx += x * (1 - m)
              } else {
                  node.vy -= (y *= yd / l * strength) * m
                  data.vy += y * (1 - m)
              }
            }
          }

          return x0 > xi + xSize || y0 > yi + ySize ||
                 x1 < xi - xSize || y1 < yi - ySize
        }

        function prepare(quad) {
          if (quad.data) {
            quad.size = sizes[quad.data.index]
          } else {
            quad.size = [0, 0]
            var i = -1
            while (++i < 4) {
              if (quad[i] && quad[i].size) {
                quad.size[0] = Math.max(quad.size[0], quad[i].size[0])
                quad.size[1] = Math.max(quad.size[1], quad[i].size[1])
              }
            }
          }
        }
      }

      function xCenter(d) { return d.x + d.vx + sizes[d.index][0] / 2 }
      function yCenter(d) { return d.y + d.vy + sizes[d.index][1] / 2 }

      force.initialize = function (_) {
        sizes = (nodes = _).map(size)
        masses = sizes.map(function (d) { return d[0] * d[1] })
      }

      force.size = function (_) {
        return (arguments.length
           ? (size = typeof _ === 'function' ? _ : constant(_), force)
           : size)
      }

      force.strength = function (_) {
        return (arguments.length ? (strength = +_, force) : strength)
      }

      force.iterations = function (_) {
        return (arguments.length ? (iterations = +_, force) : iterations)
      }

      return force
    }

    function boundedBox() {
      var nodes, sizes
      var bounds
      var size = constant([0, 0])

      function force() {
        var node, size
        var xi, x0, x1, yi, y0, y1
        var i = -1
        while (++i < nodes.length) {
          node = nodes[i]
          size = sizes[i]
          xi = node.x + node.vx
          x0 = bounds[0][0] - xi
          x1 = bounds[1][0] - (xi + size[0])
          yi = node.y + node.vy
          y0 = bounds[0][1] - yi
          y1 = bounds[1][1] - (yi + size[1])
          if (x0 > 0 || x1 < 0) {
            node.x += node.vx
            node.vx = -node.vx
            if (node.vx < x0) { node.x += x0 - node.vx }
            if (node.vx > x1) { node.x += x1 - node.vx }
          }
            if (y0 > 0 || y1 < 0) {
              node.y += node.vy
              node.vy = -node.vy
              if (node.vy < y0) { node.vy += y0 - node.vy }
              if (node.vy > y1) { node.vy += y1 - node.vy }
          }
        }
      }

      force.initialize = function (_) {
        sizes = (nodes = _).map(size)
      }

      force.bounds = function (_) {
        return (arguments.length ? (bounds = _, force) : bounds)
      }

      force.size = function (_) {
        return (arguments.length
           ? (size = typeof _ === 'function' ? _ : constant(_), force)
           : size)
      }

      return force;
    }

    function createPagination(page_max) {
      for (var i = 1; i <= page_max; i++) {
        if (i === 1) {
          $(".circles_progress").append('<li data-page=' + i + ' class="active"><a href=""><span></span></a></li>');
        } else {
          $(".circles_progress").append('<li data-page=' + i + '><a href=""><span></span></a></li>');
        }
      }
    }

    function checkPreviousNextPagination(page, page_max) {
      if (page < page_max ) {
        d3.select('.next_contribution')
          .classed('disabled', false);
        d3.select('.previous_contribution')
          .classed('disabled', false);
      }

      if (page == page_max ) {
        d3.select('.next_contribution')
          .classed('disabled', true);
        d3.select('.previous_contribution')
          .classed('disabled', false);
      }

      if (page == 1 ) {
        d3.select('.previous_contribution')
          .classed('disabled', true);
      }

    }

    function createNodes(data) {
      var velocity = Math.random() * 2 + 1
      var angle = Math.random() * 360

      var output = data.map(function(d, i) {
        return {
          width: cardWidth,
          height: cardHeight,
          x: Math.random() * (width - cardWidth),
          y: Math.random() * (height - cardHeight),
          vx: velocity * Math.cos(angle * Math.PI / 180),
          vy: velocity * Math.sin(angle * Math.PI / 180),
          name: d,
          z: z(i) * d3.randomUniform(2)(),
          love: Math.floor(d3.randomUniform(10)()),
          like: Math.floor(d3.randomUniform(10)()),
          neutral: Math.floor(d3.randomUniform(10)()),
          hate: Math.floor(d3.randomUniform(10)()),
        }
      });

      // Calculate percentage of votes for each card
      output.forEach(function(d) {
        d.total = d.name['votes_count'],
        d.love_pct = d.name['love_pct']
        d.like_pct = d.name['like_pct']
        d.neutral_pct = d.name['neutral_pct']
        d.hate_pct = d.name['hate_pct']
      });

      return output;
    }

    function createCards(data) {
      $('.card').remove()

      var card = contributions.select('.contributions_content')
        .selectAll('.card')
        .data(data)
        .enter()
        .append('div')
        .attr('class', 'card')
        .attr('data-url', function(d) { return d.name['to_path']; })
        .attr('id', function(d) { return d.name['slug']; });

      card
        .append('div')
        .attr('class', 'gradient_bar')
        .style('background', function(d) {
          // Every stop has to have every previous stop summed
          return 'linear-gradient(to right, #38b486 ' + d.name['love_pct'] + '%, #429aad ' + (d.name['love_pct'] + d.name['like_pct'] ) + '%, #9c7e7e ' + (d.name['love_pct'] + d.name['like_pct'] + d.name['neutral_pct']) + '%, #f06659 ' + (d.name['love_pct'] + d.name['like_pct'] + d.name['neutral_pct'] + d.name['hate_pct']) + '%)';
        });

      card
        .append('div').attr('class', 'title')
        .text(function(d) { return d.name['title']; });

      card
        .style('transform', function(d) { return 'translate('+ d.x + 'px,' + d.y + 'px' + ') rotate(' + d.z + 'deg) translateZ(0)'; })
        .call(drag);

      simulation.on('tick', ticked);

      $('.card').on('click', function(e){
        e.preventDefault();

        $.ajax({
          type: "GET",
          dataType: "script",
          url: $(this).data("url")
        });
      });
    }

    function constant(_) {
      return function () { return _ }
    }
  }

  return ContributionContainersController;
})();

window.GobiertoParticipation.contribution_containers_controller = new GobiertoParticipation.ContributionContainersController;
