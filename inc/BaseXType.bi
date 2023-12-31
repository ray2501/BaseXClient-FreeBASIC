/'
 ' FreeBASIC client for BaseX.
 ' Works with BaseX 7.0 and later.
 '/

#Pragma Once

#Ifndef __BASEXTYPE__
#Define __BASEXTYPE__

#Include Once "crt/string.bi"

#Ifdef __fb_win32__
#Include Once "win/winsock2.bi"
#Include Once "win/ws2tcpip.bi"
#Else
#Include Once "crt/netdb.bi"
#Include Once "crt/sys/socket.bi"
#Include Once "crt/netinet/in.bi"
#Include Once "crt/arpa/inet.bi"
#Include Once "crt/unistd.bi"
#Endif

Namespace BaseXClient

    Type Session
        Public:
            Declare Constructor()
            Declare Constructor(host As String, port As String, username As String, password As String)
            Declare Destructor()
            Declare Function OpenConnection() As Integer
            Declare Sub CloseConnection()
            Declare Function Execute(Byref Command As String, Byref result As String) As Integer
            Declare Function Create(Byref dbname As String, Byref inputmsg As String) As Integer
            Declare Function Add(Byref path As String, Byref inputmsg As String) As Integer
            Declare Function Replace(Byref path As String, Byref inputmsg As String) As Integer
            Declare Function SendInput(code As Integer, msg As String, inputmsg As String) As Integer
            Declare Function SendMSG(msg As String) As Integer
            Declare Function ReadString() As String
            Declare Function OK() As Integer
            Declare Function GetInfo() As String

        Private:
            host As String
            port As String
            username As String
            password As String
            info As String
            sfd As SOCKET

            Declare Function CreateConnection() As Integer
    End Type

    Type StringArray
        Dim As String arr (Any)
    End Type

    Type Query
        Public:
            Declare Constructor(Byref s As Session, Byref querystring As String)
            Declare Destructor()
            Declare Function Exec(Byref Command As String, Byref arg As String) As String
            Declare Sub Bind(Bindname As String, Value As String, Typename As String = "")
            Declare Sub Context(Value As String, Typename As String = "")
            Declare Function Execute() As String
            Declare Function Info() As String
            Declare Function Options() As String
            Declare Function Results() As StringArray
            Declare Sub Close()

        Private:
            Dim As Session s
            Dim As String id
    End Type

End Namespace

#Endif
