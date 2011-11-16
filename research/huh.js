$(function(){
    console.log("HUH")
    $('iframe').bind( 'load', function(){
        var frame = $(this)
        remoteWindow = frame.get(0).contentWindow
        canvas = document.createElement('canvas')
        canvas.width = '512px'
        canvas.height = '30px'
        ctx = canvas.getContext("2d")
        ctx.drawWindow( remoteWindow, 0, 0, 512, 30, "rgb(255,255,255)" );
        frame.replaceWith( canvas )
        // var remoteWindow = frame.get(0).contentWindow;
        // var canvas = document.createElement("canvas")
        //     canvas.style.width = "512px";  
        //     canvas.style.height= "30px";  
        //     canvas.width = "512px"
        //     canvas.height = "30px"
        //     var windowWidth = window.innerWidth - 25;  
        //     var windowHeight = window.innerHeight;  
        //     var ctx = ;  
        //     ctx.clearRect(0, 0,  
        //                   512,  
        //                   30);  
        //     ctx.save();  
        //     ctx.scale(512 / windowWidth,  
        //               30 / windowHeight);  
        //     ctx.drawWindow(remoteWindow,  
        //                    0, 0,  
        //                    windowWidth, windowHeight,  
        //                    "rgb(255,255,255)");  
        //     ctx.restore();            
    })
})