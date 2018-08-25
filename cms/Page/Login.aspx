<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="CMS.Page.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <link href="patternLock.css"  rel="stylesheet" type="text/css" />
    
    <script src="../Script/jquery-1.10.2.min.js"></script>
     
  
    <script src="../js/patternLock.js"></script>
    <link href="../css/patternLock.css" rel="stylesheet" />

        <link rel="stylesheet" type="text/css" href="/css/normalize2.css" />
    <link rel="stylesheet" type="text/css" href="/css/vicons-font.css" />
    <link rel="stylesheet" type="text/css" href="/css/buttons.css" />
    <link href="/css/index_style.css" rel="stylesheet" type="text/css" />

<style type="text/css">

	#warp{width:600px; margin:auto;}

	#warp div{margin-bottom:50px;}

    .divMain {
        
       
    }
    body {
       background-color:#3382C0;
    }
    .btn {
            border:1px solid #0080FF;
          background-color:	#0080FF;
         width:400px;
         height:35px;
         border-radius:5px;
         color:white;
      }
   
</style>

<script>

    var lock4
	$(function(){

		 lock4 = new PatternLock("#patternContainer4",{matrix:[5,5]});
		})

	function ds()
	{
	    alert(lock4.getPattern());
	}

	$(document).ready(function () {


	    $(".btn").mousemove(function () {
	        $(".btn").css("border", "1px solid #ffffff");
	    });

	    $(".btn").mouseleave(function () {
	        $(".btn").css("border", "1px solid #0080FF");
	    });

	    $("#patternContainer4").mouseup(function () {

	        TheLogin();
	    });

	    $.ajax({
	        type: "Get",
	        url: "/Page/Login.aspx",
	        data: { funType: "VisitCount" },
	        success: function (result) {
	             
	        }
	    })

	});

	function TheLogin()
	{
	    var password = lock4.getPattern();

	    if (!isNaN(password))
	    {
	       
	        $.ajax({
	            type: "Get",
	            url: "/Page/Login.aspx",
	            data: { funType: "True", ID: password },
	            success: function (result) {
	                if (result == "False") {
	                    $.ajax({
	                        type: "Get",
	                        url: "/Page/Login.aspx",
	                        data: { funType: "Error" },
	                        success: function (result) {

	                        }
	                    })
	                    alert("本系统已锁定,无法进入");
	                }
	                else if (result == "True") {
	                    $.ajax({
	                        type: "Get",
	                        url: "/Page/Login.aspx",
	                        data: { funType: "ComeIn" },
	                        success: function (result) {

	                        }
	                    })
	                    document.location.href = "../Main.aspx";
	                    return false;
	                }
	            }
	        })
	    }


	    return false;
	}

</script>
</head>
<body>
    <form id="form1" runat="server">
 
     <table style="width:100%; margin-top:80px;" >
         <tr>

             <td align="center">
                 <div id="patternContainer4"></div>
             </td>
         </tr>
         <tr>

             <td  align="center">
                 


             </td>
         </tr>
     </table>
 
    
    </form>
</body>

 


</html>
