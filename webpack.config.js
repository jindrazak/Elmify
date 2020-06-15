const path = require('path')

const CopyWebpackPlugin = require('copy-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')


module.exports = {
    // define entrypoints for JavaScript and SCSS
    entry: [
        './src/index.js',
        './src/less/style.less',
        './node_modules/@indicatrix/elm-chartjs-webcomponent/webcomponent/chart.js'
    ],

    // define output
    output: {
        path: path.resolve(__dirname + '/dist'),
        filename: '[name].[chunkhash].js',
        publicPath: '/'
    },

    // define loaders for file types
    module: {
        rules: [
            // loading elm files
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                // we want to use optimize=true when building for production
                loader: process.env.NODE_ENV === 'production' ? 'elm-webpack-loader?verbose=true&optimize=true' : 'elm-webpack-loader?verbose=true'
            },
            // loading styles
            {
                test: /\.less$/,
                use: [{
                    loader: 'style-loader' // creates style nodes from JS strings
                }, {
                    loader: 'css-loader' // translates CSS into CommonJS
                }, {
                    loader: 'less-loader' // compiles Less to CSS
                }]
            },
        ],

        // set noParse for elm files since we don't need webpack to resolve any imports there
        noParse: /\.elm$/
    },

    plugins: [
        // generate Html using HtmlWebpackPlugin
        new HtmlWebpackPlugin({
            title: 'Elmify - stats about your listening tastes',
            meta: {
                viewport: 'width=device-width, initial-scale=1',
                description: 'Display your top tracks and top artists based on your listening habits on Spotify. Discover which songs suit your listening tastes the best.',
                "theme-color": "#ff1493"
            }
        }),
        // configure MiniCssExtractPlugin
        new MiniCssExtractPlugin({
            filename: '[name].[chunkhash].css',
            allChunks: true
        }),
        // copy static files to dist
        new CopyWebpackPlugin([
            { from: 'src/img', to: 'img' },
        ])
    ],

    // dev server for development configuration
    devServer: {
        inline: true,
        stats: { colors: true },
        historyApiFallback: true
    }
}
