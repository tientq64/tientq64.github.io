(function(){var AbstractComponent, AbstractPureComponent, Alert, Alignment, AnchorButton, AnimationStates, App, Blockquote, Breadcrumb, Button, ButtonGroup, Callout, Card, Checkbox, Classes, Code, Collapse, CollapseFrom, CollapsibleList, Colors, ContextMenu, ContextMenuTarget, ControlGroup, DateInput, DatePicker, DateRangeBoundary, DateRangeInput, DateRangePicker, DateTimePicker, Dialog, EditableText, Elevation, Expander, FileInput, FocusStyleManager, FormGroup, H1, H2, H3, H4, H5, H6, Hotkey, Hotkeys, HotkeysTarget, Icon, IconContents, IconNames, IconSvgPaths16, IconSvgPaths20, Icons8, InputGroup, Intent, KeyCombo, Keys, Label, Menu, MenuDivider, MenuItem, Modal, MultiSelect, Navbar, NavbarDivider, NavbarGroup, NavbarHeading, NonIdealState, NumericInput, OL, Omnibar, Overlay, Popover, PopoverInteractionKind, Portal, Position, Pre, ProgressBar, QueryList, Radio, RadioGroup, RangeSlider, Select, Slider, Spinner, Suggest, Switch, Tab, Table, Tabs, Tag, TagInput, TaskbarAction, TaskbarBattery, TaskbarDatetime, TaskbarHome, TaskbarSound, Text, TextArea, TimePicker, TimePickerPrecision, Toast, Toaster, Tooltip, Tree, TreeNode, UL, Utils, app, setTimer;

({ FocusStyleManager, Classes, Keys, Utils, AbstractComponent, AbstractPureComponent, Alignment, Colors, Intent, Position, ContextMenu, Alert, Breadcrumb, Button, AnchorButton, ButtonGroup, Callout, Elevation, Card, AnimationStates, Collapse, CollapseFrom, CollapsibleList, ContextMenuTarget, Dialog, EditableText, ControlGroup, Switch, Radio, Checkbox, FileInput, FormGroup, InputGroup, Label, NumericInput, RadioGroup, TextArea, H1, H2, H3, H4, H5, H6, Blockquote, Code, Pre, OL, UL, Hotkey, KeyCombo, HotkeysTarget, Hotkeys, Icon, Menu, MenuDivider, MenuItem, Navbar, NavbarDivider, NavbarGroup, NavbarHeading, NonIdealState, Overlay, Table, Text, PopoverInteractionKind, Popover, Portal, ProgressBar, RangeSlider, Slider, Spinner, Tab, Expander, Tabs, Tag, TagInput, Toast, Toaster, Tooltip, Tree, TreeNode } = Blueprint.Core);

({ IconContents, IconNames, IconSvgPaths16, IconSvgPaths20 } = Blueprint.Icons);

({ Omnibar, QueryList, MultiSelect, Select, Suggest } = Blueprint.Select);

({ DateRangeBoundary, DateInput, DatePicker, DateTimePicker, DateRangeInput, DateRangePicker, TimePicker, TimePickerPrecision } = Blueprint.Datetime);

Classes = { ...Blueprint.Core.Classes, ...Blueprint.Select.Classes, ...Blueprint.Datetime.Classes };

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
            tasks: [],
            dialogs: []
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

  systemStorageGetFile(dir, path, opts, success, error) {
    dir.getFile(path, opts, success, error);
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
        reader[name]();
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

  appsAppRun(path, tasksPath) {
    fetch(`${path}/index.cjsx`).then(res => {
      return res.text();
    }).then(text => {
      var Component;
      Component = eval(Babel.transform(CoffeeScript.compile(text, {
        bare: true
      }), {
        presets: ["react"],
        plugins: ["syntax-object-rest-spread"]
      }).code);
      app.push.call(this, tasksPath, {
        modal: React.createElement(
          Modal,
          { key: Math.random(), title: path },
          React.createElement(Component, null)
        )
      });
    });
  }

  componentDidMount() {
    this.appsAppRun("../../programs/FileManager", "apps.app.env.tasks");
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
        return task.modal;
      }),
      this.state.apps.app.env.dialogs.map(dialog => {
        return dialog;
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
      tasks: [],
      dialogs: []
    };
  }

  close(event) {
    app.set.call(this, "isOpen", false);
  }

  onClosed() {
    app.appsTaskKill(this.props.pid);
  }

  render() {
    var ref;
    return React.createElement(
      "div",
      null,
      React.createElement(
        Dialog,
        { backdropProps: {
            hidden: true,
            ...this.props.backdropProps
          }, canEscapeKeyClose: false, canOutsideClickClose: false, className: this.props.className, enforceFocus: true, icon: this.props.icon, isCloseButtonShown: this.props.isCloseButtonShown, isOpen: this.state.isOpen, onClose: event => {
            var base;
            if (typeof (base = this.props).onClose === "function") {
              base.onClose(event);
            }
            return this.close();
          }, onClosed: el => {
            var base;
            if (typeof (base = this.props).onClosed === "function") {
              base.onClosed(el);
            }
            return this.onClosed();
          }, onClosing: this.props.onClosing, onOpened: this.props.onOpened, onOpening: this.props.onOpening, style: this.props.style, title: (ref = this.props.title) != null ? ref : this.props.name, transitionDuration: this.props.transitionDuration, transitionName: this.props.transitionName, usePortal: false },
        this.props.children ? this.props.children : ["body", "footer"].map(v => {
          if (this.props[v]) {
            return React.createElement(
              "div",
              { key: v, className: `bp3-dialog-${v}` },
              typeof this.props[v] === "function" ? this.props[v](this) : this.props[v]
            );
          }
        })
      ),
      this.state.dialogs.map(dialog => {
        return dialog;
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