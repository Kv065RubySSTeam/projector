// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// http://localhost:3000/users/index.json

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")
require('jquery')

// JQuery autocomplete plugin.
import 'easy-autocomplete/dist/jquery.easy-autocomplete'
import '@tarekraafat/autocomplete.js'

require('frest/assets/css/custom.css')

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// BEGIN Vendor JS
require('frest/app-assets/vendors/js/vendors.min.js')
require('frest/app-assets/fonts/LivIconsEvo/js/LivIconsEvo.tools.js')
require('frest/app-assets/fonts/LivIconsEvo/js/LivIconsEvo.defaults.js')
require('frest/app-assets/fonts/LivIconsEvo/js/LivIconsEvo.min.js')

// BEGIN: Theme JS
require('frest/app-assets/js/scripts/configs/horizontal-menu.js')
require('frest/app-assets/js/core/app-menu.min.js');
require('frest/app-assets/js/core/app.js')
require('frest/app-assets/js/scripts/components.js')
require('frest/app-assets/js/scripts/footer.js')

require('javascript/packs/error_fields.js');

//For boards
// require('frest/app-assets/vendors/js/ui/jquery.sticky.js')
// require('frest/app-assets/vendors/js/jkanban/jkanban.min.js')
// require('frest/app-assets/vendors/js/editors/quill/quill.min.js')
// require('frest/app-assets/vendors/js/pickers/pickadate/picker.js')
// require('frest/app-assets/vendors/js/pickers/pickadate/picker.date.js')
// require('frest/app-assets/js/scripts/pages/app-kanban_1.js')
require('frest/app-assets/js/scripts/extensions/toastr.js')
