this.GobiertoBudgets = {
  init: function() { console.log('GobiertoBudgets init');}
};

$(document).on("turbolinks:load", function(){
  return GobiertoBudgets.init();
});
