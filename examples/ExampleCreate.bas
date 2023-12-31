#Include Once "BaseXType.bi"

Dim As BaseXClient.Session client = BaseXClient.Session("localhost", "1984", "admin", "admin")
Dim As Integer ret = client.OpenConnection()
If ret <> 0 Then
    Print "Connect failed"
    End 1
End If

client.create("database", "<x>Hello World!</x>")
Print client.GetInfo()

Dim As String result
client.Execute("xquery /", result)
Print result

result = ""
client.Execute("drop db database", result)
Print result
Print client.GetInfo()

client.CloseConnection()
End 0
