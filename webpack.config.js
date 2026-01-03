const path = require('path')
const Dotenv = require('dotenv-webpack');

const HtmlWebpackPlugin = require('html-webpack-plugin')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')


module.exports = {
    entry: [
        './src/index.js',
        './src/less/style.less',
        './node_modules/@indicatrix/elm-chartjs-webcomponent/webcomponent/chart.js'
    ],
    output: {
        path: path.resolve(__dirname, 'dist'),
        filename: '[name].[contenthash].js',
        publicPath: '/',
        clean: true
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {
                        verbose: true,
                        optimize: process.env.NODE_ENV === 'production'
                    }
                }
            },
            {
                test: /\.less$/,
                use: [
                    'style-loader',
                    'css-loader',
                    'less-loader'
                ]
            },
        ],
        // set noParse for elm files since we don't need webpack to resolve any imports there
        noParse: /\.elm$/
    },
    plugins: [
        new HtmlWebpackPlugin({
            title: 'Elmify - stats about your listening tastes',
            favicon: "favicon.ico",
            meta: {
                viewport: 'width=device-width, initial-scale=1',
                description: 'Display your top tracks and top artists based on your listening habits on Spotify. Discover which songs suit your listening tastes the best.',
                "theme-color": "#ff1493",
                "google-site-verification": process.env.GOOGLE_SITE_VERIFICATION
            }
        }),
        new MiniCssExtractPlugin({
            filename: '[name].[contenthash].css'
        }),
        new Dotenv({
            systemvars: true
        })
    ],
    devServer: {
        historyApiFallback: true
    }
}
