const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    PerfectScrollbar: 'perfect-scrollbar/dist/perfect-scrollbar',
    toastr: 'frest/app-assets/vendors/js/extensions/toastr.min.js',
    autoComplete: '@tarekraafat/autocomplete.js/dist/js/autoComplete.min.js',
  })
)

module.exports = environment
