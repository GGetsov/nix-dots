import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import { Variable, bind } from "astal"
import Battery from "gi://AstalBattery"

function BatteryLevel() {
  const bat = Battery.get_default()

  return <box className="Battery"
    visible={bind(bat, "isPresent")}>
    <label label={bind(bat, "percentage").as(p =>
        `${Math.floor(p * 100)} %`
    )} />
  </box>
}

function Time(){
  const time = Variable("").poll(1000, "date '+%H:%M'")

  // const time = Variable.derive(
  // [full_time],
  // (full_time) => {
  //   return  "󱑕  " + full_time.split(" ")[0] 
  // }
  
  return <menubutton hexpand halign={Gtk.Align.CENTER} >
      <label label={bind(time()).as(time =>
        `󱑕  ${time}` 
      )} />
      <popover>
          <Gtk.Calendar />
      </popover>
    </menubutton>
}



export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return <window
    visible
    cssClasses={["Bar"]}
    gdkmonitor={gdkmonitor}
    exclusivity={Astal.Exclusivity.EXCLUSIVE}
    anchor={TOP | LEFT | RIGHT}
    application={App}>
    <centerbox cssName="centerbox">
      <box >
        <BatteryLevel />
      </box>
        <Time /> 
      <box >
        <BatteryLevel />
      </box>
    </centerbox>
  </window>
}
