fs = require 'fs'
list = JSON.parse fs.readFileSync 'fonts.json', 'utf8'
OPTIONS = []
for font in list    
    {url,family,variant} = font
    weight = 'normal'
    if /^\d+/.test variant
        m = variant.match(/^(\d+)/)
        weight  = m[0]
        variant = variant.replace weight , ''
#    html = "<html style=\"overflow:hidden;\"><head><style>html,body,*{margin:0;padding:0;border:0;}</style><link href='#{url}' rel='stylesheet' type='text/css'></head><body><p style=\"line-height:30px;font-size:15px;font-family:'#{family}';font-weight:#{weight};font-style:#{variant}\">#{family} - #{weight} - #{variant}</p></body></html>"
    dataURI = "data:text/html,#{encodeURIComponent(html)}" 
    OPTIONS.push "<option value=\"\"></option>"
    

# HEAD = "
# <!DOCTYPE html>
# <html lang=\"en\">
#   <head>
#     <meta charset=\"utf-8\">
#     <title></title>
#     <style type=\"text/css\" media=\"screen\">
#         iframe{border:0;height:30px;width:100%;border-top:1px solid #f00}}
#            html,body, *{margin:0;padding:0;}
#     </style>
#     <script src=\"http://assets.needium.com/lib/jquery/1.7.0/jquery.min.js\" type=\"text/javascript\" charset=\"utf-8\"></script>  
#     <script type=\"text/javascript\" src=\"huh.js\"></script>
#     </head>
# <body>"
# fs.writeFileSync 'iframes.html', HEAD+IFRAMES.join("\n")+"</body></html>"
