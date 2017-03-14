#include "..\library\_PSTestingLibrary.au3"
;-----------------------------------------------------------------------------;
Local $testName = "Preview Persona Options Preferences" ;
Local $tests[5]

; start Firefox and setup for tests
InitializeFirefox()

ResetPersonaSwitcherPrefs()

; Enable the Preview Persona preference with 10000 ms
EnablePreviewPersonaWithTime()

Local $themeList = GetListOfThemeIds()

; run tests and store results
$tests[0] = PreviewThemeOnIcon($themeList)
$tests[1] = PreviewThemeOnPSwitcherMenuBar($themeList)
$tests[2] = PreviewThemeOnToolsMenu($themeList)
$tests[3] = PreviewPersonaMinDelayTime()
$tests[4] = PreviewPersonaMaxDelayTime()

; save results to file
SaveResultsToFile($tests, $testName)

ResetPersonaSwitcherPrefs()

; disconnect and close from Firefox
EndFirefox()
;-----------------------------------------------------------------------------
; Helper function
Func EnablePreviewPersonaWithTime()
   ;Set preference value to 10000ms (10 sec)

   SetPsOption('preview', True)
   SetPsOption('preview-delay', "10000")

   RestartFirefox()
EndFunc
;-----------------------------------------------------------------------------;
; Testing in the Persona Switcher icon menu, that when we hover over a theme,
; a preview of that theme is displayed after 10 seconds.
Func PreviewThemeOnIcon($themeList)
   Local $testResults

   ; grab default theme
   ResetToDefaultTheme()
   Local $defaultTheme = _FFPrefGet("lightweightThemes.selectedThemeID")

   ; grab the id of the theme that will be previewed
   Local $previewThemeId = $themeList[0]

   OpenPersonaSwitcherButton()
   Send("{DOWN 2}")
   Sleep(9500)

   ;Check that the theme preview hasn't shown up yet
   Local $themeCheck = _FFPrefGet("lightweightThemes.selectedThemeID")

   ;Sleep another second
   Sleep(1000)

   ; grab the "preview" theme image url and search for the theme id
   Local $previewImageUrl = GetDisplayedThemeBackground()
   Local $isPreviewTheme = StringRegExp($previewImageUrl, $previewThemeId, 0) ;return true/false

   ;getting out of the preview menu
   Send("{ESC}")
   Sleep(500)

   If $isPreviewTheme AND $themeCheck == $defaultTheme AND $defaultTheme == _FFPrefGet("lightweightThemes.selectedThemeID") Then
      $testResults = "TEST PASSED: From the icon menu bar, the theme preview appeared in 10 seconds and did not change the active theme"
   Else
      $testResults = "TEST FAILED: From the icon menu bar, the theme preview did not appear in 10 seconds"
   EndIf

   Return $testResults
EndFunc
;-----------------------------------------------------------------------------;
; Testing in the Persona Switcher main menu, that when we hover over a theme,
; a preview of that theme is displayed after 10 seconds.
Func PreviewThemeOnPSwitcherMenuBar($themeList)
   Local $testResults

   ;Set menu preference
   SetPsOption('main-menubar', True)
   SetPsOption('preview', True)
   SetPsOption('preview-delay', "10000")

   ; grab default theme
   ResetToDefaultTheme()
   Local $defaultTheme = _FFPrefGet("lightweightThemes.selectedThemeID")

   ; grab the id of the theme that will be previewed
   Local $previewThemeId = $themeList[0]

   ; select a theme from the main menu and wait 10 secs
   Send("!p")
   Sleep(500)
   Send("{DOWN}")
   Sleep(9500)

   ;Check that the theme preview hasn't shown up yet
   Local $themeCheck = _FFPrefGet("lightweightThemes.selectedThemeID")

   ;Sleep another second
   Sleep(1000)

   ; grab the "preview" theme image url and search for the theme id
   Local $previewImageUrl = GetDisplayedThemeBackground()
   Local $isPreviewTheme = StringRegExp($previewImageUrl, $previewThemeId, 0) ;return true/false

   ;getting out of the preview menu
   Send("{ESC}")
   Sleep(500)

   If $isPreviewTheme AND $themeCheck == $defaultTheme AND $defaultTheme == _FFPrefGet("lightweightThemes.selectedThemeID") Then
      $testResults = "TEST PASSED: From the main menu, the theme preview appeared in 10 seconds and did not change the active theme"
   Else
      $testResults = "TEST FAILED: From the main menu, the theme preview did not appear in 10 seconds"
   EndIf

   Return $testResults
EndFunc
;-----------------------------------------------------------------------------;
; Testing in the Persona Switcher tools menu, that when we hover over a theme,
; a preview of that theme is displayed after 10 seconds.
Func PreviewThemeOnToolsMenu($themeList)
   Local $testResults

   ; Set menu preference
   SetPsOption('tools-submenu', True)
   SetPsOption('preview', True)
   SetPsOption('preview-delay', "10000")

   ; grab default theme
   ResetToDefaultTheme()
   Local $defaultTheme = _FFPrefGet("lightweightThemes.selectedThemeID")

   ; grab the id of the theme that will be previewed
   Local $previewThemeId = $themeList[0]

   ;opening the toolbar menu and previewing a theme
   Send("{f10}")
   Sleep(500)
   Send("t")
   Sleep(500)
   Send("p")
   Sleep(500)
   Send("{DOWN}")
   Sleep(9500)

   ;Check that the theme preview hasn't shown up yet
   Local $themeCheck = _FFPrefGet("lightweightThemes.selectedThemeID")

   ;Sleep another second
   Sleep(1000)

   ; grab the "preview" theme image url and search for the theme id
   Local $previewImageUrl = GetDisplayedThemeBackground()
   Local $isPreviewTheme = StringRegExp($previewImageUrl, $previewThemeId, 0) ;return true/false

   ;getting out of the preview menu
   Send("{ESC 2}")
   Sleep(500)

   If $isPreviewTheme AND $themeCheck == $defaultTheme AND $defaultTheme == _FFPrefGet("lightweightThemes.selectedThemeID") Then
      $testResults = "TEST PASSED: From the tools menu, the theme preview appeared in 10 seconds and did not change the active theme"
   Else
      $testResults = "TEST FAILED: From the tools menu, the theme preview did not appear in 10 seconds"
   EndIf
   Return $testResults
EndFunc
;-----------------------------------------------------------------------------;
; Testing that the min value of the preference is 0 and nothing less can be entered.
Func PreviewPersonaMinDelayTime()
   Local $testResults

   Local $negativeValueCopy = SetPsOption('preview-delay', "-1", True)
   Local $zeroValueCopy = SetPsOption('preview-delay', "0", True)

   ; check that value is set to the min
   If $zeroValueCopy == 0 AND $negativeValueCopy == 1 Then
      $testResults = "TEST PASSED: value -1 for the preference was not accepted, but value 0 was accepted because the min is 0"
   Else
      $testResults = "TEST FAILED: values -1 and 0 for the preference were both accepted even though the min is 0"
   EndIf
   Return $testResults
EndFunc
;------------------------------------------------------------------------------------
; Testing that the max value of the preference is 10000 and nothing larger
; can be entered.
Func PreviewPersonaMaxDelayTime()
   Local $testResults

   Local $valueCopy = SetPsOption('preview-delay', "10001", True)

   ; check that value is set to the max
   If $valueCopy == 10000 Then
      $testResults = "TEST PASSED: the value 10001 was not accepted for the preference because the max is 10000"
   Else
      $testResults = "TEST FAILED: the value 10001 was accepted for the preference even though the max is 10000"
   EndIf
   Return $testResults
EndFunc