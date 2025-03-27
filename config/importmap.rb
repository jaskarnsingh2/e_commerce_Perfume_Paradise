# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/request.js", to: "@rails--request.js.js" # @0.0.11

pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js"
pin "jquery_ujs", to: "https://cdn.jsdelivr.net/npm/jquery-ujs@1.2.3/src/rails.js"
pin "active_admin", to: "active_admin.js"