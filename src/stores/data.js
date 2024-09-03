import { defineStore } from 'pinia';
import { ref } from 'vue'
export const data = defineStore({
  id: 'iddata',
  state: () => ({
    env: {
        version: ref('0.0.0'),
        dateversion: ref('03.09.2024'),
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
        gen: {
          id: ref(0),
          idType: ref(0),
          type: ref(''),
          nom: ref(''),
          description: ref(''),
          commentaire: ref(''),
          dateCreation: ref(''),
          dateDebut: ref(''),
          dateFin: ref(''),
          bTermine: ref(false)
        },
        employeConcerne: [],
        /*
          idemploye: ref(0),
          bactif: ref(true),
          nom: ref(''),
          uniteorg: ref(''),
          idrole: ref(0),
          role: ref(''),
          datedebutparticipe: ref(''),
          datefinparticipe: ref(''),
          commentaire: ref(''),
        */
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
      dataGenChange: ref(false),
      bdataGenNomOK: ref(true),
      bdataGenDateDebutOK: ref(true),
      bdataGenDateFinOK: ref(true),
      dataEmployeConcChange: ref(false),
      bdataEmployeConcOK: ref(true),
      dataUniteOrgConcChange: ref(false),
      bdataUniteOrgConcOK: ref(true),
      dataActeurConcChange: ref(false),
      bdataActeurConcOK: ref(true),
    },
    messagesErreur: {
      bSnackbar: ref(false),
      timeOutSnackbar: ref(10000),
      messageSnackbar: ref(''),
      dateDebut: ref(''),
      dateFin: ref(''),
      serverbackend: ref(''),
    }, 
  }),
  getters: {
    bdataGenOK: (state)  => {
      if (state.controle.bdataGenNomOK 
          && state.controle.bdataGenDateDebutOK
          && state.controle.bdataGenDateFinOK) {
        return true
      } else {
        return false
      }
    }  
  }
})
