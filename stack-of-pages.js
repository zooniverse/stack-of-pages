// Generated by CoffeeScript 1.6.3
(function() {
  var StackOfPages,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  StackOfPages = (function() {
    StackOfPages._GenericPage = (function() {
      function _GenericPage(content) {
        this.el = document.createElement('div');
        this.el.className = 'generic-page-in-a-stack';
        if (content.nodeType != null) {
          this.el.appendChild(content);
        } else {
          this.el.innerHTML = content;
        }
      }

      return _GenericPage;

    })();

    StackOfPages.prototype.hashes = null;

    StackOfPages.prototype["default"] = '#/';

    StackOfPages.prototype.tagName = 'div';

    StackOfPages.prototype.className = 'stack-of-pages';

    StackOfPages.prototype.activeClass = 'active';

    StackOfPages.prototype.inactiveClass = 'inactive';

    StackOfPages.prototype.changeDisplay = true;

    StackOfPages.prototype.hashRootAttr = 'data-location-hash';

    StackOfPages.prototype.pageElProperties = ['el'];

    StackOfPages.prototype.el = null;

    StackOfPages.prototype.activePage = null;

    StackOfPages.prototype.recentClick = false;

    StackOfPages.prototype.scrollOffsets = null;

    function StackOfPages(hashes, params) {
      var el, hash, preTarget, property, target, value, _ref, _ref1, _ref2;
      this.hashes = hashes != null ? hashes : {};
      if (params == null) {
        params = {};
      }
      this.onHashChange = __bind(this.onHashChange, this);
      this.onScroll = __bind(this.onScroll, this);
      this.onClick = __bind(this.onClick, this);
      if ('hashes' in this.hashes) {
        _ref = [null, this.hashes], this.hashes = _ref[0], params = _ref[1];
      }
      for (property in params) {
        value = params[property];
        this[property] = value;
      }
      if (this.hashes == null) {
        this.hashes = {};
      }
      if ('DEFAULT' in this.hashes) {
        this["default"] = this.hashes.DEFAULT;
      }
      if (this.el == null) {
        this.el = document.createElement(this.tagName);
      }
      this._toggleClass(this.el, this.className, true);
      if (this.scrollOffsets == null) {
        this.scrollOffsets = {};
      }
      _ref1 = this.hashes;
      for (hash in _ref1) {
        preTarget = _ref1[hash];
        target = typeof preTarget === 'function' ? new preTarget : (preTarget.nodeType != null) || ((_ref2 = typeof preTarget) === 'string' || _ref2 === 'number') ? new this.constructor._GenericPage(preTarget) : preTarget;
        el = ((function() {
          var _i, _len, _ref3, _results;
          _ref3 = this.pageElProperties;
          _results = [];
          for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
            property = _ref3[_i];
            if (target[property] != null) {
              _results.push(target[property]);
            }
          }
          return _results;
        }).call(this))[0];
        if (el == null) {
          el = target;
        }
        if ('jquery' in el) {
          el = el.get(0);
        }
        this.hashes[hash] = {
          target: target,
          el: el
        };
        this.deactivatePage(this.hashes[hash]);
        this.el.appendChild(el);
      }
      addEventListener('click', this.onClick, false);
      addEventListener('scroll', this.onScroll, false);
      addEventListener('hashchange', this.onHashChange, false);
      this.onHashChange();
    }

    StackOfPages.prototype.onClick = function(e) {
      var _this = this;
      this.recentClick = true;
      return setTimeout(function() {
        return _this.recentClick = false;
      });
    };

    StackOfPages.prototype.onScroll = function() {
      return this.scrollOffsets[location.hash] = [pageXOffset, pageYOffset];
    };

    StackOfPages.prototype.onHashChange = function() {
      var currentHash, e, foundMatch, hash, hashPattern, hashPatternSegments, hashSegments, i, matches, param, params, paramsOrder, segment, targetAndEl, _i, _len, _ref,
        _this = this;
      currentHash = location.hash || this["default"];
      foundMatch = false;
      _ref = this.hashes;
      for (hash in _ref) {
        targetAndEl = _ref[hash];
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
                _results.push('([^\/]+)');
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
        hashPattern = "^" + (hashPatternSegments.join('/')) + "/?$";
        matches = currentHash.match(hashPattern);
        if (matches != null) {
          foundMatch = true;
          params = {
            hashPattern: hashPattern
          };
          for (i = _i = 0, _len = paramsOrder.length; _i < _len; i = ++_i) {
            param = paramsOrder[i];
            params[param] = matches[i];
          }
          try {
            this.activatePage(targetAndEl, params);
            document.body.parentNode.setAttribute(this.hashRootAttr, hash);
          } catch (_error) {
            e = _error;
            if ('ERROR' in this.hashes) {
              params.error = e;
            } else {
              throw e;
            }
          }
        }
      }
      if ((params != null ? params.error : void 0) != null) {
        this.activatePage(this.hashes.ERROR, params);
      }
      if (!foundMatch) {
        if ('NOT_FOUND' in this.hashes) {
          this.activatePage(this.hashes.NOT_FOUND, params);
        }
      }
      if (!this.recentClick) {
        return setTimeout(function() {
          var x, y, _ref1;
          _ref1 = _this.scrollOffsets[location.hash] || [0, 0], x = _ref1[0], y = _ref1[1];
          return scrollTo(x, y);
        });
      }
    };

    StackOfPages.prototype.activate = function(params) {
      if (!(params.hash in this.hashes)) {
        if (this["default"] in this.hashes) {
          return this.activatePage(this.hashes[this["default"]]);
        }
      }
    };

    StackOfPages.prototype.activatePage = function() {
      var el, params, target, _arg, _ref;
      _arg = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      target = _arg.target, el = _arg.el;
      if (((_ref = this.activePage) != null ? _ref.target : void 0) !== target) {
        if (this.activePage != null) {
          this.deactivatePage.apply(this, [this.activePage].concat(__slice.call(params)));
        }
        this.activePage = {
          target: target,
          el: el
        };
      }
      if (this.changeDisplay) {
        el.style.display = '';
      }
      this._toggleClass(el, this.activeClass, true);
      this._toggleClass(el, this.inactiveClass, false);
      return typeof target.activate === "function" ? target.activate.apply(target, params) : void 0;
    };

    StackOfPages.prototype.deactivatePage = function() {
      var el, params, target, _arg;
      _arg = arguments[0], params = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      target = _arg.target, el = _arg.el;
      if (this.changeDisplay) {
        el.style.display = 'none';
      }
      this._toggleClass(el, this.activeClass, false);
      this._toggleClass(el, this.inactiveClass, true);
      return typeof target.deactivate === "function" ? target.deactivate.apply(target, params) : void 0;
    };

    StackOfPages.prototype._toggleClass = function(el, className, condition) {
      var alreadyThere, classList;
      classList = el.className.split(/\s+/);
      alreadyThere = __indexOf.call(classList, className) >= 0;
      if (condition && !alreadyThere) {
        classList.push(className);
      }
      if (!condition && alreadyThere) {
        classList.splice(classList.indexOf(className), 1);
      }
      return el.className = classList.join(' ');
    };

    StackOfPages.prototype.destroy = function() {
      var hash, target, _ref;
      removeEventListener('click', this.onClick, false);
      removeEventListener('scroll', this.onScroll, false);
      removeEventListener('hashchange', this.onHashChange, false);
      _ref = this.hashes;
      for (hash in _ref) {
        target = _ref[hash].target;
        if (typeof target.destroy === "function") {
          target.destroy.apply(target, arguments);
        }
      }
      return this.el.parentNode.removeChild(this.el);
    };

    return StackOfPages;

  })();

  window.StackOfPages = StackOfPages;

  if (typeof module !== "undefined" && module !== null) {
    module.exports = StackOfPages;
  }

}).call(this);

/*
//@ sourceMappingURL=stack-of-pages.map
*/
