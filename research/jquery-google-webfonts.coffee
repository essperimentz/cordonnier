# WebFontConfig = window.WebFontConfig = 
#     google: 
#         families: ["Abel:regular:latin"
#         , "Aclonica:regular:latin"
#         , "Anton:regular:latin-ext"
#         , "Bentham:regular:latin"
#         , "Bevan:regular:latin"
#         , "Bigshot One:regular:latin"
#         , "Candal:regular:latin"
#         , "Cedarville Cursive:regular:latin"
#         , "Damion:regular:latin"
#         , "Dorsa:400:latin"
#         , "Eater Caps:400:latin-ext"
#         , "Fanwood Text:400,400italic:latin"
#         , "Federant:400:latin"
#         , "Fontdiner Swanky:regular:latin"
#         , "Forum:regular:latin-ext"
#         , "Geo:regular:latin"
#         , "Goblin One:regular:latin"
#         , "Gruppo:regular:latin"
#         , "Hammersmith One:regular:latin"
#         , "Inconsolata:regular:latin"
#         , "Indie Flower:regular:latin"
#         , "Irish Grover:regular:latin"
#         , "Julee:regular:latin"
#         , "Jura:300,400,500,600:latin-ext"
#         , "Kameron:400,700:latin"
#         , "Kelly Slab:regular:latin-ext"
#         , "Kristi:regular:latin"
#         , "La Belle Aurore:regular:latin"
#         , "Lancelot:400:latin"
#         , "Maiden Orange:regular:latin"
#         , "MedievalSharp:regular:latin-ext"
#         , "Neuton:200,300,regular,italic,700,800:latin-ext"
#         , "News Cycle:regular:latin"
#         , "Old Standard TT:regular,italic,bold:latin"
#         , "Ovo:regular:latin"
#         , "Pacifico:regular:latin"
#         , "Passero One:regular:latin"
#         , "Quattrocento:regular:latin"
#         , "Quicksand:300,400,700:latin"
#         , "Radley:regular:latin"
#         , "Raleway:100:latin"
#         , "Rammetto One:400:latin-ext"
#         , "Satisfy:400:latin"
#         , "Schoolbell:regular:latin"
#         , "Sniglet:800:latin"
#         , "Sunshiney:regular:latin"
#         , "Supermercado One:400:latin"
#         , "Tangerine:regular,bold:latin"
#         , "Ultra:regular:latin"
#         , "UnifrakturCook:bold:latin"
#         , "Unna:regular:latin"
#         , "VT323:regular:latin"
#         , "Varela:regular:latin-ext"
#         , "Varela Round:regular:latin"
#         , "Vast Shadow:regular:latin"
#         , "Vibur:regular:latin"
#         , "Vidaloka:400:latin"
#         , "Wallpoet:regular:latin"
#         , "Yellowtail:regular:latin"
#         , "Yeseva One:regular:latin"
#         , "Zeyada:regular:latin"]
# gkey = 'AIzaSyAdnVAbQyiMmP28f7ZA0EXboPgYaiApSvk'
# # load google fonts js
# wf       = document.createElement('script')
# protocol = if 'https:' is document.location.protocol then 'https' else 'http'
# wf.src = "#{protocol}://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js"
# s        = document.getElementsByTagName('script')[0]
# s.parentNode.insertBefore(wf, s)
# 
# makePicker = ( el )->
#     if $( el ).find('select').length > 0 then return el
#     vmatch = /^(\d+)(.+)/
#     index   = 0 
#     $el     = $( el )
#     $hidden_url    = $el.find 'input[type=hidden]:first'
#     $hidden_family = $el.find 'input[type=hidden]:last'
#     $select = $('<select>').addClass('font-picker span6')
#     $select.bind 'change', ()->
#         $hidden_url.val( $select.val() )
#         $hidden_family.val( $select.find(':selected').first().data('family') )    
#     for string in WebFontConfig.google.families
#         [family,variants,subset] = string.split(':')
#         data = 
#             family:   family
#             variants: variants.split ','
#             subset:   subset
#             url: "http://fonts.googleapis.com/css?family=#{encodeURIComponent(family)}:#{variants}&subset=#{subset}"
#         $optgroup = $('<optgroup>').attr( 'label', family ).css(fontFamily: family).appendTo $select
#         data.variants.forEach (variant)->
#             if vmatch.test variant
#                 matches = variant.match vmatch
#                 variant = matches[1]
#                 weight  = matches[0]
#             else
#                 weight  = 'normal'
#             $option = $('<option>').data( data ).val( data.url ).css( fontFamily: family, fontWeight: weight, fontStyle:  variant )
#             $option.text "#{family}, #{weight}, #{variant}"
#             $optgroup.append $option
#     $el.append $select
#     return $el
# 
# $.fn.googleFontPicker = ()-> $( @ ).map ()-> makePicker( @ )