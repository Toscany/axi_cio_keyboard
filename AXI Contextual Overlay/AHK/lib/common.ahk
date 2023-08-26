/*
	Contains Common Functions
*/

ObjToStr(obj) {
	str := "" , array := true
	for k in obj {
		if (k == A_Index)
			continue
		array := false
		break
	}
	for a, b in obj
		str .= (array ? "" : "'" a "': ") . (IsObject(b) ? ObjToStr(b) : "'" b "'") . ", "	
	str := RTrim(str, " ,")
	return (array ? "[" str "]" : "{" str "}")
}

getFile(target, access := "r") {
	try
		FileObj := FileOpen(target, access)
	catch as Err
	{
		 MsgBox "Can't open `"" target "`" with `"" access "`" permissions."
			. "`n`n" Type(Err) ": " Err.Message
		return
	}
	return FileObj
}

;            Keybinds.json Structure
;	+---------------------------------------+
; A [	+---------------------------------+ |
;	| M	[		Id	:	###				  | |
;	|	|	  Name	:	"abc"			  | |
;	|	|					+-----------+ | |
;	|	|  		KB	:  A 	[	###,	| | |
;	|	|				 	|	###		] | |
;	|	|					+-----------+ ] |
;	|	+---------------------------------+,|
;	|		.								|
;	|		.								|
;	|		.								|
;	|		N								|
;	+---------------------------------------+
;
; KBtoMessage creates a message box with the contents of the keybinds.json

MessageKBjson(jsonObj) {
	message := ""
	message .= "Array length : " jsonObj.Length "`n`n Elements:`n"

	for i in jsonObj {  ; iterate through an Array of Maps
		res := ""
		res .= "Id: " i["Id"] 
			. 	" : " i["Name"]
		size := i["KB"].Length
		if size = 0 {
			message .= res "`n"		;"Keybinds array is length zero = no key bound"
			continue 				; jumps to next i in json without appending res with KB data
		}
		
		res	.= " Keybind : " i.Get("KB")[1]
		
		if size > 1 {
			j := 1
			while j < size
				res .= " + " i["KB"][++j]
		}
		message .= res "`n"
	}
	MsgBox message
	return message
}


; the "Boundaries" key has an Array value containing Maps with 2 keys to X,Y coordinates
; target is an array of 8 integers [ 0, 0, 0, 0, 0, 0, 0, 0 ]
getBounds(&target, bound_array_of_maps) { 
	bounds := bound_array_of_maps 
	
	target[1] := bounds[1]["X"]
	target[2] := bounds[1]["Y"]
	target[3] := bounds[2]["X"]
	target[4] := bounds[2]["Y"]
	target[5] := bounds[3]["X"]
	target[6] := bounds[3]["Y"]
	target[7] := bounds[4]["X"]
	target[8] := bounds[4]["Y"]
	return target
}

; NohBoard keyboard.json format
; NOTE: NohBoard will throw an error;
;	 if "__type" map keys are moved from being the first key in their respective map
;    all other map keys can be sorted and/or rearranged
	; +---------------------------------------------------------------+
	; [	Version	:	2,												  |
	; |	Height	:	555,											  |
	; |	Width	:	401,											  |
	; |				+-----------------------------------------------+ |
	; | Elements: A [	+-----------------------------------------+ | |
	; |				| M	[	    __type	: "MouseSpeedIndicator"	  | | |
	; |				|	|		  Id	: 	113,				  | | |
	; |				|	| 		Radius	:	51,					  ] | |
	; |				|	|					+-----------+		  | | |
	; |				|	|	  Location	: M [ X : XXX,	|		  | | |
	; |				|	|					| Y : XXX	]		  | | |
	; |				|	|					+-----------+		  ] | |
 	; |				|	+-----------------------------------------+,| |
	; |				|	+-----------------------------------------+ | |
	; |				| M	[ 	  __type	:	"KeyboardKey",		  | | |
	; |				|	|			Id	:	###,				  | | |
	; |				|	|		  Name	:	"abc",				  | | |
	; |				|	|					+-----------+		  | | |
	; |				|	|	  KeyCodes	: A	[	###,	|		  | | |
	; |				|	|					|	...		]		  | | |
	; |				|	|					+-----------+,		  | | |
	; |				|	|		  Text	: 	"abc",				  | | |
	; |				|	|	 ShiftText	:	"abc",				  |	| |
	; |				|	| ChangeOnCaps	:	true/false,			  | | |
	; |				|	|					+-----------+		  | | |
	; |				|	| TextPosition	: M [ X : ###,	|		  | | |
	; |				|	|					| Y : ###	]		  | | |
	; |				|	|					+-----------+,		  | | |
	; |				|	|					+-------------------+ | | |
	; |				|	|					|	  +---------+	| | | |
	; |				|	|	Boundaries	: A	[	M [ X : ###,|	| | | |
	; |				|	|					|	  |	Y : ###	],	| | | |
	; |				|	|					|	  +---------+	| | | |
	; |				|	|					|	M [ X : ###,|	| | | |
	; |				|	|					|	  |	Y : ###	]	| | | |
	; |				|	|					|	  +---------+	| | | |
	; |				|	|					|	M [ X : ###,|	| | | |
	; |				|	|					|	  |	Y : ###	],	| | | |
	; |				|	|					|	  +---------+	| | | |
	; |				|	|					|	M [ X : ###,|	| | | |
	; |				|	|					|	  |	Y : ###	]	| | | |
	; |				|	|	  				|	  +---------+	] | | |
	; |				|	|	  				+-----------------+ ] | | |
 	; |				|	+-----------------------------------------+,| |
	; |				|		.										| |
	; |				|		.										| |
	; |				|		.										] |
	; |				|		N										] |
	; |				+-----------------------------------------------+ |
	; +-----------------------------------------------------------------+
; NohBoard_Keyboard_Json_Export
;	returns a json formatted string for replacing the current keyboard.json
; 	NOTE: The "Name" and "KB" (keybind) values from keybind_jsonObj are copied into 
;		respective elements of keyboard_jsonObj during the return string construction.
NohBoard_Keyboard_Json_Export(keybind_jsonObj, keyboard_jsonObj) {
	
	; Non-Format text vars
	indent := "   ", indent2 := indent indent,	indent3 := indent2 indent, indent4 := indent2 indent2, indent5 := indent3 indent2
	newA := "[`n", newM := "{`n", endM := "}", nextval := ",`n"
	k_type := "`"__type`": ", k_id := "`"Id`": ", k_rad := "`"Radius`": "
	k_coc := "`"ChangeOnCaps`": ", k_tk := k_type "`"KeyboardKey`"",
	k_codes := "`"KeyCodes`": " newA, k_tp := "`"TextPosition`": "
	
	; Format text vars
	k_loc := "`"Location`": " 
	k_xy := newM
		. indent5 "`"X`": {1}" nextval
		. indent5 "`"Y`": {2}`n"
		. indent4 endM
	k_n := "`"Name`": `"{}`""
	k_text := "`"Text`": `"{}`"", k_stext := "`"ShiftText`": `"{}`""
	k_bound := "`"Boundaries`": " newA indent4 newM
			. indent5	"`"X`": {1},`n"
			. indent5	"`"Y`": {2}`n"
			. indent4 endM nextval
			. indent4 newM
			. indent5	"`"X`": {3},`n"
			. indent5 	"`"Y`": {4}`n"
			. indent4 endM nextval 
			. indent4 newM
			. indent5	"`"X`": {5},`n"
			. indent5	"`"Y`": {6}`n"
			. indent4 endM nextval
			. indent4 newM
			. indent5	"`"X`": {7},`n"
			. indent5	"`"Y`": {8}`n"
			. indent4 endM "]`n" 
	bounds := [ 0, 0, 0, 0, 0, 0, 0, 0 ]
	
	; Begin building NohBoard keyboard.json
	jsonStr := ""
			. newM indent "`"Version`":" indent keyboard_jsonObj["Version"] nextval
			. indent "`"Height`":" indent keyboard_jsonObj["Height"] nextval
			. indent "`"Width`":" indent keyboard_jsonObj["Width"] nextval
			. indent "`"Elements`": [`n"
	
	e := keyboard_jsonObj["Elements"]
	j := 1 ; index
	e_size := e.Length
	for i in e {
		jsonStr .= indent2 newM
		
		if i["__type"] == "MouseSpeedIndicator" {
			jsonStr .=  indent3 k_type "`"MouseSpeedIndicator`"" nextval
					. 	indent3 k_id i["Id"] nextval
					.	indent3 k_rad i["Radius"] nextval
					.	indent3 Format(k_loc k_xy, i["Location"].Get("X"),i["Location"].Get("Y")) 
					.	"`n" indent2 endM nextval
			continue
		}
		; all the keys ondisplay
		jsonStr .= indent3	k_tk nextval
				. indent3	k_id i["Id"] nextval
				
		for z in keybind_jsonObj 
			if z["Id"] = i["Id"] {
				jsonStr .= indent3	Format(k_n, z["Name"]) nextval
						.	indent3 k_codes
				x := 1
				z_size := z["KB"].Length
				if z_size = 0
					jsonStr .= indent3 " ],`n"
				for y in z["KB"]
					jsonStr .= indent4 y 
							. (( x++ < z_size )? nextval : ("`n" indent3 "]" nextval))
				
				break
			}
		jsonStr .= indent3 Format(k_text, i["Text"]) nextval
				. indent3 Format(k_stext, i["ShiftText"]) nextval
				. indent3 k_coc (i["ChangeOnCaps"]? "true" : "false") nextval
				. indent3 Format(k_tp k_xy, i["TextPosition"].Get("X"), i["TextPosition"].Get("Y")) nextval
				
		getBounds(&bounds, i["Boundaries"])
		jsonStr .= indent3 	Format(k_bound, bounds* )
				. 	indent2 endM
		if ++j < e_size
			jsonStr .= nextval
	}
	jsonStr .= "`n" indent "]`n" endM "`n"
	
	return jsonStr
}
