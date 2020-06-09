const path = require('path')

const CopyWebpackPlugin = require('copy-webpack-plugin')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')


module.exports = {
    // define entrypoints for JavaScript and SCSS
    entry: [
        './src/index.js',
        './src/less/style.less'
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
                test: /\.(scss|css)$/,
                loader: [
                    { loader: MiniCssExtractPlugin.loader },  // using MiniCssExtractPlugin to extract styles into separate file
                    'css-loader',
                    'sass-loader'
                ]
            },
            // loading fonts
            {
                test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: 'url-loader?limit=10000&mimetype=application/font-woff'
            },
            {
                test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                loader: 'file-loader'
            }
        ],

        // set noParse for elm files since we don't need webpack to resolve any imports there
        noParse: /\.elm$/
    },

    plugins: [
        // generate Html using HtmlWebpackPlugin
        new HtmlWebpackPlugin({
            title: 'Elm Webpack Boilerplate'
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
