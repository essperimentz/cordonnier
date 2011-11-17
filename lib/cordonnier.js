(function() {
  /*
  	Cordonnier v0.1
      Copyright 2011 Francois Lafortune, @quickredfox
      Licensed under the Apache License v2.0
      http://www.apache.org/licenses/LICENSE-2.0
  */
  var MASTERS, buildFilters, buildOutput, injectLink, injectRule, injectScript, listen, noClick, readFields, shrinkicon, updatePreview;
  MASTERS = {};
  /* 
      looks for [[things]] and replaces them with { things: 'value' }
  */
  String.prototype.insertData = function(o) {
    return this.replace(/\[\[([^\[\]]*)\]\]/g, function(a, b) {
      var r;
      r = o[b];
      if (typeof r === 'string' || typeof r === 'number') {
        return r;
      } else {
        return '';
      }
    });
  };
  /*
      Reads the form fields, sets some defaults
  */
  readFields = function() {
    var fields;
    fields = $('form').serializeArray().reduce(function(fields, field) {
      var value;
      if ((value = field.value.trim())) {
        fields[field.name] = value;
      }
      return fields;
    }, {});
    if (!fields.year) {
      fields.year = (new Date()).getFullYear();
    }
    if (!fields.project) {
      fields.project = "My Project";
    }
    if (!fields.copyright) {
      fields.copyright = "Company Inc.";
    }
    if (!fields.master) {
      fields.master = 'hero';
    }
    return fields;
  };
  /*
      Takes a dataURI and shrinks it's resulting image to a maximum height of 32px
  */
  shrinkicon = function(dataURI, callback) {
    var img;
    img = new Image();
    img.onload = function() {
      var URI, canvas, ctx, height, ideal, max, width;
      width = img.width, height = img.height;
      max = Math.max(width, height);
      ideal = 32;
      if (max < 32) {
        return {
          URI: dataURI,
          width: width,
          height: height
        };
      }
      if (height < 32) {
        ideal = height;
      }
      width = (width * ideal) / height;
      canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = ideal;
      ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, width, ideal);
      URI = canvas.toDataURL("image/png");
      return callback({
        URI: URI,
        width: width,
        height: ideal
      });
    };
    return img.src = dataURI;
  };
  /*
   Inject a <link> tag right before the first <style> on a provided master
  */
  injectLink = function(master, link) {
    return master = master.replace(/<style/, "" + link + "\n\t<style");
  };
  /*
   Inject a css rule right before the first </style> on a provided master
  */
  injectRule = function(master, rule) {
    return master = master.replace(/<\/style\>/, "" + rule + "\n\t</style>");
  };
  /*
   Inject a <script> tag right before the </body> on a provided master
  */
  injectScript = function(master, script) {
    return master = master.replace(/<\/body\>/, "" + script + "\n</body>");
  };
  /*
   Filters to bind data on masters. 
  */
  buildFilters = [
    function(master, fields, isPreview) {
      if (!isPreview) {
        return master.replace(/\<!--\[preview[^\[]+<!--.+-->/g, '');
      } else {
        return master;
      }
    }, function(master, fields, isPreview) {
      if (fields.font_url) {
        return injectLink(master, "<link rel=\"stylesheet\" type=\"text/css\" href=\"" + fields.font_url + "\" media=\"screen\">");
      } else {
        return master;
      }
    }, function(master, fields, isPreview) {
      if (fields.font_family) {
        return injectRule(master, "h1,h2,h3,h4,h5,h6,.brand{font-family:" + fields.font_family + "}");
      } else {
        return master;
      }
    }, function(master, fields, isPreview) {
      var lighter, textcolor;
      if (fields.color) {
        lighter = $.xcolor.lighten(fields.color, 1);
        textcolor = "#ffffff";
        if (!$.xcolor.readable(textcolor, fields.color)) {
          textcolor = '#000000';
          master = injectRule(master, "/* todo: fix this */\n\t.topbar *{color:" + textcolor + "!important}");
        }
        return injectRule(master, "\n\t.topbar-inner,.topbar .fill{\n\tcolor:" + textcolor + ";\n\tbackground-color:" + fields.color + ";\n\tbackground-repeat:repeat-x;\n\tbackground-image:-khtml-gradient(linear,left top,left bottom,from(" + lighter + "),to(" + fields.color + "));\n\tbackground-image:-moz-linear-gradient(top," + lighter + "," + fields.color + ");\n\tbackground-image:-ms-linear-gradient(top," + lighter + "," + fields.color + ");\n\tbackground-image:-webkit-gradient(linear,left top,left bottom,color-stop(0%," + fields.color + "),color-stop(100%," + fields.color + "));\n\tbackground-image:-webkit-linear-gradient(top," + lighter + "," + fields.color + ");\n\tbackground-image:-o-linear-gradient(top," + lighter + "," + fields.color + ");\n\tbackground-image:linear-gradient(top," + lighter + "," + fields.color + ");\n\tfilter:progid:DXImageTransform.Microsoft.gradient(startColorstr='" + lighter + "',endColorstr=" + fields.color + ",GradientType=0);\n}");
      } else {
        return master;
      }
    }, function(master, fields, isPreview) {
      var pad;
      if (fields.icon) {
        pad = parseFloat(fields.icon_width) + 10;
        return injectRule(master, ".topbar .brand{display:inline-block;padding-left:" + pad + "px;background:url(" + fields.icon + ") 5px center no-repeat;}");
      } else {
        return master;
      }
    }, function(master, fields, isPreview) {
      if (!isPreview) {
        return injectScript(master, '<script src="http://code.jquery.com/jquery-1.6.4.min.js"></script>');
      } else {
        return master;
      }
    }
  ];
  /*
    Builds html output
  */
  buildOutput = function(fields, isPreview) {
    var filters, master, reductor;
    if (isPreview == null) {
      isPreview = false;
    }
    filters = [].concat(buildFilters);
    master = MASTERS[fields.master];
    reductor = function(master, filter) {
      return filter.call(null, master, fields, isPreview);
    };
    return filters.reduce(reductor, master).insertData(fields);
  };
  /*
    Updates preview iframe
  */
  updatePreview = function() {
    var fields, markup, preview;
    fields = readFields();
    preview = buildOutput(fields, true);
    markup = buildOutput(fields);
    $('#preview').attr('src', "data:text/html," + (encodeURIComponent(preview)));
    return $('#html').val(markup);
  };
  noClick = function() {
    var $block, $parent, $preview, pos;
    $preview = $('#preview');
    $parent = $preview.parent();
    pos = $parent.css('position');
    if (pos !== 'absolute') {
      $parent.css('position', 'relative');
    }
    $block = $('<div>');
    $parent.append($block);
    return $block.css({
      top: 0,
      right: 0,
      bottom: 0,
      left: 0,
      width: $preview.width(),
      height: $preview.height(),
      position: 'absolute'
    });
  };
  /*
    Fetch templates, then listen for form changes
  */
  listen = function() {
    var fetch;
    fetch = $.when.apply($.Deferred, [
      $.get("templates/hero.html").pipe(function(html) {
        return MASTERS['hero'] = html;
      }), $.get("templates/fluid.html").pipe(function(html) {
        return MASTERS['fluid'] = html;
      }), $.get("templates/container-app.html").pipe(function(html) {
        return MASTERS['container-app'] = html;
      })
    ]);
    fetch.fail(function(error) {
      return alert('template fetch failed');
    });
    return fetch.done(function() {
      return $('form').bind('change', (function(e) {
        if (e) {
          e.preventDefault();
        }
        updatePreview();
        return arguments.callee;
      })());
    });
  };
  /*
    Wait for DOM, init "plugins"
  */
  $(function() {
    /*
            Start the app.
        */
    var readFile;
    listen();
    noClick();
    /* 
        App-specific plugins
    */
    /* Image uploader */
    readFile = function(file, callback) {
      var reader;
      reader = new FileReader();
      reader.onload = function(e) {
        return callback(e.target.result);
      };
      reader.onerror = function() {
        return alert("Error reading file");
      };
      return reader.readAsDataURL(file);
    };
    $('input#icon').each(function() {
      var $form, $original, $uploader;
      $original = $(this);
      $form = $original.parents('form:first');
      $uploader = $original.clone();
      $original.replaceWith($uploader);
      return $uploader.bind('change', function(e) {
        e.stopPropagation();
        if (this.files.length > 0) {
          return readFile(this.files[0], function(dataURI) {
            var $wrap;
            $wrap = $('<div>');
            return shrinkicon(dataURI, function(shrunk) {
              var $newicon, $reset;
              $newicon = $('<img>').addClass('preview-file-upload').attr({
                src: shrunk.URI,
                height: shrunk.height,
                width: shrunk.width
              });
              $reset = $('<a>').addClass('reset-file-upload').attr({
                href: '#'
              }).text('change icon').bind('click', function(e) {
                e.preventDefault();
                $wrap.remove();
                return $uploader.show();
              });
              $uploader.hide().after($.fn.append.apply($wrap, [
                $newicon, $reset, $('<input>').attr({
                  type: 'hidden',
                  value: shrunk.URI,
                  name: 'icon'
                }), $('<input>').attr({
                  type: 'hidden',
                  value: shrunk.width,
                  name: 'icon_width'
                }), $('<input>').attr({
                  type: 'hidden',
                  value: shrunk.height,
                  name: 'icon_height'
                })
              ]));
              return $form.trigger("change");
            });
          });
        }
      });
    });
    /* Master Template Picker */
    $('.master-picker').each(function() {
      var $labels, $picker;
      $picker = $(this);
      $labels = $picker.find('label');
      $picker.find('input').hide();
      return $labels.each(function() {
        var $label;
        $label = $(this);
        return $label.bind('click', function() {
          $labels.removeClass('checked');
          return $label.addClass('checked');
        });
      });
    });
    /* FONT PICKER */
    $.getJSON('lib/fonts.json', function(fontlist) {
      return $('.font-picker').each(function() {
        var $hidden_family, $hidden_url, $option, $picker, $preview, $select, family, font, parts, url, variant, weight, _i, _len, _results;
        $picker = $(this);
        $select = $picker.find('select');
        $preview = $picker.find('iframe');
        $hidden_url = $picker.find('input[type=hidden]:first');
        $hidden_family = $picker.find('input[type=hidden]:last');
        $select.bind('change', function(e) {
          var family, url;
          $preview.show();
          url = $(this).val();
          family = $select.find(':selected').data('family');
          $preview.attr('src', "data:text/html," + ($preview.data(url)));
          $hidden_url.val(url);
          return $hidden_family.val(family);
        });
        _results = [];
        for (_i = 0, _len = fontlist.length; _i < _len; _i++) {
          font = fontlist[_i];
          family = font.family, variant = font.variant, url = font.url;
          weight = 'normal';
          if (parts = /^(\d+)(\D+)/.exec(variant)) {
            weight = parts[1];
            variant = parts[2];
          }
          $preview.data(font.url, encodeURIComponent("<!DOCTYPE html><html>                    <head>                        <link href='" + url + "' rel='stylesheet' type='text/css'>                        <style>                            html,body,*{margin:0!important;padding:0!important;border:0!important;overflow:hidden;}                            body{text-align:left;font-size:13px;font-family:'" + family + "';font-weight:" + weight + ";font-style:" + variant + "}                        </style>                    </head>                    <body>" + family + " - " + weight + " - " + variant + "</body>                </html>"));
          $option = $("<option>").attr({
            value: font.url
          }).data(font).text("" + family + " - " + weight + " - " + variant);
          _results.push($select.append($option));
        }
        return _results;
      });
    });
    /* COLOR PICKER */
    return $('.color-picker').each(function() {
      var $input, $picker;
      $input = $(this).find('input');
      $picker = $(this).find('.picker');
      $.farbtastic($picker, function(color) {
        $input.val(color);
        return $input.parents('form:first').trigger('change');
      });
      $picker.hide();
      return $input.bind('blur focus', function() {
        return $picker.toggle();
      });
    });
  });
}).call(this);
