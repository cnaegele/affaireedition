import { defineStore } from 'pinia';
import { ref } from 'vue'
export const data = defineStore({
  id: 'iddata',
  state: () => ({
    env: {
        version: ref('0.0.0'),
        dateversion: ref('22.08.2024'),
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
        uniteOrgConcerne: [],
        /*
          iduniteorg: ref(0),
          bactif: ref(true),
          nomuo: ref(''),
          desctreeuo: ref(''),
          idrole: ref(0),
          role: ref(''),
          datedebutparticipe: ref(''),
          datefinparticipe: ref(''),
          commentaire: ref(''),
        */
        acteurConcerne: [],
        /*
          idacrole: ref(0),
          idacteur: ref(0),
          bactif: ref(true),
          nom: ref(''),
          idrole: ref(0),
          role: ref(''),
          commentaire: ref(''),
        */
    },
    controle: {
      dataChange: ref(false),
      dataUniteOrgConcChange: ref(false),
      dataActeurConcChange: ref(false),
    },
    messagesErreur: {
      dataRue: ref(''),
      dataAdresse: ref(''),
      serverbackend: ref(''),
    }, 
  })
})
