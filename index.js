(function(){var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

var AbstractComponent, AbstractPureComponent, Alert, Alignment, AnchorButton, AnimationStates, App, Blockquote, Breadcrumb, Button, ButtonGroup, Callout, Card, Checkbox, Classes, Code, Collapse, CollapseFrom, CollapsibleList, Colors, ContextMenu, ContextMenuTarget, ControlGroup, DateInput, DatePicker, DateRangeBoundary, DateRangeInput, DateRangePicker, DateTimePicker, Dialog, EditableText, Elevation, Expander, FileInput, FocusStyleManager, FormGroup, H1, H2, H3, H4, H5, H6, Hotkey, Hotkeys, HotkeysTarget, Icon, IconContents, IconNames, IconSvgPaths16, IconSvgPaths20, Icons8, InputGroup, Intent, KeyCombo, Keys, Label, Menu, MenuDivider, MenuItem, Modal, MultiSelect, Navbar, NavbarDivider, NavbarGroup, NavbarHeading, NonIdealState, NumericInput, OL, Omnibar, Overlay, Popover, PopoverInteractionKind, Portal, Position, Pre, ProgressBar, QueryList, Radio, RadioGroup, RangeSlider, Select, Slider, Spinner, Suggest, Switch, Tab, Table, Tabs, Tag, TagInput, TaskbarAction, TaskbarBattery, TaskbarDatetime, TaskbarHome, TaskbarSound, Text, TextArea, TimePicker, TimePickerPrecision, Toast, Toaster, Tooltip, Tree, TreeNode, UL, Utils, app, reactElementToJsxString, setTimer;

({ FocusStyleManager, Classes, Keys, Utils, AbstractComponent, AbstractPureComponent, Alignment, Colors, Intent, Position, ContextMenu, Alert, Breadcrumb, Button, AnchorButton, ButtonGroup, Callout, Elevation, Card, AnimationStates, Collapse, CollapseFrom, CollapsibleList, ContextMenuTarget, Dialog, EditableText, ControlGroup, Switch, Radio, Checkbox, FileInput, FormGroup, InputGroup, Label, NumericInput, RadioGroup, TextArea, H1, H2, H3, H4, H5, H6, Blockquote, Code, Pre, OL, UL, Hotkey, KeyCombo, HotkeysTarget, Hotkeys, Icon, Menu, MenuDivider, MenuItem, Navbar, NavbarDivider, NavbarGroup, NavbarHeading, NonIdealState, Overlay, Table, Text, PopoverInteractionKind, Popover, Portal, ProgressBar, RangeSlider, Slider, Spinner, Tab, Expander, Tabs, Tag, TagInput, Toast, Toaster, Tooltip, Tree, TreeNode } = Blueprint.Core);

({ IconContents, IconNames, IconSvgPaths16, IconSvgPaths20 } = Blueprint.Icons);

({ Omnibar, QueryList, MultiSelect, Select, Suggest } = Blueprint.Select);

({ DateRangeBoundary, DateInput, DatePicker, DateTimePicker, DateRangeInput, DateRangePicker, TimePicker, TimePickerPrecision } = Blueprint.Datetime);

Classes = { ...Blueprint.Core.Classes, ...Blueprint.Select.Classes, ...Blueprint.Datetime.Classes };

reactElementToJsxString = function (el) {
  if (el) {
    return reactElementToJsxString(el);
  } else {
    return el;
  }
};

setTimer = (timer, cb) => {
  return setTimeout(cb, timer);
};

app = null;

App = class App extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      system: {
        display: {
          brightness: 1
        },
        sound: {
          volume: .5
        },
        battery: {
          level: void 0,
          charging: void 0,
          env: {
            manager: null
          }
        },
        storage: {
          local: {
            env: {
              manager: null,
              listeners: {
                connected: []
              }
            }
          },
          drive: {
            env: {
              manager: null
            }
          }
        }
      },
      personal: {
        background: {
          type: "image",
          imgSrc: "https://i.imgur.com/wOcQPsq.png",
          size: "cover"
        },
        taskbar: {
          location: "bottom"
        }
      },
      apps: {
        app: {
          list: [],
          env: {
            tasks: []
          }
        }
      }
    };
  }

  set(path, val, nextTick) {
    this.setState(objectPathImmutable.set(this.state, path, val), nextTick);
  }

  update(path, updater, nextTick) {
    this.setState(objectPathImmutable.update(this.state, path, updater), nextTick);
  }

  push(path, val, nextTick) {
    this.setState(objectPathImmutable.push(this.state, path, val), nextTick);
  }

  del(path, nextTick) {
    this.setState(objectPathImmutable.del(this.state, path), nextTick);
  }

  assign(path, obj, nextTick) {
    this.setState(objectPathImmutable.assign(this.state, path, val), nextTick);
  }

  insert(path, val, pos, nextTick) {
    this.setState(objectPathImmutable.insert(this.state, path, val, pos), nextTick);
  }

  systemDisplaySetBrightness(val) {
    if (!isNaN(val = +val)) {
      this.set("system.display.brightness", val);
    }
  }

  systemSoundGetIconName(volume = this.state.system.sound.volume) {
    if (volume === 0) {
      return "volume-off";
    } else if (volume < .5) {
      return "volume-down";
    } else {
      return "volume-up";
    }
  }

  systemSoundSetVolume(val) {
    if (!isNaN(val = +val)) {
      this.set("system.sound.volume", val);
    }
  }

  systemBatteryGetIcons8Name(level) {
    if (level === void 0) {
      return "battery-unknown";
    } else if (level === 0) {
      return "empty-battery";
    } else if (level < 1 / 3) {
      return "low-battery";
    } else if (level < 2 / 3) {
      return "medium-battery";
    } else if (level < 1) {
      return "high-battery";
    } else {
      return "full-battery";
    }
  }

  systemStorageGetFile(dir, path, success, error) {
    dir.getFile(path, {
      create: false
    }, success, error);
  }

  systemStorageCreateFile(dir, path, success, error) {
    dir.getFile(path, {
      create: true
    }, success, error);
  }

  systemStorageWriteFile(file, data, dataType, success, error) {
    file.createWriter(writer => {
      var blob;
      blob = new Blob([data], { dataType });
      writer.onwriteend = success;
      writer.onerror = error;
      writer.write(blob);
    }, error);
  }

  systemStorageReadFile(file, returnType = "text", success, error) {
    file.file(file => {
      var name, reader;
      reader = new FileReader();
      reader.onload = () => {
        success(reader.result);
      };
      reader.onerror = err => {
        error(err);
      };
      if (typeof reader[name = "readAs" + returnType[0].toUpperCase() + returnType.slice(1)] === "function") {
        reader[name](file);
      }
    }, error);
  }

  systemStorageDeleteFile(file, success, error) {
    file.remove(success, error);
  }

  systemStorageListEntries(dir, success, error) {
    var entries, fetchEntries, reader;
    reader = dir.createReader();
    entries = [];
    fetchEntries = () => {
      reader.readEntries(result => {
        if (result.length) {
          entries = [...entries, ...result];
          return fetchEntries();
        } else {
          return success(entries.sort().reverse());
        }
      }, error);
    };
    fetchEntries();
  }

  systemStorageLocalConnect(cb) {
    if (this.state.system.storage.local.env.manager) {
      cb(this.state.system.storage.local.env.manager);
    } else {
      this.push("system.storage.local.env.listeners.connected", cb);
    }
    return cb;
  }

  systemStorageLocalDisconnect(cbRef) {
    this.set("system.storage.local.env.listeners.connected", this.state.system.storage.local.env.listeners.connected.filter(cbFn => {
      return cbFn !== cbRef;
    }));
  }

  appsAppRun(parent, path, propsData) {
    fetch(path).then(res => {
      return res.text();
    }).then(text => {
      var Component, ref, task;
      Component = eval(Babel.transform(CoffeeScript.compile(text, {
        bare: true
      }), {
        presets: ["react"],
        plugins: ["syntax-object-rest-spread"]
      }).code);
      task = {
        name: Component.name,
        title: (ref = Component.modal) != null ? ref.title : void 0,
        path: path,
        pid: _.random(9e9),
        parent: parent
      };
      task.jsx = React.createElement(
        Modal,
        { key: task.pid, task: task, propsData: propsData },
        Component
      );
      app.push.call(parent, "apps.app.env.tasks", task);
    });
  }

  appsAppKill(task) {
    var ref, taskChild;
    ref = task.modal.state.apps.app.env.tasks;
    for (taskChild of ref) {
      taskChild.modal.close();
    }
    this.set.call(task.modal, "isOpen", false);
    setTimer(100, () => {
      this.set.call(task.parent, "apps.app.env.tasks", _.filter(task.parent.state.apps.app.env.tasks, taskChild => {
        return taskChild !== task;
      }));
    });
  }

  componentWillMount() {
    var ref;
    app = this;
    if (typeof navigator.getBattery === "function") {
      navigator.getBattery().then(battery => {
        battery.onlevelchange = () => {
          this.set("system.battery.level", battery.level);
        };
        battery.onchargingchange = () => {
          this.set("system.battery.charging", battery.charging);
        };
        this.set("system.battery.env.manager", battery);
        battery.onlevelchange();
        return battery.onchargingchange();
      });
    }
    if ((ref = navigator.webkitPersistentStorage) != null) {
      ref.requestQuota(1024 * 1024 * 4, size => {
        if (typeof window.webkitRequestFileSystem === "function") {
          window.webkitRequestFileSystem(Window.PERSISTENT, size, fs => {
            this.set("system.storage.local.env.manager", fs, () => {
              var cbFn, ref1, results;
              ref1 = this.state.system.storage.local.env.listeners.connected;
              results = [];
              for (cbFn of ref1) {
                results.push(cbFn(this.state.system.storage.local.env.manager));
              }
              return results;
            });
          }, err => {});
        }
      }, err => {});
    }
  }

  componentDidMount() {
    this.appsAppRun(this, "/programs/FileManager/index.cjsx");
  }

  rootClass() {
    return {
      backgroundImage: `url(${this.state.personal.background.imgSrc})`,
      backgroundSize: this.state.personal.background.size,
      backgroundPosition: "50%",
      backgroundRepeat: "no-repeat"
    };
  }

  rootNavbarClass() {
    return {
      [this.state.personal.taskbar.location]: 0
    };
  }

  render() {
    return React.createElement(
      "div",
      { className: "App", style: this.rootClass() },
      this.state.apps.app.env.tasks.map(task => {
        return task.jsx;
      }),
      React.createElement(
        Navbar,
        { className: "App-taskbar bp3-dark", style: this.rootNavbarClass() },
        React.createElement(
          NavbarGroup,
          { align: "left" },
          React.createElement(TaskbarHome, null),
          React.createElement(NavbarDivider, null)
        ),
        React.createElement(
          NavbarGroup,
          { align: "right" },
          React.createElement(NavbarDivider, null),
          React.createElement(
            ButtonGroup,
            null,
            React.createElement(TaskbarSound, null),
            React.createElement(TaskbarBattery, null),
            React.createElement(TaskbarDatetime, null),
            React.createElement(TaskbarAction, null)
          )
        )
      ),
      React.createElement("div", { className: "App-brightness", style: {
          opacity: 1 - this.state.system.display.brightness
        } })
    );
  }

};

Icons8 = function () {
  class Icons8 extends React.Component {
    render() {
      return React.createElement("img", { className: "bp3-icon", src: this.props.icon instanceof Element || /https?\:\/\//.test(this.props.icon) ? this.props.icon : `https://png.icons8.com/${this.props.type}/${this.props.size}/${this.props.color}/${this.props.icon}.png` });
    }

  };

  Icons8.defaultProps = {
    type: "material-rounded",
    color: "5c7080",
    size: 20
  };

  return Icons8;
}.call(this);

Modal = class Modal extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isOpen: true,
      apps: {
        app: {
          env: {
            tasks: []
          }
        }
      }
    };
    this.children = null;
    this.props.task.modal = this;
  }

  close() {
    app.appsAppKill(this.props.task);
  }

  render() {
    var Component, propsModal, ref, ref1, ref2, ref3, ref4;
    Component = this.props.children;
    propsModal = (ref = Component.modal) != null ? ref : {};
    return React.createElement(
      "div",
      { className: "Modal" },
      React.createElement(
        Dialog,
        { backdropClassName: propsModal.backdropClassName, backdropProps: {
            hidden: true,
            ...propsModal.backdropProps
          }, canEscapeKeyClose: (ref1 = propsModal.canEscapeKeyClose) != null ? ref1 : false, canOutsideClickClose: (ref2 = propsModal.canOutsideClickClose) != null ? ref2 : false, className: propsModal.className, icon: propsModal.icon, isCloseButtonShown: propsModal.isCloseButtonShown, isOpen: this.state.isOpen, onClose: event => {
            if (typeof propsModal.onClose === "function") {
              propsModal.onClose(event);
            }
            return this.close();
          }, style: propsModal.style, title: (ref3 = (ref4 = propsModal.title) != null ? ref4 : propsModal.name) != null ? ref3 : propsModal.path, usePortal: false },
        React.createElement(Component, _extends({ task: this.props.task }, this.props.propsData))
      ),
      this.state.apps.app.env.tasks.map(task => {
        return task.jsx;
      })
    );
  }

};

TaskbarAction = class TaskbarAction extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      grid: [{
        label: "Wifi",
        icon: React.createElement(Icons8, { icon: "wifi" })
      }, {
        label: "Bluetooth",
        icon: React.createElement(Icons8, { icon: "bluetooth" })
      }, {
        label: "Cài đặt",
        icon: "cog"
      }, {
        label: "Định vị",
        icon: React.createElement(Icons8, { icon: "place-marker" })
      }, {
        label: "Độ sáng",
        icon: "flash"
      }, {
        label: "Làm dịu mắt",
        icon: React.createElement(Icons8, { icon: "eye" })
      }, {
        label: "Không làm phiền",
        icon: "moon"
      }, {
        label: "Chế độ máy bay",
        icon: "airplane"
      }]
    };
  }

  render() {
    return React.createElement(
      Popover,
      { inheritDarkTheme: false, position: Position.TOP },
      React.createElement(Button, { minimal: true, icon: "menu" }),
      React.createElement(
        "div",
        { className: "bp3-padding" },
        React.createElement(
          ButtonGroup,
          { className: "TaskbarAction-grid", minimal: true },
          this.state.grid.map(function (item, i) {
            return React.createElement(
              Button,
              { key: i, icon: item.icon },
              item.label
            );
          })
        )
      )
    );
  }

};

TaskbarBattery = class TaskbarBattery extends React.Component {
  render() {
    return React.createElement(
      Tooltip,
      { content: `Pin: ${Math.round(app.state.system.battery.level * 100)}%`, openOnTargetFocus: false, disabled: app.state.system.battery.level === void 0 },
      React.createElement(Button, { icon: React.createElement(Icons8, { icon: app.systemBatteryGetIcons8Name(app.state.system.battery.level), color: "bfccd6" }), minimal: true })
    );
  }

};

TaskbarDatetime = class TaskbarDatetime extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      moment: moment()
    };
    this.timeout = void 0;
  }

  componentDidMount() {
    var tick;
    tick = () => {
      app.set.call(this, "moment", moment());
      this.timeout = setTimer(60000, () => {
        tick();
      });
    };
    setTimer((60 - this.state.moment.second()) * 1000, () => {
      tick();
    });
  }

  componentWillUnmount() {
    clearTimeout(this.timeout);
  }

  render() {
    return React.createElement(
      Popover,
      { inheritDarkTheme: false, position: Position.TOP },
      React.createElement(
        Tooltip,
        { tooltipClassName: "bp3-capitalize", content: this.state.moment.format("dddd, DD MMMM YYYY"), openOnTargetFocus: false, position: Position.TOP },
        React.createElement(
          Button,
          { minimal: true },
          this.state.moment.format("HH:mm DD/MM/YYYY")
        )
      ),
      React.createElement(DatePicker, { showActionsBar: true, defaultValue: this.state.moment.toDate() })
    );
  }

};

TaskbarHome = class TaskbarHome extends React.Component {
  render() {
    return React.createElement(
      Popover,
      { inheritDarkTheme: false, position: Position.TOP },
      React.createElement(Button, { minimal: true, text: "Leaf OS" })
    );
  }

};

TaskbarSound = class TaskbarSound extends React.Component {
  render() {
    return React.createElement(
      Popover,
      { inheritDarkTheme: false, position: Position.TOP },
      React.createElement(
        Tooltip,
        { content: `Âm lượng: ${Math.round(app.state.system.sound.volume * 100)}%`, openOnTargetFocus: false, position: Position.TOP },
        React.createElement(Button, { icon: app.systemSoundGetIconName(), minimal: true })
      ),
      React.createElement(
        "div",
        { className: "bp3-padding" },
        React.createElement(Slider, { max: 100, labelStepSize: 25, vertical: true, value: app.state.system.sound.volume * 100, onChange: val => {
            app.systemSoundSetVolume((val / 100).toFixed(2));
          } })
      )
    );
  }

};

FocusStyleManager.onlyShowFocusOnTabs();

ReactDOM.render(React.createElement(App, null), document.getElementById("root"));})();