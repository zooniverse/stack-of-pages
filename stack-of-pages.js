// Generated by CoffeeScript 1.7.1
(function() {
  var StackOfPages, dispatchEvent, forgetClick, onClick, onScroll, recentClick, scrollOffsets;

  dispatchEvent = function(element, eventName, detail) {
    var e;
    e = document.createEvent('CustomEvent');
    e.initCustomEvent(eventName, true, true, detail);
    return element.dispatchEvent(e);
  };

  recentClick = false;

  forgetClick = function() {
    return recentClick = false;
  };

  onClick = function() {
    recentClick = true;
    return setTimeout(forgetClick, 50);
  };

  addEventListener('click', onClick, false);

  scrollOffsets = {};

  onScroll = function() {
    return scrollOffsets[location.hash] = {
      x: pageXOffset,
      y: pageYOffset
    };
  };

  addEventListener('scroll', onScroll, false);

  StackOfPages = (function() {
    StackOfPages.prototype.hashes = null;

    StackOfPages.prototype["default"] = '#/';

    StackOfPages.prototype.changeDisplay = true;

    StackOfPages.prototype.functionsAreConstructors = true;

    StackOfPages.prototype.tagName = 'div';

    StackOfPages.prototype.className = 'stack-of-pages';

    StackOfPages.prototype.activatedAttr = 'data-active-in-stack';

    StackOfPages.prototype.hashRootAttr = 'data-location-hash';

    StackOfPages.prototype.activateEvent = 'activate-in-stack';

    StackOfPages.prototype.deactivateEvent = 'deactivate-in-stack';

    StackOfPages.prototype.notFoundKey = 'notFound';

    StackOfPages.prototype.el = null;

    StackOfPages.prototype.current = null;

    function StackOfPages(settings) {
      var key, value;
      if (settings == null) {
        settings = {};
      }
      if (this.el == null) {
        this.el = document.createElement(this.tagName);
      }
      this.el.className = this.className;
      this.hashes = {};
      for (key in settings) {
        value = settings[key];
        if (key.charAt(0) === '#' || key === this.notFoundKey) {
          this.add(key, value);
        } else {
          this[key] = value;
        }
      }
      addEventListener('hashchange', this, false);
      this.onHashChange();
      if (this.current == null) {
        if (this["default"] in this.hashes) {
          this.activate(this.hashes[this["default"]], {
            initial: true
          });
        }
      }
    }

    StackOfPages.prototype.add = function(hash, thing) {
      var element;
      element = this.findElement(thing);
      if (element != null) {
        if (hash != null) {
          this.hashes[hash] = element;
        }
        this.el.appendChild(element);
        return this.deactivate(element, {
          initial: true
        });
      } else {
        throw new Error("Couldn't determine element for " + hash);
      }
    };

    StackOfPages.prototype.findElement = function(thing) {
      var div, _ref;
      if (typeof thing === 'function') {
        if (this.functionsAreConstructors) {
          thing = new thing;
        } else {
          thing = thing.call(this, this);
        }
      }
      if ((_ref = typeof thing) === 'string' || _ref === 'number' || _ref === 'boolean') {
        div = document.createElement('div');
        div.innerHTML = thing;
        thing = div.children[0];
      }
      if ('el' in thing) {
        if (thing.el instanceof Element) {
          thing = thing.el;
        } else if ('jquery' in thing.el) {
          thing = thing.el.get(0);
        }
      }
      if (thing instanceof Element) {
        return thing;
      }
    };

    StackOfPages.prototype.handleEvent = function(e) {
      var handler;
      handler = (function() {
        switch (e.type) {
          case 'hashchange':
            return this.onHashChange;
        }
      }).call(this);
      return handler != null ? handler.apply(this, arguments) : void 0;
    };

    StackOfPages.prototype.onHashChange = function() {
      var currentHash, element, foundMatch, hash, hashPatternSegments, hashSegments, i, matches, param, params, paramsOrder, segment, x, y, _i, _len, _ref, _ref1;
      currentHash = location.hash || this["default"];
      if (recentClick || !(currentHash in scrollOffsets)) {
        scrollOffsets[currentHash] = {
          x: 0,
          y: 0
        };
      }
      _ref = scrollOffsets[currentHash], x = _ref.x, y = _ref.y;
      setTimeout(function() {
        return scrollTo(x, y);
      });
      foundMatch = false;
      params = {};
      _ref1 = this.hashes;
      for (hash in _ref1) {
        element = _ref1[hash];
        paramsOrder = ['hash'];
        hashSegments = hash.split('/');
        hashPatternSegments = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = hashSegments.length; _i < _len; _i++) {
            segment = hashSegments[_i];
            switch (segment.charAt(0)) {
              case ':':
                paramsOrder.push(segment.slice(1));
                _results.push('?([^/]*)');
                break;
              case '*':
                paramsOrder.push('_');
                _results.push('?(.*)');
                break;
              default:
                _results.push(segment);
            }
          }
          return _results;
        })();
        params.hashPattern = "^" + (hashPatternSegments.join('/')) + "/?$";
        matches = currentHash.match(params.hashPattern);
        if (matches != null) {
          foundMatch = true;
          for (i = _i = 0, _len = paramsOrder.length; _i < _len; i = ++_i) {
            param = paramsOrder[i];
            params[param] = matches[i];
          }
          this.activate(element, params);
          document.body.parentNode.setAttribute(this.hashRootAttr, hash);
        }
        if (foundMatch) {
          break;
        }
      }
      if (!foundMatch) {
        params.notFound = true;
        if (this.notFoundKey in this.hashes) {
          return this.activate(this.hashes[this.notFoundKey], params);
        }
      }
    };

    StackOfPages.prototype.activate = function(el, params) {
      var _ref;
      if (this.current != null) {
        this.deactivate(this.current, params);
      }
      this.current = el;
      el.setAttribute(this.activatedAttr, (_ref = params.hash) != null ? _ref : params.initial);
      if (this.changeDisplay) {
        el.style.display = '';
      }
      return dispatchEvent(el, this.activateEvent, params);
    };

    StackOfPages.prototype.deactivate = function(el, params) {
      el.removeAttribute(this.activatedAttr);
      if (this.changeDisplay) {
        el.style.display = 'none';
      }
      return dispatchEvent(el, this.deactivateEvent, params);
    };

    StackOfPages.prototype.destroy = function() {
      removeEventListener('hashchange', this, false);
      return this.el.parentNode.removeChild(this.el);
    };

    return StackOfPages;

  })();

  window.StackOfPages = StackOfPages;

  if (typeof module !== "undefined" && module !== null) {
    module.exports = StackOfPages;
  }

}).call(this);
