#Include Once "BaseXType.bi"

Dim As BaseXClient.Session client = BaseXClient.Session("localhost", "1984", "admin", "admin")
Dim As Integer ret = client.OpenConnection()
If ret <> 0 Then
    Print "Connect failed"
    End 1
End If

Dim As String myinput = "declare variable $name external; for $i in 1 to 10 return element { $name } { $i }"
Dim As BaseXClient.Query query = BaseXClient.Query(client, myinput)

query.Bind("name", "number")
Dim As String eresult = query.Execute()
Print eresult

query.Close()
client.CloseConnection()
End 0
