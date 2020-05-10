const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    dragula: 'frest/app-assets/vendors/js/extensions/dragula.min.js'
  })
)

module.exports = environment
