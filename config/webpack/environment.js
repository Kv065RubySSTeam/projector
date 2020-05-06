const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    toastr: 'frest/app-assets/vendors/js/extensions/toastr.min.js'
  })
)

module.exports = environment
