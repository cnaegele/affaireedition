/**
 * main.js
 *
 * Bootstraps Vuetify and other plugins then mounts the App`
 */

import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import vuetifyPlugin from './plugins/vuetify'

const pinia = createPinia()
const app = createApp(App)

app.use(pinia)
app.use(vuetifyPlugin)

app.mount('#app')
