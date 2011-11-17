###
	Cordonnier v0.1
    Copyright 2011 Francois Lafortune, @quickredfox
    Licensed under the Apache License v2.0
    http://www.apache.org/licenses/LICENSE-2.0
###
MASTERS = {}

### 
    looks for [[things]] and replaces them with { things: 'value' }
###
String::insertData = (o)->
    @replace /\[\[([^\[\]]*)\]\]/g, (a, b)->
        r = o[b]
        if typeof r is 'string' or typeof r is 'number' then r else ''

###
    Reads the form fields, sets some defaults
###
readFields = ()->
    fields = $('form').serializeArray().reduce (fields, field)->
        if (value = field.value.trim())
            fields[field.name] = value
        return fields
    , {}
    if !fields.year
        fields.year = (new Date()).getFullYear()
    if !fields.project
        fields.project = "My Project"
    if !fields.copyright
        fields.copyright = "Company Inc."
    if !fields.master
        fields.master = 'hero'
    fields

###
    Takes a dataURI and shrinks it's resulting image to a maximum height of 32px
### 
shrinkicon = (dataURI, callback)->
    img        = new Image()
    img.onload = ()->        
        {width,height} = img
        max            = Math.max(width,height)
        ideal = 32
        if max < 32 then return URI: dataURI , width: width, height: height
        if height < 32 then ideal = height
        width = (width*ideal)/height
        canvas         = document.createElement('canvas')
        canvas.width   = width
        canvas.height  = ideal
        ctx = canvas.getContext('2d')
        ctx.drawImage( img, 0, 0, width, ideal )
        URI = canvas.toDataURL("image/png")
        callback URI: URI , width: width, height: ideal
    img.src    = dataURI

###
 Inject a <link> tag right before the first <style> on a provided master
###
injectLink = ( master, link )-> 
    master = master.replace /<style/, "#{link}\n\t<style"

###
 Inject a css rule right before the first </style> on a provided master
###    
injectRule = ( master, rule )-> 
    master = master.replace /<\/style\>/, "#{rule}\n\t</style>"

###
 Inject a <script> tag right before the </body> on a provided master
###
injectScript = ( master, script )->
    master = master.replace /<\/body\>/, "#{script}\n</body>"

###
 Filters to bind data on masters. 
###    
buildFilters = [
    ( master, fields, isPreview)->
        unless isPreview 
            return master.replace /\<!--\[preview[^\[]+<!--.+-->/g, ''
        else return master
    
    ( master, fields, isPreview )->
        if fields.font_url
            return injectLink master, "<link rel=\"stylesheet\" type=\"text/css\" href=\"#{fields.font_url}\" media=\"screen\">"
        else return master
        
    ( master, fields, isPreview )->
        if fields.font_family
            return injectRule master, "h1,h2,h3,h4,h5,h6,.brand{font-family:#{fields.font_family}}"
        else return master
        
    ( master, fields, isPreview )->
        if fields.color
            lighter   = $.xcolor.lighten( fields.color, 1 )
            textcolor = "#ffffff"
            unless $.xcolor.readable(textcolor,fields.color)
                textcolor = '#000000'
                master = injectRule master, "/* todo: fix this */\n\t.topbar *{color:#{textcolor}!important}"
            return injectRule master, "\n\t.topbar-inner,.topbar .fill{\n\tcolor:#{textcolor};\n\tbackground-color:#{fields.color};\n\tbackground-repeat:repeat-x;\n\tbackground-image:-khtml-gradient(linear,left top,left bottom,from(#{lighter}),to(#{fields.color}));\n\tbackground-image:-moz-linear-gradient(top,#{lighter},#{fields.color});\n\tbackground-image:-ms-linear-gradient(top,#{lighter},#{fields.color});\n\tbackground-image:-webkit-gradient(linear,left top,left bottom,color-stop(0%,#{fields.color}),color-stop(100%,#{fields.color}));\n\tbackground-image:-webkit-linear-gradient(top,#{lighter},#{fields.color});\n\tbackground-image:-o-linear-gradient(top,#{lighter},#{fields.color});\n\tbackground-image:linear-gradient(top,#{lighter},#{fields.color});\n\tfilter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#{lighter}',endColorstr=#{fields.color},GradientType=0);\n}"
        else return master
        
    ( master, fields, isPreview)->
        if fields.icon
            pad = parseFloat(fields.icon_width)+10
            return injectRule master, ".topbar .brand{display:inline-block;padding-left:#{pad}px;background:url(#{fields.icon}) 5px center no-repeat;}"
        else return master
        
    ( master, fields, isPreview)->
        unless isPreview
            return injectScript master, '<script src="http://code.jquery.com/jquery-1.6.4.min.js"></script>'
        else return master
]
    
###
  Builds html output
###        
buildOutput = (fields, isPreview=false )->
    filters  = [].concat buildFilters
    master   = MASTERS[fields.master] 
    reductor = ( master, filter )-> filter.call( null, master, fields, isPreview )
    filters.reduce( reductor, master ).insertData( fields )

###
  Updates preview iframe
###        

updatePreview = ()->
    fields    = readFields()
    preview   = buildOutput( fields, true )
    markup    = buildOutput( fields )
    $('#preview').attr 'src', "data:text/html,#{encodeURIComponent(preview)}"
    $('#html').val( markup )    

noClick = ( )->
    $preview = $('#preview')
    $parent  = $preview.parent()
    pos      = $parent.css('position')
    if pos isnt 'absolute'
        $parent.css('position', 'relative')
    $block = $('<div>')
    $parent.append($block)
    $block.css top:0 ,right:0 , bottom:0, left: 0, width: $preview.width(), height: $preview.height(), position: 'absolute'
    
###
  Fetch templates, then listen for form changes
###
listen = ()->
    fetch = $.when.apply $.Deferred, [
        $.get( "templates/hero.html" ).pipe (html)-> 
            MASTERS['hero'] = html
        $.get( "templates/fluid.html" ).pipe (html)-> 
            MASTERS['fluid'] = html
        $.get( "templates/container-app.html" ).pipe (html)-> 
            MASTERS['container-app'] = html
    ]
    
    
    fetch.fail (error)->
        alert('template fetch failed')
        
    fetch.done ()->
        $('form').bind 'change', ((e)->
            if e then e.preventDefault()
            updatePreview(  )
            arguments.callee
        )()
###
  Wait for DOM, init "plugins"
###
$ ()->
    ###
        Start the app.
    ###
    listen()
    noClick()
    ### 
        App-specific plugins
    ###    
    
    ### Image uploader ###
    readFile = ( file, callback )->
        reader = new FileReader()
        reader.onload = (e)->
            callback( e.target.result )
        reader.onerror = ()->
            alert "Error reading file"
        reader.readAsDataURL(file);
        
    $('input#icon').each ()->
        $original = $( @ )
        $form     = $original.parents('form:first')
        $uploader = $original.clone()
        $original.replaceWith $uploader
        $uploader.bind 'change', (e)->
            e.stopPropagation()
            if this.files.length > 0
                readFile this.files[0], (dataURI)->
                    $wrap    = $('<div>')
                    shrinkicon dataURI, ( shrunk )-> 
                        $newicon = $('<img>').addClass('preview-file-upload').attr src: shrunk.URI, height: shrunk.height, width: shrunk.width
                        $reset   = $('<a>').addClass('reset-file-upload').attr(href:'#').text('change icon').bind 'click', (e)->
                            e.preventDefault() 
                            $wrap.remove()
                            $uploader.show()
                        $uploader.hide().after $.fn.append.apply $wrap, [ 
                            $newicon
                            $reset
                            $('<input>').attr( type: 'hidden', value: shrunk.URI, name: 'icon')
                            $('<input>').attr( type: 'hidden', value: shrunk.width, name: 'icon_width')
                            $('<input>').attr( type: 'hidden', value: shrunk.height, name: 'icon_height')                                
                        ]    
                        $form.trigger "change"
    
    ### Master Template Picker ###
    $('.master-picker').each ()->
        $picker = $( @ )
        $labels = $picker.find('label')
        $picker.find('input').hide()        
        $labels.each ()->
            $label = $( @ )
            $label.bind 'click', ()->
                $labels.removeClass 'checked'
                $label.addClass 'checked'
            
            
    
    ### FONT PICKER ###
    $.getJSON 'lib/fonts.json', (fontlist)->
        $('.font-picker').each ()->
            $picker = $( @ )
            $select  = $picker.find('select')
            $preview = $picker.find('iframe')
            $hidden_url    = $picker.find 'input[type=hidden]:first'
            $hidden_family = $picker.find 'input[type=hidden]:last'
            $select.bind 'change', (e)->
                $preview.show()
                url    = $(@).val()
                family = $select.find(':selected').data('family')
                $preview.attr 'src', "data:text/html,#{$preview.data(url)}"
                $hidden_url.val( url )
                $hidden_family.val( family )
            
            for font in fontlist
                {family,variant,url} = font
                weight = 'normal'
                if parts = /^(\d+)(\D+)/.exec( variant )
                    weight  = parts[1]
                    variant = parts[2]
                $preview.data font.url, encodeURIComponent "<!DOCTYPE html><html>
                    <head>
                        <link href='#{url}' rel='stylesheet' type='text/css'>
                        <style>
                            html,body,*{margin:0!important;padding:0!important;border:0!important;overflow:hidden;}
                            body{text-align:left;font-size:13px;font-family:'#{family}';font-weight:#{weight};font-style:#{variant}}
                        </style>
                    </head>
                    <body>#{family} - #{weight} - #{variant}</body>
                </html>"
                $option = $( "<option>" ).attr( value: font.url ).data( font ).text( "#{family} - #{weight} - #{variant}" )
                $select.append $option
                
    ### COLOR PICKER ###
    $('.color-picker').each ()->
        $input  = $( @ ).find( 'input'   )
        $picker = $( @ ).find( '.picker' )
        $.farbtastic $picker, (color)-> 
            $input.val( color )
            $input.parents('form:first').trigger 'change'
        $picker.hide()
        $input.bind 'blur focus', ()-> $picker.toggle()
     


