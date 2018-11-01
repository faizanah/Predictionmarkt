const { environment } = require('@rails/webpacker')
const merge = require('webpack-merge')
const webpack = require('webpack')

const coffee =  require('./loaders/coffee')
const babel =  require('./loaders/babel')

environment.loaders.append('coffee', coffee)
environment.loaders.append('babel', babel)

// https://stackoverflow.com/questions/45998003/how-to-use-jquery-with-rails-webpacker-3
// https://github.com/webpack/webpack/issues/4258
// Add an additional plugin of your choosing : ProvidePlugin
environment.plugins.append('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    JQuery: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    // 'window.Tether': "tether",
    Popper: ['popper.js', 'default'], // for Bootstrap 4
  })
)

const envConfig = module.exports = environment
const aliasConfig = module.exports = {
  resolve: {
    alias: {
      jquery: 'jquery/src/jquery'
    }
  }
}

module.exports = merge(envConfig.toWebpackConfig(), aliasConfig)
// console.log(module.exports)
