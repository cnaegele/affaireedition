//plugins/vuetify.js
import '@mdi/font/css/materialdesignicons.css'
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { VDateInput } from 'vuetify/labs/VDateInput'
import { data } from '@/stores/data.js'
import {getTheme} from '../../../cnlib/vgotheme.js' 

const goelandTheme = getTheme('goeland')

export default {
  install: (app) => {
    const lesDatas = data()
    const vuetify = createVuetify({
      components: {
        VDateInput,
      },
      directives,
      theme: {
        defaultTheme: lesDatas.env.themeChoisi,
        themes: {
          goelandTheme,
        },
      },
    })

    app.use(vuetify)
  }
}
