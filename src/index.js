const program = require('./elm/Main.elm');


var metaTag=document.createElement('meta');
metaTag.name = "viewport"
metaTag.content = "width=device-width, initial-scale=1.0"
document.getElementsByTagName('head')[0].appendChild(metaTag);

program.Elm.Main.init({
    flags: {}
});

