const path = require('path')

const HtmlWebpackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')


module.exports = {
    entry: [
        './src/index.js',
        './src/less/style.less',
        './node_modules/@indicatrix/elm-chartjs-webcomponent/webcomponent/chart.js'
    ],
    output: {
        path: path.resolve(__dirname + '/dist'),
        filename: '[name].[chunkhash].js',
        publicPath: '/'
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                // we want to use optimize=true when building for production
                loader: process.env.NODE_ENV === 'production' ? 'elm-webpack-loader?verbose=true&optimize=true' : 'elm-webpack-loader?verbose=true'
            },
            {
                test: /\.less$/,
                use: [{
                    loader: 'style-loader'
                }, {
                    loader: 'css-loader'
                }, {
                    loader: 'less-loader'
                }]
            },
        ],
        // set noParse for elm files since we don't need webpack to resolve any imports there
        noParse: /\.elm$/
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: 'Elmify - stats about your listening tastes',
            meta: {
                viewport: 'width=device-width, initial-scale=1',
                description: 'Display your top tracks and top artists based on your listening habits on Spotify. Discover which songs suit your listening tastes the best.',
                "theme-color": "#ff1493"
            }
        }),
        new MiniCssExtractPlugin({
            filename: '[name].[chunkhash].css',
            allChunks: true
        }),
    ],
    devServer: {
        inline: true,
        stats: { colors: true },
        historyApiFallback: true
    }
}
