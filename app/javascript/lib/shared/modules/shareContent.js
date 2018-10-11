import * as flight from 'flightjs'

export var shareContent = flight.component(function(){
  this.attributes({
    url: "",
    modalOptions: 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=300,width=600'
  });

  this.after('initialize', function() {
    if(this.$node.find('[data-share-url]').length > 0){
      this.attr.url = this.$node.find('[data-share-url]').data('share-url');
    }

    if(this.$node.data('anchor') !== undefined){
      this.attr.url += '#' + this.$node.data('anchor');
    }

    this.attr.twitterHandle = document.head.querySelector("[name='twitter:site']").content;

    if(this.attr.url === "") {
      this.attr.url = window.location.href;
    }

    this.twitterLink = this.$node.find('[data-share-network=twitter]');
    this.facebookLink = this.$node.find('[data-share-network=facebook]');
    this.linkedinLink = this.$node.find('[data-share-network=linkedin]');
    this.emailLink = this.$node.find('[data-share-network=email]');
    this.codeLink = this.$node.find('[data-share-network=code]');

    if(this.twitterLink)
      this.twitterLink.on('click', this.clickTwitterHandle.bind(this));

    if(this.facebookLink)
      this.facebookLink.on('click', this.clickFacebookHandle.bind(this));

    if(this.linkedinLink)
      this.linkedinLink.on('click', this.clickLinkedinHandle.bind(this));

    if(this.emailLink.length)
      this.emailLink.on('click', this.clickEmailHandle.bind(this));
  });

  this.clickTwitterHandle = function(e) {
    e.preventDefault();
    try {
      var twitter_intent_url = 'https://twitter.com/intent/tweet?text=' + this.shareText();
      if (this.attr.twitterHashtags != undefined) {
        twitter_intent_url += '&hashtags= ' + this.attr.twitterHashtags;
      }
      twitter_intent_url += '&url=' + encodeURIComponent(this.attr.url);
      if (this.attr.twitterHandle != undefined) {
        twitter_intent_url += '&via=' + this.attr.twitterHandle;
      }

      window.open(twitter_intent_url, '', this.attr.modalOptions);

    } catch(missingShareTextNode) {
      console.warn('Error: missing share Text Node');
    }
  };

  this.clickFacebookHandle = function(e) {
    e.preventDefault();
    window.open('http://www.facebook.com/sharer/sharer.php?u='+ encodeURIComponent(this.attr.url), '', this.attr.modalOptions);
  };

  this.clickLinkedinHandle = function(e) {
    e.preventDefault();

    window.open('https://www.linkedin.com/shareArticle?mini=true&url='+encodeURIComponent(this.attr.url)+'&title=' + this.shareText(), '', this.attr.modalOptions);
  };

  this.clickEmailHandle = function(e) {
    e.preventDefault();
    try {
      window.location.href = 'mailto:?subject=Recommended article from ICIJ&body=' + this.shareText() + ' ' + encodeURIComponent(this.attr.url);
    } catch(missingShareTextNode) {
      console.warn('Error: missing share Text Node');
    }
  };

  this.shareText = function(){
    var text;
    var textNode = this.$node.find('[data-share-text]');

    if(textNode.length && textNode.data('share-text') !== undefined) {
      text = textNode.data('share-text');
    } else {
      if (!textNode.length)
        textNode = $('[data-share-text]')
      if (!textNode.length)
        textNode = $('h1');
      text = $.trim(textNode.text());
      if(!text.length)
        text = window.document.title;
    }

    if(text.length > 101) {
      text = text.substring(0,101) + '…';
    }
    return text;
  };
});

$(document).on('turbolinks:load ajax:complete ajaxSuccess', function() {
  shareContent.attachTo('[data-share]');
});
