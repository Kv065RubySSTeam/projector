const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    PerfectScrollbar: 'perfect-scrollbar/dist/perfect-scrollbar'
  })
)

module.exports = environment
