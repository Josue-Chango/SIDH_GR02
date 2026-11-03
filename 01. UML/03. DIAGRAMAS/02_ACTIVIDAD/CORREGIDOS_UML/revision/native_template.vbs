Option Explicit
Dim pd, m, d, u, a, b, f, s, v, c, fs, out
Set pd=CreateObject("PowerDesigner.Application")
pd.InteractiveMode=0
Set m=pd.CreateModel(&H18112060,"|Diagram=ActivityDiagram")
If m Is Nothing Then WScript.Quit 2
Set d=m.ActivityDiagrams.Item(0)
Set a=m.Activities.CreateNew()
a.Name="Accion de ejemplo"
Set s=d.AttachObject(a)
s.Position=Array(0,0)
Set b=m.Starts.CreateNew()
b.Name="Inicio"
Set s=d.AttachObject(b)
s.Position=Array(0,4000)
Set f=m.Flows.CreateNew()
Set f.Object1=b
Set f.Object2=a
f.ConditionExpression="condicion_de_prueba"
Set s=d.AttachLinkObject(f)
On Error Resume Next
Set u=m.OrganizationUnits.CreateNew()
If Err.Number=0 Then
 u.Name="Sistema"
 Set s=d.AttachObject(u)
 WScript.Echo "OrganizationUnits: OK"
Else
 WScript.Echo "OrganizationUnits: " & Err.Description
 Err.Clear
End If
On Error GoTo 0
m.Save "C:\Users\Usuario\Desktop\Web Avanzada\CORREGIDOS_UML\revision\native_template.oom"
WScript.Echo "Plantilla nativa guardada"
