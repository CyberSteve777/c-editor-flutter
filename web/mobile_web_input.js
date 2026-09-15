// Mobile browsers (not "desktop site") use Flutter's fullscreen a11y
// placeholder and a visual viewport that often disagrees with the canvas.
// That combination eats taps along the bottom and top-right. Desktop UA
// never creates the fullscreen overlay, which is why requesting the PC
// version appears to "fix" it.
(function () {
  'use strict';

  var PLACEHOLDER = 'flt-semantics-placeholder';
  var VIEWPORT_CONTENT =
    'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
  var STYLE_ATTR = 'data-c-editor-mobile-input';
  var PLACEHOLDER_CSS =
    PLACEHOLDER +
    '{pointer-events:none!important;position:absolute!important;' +
    'left:-1px!important;top:-1px!important;right:auto!important;' +
    'bottom:auto!important;width:1px!important;height:1px!important;' +
    'overflow:hidden!important;}';

  var observed = typeof WeakSet === 'function' ? new WeakSet() : null;

  function resetViewportScroll() {
    window.scrollTo(0, 0);
    if (document.documentElement) document.documentElement.scrollTop = 0;
    if (document.body) document.body.scrollTop = 0;
  }

  function ensureViewportMeta() {
    var head = document.head;
    if (!head) return;
    var meta = document.querySelector('meta[name="viewport"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.setAttribute('name', 'viewport');
      head.appendChild(meta);
    }
    if (meta.getAttribute('content') !== VIEWPORT_CONTENT) {
      meta.setAttribute('content', VIEWPORT_CONTENT);
    }
  }

  function isPlaceholder(node) {
    if (!node || node.nodeType !== 1) return false;
    var name = node.localName || node.nodeName;
    return name === PLACEHOLDER || name === PLACEHOLDER.toUpperCase();
  }

  function neutralizePlaceholder(el) {
    el.setAttribute('tabindex', '-1');
    el.style.setProperty('pointer-events', 'none', 'important');
    el.style.setProperty('position', 'absolute', 'important');
    el.style.setProperty('left', '-1px', 'important');
    el.style.setProperty('top', '-1px', 'important');
    el.style.setProperty('right', 'auto', 'important');
    el.style.setProperty('bottom', 'auto', 'important');
    el.style.setProperty('width', '1px', 'important');
    el.style.setProperty('height', '1px', 'important');
    el.style.setProperty('overflow', 'hidden', 'important');
  }

  function injectShadowStyle(shadow) {
    if (!shadow || !shadow.appendChild) return;
    if (shadow.querySelector && shadow.querySelector('style[' + STYLE_ATTR + ']')) {
      return;
    }
    var style = document.createElement('style');
    style.setAttribute(STYLE_ATTR, '');
    style.appendChild(document.createTextNode(PLACEHOLDER_CSS));
    shadow.appendChild(style);
  }

  function walk(root) {
    if (!root) return;
    if (isPlaceholder(root)) neutralizePlaceholder(root);
    var shadow = root.shadowRoot;
    if (shadow) {
      injectShadowStyle(shadow);
      observe(shadow);
      walk(shadow);
    }
    var children = root.children;
    if (!children) return;
    for (var i = 0; i < children.length; i++) {
      walk(children[i]);
    }
  }

  function observe(root) {
    if (!root || !root.addEventListener || (observed && observed.has(root))) {
      return;
    }
    if (observed) observed.add(root);
    var observer = new MutationObserver(function (mutations) {
      for (var i = 0; i < mutations.length; i++) {
        var added = mutations[i].addedNodes;
        for (var j = 0; j < added.length; j++) {
          walk(added[j]);
        }
      }
    });
    observer.observe(root, { childList: true, subtree: true });
  }

  function install() {
    ensureViewportMeta();
    resetViewportScroll();
    observe(document);
    if (document.documentElement) walk(document.documentElement);
  }

  install();
  window.addEventListener('load', install);
  window.addEventListener('pageshow', resetViewportScroll);
  window.addEventListener('resize', resetViewportScroll);
  window.addEventListener('orientationchange', install);
  window.addEventListener('flutter-first-frame', install);
  if (window.visualViewport) {
    window.visualViewport.addEventListener('resize', resetViewportScroll);
    window.visualViewport.addEventListener('scroll', resetViewportScroll);
  }
})();
