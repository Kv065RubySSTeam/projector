// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require('jquery')
require('jquery-ujs');


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

require('frest/app-assets/vendors/js/vendors.min.js')
require('frest/app-assets/fonts/LivIconsEvo/js/LivIconsEvo.tools.js')
require('frest/app-assets/fonts/LivIconsEvo/js/LivIconsEvo.defaults.js')
require('frest/app-assets/fonts/LivIconsEvo/js/LivIconsEvo.min.js')

// BEGIN: Theme JS

require('frest/app-assets/js/scripts/configs/horizontal-menu.js')
require('frest/app-assets/js/core/app-menu.min.js');
//require('frest/app-assets/js/core/app.js')
//require('frest/app-assets/js/scripts/components.js')
require('frest/app-assets/js/scripts/footer.js')

require('javascript/packs/dropdown_toggle.js');
require('javascript/packs/columns/update_column.js');
