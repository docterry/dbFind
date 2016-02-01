/*	dbFindConflict
	Recursively searches Dropbox folder for "conflicted copy" files.
	If "conflicted copy" is older than other file, delete conflicted copy.
	If "conflicted copy" is newer than other file, ask. Help button loads files into WinMerge Portable.
*/
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%

myDir := A_ScriptDir
if instr(myDir,"Dropbox\") {
	dbPath := strX(myDir,"",1,0,"Dropbox\",1,0)
} else {
	dbPath := A_MyDocuments "\Dropbox\"
	if !InStr(FileExist(dbPath), "D") {
		MsgBox, 16, Cannot find Dropbox folder
		ExitApp
	}
}
searchStr := "conflicted copy"
regExStr := "\s\(.*" searchStr ".*\)"
Gui, +OwnDialogs
OnMessage(0x10, "exitout")
filect := 0
estMax := 6000

Progress, M2 T, , 0, 0
Loop, %dbPath%* , , 1
{
	full := A_LoopFileLongPath
	ind := A_Index
	Progress, % 100*(ind/estMax) , , % ind, % filect " conflicted"
	if instr(full,searchStr) {
		fullNon := RegExReplace(full,regExStr)
		if !FileExist(fullNon) {
			Progress, Hide
			MsgBox, 4, Missing file
					, % full "`n`n"
					. "Found ""conflicted copy"" without`n"
					. "non-conflicted copy.`n`n"
					. "Rename file?"
			IfMsgBox Yes
			{
				FileMove, %full%, %fullNon%
			}
			continue
			Progress, show
		}
		FileGetTime, dateNm, %full%
		FileGetTime, dateNon, %fullNon%
		dateDiff := dateNm
		dateDiff -= dateNon, Seconds
		if (dateDiff>0) {										; Conflicted copy is at least 1 sec newer
			FileMove, %full%, %fullNon%, 1
			filelog .= full " newer.`n"
			filect += 1
		} else {												; Conflicted copy is older,
			FileDelete %full%									; Delete it.
			filelog .= full " older.`n"
			filect += 1
		}
	}
}
Progress, off
MsgBox,,% filect " files deleted", % ind " total files.`n" filelog

ExitApp

exitout() 
{
	global
	Progress, off
	MsgBox,,Aborted!, % filect " files deleted.`n" ind " total files.`n" filelog
	ExitApp
}

/* StrX parameters
StrX( H, BS,BO,BT, ES,EO,ET, NextOffset )

Parameters:
H = HayStack. The "Source Text"
BS = BeginStr. 
Pass a String that will result at the left extreme of Resultant String.
BO = BeginOffset. 
Number of Characters to omit from the left extreme of "Source Text" while searching for BeginStr
Pass a 0 to search in reverse ( from right-to-left ) in "Source Text"
If you intend to call StrX() from a Loop, pass the same variable used as 8th Parameter, which will simplify the parsing process.
BT = BeginTrim.
Number of characters to trim on the left extreme of Resultant String
Pass the String length of BeginStr if you want to omit it from Resultant String
Pass a Negative value if you want to expand the left extreme of Resultant String
ES = EndStr. Pass a String that will result at the right extreme of Resultant String
EO = EndOffset.
Can be only True or False.
If False, EndStr will be searched from the end of Source Text.
If True, search will be conducted from the search result offset of BeginStr or from offset 1 whichever is applicable.
ET = EndTrim.
Number of characters to trim on the right extreme of Resultant String
Pass the String length of EndStr if you want to omit it from Resultant String
Pass a Negative value if you want to expand the right extreme of Resultant String
NextOffset : A name of ByRef Variable that will be updated by StrX() with the current offset, You may pass the same variable as Parameter 3, to simplify data parsing in a loop
*/
StrX( H,  BS="",BO=0,BT=1,   ES="",EO=0,ET=1,  ByRef N="" ) { ;    | by Skan | 19-Nov-2009
Return SubStr(H,P:=(((Z:=StrLen(ES))+(X:=StrLen(H))+StrLen(BS)-Z-X)?((T:=InStr(H,BS,0,((BO
<0)?(1):(BO))))?(T+BT):(X+1)):(1)),(N:=P+((Z)?((T:=InStr(H,ES,0,((EO)?(P+1):(0))))?(T-P+Z
+(0-ET)):(X+P)):(X)))-P) ; v1.0-196c 21-Nov-2009 www.autohotkey.com/forum/topic51354.html
}
