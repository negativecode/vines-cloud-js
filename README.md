# Vines Cloud JavaScript API

Vines Cloud exposes pubsub message channels and key/value data storage to mobile applications via a RESTful HTTP API and XMPP. This JavaScript library is a thin wrapper over those protocols to access your cloud account from web apps.

Additional documentation can be found at [www.getvines.com](http://www.getvines.com/).

## Usage

This is a quick overview of the methods available in the API. See the examples/ directory
for working demos.

```js
// create an api client with your account's domain
var vines = new Vines('wonderland.getvines.com');

// authenticate a user before other api calls are allowed
vines.authenticate('alice@wonderland.getvines.com', 'password', function(user, error) {
  if (user) {
     console.log('authenticated', user);
     // user, storage, and channel calls . . .
  } else {
    console.log('username and password failed', error);
  }
});

// create some common callback functions
var count   = function(count, error) { console.log('count', count, error); };
var all     = function(found, error) { console.log('found all', found, error); };
var one     = function(found, error) { console.log('found one', found, error); };
var saved   = function(obj, error)   { console.log('saved', obj, error); };
var deleted = function(obj, error)   { console.log('deleted', obj, error); };

// user management
vines.users.count(count);
vines.users.all({limit: 0, skip: 0}, all);
vines.users.find({id: 'alice@wonderland.getvines.com'}, one);
vines.users.save({id: 'alice@wonderland.getvines.com', color: 'blue'}, saved);
vines.users.remove({id: 'alice@wonderland.getvines.com'}, deleted);

// apps hosted in your account
vines.apps.count(count);
vines.apps.all({limit: 0, skip: 0}, all);
vines.apps.find({id: 'tea-app'}, one);

// json data storage by object class
var comments = app.storage('Comment');
comments.count(count);
comments.all({limit: 0, skip: 0}, all);
comments.find({id: nickname}, one);
comments.save({text: 'This is a comment!', postId: '4f2322df2a555e67c5000017'}, saved);
comments.remove({id: '4f2322df2a555e67c5000018'}, deleted);

// real-time message channels
var comments = app.channel('comments');
comments.subscribe(function(message) {
  console.log('comment received', message);
});
comments.publish({comment: 'This is a comment!', postId: '4f2322df2a555e67c5000017'});
comments.unsubscribe();
```

## Asynchronous Usage Patterns

All methods in the API pass their results asynchronously to a callback function. This prevents the browser's main thread from blocking while data is loaded from the server. However, this can also lead to complex nested callback functions as dependent data is loaded.

So, the API can be used in two ways. You can choose whichever style makes your code easiest to maintain.

### Provide a Callback to Each Method

Each method accepts a callback function as its last argument. The results of the method are passed to the callback when they're ready sometime in the future.  Any errors that occurred are also passed to the callback.

```js
var comments = app.storage('Comment');

// simple logging callback
comments.all({limit: 0, skip: 0}, function(found, error) {
  console.log('all comments', found, error);
});

// add some error handling
comments.all({limit: 0, skip: 0}, function(found, error) {
  if (error) {
    console.log('loading comments failed', error);
  } else {
    found.forEach(function(comment) {
      console.log('found comment', comment);
    });
  }
});

// add a nested callback to delete comments
comments.all({limit: 0, skip: 0}, function(found, error) {
  if (error) {
    console.log(error);
  } else {
    found.forEach(function(comment) {
      comments.remove(comment, function(error) {
        if (error) {
          console.log('deleting comment failed', error);
        } else {
          console.log('comment deleted', comment.id);
        }
      });
    });
  }
});
```

This style is easy to maintain for simple uses, but by the time we add error handling and a nested call to delete comments, it becomes tough to follow. Luckily there's a better way to write complex asynchronous code using the [Future/Promise](http://en.wikipedia.org/wiki/Futures_and_promises) design pattern.

### Register Callbacks on a jQuery Promise

Each API method returns a [jQuery Promise](http://api.jquery.com/Types/#Promise) object on which we can register callback functions. This lets us consolidate error handling in one place and removes the nested callbacks.

```js
var comments = app.storage('Comment');
var fail = function(error) { console.log(error); };
var removeAll = function(found) {
  found.forEach(function(comment) {
    comments.remove(comment).fail(fail);
  });
});
comments.all({limit: 0, skip: 0}).then(removeAll, fail);

// or save the promise for registering callbacks later
var result = comments.all({limit: 0, skip: 0});
result.then(removeAll, fail);

// or register success and failure functions separately
result.done(removeAll).fail(fail);

// or register multiple callbacks
result.done(removeAll).done(console.log);
```

Check out the jQuery [Deferred documentation](http://api.jquery.com/category/deferred-object/) for more details.  It's a great way to chain asynchronous calls together that's easier to follow than nested callback functions.

And be sure to read about the [when](http://api.jquery.com/jQuery.when/) and [pipe](http://api.jquery.com/deferred.pipe/) methods.

## Dependencies

This library requires jQuery 1.7.1 or better.

## Contact

* David Graham <david@negativecode.com>

## License

Released under the MIT license. Check the LICENSE file for details.
