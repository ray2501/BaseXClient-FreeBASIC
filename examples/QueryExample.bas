#Include Once "BaseXType.bi"

Dim As BaseXClient.Session client = BaseXClient.Session("localhost", "1984", "admin", "admin")
Dim As Integer ret = client.OpenConnection()
If ret <> 0 Then
    Print "Connect failed"
    End 1
End If

Dim As String myinput = "for $i in 1 to 10 return <xml>Text { $i }</xml>"
Dim As BaseXClient.Query query = BaseXClient.Query(client, myinput)
Dim As BaseXClient.StringArray result = query.Results()

For position As Integer = Lbound(result.arr) To Ubound(result.arr)
    Print result.arr(position)
Next

query.Close()
client.CloseConnection()
End 0
