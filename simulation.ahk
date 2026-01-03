; ===========================
; Wired Simulation (No GDI+)
; ===========================
; Uses only standard AutoHotkey GUI controls
; Shows nodes (Human, Device, AI) with immersion + identity bars

#SingleInstance Force

global nodes := []
global running := true
global tick := 0

Gui, +Resize +AlwaysOnTop
Gui, Font, s10, Segoe UI
Gui, Add, Text, xm ym, Wired Simulation (Basic)
Gui, Add, Button, x+10 yp w80 gToggleRun, Pause/Run
Gui, Add, Button, x+10 yp w80 gStep, Step
Gui, Add, Button, x+10 yp w80 gReset, Reset
Gui, Add, Text, xm y+20 vTickText, Tick 0

Gui, Add, ListView, xm y+10 w500 h400 vNodeList, ID|Type|Immersion|Identity|Heat

InitNodes()
UpdateDisplay()

Gui, Show, w520 h460, Wired Simulation
SetTimer, SimStep, 500
return

; --- Simulation Step ---
SimStep:
if !running
    return
tick++
UpdateNodes()
UpdateDisplay()
return

ToggleRun:
running := !running
return

Step:
if !running {
    tick++
    UpdateNodes()
    UpdateDisplay()
}
return

Reset:
InitNodes()
tick := 0
UpdateDisplay()
return

; --- Helpers ---
InitNodes() {
    global nodes
    nodes := []
    types := ["Human","Device","AI"]
    Loop, 10 {
        type := types[Mod(A_Index,3)+1]
        node := {id:A_Index
            , type:type
            , immersion:RandomFloat(0.3,0.7)
            , identity:RandomFloat(0.6,0.9)
            , resilience:RandomFloat(0.2,0.8)
            , heat:0}
        nodes.Push(node)
    }
}

UpdateNodes() {
    global nodes
    for i, n in nodes {
        shock := 0.02 * n.immersion
        heal := 0.01 * n.resilience
        n.identity := Clamp01(n.identity - shock + heal)
        n.immersion := Clamp01(n.immersion + RandomFloat(-0.02,0.02))
        n.heat := Clamp01(n.heat*0.8 + shock*3)
    }
}

UpdateDisplay() {
    global nodes, tick
    GuiControl,, TickText, Tick %tick%
    LV_Delete()
    for i, n in nodes {
        LV_Add("", n.id, n.type, Round(n.immersion,2), Round(n.identity,2), Round(n.heat,2))
    }
}

; --- Math helpers ---
RandomFloat(min,max) {
    Random, out, 0.0, 1.0
    return min + (max-min)*out
}
Clamp01(val) {
    return (val<0 ? 0 : val>1 ? 1 : val)
}

GuiClose:
ExitApp
