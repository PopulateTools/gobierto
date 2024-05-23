// Do that to avoid JS "imports" hoisting
// https://gorails.com/episodes/how-to-use-jquery-with-esbuild
import $ from 'jquery'

window.$ = $
window.jQuery = $
