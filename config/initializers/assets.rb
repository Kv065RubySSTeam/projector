# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')


# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

Rails.application.config.assets.paths << Rails.root.join("vendor", "frest")
Rails.application.config.assets.paths << Rails.root.join('vendor/frest')
Rails.application.config.assets.precompile += ['app-assets/css/bootstrap.css',
                                               'app-assets/css/bootstrap-extended.css',
                                               'app-assets/css/colors.css',
                                               'app-assets/css/components.min.css',
                                               'app-assets/vendors/css/vendors.min.css',
                                               'app-assets/css/core/menu/menu-types/vertical-menu.min.css',
                                               'app-assets/css/components.css',
                                               'app-assets/css/pages/app-invoice.min.css',
                                               'app-assets/vendors/css/tables/datatable/datatables.min.css',
                                               'app-assets/vendors/css/extensions/sweetalert2.min.css',
                                               'app-assets/vendors/css/extensions/toastr.css',
                                               'app-assets/fonts/boxicons/fonts/boxicons.woff2',
                                               'app-assets/fonts/boxicons/fonts/boxicons.woff',
                                               'app-assets/fonts/boxicons/fonts/boxicons.ttf']
