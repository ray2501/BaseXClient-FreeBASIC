#Include Once "BaseXType.bi"

Dim As BaseXClient.Session client = BaseXClient.Session("localhost", "1984", "admin", "admin")
Dim As Integer ret = client.OpenConnection()
If ret <> 0 Then
    Print "Connect failed"
    End 1
End If

Dim As String result
client.Execute("xquery 1 to 10", result)
Print result

client.CloseConnection()
End 0
