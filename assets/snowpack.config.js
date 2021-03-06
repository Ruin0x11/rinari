module.exports = {
    plugins: [
        'snowpack-plugin-stylus'
    ],
    mount: {
        "js": { url: "/js" },
        "css": { url: "/css" },
        "static": { url: "/", static: true, resolve: false }
    },
    buildOptions: {
        out: "../priv/static/"
    },
    optimize: {
        entrypoints: ["./static/index.html"],
        bundle: true,
        minify: true,
        target: 'es2018'
    },
};
