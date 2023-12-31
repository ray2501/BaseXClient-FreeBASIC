/'
 ' FreeBASIC client for BaseX.
 ' Works with BaseX 7.0 and later.
 '/

#Pragma Once

#Include Once "md5.bi"
#Include Once "BaseXType.bi"

Namespace BaseXClient

    /'
     ' For Type Session
     '/
    Constructor Session()
        This.host = "localhost"
        This.port = "1984"
        This.username = "admin"
        This.password = "admin"

        This.info = ""
    End Constructor

    Constructor Session(host As String, port As String, username As String, password As String)
        This.host = host
        This.port = port
        This.username = username
        This.password = password

        This.info = ""
    End Constructor

    Destructor Session()
    End Destructor

    Function Session.OpenConnection() As Integer
        Dim retcode As Integer

    #Ifdef __fb_win32__
        '' init winsock
        Dim wsaData As WSAData
        If( WSAStartup( MAKEWORD( 1, 1 ), @wsaData ) <> 0 ) Then
            Print "Error: WSAStartup failed"
            End 1
        End If
    #Endif

        /'
         ' Connect to BaseX server
         '/
        retcode = CreateConnection()
        If retcode < 0 Then
            Return -1
        End If

        /'
         ' Authentification
         '/
        Dim recvbuffer As Zstring * 20
        memset(Cast(Any Ptr, @recvbuffer), 0, 20)

        Dim As Integer bytes = recv( This.sfd, recvBuffer, 20, 0 )
        If( bytes <= 0 ) Then
            Return -1
        End If

        retcode = SendMSG(This.username)
        If retcode <= 0 Then
            Return -1
        End If

        Dim As Integer mysym = Instr(recvbuffer, ":")
        Dim As String token
        If mysym > 0 Then
            Dim As String realm = Left(recvbuffer, mysym - 1)
            Dim As String nonce = Right(recvbuffer, Len(recvbuffer) - mysym)

            token = Md5(MD5(This.username + ":" + realm + ":" + This.password) + nonce)
        Else
            token = Md5(This.password)
        End If

        If SendMSG(token) <= 0 Then
            Return -1
        End If

        /'
         ' Retrieve authentification status.
         '/
        retcode = OK()
        Return retcode
    End Function

    Sub Session.CloseConnection()
        SendMSG("exit")

        '' close socket
        shutdown( This.sfd, 2 )
        closesocket( This.sfd )

    #Ifdef __fb_win32__
        '' quit winsock
        WSACleanup( )
    #Endif
    End Sub

    Function Session.Execute(Byref Command As String, Byref result As String) As Integer
        Dim retcode As Integer
        This.info = ""

        retcode = SendMSG(Command)
        If retcode <= 0 Then
            Return -1
        End If

        result = ReadString()
        This.info = ReadString()

        retcode = OK()
        Return retcode
    End Function

    Function Session.Create(Byref dbname As String, Byref inputmsg As String) As Integer
        Dim retcode As Integer

        retcode = SendInput(8, dbname, inputmsg)
        Return retcode
    End Function

    Function Session.Add(Byref path As String, Byref inputmsg As String) As Integer
        Dim retcode As Integer

        retcode = SendInput(9, path, inputmsg)
        Return retcode
    End Function

    Function Session.Replace(Byref path As String, Byref inputmsg As String) As Integer
        Dim retcode As Integer

        retcode = SendInput(12, path, inputmsg)
        Return retcode
    End Function

    Function Session.SendInput(code As Integer, msg As String, inputmsg As String) As Integer
        Dim retcode As Integer
        This.info = ""

        Dim As String mymsg = Chr(code) + msg + Chr(0)
        Dim As Integer bytes = send(This.sfd, mymsg, Len(mymsg), 0)
        If bytes = SOCKET_ERROR Then
            Return -1
        End If

        Dim As String myinputmsg = inputmsg + Chr(0)
        bytes = send(This.sfd, myinputmsg, Len(myinputmsg), 0)
        If bytes = SOCKET_ERROR Then
            Return -1
        End If

        This.info = ReadString()

        retcode = OK()
        Return retcode
    End Function

    Function Session.SendMSG(msg As String) As Integer
        Dim As String mymsg = msg + Chr(0)
        Dim As Integer bytes = send(This.sfd, mymsg, Len(mymsg), 0)
        If bytes = SOCKET_ERROR Then
            Return -1
        End If

        Return bytes
    End Function

    Function Session.ReadString() As String
        Dim As String buffer

        Do
            Dim mychar As Byte
            Dim As Integer bytes = recv(This.sfd, @mychar, 1, 0)
            If bytes = SOCKET_ERROR Or bytes = 0 Then
                Exit Do
            End If

            If mychar <> 0 Then
                buffer = buffer + Chr(mychar)
            Else
                Exit Do
            End If
        Loop

        Return buffer
    End Function

    Function Session.OK() As Integer
        Dim mychar As Byte
        Dim As Integer bytes = recv(This.sfd, @mychar, 1, 0)
        If bytes = SOCKET_ERROR Or bytes = 0 Then
            Return -1
        End If

        Return mychar
    End Function

    Function Session.GetInfo() As String
        Return This.info
    End Function

    Function Session.CreateConnection() As Integer
        Dim As addrinfo hints
        Dim As addrinfo Ptr result = NULL

        hints.ai_family   = AF_UNSPEC        'Allows IPv4 or IPv6
        hints.ai_socktype = SOCK_STREAM
        hints.ai_protocol = IPPROTO_TCP

        Dim As Integer rc = getaddrinfo(This.host, This.port, @hints, @result)
        If rc <> 0  Then
            Return -1
        End If

        Dim As addrinfo Ptr rp = result
        While (rp <> NULL)
            This.sfd = opensocket(rp->ai_family, rp->ai_socktype, rp->ai_protocol)
            If( This.sfd <= 0 ) Then
                Continue While
            End If

            If (connect(This.sfd, rp->ai_addr, rp->ai_addrlen) <> -1) Then
                Exit While  ' Success
            End If

            shutdown(This.sfd, 2)  ' Connect failed: close socket, try next address
            closesocket(This.sfd)
            rp = rp->ai_next
        Wend

        If rp = NULL Then
            Return -2
        End If

        freeaddrinfo(result)
        Return 0
    End Function


    /'
     ' For Type Query
     '/
    Constructor Query(Byref s As Session, Byref querystring As String)
        This.s = s
        This.id = Exec(Chr(0), querystring)
    End Constructor

    Destructor Query()
    End Destructor

    Function Query.Exec(Byref Command As String, Byref arg As String) As String
        Dim As String sendString = Command + arg
        Dim As Integer retcode

        retcode = This.s.SendMSG(sendString)
        If retcode <= 0 Then
            Return ""
        End If

        Dim As String result = This.s.ReadString()
        retcode = This.s.OK()
        If retcode = 0 Then
            Return result
        Else
            ' Read the failed result
            result = This.s.ReadString()
            Return result
        End If
    End Function

    Sub Query.Bind(Bindname As String, Value As String, Typename As String = "")
        Dim As String commandargs = This. id + Chr(0) + Bindname + Chr(0) + Value +Chr(0) + Typename

        Exec(Chr(3), commandargs)
    End Sub

    Sub Query.Context(Value As String, Typename As String = "")
        Dim As String commandargs = This. id + Chr(0) + Value +Chr(0) + Typename

        Exec(Chr(14), commandargs)
    End Sub

    Function Query.Execute() As String
        Dim As String result

        result = Exec(Chr(5), This.id)
        Return result
    End Function

    Function Query.Info() As String
        Dim As String result

        result = Exec(Chr(6), This.id)
        Return result
    End Function

    Function Query.Options() As String
        Dim As String result

        result = Exec(Chr(7), This.id)
        Return result
    End Function

    Function Query.Results() As StringArray
        Dim As StringArray myresult
        Dim As Integer count = 0
        Dim As Integer max = 50
        Dim As Integer retcode

        Dim As String Command = Chr(4) + This.id + Chr(0)
        retcode = This.s.SendMSG(Command)
        If retcode <= 0 Then
            Return myresult
        End If

        Redim myresult.arr(0 To max) As String

        Do
            retcode = This.s.OK()
            If retcode <> 0 Then
                Dim As String recvString = This.s.readString
                If count < max Then
                    myresult.arr(count) = recvString
                    count = count + 1
                Else
                    max = max + 50
                    Redim Preserve myresult.arr(0 To max) As String

                    myresult.arr(count) = recvString
                    count = count + 1
                End If
            Else
                Exit Do
            End If
        Loop

        retcode = This.s.OK()
        If retcode <> 0 Then
            Redim myresult.arr(0 To 0) As String
            myresult.arr(0) = This.s.readString
        Else
            ' Redim to current number
            Redim Preserve myresult.arr(0 To count - 1) As String
        End If

        Return myresult
    End Function

    Sub Query.Close()
        Dim As String result

        Exec(Chr(2), This.id)
        This.id = ""
    End Sub

End Namespace
