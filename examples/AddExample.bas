#Include Once "BaseXType.bi"

Dim As BaseXClient.Session client = BaseXClient.Session("localhost", "1984", "admin", "admin")
Dim As Integer ret = client.OpenConnection()
If ret <> 0 Then
    Print "Connect failed"
    End 1
End If

Dim As String result
client.Execute("create db database", result)
Print result
Print client.GetInfo()

client.Add("world/World.xml", "<x>Hello World!</x>")
Print client.GetInfo()

client.Add("Universe.xml","<x>Hello Universe!</x>")
Print client.GetInfo()

result = ""
client.Execute("xquery /", result)
Print result

result = ""
client.Execute("drop db database", result)
Print result
Print client.GetInfo()

client.CloseConnection()
End 0
