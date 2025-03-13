import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import { Variable } from "astal"

const full_time = Variable("").poll(1000, "date '+%H:%M %A %d/%m'")

const time = Variable.derive(
  [full_time],
  (full_time) => {
    return  full_time.split(" ")[0] + " 󱑕 "
  }
)

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
      <box />
      <menubutton
        hexpand
        halign={Gtk.Align.CENTER}
    >
        <label label={time()} />
        <popover>
            <Gtk.Calendar />
        </popover>
      </menubutton>
    </centerbox>
  </window>
}
