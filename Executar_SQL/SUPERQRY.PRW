#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "INKEY.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} SuperQry
Montar uma tela para a digita��o e execu��o de Comandos SQL ( Select, Update e Insert ).
@type function
@version 12.1.25
@author Jorge Alberto
@since 07/09/2020
/*/
User Function SuperQry()

    Local cSQL := ""
    Local cLogErro := ""
    Local cMensagem := ""
    Local cTipo := "Original"
    Local aCoors := FWGetDialogSize()
    Local aPastas := {}
    Local aHeader := {}
    Local aTipos := {"Titulo","Original"}
    Local oPanelConfig
    Local oPanelAcoes
    Local oPanelResultado
    Local oPanelQuery
    Local oLayer
    Local oDlg
    Local oFont := TFont():New( "Arial",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
    Local oMGSql
    Local oMenu

    Private oPanelMsg
    Private oGridResult

	//**************************************************************
	// Calcula as 2 dimens�es, onde cada uma ter� seus objetos      
	//**************************************************************
	oSize := FwDefSize():New( .F. ) // N�o ter� barra com os bot�es
	oSize:AddObject( "SUPERIOR", 100, 10, .T., .T. )
	oSize:AddObject( "INFERIOR", 100, 90, .T., .T. )
	oSize:lProp := .F. // Proporcional
	oSize:Process() // Dispara os calculos

	//**************************************************************
	// Divide a Superior em 3                                      
	//**************************************************************
	oSizeSup := FwDefSize():New( .F. ) // N�o ter� barra com os bot�es
	oSizeSup:aWorkArea := oSize:GetNextCallArea( "SUPERIOR" )
	oSizeSup:AddObject( "OPCOES"  , 10, 100, .T., .T. )
	oSizeSup:AddObject( "CONSULTA", 80, 100, .T., .T. )
	oSizeSup:AddObject( "MENSAGEM", 10, 100, .T., .T. )
	oSizeSup:lLateral := .T. //Calculo em Lateral
	oSizeSup:lProp := .T.
	oSizeSup:Process()

	//**************************************************************
	// Monta Dialog                                                
    //**************************************************************
	oDlg := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],"Super Query Analyser",,,,nOr(WS_VISIBLE,WS_POPUP),,,,,.T.)

    //**************************************************************
    //Aqui est� criando o Grupo onder ser�o colocados os Bot�es
    //**************************************************************
    oGgpOpcoes := TGroup():New(oSizeSup:GetDimension("OPCOES","LININI"),;
                                oSizeSup:GetDimension("OPCOES","COLINI"),;
                                oSizeSup:GetDimension("OPCOES","LINEND"),;
                                oSizeSup:GetDimension("OPCOES","COLEND"),'Op��es',oDlg,,,.T.)

    //*********************************************************************************
    //Aqui est� criando o Grupo onde ser� colocado o MultiGet para a digita��o do SQL
    //*********************************************************************************
    oPanelQuery := TGroup():New(oSizeSup:GetDimension("CONSULTA","LININI"),;
                                oSizeSup:GetDimension("CONSULTA","COLINI"),;
                                oSizeSup:GetDimension("CONSULTA","LINEND"),;
                                oSizeSup:GetDimension("CONSULTA","COLEND"),'Consulta SQL',oDlg,,,.T.)
    
    //****************************************************************************
    //Aqui est� criando o Grupo onde ser� colocado o MultiGet para as Mensagens 
    //****************************************************************************
    oPanelMsg := TGroup():New( oSizeSup:GetDimension("MENSAGEM","LININI"),;
                                oSizeSup:GetDimension("MENSAGEM","COLINI"),;
                                oSizeSup:GetDimension("MENSAGEM","LINEND"),;
                                oSizeSup:GetDimension("MENSAGEM","COLEND"),'Mensagens',oDlg,,,.T.)

    //******************************************************************************
    //Aqui est� criando o Grupo onde ser� colocado o browse dos dados apresentados
    //******************************************************************************
    oPanelResultado := TGroup():New(oSize:GetDimension("INFERIOR","LININI"),;
                                oSize:GetDimension("INFERIOR","COLINI"),;
                                oSize:GetDimension("INFERIOR","LINEND"),;
                                oSize:GetDimension("INFERIOR","COLEND"),"Resultado",oDlg,,,.T.)

    //***********************************************
    //Aqui est� criando os Bot�es/Atalhos das a��es
    //***********************************************
    SetKey( VK_F5, {|| MsgRun( "Executando a consulta...", "Aguarde",  {|| ExecSQL(oPanelResultado, cSQL, @cLogErro, cTipo ) } ) } )
    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+10,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Executar SQL (F5)",oGgpOpcoes,{|u| MsgRun( "Executando a consulta...", "Aguarde",  {|| ExecSQL(oPanelResultado, cSQL, @cLogErro, cTipo ) } ) },50,12,,,,.T.,,"",,,,.F. )

	TComboBox():New( oSizeSup:GetDimension("OPCOES","LININI")+30,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    {|u| If(PCount()>0,cTipo:=u,cTipo)},aTipos,040,010,oGgpOpcoes,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cTipo, "Coluna dos dados", 1 )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+60,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Gera Excel",oGgpOpcoes,{|u| MsgRun( "Gerando arquivo...", "Aguarde",  {|| GeraExcel( cSQL, cLogErro ) } ) },35,12,,,,.T.,,"",,,,.F. )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+80,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Envia Log",oGgpOpcoes,{|u| MsgRun( "Enviando arquivo...", "Aguarde",  {|| Mysend(cLogErro) } ) },35,12,,,,.T.,,"",,,,.F. )

    TButton():New( oSizeSup:GetDimension("OPCOES","LININI")+100,;
                    oSizeSup:GetDimension("OPCOES","COLINI")+5,;
                    "Fechar",oGgpOpcoes,{|u| oDlg:END() },35,12,,,,.T.,,"",,,,.F. )
    

    //******************************************************
    //Aqui est� criando o MultiGet para a digita��o do SQL
    //******************************************************
    oMGSql := tMultiget():new(oSizeSup:GetDimension("CONSULTA","LININI")+10/*Linha inicial*/,;
                    oSizeSup:GetDimension("CONSULTA","COLINI")+05/*Coluna inicial*/,;
                    {| u | if( pCount() > 0, cSQL := u, cSQL )},oPanelQuery,;
                    oSizeSup:GetDimension("CONSULTA","XSIZE")-10/*Largura*/,;
                    oSizeSup:GetDimension("CONSULTA","YSIZE")-15/*Altura*/,oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/,/*bValid*/,,,/*lNoBorder*/,.T./*lVScroll*/)

    oMenu := TMenu():New(0,0,0,0,.T.)
    oMenu:Add( TMenuItem():New(oMenu,"Op��o",,,,{|| MsgInfo("Melhoria futura", "Super Query") },,,,,,,,,.T.) )
    oMGSql:SetPopup(oMenu)
    oMGSql:SetFocus()

    oDlg:Activate()

    SetKey( VK_F5 , NIL )

Return


//********************************
//Executar os comandos digitados
//********************************
Static Function ExecSQL(oPanelResultado, cSql, cLogErro, cTipo )

    Local nQueryRet := 0 
    Local nX := 0
    Local oFont := TFont():New( "Tahoma",0,-14,,.F.,0,,700,.F.,.F.,,,,,, )
    Local cTRB := ""
    Local cErro := ""
    Local cCampo := ""
    Local cMensagem := ""
    Local cComandoSQL := UPPER( cSql )
    Local aHeaderEx := {}
    Local aColsEx := {}
    Local aFieldFill := {}
    Local aStru := {}
    Local aSQL := {}
    Local oMGMensagem

    If Empty( cSql )
        Return
    EndIf

    //*************************************************
    //Aqui est� criando o MultiGet para as Mensagens 
    //*************************************************
    oMGMensagem := tMultiget():new(oSizeSup:GetDimension("MENSAGEM","LININI")+10/*Linha inicial*/,;
                oSizeSup:GetDimension("MENSAGEM","COLINI")+05/*Coluna inicial*/,;
                {| u | if( pCount() > 0, cMensagem := u, cMensagem )},oPanelMsg,;
                oSizeSup:GetDimension("MENSAGEM","XSIZE")-10/*Largura*/,;
                oSizeSup:GetDimension("MENSAGEM","YSIZE")-15/*Altura*/,oFont,,,,,.T./*lPixel*/,,,,,,.T./*lReadOnly*/,/*bValid*/,,,.T./*lNoBorder*/,.T./*lVScroll*/)

    If ( 'INSERT ' $ cComandoSQL .OR. 'UPDATE ' $ cComandoSQL .OR. ' INTO ' $ cComandoSQL )
        
        If At( ";", cSql ) <= 0
            cSql := cSql + ";"
        EndIf
        aSQL:= StrTokArr( strtran(cSql,CRLF," "), ";" ) // troca o ENTER por ESPA�O para compatibilizar  e depois divide por instru��es
        Processa({|| cErro := RunSql(aSQL)}," Processando Intru��es SQL...")

        oMGMensagem:AppendText( "Comando executado " + IIF( Empty( cErro ), "sem", "com" ) + " erro !" )

        //********************************************************
        //Aqui est� criando o MultiGet com OU sem erro do gerado
        //********************************************************
        tMultiget():new(oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                        oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                        {| u | if( pCount() > 0, cErro := u, cErro )},oPanelResultado,;
                        oSize:GetDimension("INFERIOR","XSIZE")-10,;//nLargura
                        oSize:GetDimension("INFERIOR","YSIZE")-15,;//nAltura
                        oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)
    
    ElseIf 'SELECT ' $ cComandoSQL

        If TCSQLEXEC(cSql) < 0
            cErro := TCSQLError()
            //********************************************************
            //Aqui est� criando o MultiGet com o erro do SQL gerado
            //********************************************************
            tMultiget():new(oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                            oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                            {| u | if( pCount() > 0, cErro := u, cErro )},oPanelResultado,;
                            oSize:GetDimension("INFERIOR","XSIZE")-10,;//nLargura
                            oSize:GetDimension("INFERIOR","YSIZE")-15,;//nAltura
                            oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)
            cLogErro := cErro
            oMGMensagem:AppendText( "" )
        Else
            cLogErro := ""
            cTRB := GetNextAlias()

            // Fun��o padr�o que executa a consulta e carrega na tabela cTRB
            MPSysOpenQuery( cSql, cTRB )
            aStru := (cTRB)->(DBSTRUCT())

            For nX := 1 to Len(aStru)
                cCampo := aStru[nX][1]

                If cTipo == "Titulo"
                    cTitulo := AllTrim(FWX3Titulo(cCampo) )
                    If Empty(cTitulo)
                        cTitulo := cCampo
                    Endif
                Else
                    cTitulo := cCampo
                EndIf

                Aadd(aHeaderEx,{ cTitulo, cCampo, "", aStru[nX][3], aStru[nX][4], ".T.", ".T.", aStru[nX][2] , "", "", "", ""} )
            Next nX

            // Se n�o tem dados, cria uma linha vazia
            If (cTRB)->( EOF() )
                Aadd(aColsEx, Array( Len(aStru) ) )
            Else
                // Faz a Leitura dos dados
                While  !(cTRB)->(EOF())

                    For nX := 1 to Len(aStru)
                        cCampo := aStru[nX][1]
                        Aadd(aFieldFill,  &('(cTRB)->' + cCampo ))
                    Next nX
                    Aadd(aFieldFill, .F.) //Delete
                    
                    Aadd(aColsEx, aFieldFill)
                    aFieldFill := {}
                    nQueryRet++

                    (cTRB)->(DBSkip())
                Enddo
            EndIf
            (cTRB)->( DbCloseArea() )
            oMGMensagem:AppendText( "Consulta retornou " + cValToChar( nQueryRet ) + " registros." )

            //******************************************************
            //Aqui est� criando o Grid com os resultados
            //******************************************************
            oGridResult := MsNewGetDados():New( oSize:GetDimension("INFERIOR","LININI")+10,; //nTop
                                                oSize:GetDimension("INFERIOR","COLINI")+05,; //nLeft
                                                oSize:GetDimension("INFERIOR","LINEND")-05,; //nBottom
                                                oSize:GetDimension("INFERIOR","COLEND")-05,; //nRight
                                                0,;	     		                            //nStyle // GD_INSERT+GD_DELETE+GD_UPDATE
                                                "AllwaysTrue()",;							//cLinhaOk
                                                ,;											//cTudoOk
                                                "",;										//cIniCpos
                                                ,;											//aAlter
                                                ,;											//nFreeze
                                                99,;										//nMax
                                                ,;											//cFieldOK
                                                ,;											//cSuperDel
                                                ,;											//cDelOk
                                                oPanelResultado,;					        //oWnd
                                                aHeaderEx,;								    //aHeader
                                                aColsEx)									//aCols
            oGridResult:nAt := 1
            oGridResult:oBrowse:nAt := 1
            oGridResult:Refresh()

        EndIf

    Else
        oMGMensagem:AppendText( "Comando n�o permitido !" )
    EndIf

Return


//***************************************
//Executar o Insert ou Update digitado
//***************************************
Static Function RunSql( aSQL )

    Local nX := 0
    Local nLenSQL := Len( aSql )
    Local cSqlEx := ""
    Local cErro := ""

    ProcRegua( nLenSQL )

    For nX:= 1 To nLenSQL
        IncProc("Processando Instru��o " + alltrim(STR(nX)) + ' de ' + alltrim( STR( nLenSQL ) ) )

        cSqlEx := aSQL[nX]

        If TCSQLEXEC(cSqlEx) < 0
            lErro := .T.
            cErro += TCSQLError() + CRLF
        EndIf

    Next nX

Return( cErro )


//******************************************************************************************************************
//Gerar um arquivo com os dados localizados e tamb�m com o comando SQL executado.
//Sendo que ir� gerar esse arquivo no formato .XLS quando tiver o Excel instalado, OU ent�o cria um arquivo .CSV
//******************************************************************************************************************
Static Function GeraExcel( cSql, cLogErro )

    Local nX, nY
    Local nHdr := 0
    Local nModo //Modo do Tipo do Campo| 1 = Modo Texto ou data | 2 = Valor sem R$ | 3 = Valor com R$
    Local aHeader := {}
    Local aCols:= {}
    Local aLinha
    Local aArea := {}
    Local cAba01
    Local cTitTabela01
    Local cAba02
    Local cTmp := ""
    Local cTitTabela02
    Local X_TIPO := 8
    Local X_TITULO := 1
    Local oFWMsExcel
    Local oExcel
    Local cTime := ""
    Local cArquivo := ""

    If !Empty( cLogErro )
        MsgInfo( "N�o � poss�vel gerar o excel com erro !")
        Return
    EndIf

    aHeader  := oGridResult:aHeader
    aCols    := oGridResult:aCols
    aArea    := GetArea()
    cTime    := time()
    cArquivo := GetTempPath()+'superqry-temp-' + SUBSTR(cTime,1,2) + "H" + SUBSTR(cTime,4,2) + '.xml'
    
    If ApOleClient("MSExcel")

        //Criando o objeto que ir� gerar o conte�do do Excel
        oFWMsExcel := FWMSExcel():New()
        oFWMsExcel:SetTitleBold(.T.) //T�tulo Negrito

        //Aba 01 - Dados
        cAba01 := "Dados"
        cTitTabela01 := 'Dados da Consulta'
        oFWMsExcel:AddworkSheet(cAba01) //N�o utilizar n�mero junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
        oFWMsExcel:AddTable(cAba01,cTitTabela01)
        //Criando Colunas
        For nX := 1 to Len(aHeader)
            DO CASE
            CASE  aHeader[nx,X_TIPO] $ 'C'
                nModo := 1 //1 = Modo Texto
            CASE  aHeader[nx,X_TIPO] $ 'D'
                nModo := 1
            CASE  aHeader[nx,X_TIPO] $ 'N'
                nModo := 2 //2 = Valor sem R$ | 3 = Valor com R$
            OTHERWISE
                nModo := 1
            END CASE
            oFWMsExcel:AddColumn(cAba01,cTitTabela01,aHeader[nx,X_TITULO],nModo)
        Next nX
        //Criando as Linhas

        For nX := 1 to Len(aCols)
            aLinha := {}
            For nY := 1 to LEN(aCols[nX])
                AADD(aLinha, aCols[nX][nY])
            Next nY
            oFWMsExcel:AddRow(cAba01,cTitTabela01,aLinha)
        Next nX


        //Aba 02 - Sql
        cAba02 := "SQL"
        cTitTabela02 := 'Consulta SQL'

        oFWMsExcel:AddworkSheet(cAba02)
        //Criando a Tabela
        oFWMsExcel:AddTable(cAba02,cTitTabela02)
        oFWMsExcel:AddColumn(cAba02,cTitTabela02,"Consulta",1)

        //Criando as Linhas... Enquanto n�o for fim da query
        oFWMsExcel:AddRow(cAba02,cTitTabela02,{cSql})

        //Ativando o arquivo e gerando o xml
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cArquivo)

        //Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New()       //Abre uma nova conex�o com Excel
        oExcel:WorkBooks:Open(cArquivo) //Abre uma planilha
        oExcel:SetVisible(.T.)          //Visualiza a planilha
        oExcel:Destroy()                //Encerra o processo do gerenciador de tarefas
    
    Else// N�o tem Excel instalado
        
        // Pega o nome do arquivo, mas sem a extens�o XML para usar o CSV
        cArquivo := Left( cArquivo, Len(cArquivo)-3 ) + "csv"

        nHdr := FCreate( cArquivo )
        If nHdr <= 0
            MsgInfo( 'N�o foi poss�vel criar o arquivo "' + cArquivo + '"'+CRLF+'Verifique se o arquivo est� em uso.')
        Else
            // Carrega o Cabe�alho das colunas
            For nX := 1 to Len(aHeader)
                cTmp += cValToChar( aHeader[ nX, 1 ] ) + ";"
            Next nX
            FWrite( nHdr, cTmp + CRLF )

            // Carrega os dados para gerar cada Linha
            For nX := 1 to Len(aCols)
            
                cTmp := ""
                For nY := 1 to LEN(aCols[nX])-1
                    cTmp += cValToChar( aCols[ nX, nY ] ) + ";"
                Next nY
                FWrite( nHdr, cTmp + CRLF )
            
            Next nX

            // No final gera uma linha com o SQL executado 
            fWrite( nHdr, strtran(cSql,CRLF," ") + CRLF)

            FClose( nHdr )
            ShellExecute("open", cArquivo, "", GetTempPath(), 1)
        EndIf
    EndIf

    RestArea(aArea)
Return


//*************************
//Envia o erro por e-mail
//*************************
Static Function Mysend( cTxt )
    Local lEnvia := .F.
    Static oDlgLog
    Static oButton1
    Static oButton2
    Static oGet1
    Static cGet1 := ""
    Static oSay

    If Empty( cTxt )
        MsgInfo( "N�o tem erro para enviar log !")
        Return
    EndIf

    cGet1 := PadR( AllTrim( UsrRetMail( RetCodUsr() ) ), 200 )

    DEFINE MSDIALOG oDlgLog TITLE "Envio de Log" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

    @ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlgLog PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
    @ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlgLog PICTURE "@!" COLORS 0, 12632256 PIXEL

    @ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlgLog ACTION {||lEnvia := .T.,oDlgLog:End()} PIXEL
    @ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlgLog ACTION oDlgLog:End()  PIXEL

    ACTIVATE MSDIALOG oDlgLog CENTERED

    If lEnvia
        CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

            If !lResult
                MsgBox('Erro no Envio')
                Return()
            EndIf

            cAccount := GETMV("MV_RELACNT")

            SEND MAIL FROM cAccount;
                TO cGet1;
                SUBJECT "Executar Query";
                BODY cTxt

        DISCONNECT SMTP SERVER

        MsgInfo("Email Enviado com Sucesso!")
    EndIf

Return
