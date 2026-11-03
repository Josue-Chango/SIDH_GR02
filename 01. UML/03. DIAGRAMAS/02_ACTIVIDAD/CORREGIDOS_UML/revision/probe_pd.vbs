Option Explicit
Dim pd, m, d, s, f
Set pd = CreateObject("PowerDesigner.Application")
WScript.Echo "PowerDesigner COM conectado"
pd.InteractiveMode = 0
Set m = pd.OpenModel("C:\Users\Usuario\Desktop\Web Avanzada\CORREGIDOS_UML\DA_CU01_Iniciar_Sesion.oom")
If m Is Nothing Then WScript.Quit 2
WScript.Echo "Modelo: " & m.Name
WScript.Echo "Actividades: " & m.Activities.Count & " Flujos: " & m.Flows.Count
For Each f In m.Flows
  On Error Resume Next
  WScript.Echo f.Name & ": " & f.Object1.Name & " -> " & f.Object2.Name & " / " & f.Condition
  If Err.Number <> 0 Then WScript.Echo "ERROR: " & Err.Description : Err.Clear
  On Error GoTo 0
Next
Set d = m.ActivityDiagrams.Item(0)
WScript.Echo "Diagrama: " & d.Name & "; simbolos: " & d.Symbols.Count
Set pd = Nothing
