// Open in current tab
mapkey('o', '#8Open an URL in current tab', 'Normal.openOmnibar({type: "URLs", extra: "getTopSites", tabbed: false})');

// Open hint in new tab
mapkey('F', 'Open a link in new window', function() {
    Hints.create("a:visible", function(link, event) {
        window.open(link.getAttribute('href'));
    })
});

// Next tab
unmap('L');
mapkey('L', 'Next tab', function() {
    RUNTIME('nextTab');
});

// Previous tab
unmap('H');
mapkey('H', 'Previous tab', function() {
    RUNTIME('previousTab');
});

// Go back
unmap('<Ctrl-h>');
mapkey('<Ctrl-h>', 'Go back', function() {
    history.go(-1);
});

// Go forward
unmap('<Ctrl-l>');
mapkey('<Ctrl-l>', 'Go forward', function() {
    history.go(1);
});

unmap('<Ctrl-d>');
mapkey('<Ctrl-d>', 'Scroll down half page', function () {
    Normal.scroll('pageDown');
});
unmap('<Ctrl-l>');
mapkey('<Ctrl-l>', 'Scroll up half page', function () {
    Normal.scroll('pageUp');
});

unmap('x');
mapkey('x', 'Close tab', function () {
    RUNTIME('closeTab');
});

Hints.style("background: #000;");

settings.theme = '\
.sk_theme { \
    background: #333; \
    color: #fff; \
} \
.sk_theme tbody { \
    color: #fff; \
} \
.sk_theme input { \
    color: #fff; \
} \
.sk_theme .url { \
    color: #555; \
} \
.sk_theme .annotation { \
    color: #bfbfbf; \
} \
.sk_theme .focused { \
    background: #fff; \
    color: #333; \
} \
.sk_theme .focused .title { \
    color: #ff5722; \
} \
.sk_theme .omnibar_folder { \
    color: #4caf50; \
} \
.sk_theme .omnibar_timestamp { \
    color: #ffeb3b; \
} \
';

