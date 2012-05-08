/*
 * Demonstrates using all of the available Vines Cloud API methods with comments
 * to a fictional blog. Authentication, JSON storage, new user registration, and
 * pubsub message channel use cases are covered.
 *
 * The API is used in a variety of styles so you can get a feel for the different
 * ways it can be used. The jQuery Promise API is frequently used to simplify
 * nested asynchronous callbacks.
 */
$(function() {
  var vines = null;

  /*
   * Starts the demo by authenticating with the Vines Cloud service. Multiple
   * done callbacks can be registered on the login Promise object. They will be
   * run in the order they're registered.
   */
  function start() {
    var username = $('#username').val();
    var password = $('#password').val();
    var domain = username.split('@')[1];
    vines = new Vines(domain);

    var login = vines.authenticate(username, password);
    login.fail(log('user: authentication failed ' + username));
    // register multiple done callbacks
    login.done(log('user: authenticated'));
    login.done(function(user) {
      // inline callbacks are useful for simple cases
      vines.apps.count(function(count, error) {
        console.log('app: count', count, error);
      });
    });
    login.done(findApps);
    return false; // prevent form submit
  }

  /*
   * Find a single App hosted in your cloud account. Returns a Promise
   * object on which done and fail callbacks can be registered.
   */
  function findApp(nickname) {
    return vines.apps.where({nick: nickname}).first()
      .fail(log('app: find failed ' + nickname));
  }

  /*
   * After authentication is complete, we find all the apps hosted in this
   * cloud account and run the demo with the first app available.
   */
  function findApps() {
    var apps = vines.apps.all();
    apps.fail(log('app: find failed'));
    apps.done(log('app: found first 10'));
    apps.done(function(found) {
      // use the run function reference directly as a callback
      findApp(found[0].nick).done(run);
    });
    return apps; // return the Promise
  }

  /*
   * Run the demo with the given App as context. Storage and pubsub channel
   * functionality is specific to each app.
   */
  function run(app) {
    users();
    storage(app);
    channels(app);
  }

  /*
   * Use the App#classes and App#storage methods to save and retrieve
   * JSON objects from a cloud database.
   */
  function storage(app) {
    // find all available JSON object classes
    app.classes(function(classes, error) {
      console.log('storage: found classes', classes, error);
    });

    // use the Comment class to store data
    var comments = app.storage('Comment');
    comments.count(function(count, error) {
      console.log('comment: count', count, error);
    });

    // find the first 10 Comment objects
    comments.where().limit(10).skip(0).all(function(found, error) {
      if (error) {
        console.log('comment: find failed', error);
      } else {
        console.log('comment: found first 10', found);
      }
    });

    // complex query with where clause
    var query = comments.where('text exists and text like :match', {match: 'comment!'});

    // count the number of matching comments
    query.count(function(count, error) {
      console.log('comment: count with where clause', count, error);
    });

    // return all matching comments
    query.all().done(function(comments) {
      console.log('comment: found with where clause', comments);
    });

    // return just the first matching comment
    query.first(function(comment, error) {
      console.log('comment: first with where clause', comment, error);
    });

    // create a function to update the comment after it's saved
    var update = function(comment) { updateComment(comments, comment.id); };

    // persist a new Comment object to the cloud database
    var save = comments.save({text: 'This is a comment!'});
    save.fail(log('comment: save failed'));
    save.done(log('comment: save succeeded'));
    save.done(update);
  }

  /*
   * Retrieve the Comment with the given ID, update its data, save it back to
   * the cloud, and then clean up after ourselves and delete it.
   */
  function updateComment(comments, id) {
    var find = comments.find(id);
    find.fail(log('comment: find failed ' + id));
    find.done(log('comment: found by id ' + id));
    find.done(function(comment) {
      comment.text = 'This is my updated comment!';
      // the inline callback and Promise styles can be mixed
      comments.save(comment, function(updated, error) {
        console.log('comment: update succeeded', updated, error);
      }).done(function() {
        // callbacks can be chained
        comments.remove(id)
          .done(log('comment: delete succeeded'))
          .fail(log('comment: delete failed'));
      });
    });
  }

  /*
   * Sign up a new user account and then immediately delete the user. Only an
   * admin user account is allowed to delete other users.
   */
  function users() {
    vines.users.count().always(log('user: count'));
    vines.users.where().limit(10).skip(0).all().done(log('user: found first 10'));

    // register a new user then delete their account
    var user = {id: 'demo-user@' + vines.domain, password: 'password'};
    var signup = vines.users.save(user);
    signup.fail(log('user: signup failed'));
    signup.done(log('user: signup succeeded'));
    signup.done(deleteUser);
  }

  function deleteUser(user) {
    var find = vines.users.find(user.id);
    find.fail(log('user: find failed ' + user.id));
    find.done(log('user: found by id ' + user.id));
    find.done(function(user) {
      vines.users.remove(user.id)
        .done(log('user: delete succeeded'))
        .fail(log('user: delete failed'));
    });
  }

  /*
   * Create a "comments" pubsub channel, subscribe to its stream of messages,
   * and publish a comment to it. Send messages to the comments channel from the
   * Vines Cloud web console to see them appear in this demo app.
   */
  function channels(app) {
    var comments = app.channel('comments');
    comments.subscribe(function(message) {
      console.log('comment: received on channel', message);
    });
    comments.publish({comment: 'This is a comment!', spam: false});

    var channels = app.channels();
    channels.done(function(found) {
      console.log('channels: found all', found);
      if (found.length == 0) return;
      found[0].publish({comment: 'Another comment!'});
    });
  }

  /*
   * Returns a function that logs the given message along with any other
   * arguments it's passed. This is useful as a done or fail callback on
   * a jQuery Promise.
   */
  function log(message) {
    return function(obj, error) {
      console.log(message, obj, error);
    };
  }

  // begin when the start button is clicked
  $('#demo-form').submit(start);
});
