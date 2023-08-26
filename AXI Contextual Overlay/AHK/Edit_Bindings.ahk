#Include .\lib\ActiveScript.ahk
#Include .\lib\JXON.ahk
#Include .\lib\common.ahk

keybindsFilePath := ".\keybinds.json"
b_keybindsFilePath := ".\backups\b_keybinds.json"
keyboardFilePath := "..\Maneuvering\keyboard.json"

jsonStr := "",	jsonObj := "",	currFile := ""
messageA := "", messageB := ""


; Load keybinds json object
keybindsFile := getFile(keybindsFilepath, "r")
jsonStr := keybindsFile.Read()
keybindsFile.Close()

keybind_json := ""
keybind_json := Jxon_Load(&jsonStr)

; backup keybinds json

; backup keyboard json  

; Load keyboard json object

currFile := getFile(keyboardFilePath, "r")
jsonStr := currFile.Read()
currFile.Close()

keyboard_json := ""
keyboard_json := Jxon_Load(&jsonStr)

; write new keyboard.json using names and keybinds from keybinds.json
jsonStr := NohBoard_Keyboard_Json_Export(keybind_json, keyboard_json)

currFile := getFile(keyboardFilePath,"w")
currFile.Write(jsonStr)
currFile.Close()

MsgBox "Task Complete"
