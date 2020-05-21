<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<br>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8'">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport"
	content="width=device-width, initial-scale=1.0, user-scalable=0, minimal-ui">
<link
	href="https://fonts.googleapis.com/css?family=Montserrat:300,300i,400,400i,500,500i%7COpen+Sans:300,300i,400,400i,600,600i,700,700i"
	rel="stylesheet">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/css/bootstrap.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/fonts/font-awesome/css/font-awesome.min.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/css/bootstrap-extended.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/css/app.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/css/colors.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/css/core/menu/menu-types/vertical-menu.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/css/core/menu/menu-types/vertical-overlay-menu.css' />">
<link rel="stylesheet" type="text/css"
	href="<c:url value='/asset/css/style.css' />">
<script src="<c:url value='/asset/js/jquery.min.js' />"
	type="text/javascript"></script>

</head>
<div class="content-header row">
	<div class="content-header-left col-md-6 col-xs-12 mb-1">
		<h2 class="content-header-title">AWS Machine Learning - AI Service</h2>
	</div>
</div>
<div class="row">
	<div class="col-xs-12">
		<div class="input-group">
			<br>
			<button id="btnDetectModeration" onclick="showDetectModeration(this.id)">Detect Moderation</button>
			<button id="btnDetectText" onclick="showDetectModeration(this.id)">Detect Text</button>
			<button id="btnTranslate" onclick="showDetectModeration(this.id)">Translate</button>
			<button id="btnTextToSpeech" onclick="showDetectModeration(this.id)">Text To Speech</button>
		</div>
	</div>
</div>

<br>
<jsp:include page="detect_moderation.jsp"></jsp:include>
<jsp:include page="detect_text.jsp"></jsp:include>
<jsp:include page="texttospeech.jsp"></jsp:include>
<jsp:include page="translate.jsp"></jsp:include>
<script type="text/javascript">
const listId = ["DetectModeration","DetectText", "Translate", "TextToSpeech"];
function showDetectModeration(id){
	$("#"+id.substr(3)).attr("style","");
	listId.forEach(item => {
		if(item != id.substr(3)){
			$("#"+item).attr("style","display: none;");
		}
	});
}
$(document).ready(function() {
	$("#detectModeration").attr("style","display: none;");
	
    $('#reset').click(function(){
    	$("#input").val("");
    });
    const ctx = "<%=request.getContextPath()%>";
    $('#subTranslate').click(function(){
    	
        var input= $('#inputTranslate').val();
        $.ajax({
    			url: ctx+"/translate",
    			type: 'POST',
    			processData: false,
    			contentType: "application/json;charset=utf-8",
    			data: input,
    			success: function(res){
    				if(res!=null){
    					$("#resultTranslate").val(res);
    	      		}
    			}
    	});
    });

	$('#subTextToSpeech').click(function(){
        var input= $('#input').val();
        var msg = new SpeechSynthesisUtterance(input);
		window.speechSynthesis.speak(msg);
    });
    
    $('#subDetectModeration').click(function(event){
		event.preventDefault();
		var curFiles = $("#file")[0].files[0];
		if (curFiles) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('#blah')
                    .attr('src', e.target.result)
                    .width(250)
                    .height(300);
            };

            reader.readAsDataURL(curFiles);
            uploadDocument("file","detect-moderation","resultDetectModeration");
        }
	});
    
    $('#subDetectText').click(function(event){
		event.preventDefault();
		var curFiles = $("#fileDetectText")[0].files[0];
		if (curFiles) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('#blahDetectText')
                    .attr('src', e.target.result)
                    .width(250)
                    .height(300);
            };

            reader.readAsDataURL(curFiles);
            uploadDocument("fileDetectText","detect-text","resultDetectText");
        }
	});
	
	
	function uploadDocument(id, url, target) {
    	var formAttachData  = new FormData();
    	var fileName = $("#"+id)[0].files[0].name;
    	formAttachData.append("file", $("#"+id)[0].files[0]);
   		var jqxhr = $.ajax({
   				url: ctx+"/"+url,
   				type: 'POST',
   				processData: false,
   				contentType: false,
   				data: formAttachData,
   		});
   		jqxhr.done(function(res) {
   	   		if(res!=null){
   	   		$("#"+target).empty();
   	   		$("#"+target).append("Result: <br>");
   	   			res.forEach(function (item) {
   	   				$("#"+target).append(item+'<br>');
   	   			});
   	   		}
   	   		$("#file").val(null);
   		});
	}
});

</script>
</html>