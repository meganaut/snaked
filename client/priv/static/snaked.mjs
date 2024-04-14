// build/dev/javascript/prelude.mjs
var CustomType = class {
  withFields(fields) {
    let properties = Object.keys(this).map(
      (label) => label in fields ? fields[label] : this[label]
    );
    return new this.constructor(...properties);
  }
};
var List = class {
  static fromArray(array, tail) {
    let t = tail || new Empty();
    return array.reduceRight((xs, x) => new NonEmpty(x, xs), t);
  }
  [Symbol.iterator]() {
    return new ListIterator(this);
  }
  toArray() {
    return [...this];
  }
  // @internal
  atLeastLength(desired) {
    for (let _ of this) {
      if (desired <= 0)
        return true;
      desired--;
    }
    return desired <= 0;
  }
  // @internal
  hasLength(desired) {
    for (let _ of this) {
      if (desired <= 0)
        return false;
      desired--;
    }
    return desired === 0;
  }
  countLength() {
    let length = 0;
    for (let _ of this)
      length++;
    return length;
  }
};
function toList(elements, tail) {
  return List.fromArray(elements, tail);
}
var ListIterator = class {
  #current;
  constructor(current) {
    this.#current = current;
  }
  next() {
    if (this.#current instanceof Empty) {
      return { done: true };
    } else {
      let { head, tail } = this.#current;
      this.#current = tail;
      return { value: head, done: false };
    }
  }
};
var Empty = class extends List {
};
var NonEmpty = class extends List {
  constructor(head, tail) {
    super();
    this.head = head;
    this.tail = tail;
  }
};

// build/dev/javascript/gleam_stdlib/gleam/option.mjs
var None = class extends CustomType {
};

// build/dev/javascript/lustre/lustre/effect.mjs
var Effect = class extends CustomType {
  constructor(all) {
    super();
    this.all = all;
  }
};
function none() {
  return new Effect(toList([]));
}

// build/dev/javascript/lustre/lustre/internals/vdom.mjs
var Text = class extends CustomType {
  constructor(content) {
    super();
    this.content = content;
  }
};

// build/dev/javascript/lustre/lustre/element.mjs
function text(content) {
  return new Text(content);
}

// build/dev/javascript/lustre/lustre.mjs
var App = class extends CustomType {
  constructor(init, update, view, on_attribute_change) {
    super();
    this.init = init;
    this.update = update;
    this.view = view;
    this.on_attribute_change = on_attribute_change;
  }
};
function application(init, update, view) {
  return new App(init, update, view, new None());
}
function element(html) {
  let init = (_) => {
    return [void 0, none()];
  };
  let update = (_, _1) => {
    return [void 0, none()];
  };
  let view = (_) => {
    return html;
  };
  return application(init, update, view);
}

// build/dev/javascript/snaked/snaked.mjs
function main() {
  return element(text("Hello from snaked!"));
}

// build/.lustre/entry.mjs
main();
