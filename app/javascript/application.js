// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "jquery"
import "select2"
import "@hotwired/turbo-rails"
import "controllers"

// app/javascript/application.js (or packs/application.js)
document.addEventListener('turbo:load', function() {
    $('.select2').select2({
      tags: true,
      tokenSeparators: [',', ' '],
      createTag: function(params) {
        return {
          id: params.term,
          text: params.term,
          newTag: true
        }
      }
    });
  });