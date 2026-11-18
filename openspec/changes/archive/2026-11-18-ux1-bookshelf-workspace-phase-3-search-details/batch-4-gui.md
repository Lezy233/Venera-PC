# UX1 5.x GUI evidence

本阶段尚未取得可交付的 5.x GUI 证据，故 5.5 保持未勾选。

## Display access check

Read-only shell facts at 2026-11-18:

- `DISPLAY=:2`
- `GDK_BACKEND=wayland,x11`
- `WAYLAND_DISPLAY=wayland-1`
- `XDG_SESSION_TYPE=wayland`
- `XAUTHORITY` unset
- `/run/user/1000/wayland-1` is a readable socket
- `xprop -root` on `:2` cannot open the display

The current executor pane can see the Wayland socket but cannot use the X11 helper on
`:2`; no `:1` fixture was started and no owner window or data was touched. A fixed
GUI helper was not recreated without architect review. Therefore no search, detail
mode, settings persistence, loading/error, route, focus, request-count, or screenshot
claim is made here.

A bounded Wayland capability probe found `/usr/bin/grim`, `/usr/bin/wl-copy`, and
`/usr/bin/wayland-info`; the socket is `srwxr-xr-x`, uid/gid 1000, at
`/run/user/1000/wayland-1`. There is no `wtype`, `ydotool`, or `swaymsg`, so this pane
has screenshot support but no approved input path for real production taps/keys. The
probe stopped before launching the bundle; no Wayland window, screenshot, or owner
data was touched. This is an environment capability boundary, not a product result.

## Build

The normal production Linux bundle built successfully with:

```text
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 \
  fvm flutter build linux --debug --no-pub
```

Output: `build/linux/x64/debug/bundle/venera-next`. This is a build result, not GUI
evidence.
