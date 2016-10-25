'use strict';

$(function () {

  // Track user in Mixpanel when she signs up
  $('#new_user .submit').click(function(e) {
    // e.preventDefault();

    // $('#user_email').val()
    // $('#select2-user_place_id-container').val()
    // $('input[data-user-type]:checked').attr('data-user-type');

    // var name = $('#lead_form').find('input[name="lead_name"]').val();
    // var surname = $('#lead_form').find('input[name="lead_surname"]').val();
    var email = $('#user_email').val();
    var phone = $('#lead_phone').val();
    var place = $('#select2-user_place_id-container').text();
    var user_type = $('input[data-user-type]:checked').attr('data-user-type');
    // console.log('Name: ' + name);
    // console.log('Surname: ' + surname);
    console.log('Email: ' + email);
    console.log('Place: ' + place);
    console.log('Phone: ' + phone);
    console.log('User Type: ' + user_type);

    mixpanel.identify(email);
    mixpanel.people.set({
      // "$first_name": name,
      // "$last_name": surname,
      "$email": email,
      "Phone": phone
    });
    mixpanel.people.union({
      "User Type": [user_type],
      "Place": [place]
    });

  });

  // Track user when she verifies or edits account
  $('.edit_user .submit').click(function(e) {
    // e.preventDefault();

    // $('#user_email').val()
    // $('#select2-user_place_id-container').val()
    // $('input[data-user-type]:checked').attr('data-user-type');

    var name = $('#user_first_name').val();
    var surname = $('#user_last_name').val();
    var email = $('#user_email').val();
    var place = $('#select2-user_place_id-container').text();
    var user_type = $('input[data-user-type]:checked').attr('data-user-type');
    // console.log('Name: ' + name);
    // console.log('Surname: ' + surname);
    console.log('Email: ' + email);
    console.log('Place: ' + place);
    console.log('User Type: ' + user_type);

    mixpanel.identify(email);
    mixpanel.people.set({
      "$first_name": name,
      "$last_name": surname,
      "$email": email,
      "Confirmed account": true
    });
    mixpanel.people.union({
      "User Type": [user_type],
      "Place": [place]
    });

  });


  if ($("[data-analytics-track]").length) {
    switch ($("[data-analytics-track]").data('analytics-track')) {
      case "Page_About":
        mixpanel.track('Visit About Page');
        break;
    }

  }

  // General Page view increment for people
  mixpanel.people.increment('Page views');

});
