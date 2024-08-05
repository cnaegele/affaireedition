import { defineStore } from 'pinia';
import { ref } from 'vue'
export const data = defineStore({
  id: 'iddata',
  state: () => ({
    env: {
        version: ref('0.0.0'),
        dateversion: ref('05.08.2024'),
        themeChoisi: ref(localStorage.getItem('themeChoisi') || 'dark'),
    },
    user: {
        idEmployeUser: ref(0),
        nomEmployeUser: ref(''),
        prenomEmployeUser: ref(''),
        loginEmployeUser: ref(''),
        groupeSecurite: ref(''),
        bInGroupe: ref(0),
    },
    affaire: {
        id: ref(0),
        idType: ref(0),
        type: ref(''),
        nom: ref(''),
        description: ref(''),
        dateCreation: ref(''),
        dateDebut: ref(''),
        dateFin: ref(''),
    },
    messagesErreur: {
      dataRue: ref(''),
      dataAdresse: ref(''),
      serverbackend: ref(''),
    }, 
  })
})
