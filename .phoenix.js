const apps = [
    'Telegram',
    'Firefox Developer Edition',
    'iTerm',
    'Visual Studio Code',
    'Canary Mail',
    null,
    null,
    null,
    'zoom.us',
    'Slack',
];

for (const [idx, app] of apps.entries()) {
    if (app) {
        Key.on(idx.toString(), ['cmd'], () => {
            App.launch(app).focus();
        });
    }
}
