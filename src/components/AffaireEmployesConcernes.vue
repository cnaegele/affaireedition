<template>
    <v-row v-if="afficheChoixEmploye" class="border-solid border-1">
      <v-col cols="12" md="12">
        <span v-if="modeChoixEmployeConc == 'unique'">Choisir un employé</span>
        <span v-else>Choisir des employés</span>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <v-btn
          rounded="lg"
          @click="quitteChoixEmployeConcerne()"
        >QUITTER</v-btn>
        <Suspense>
            <EmployeChoix 
                uniteHorsVdL="non" 
                :modeChoix="modeChoixEmployeConc"
                @choixEmploye="receptionEmploye"
            />
        </Suspense>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12" md="12">
        <v-expansion-panels v-model="panelEmployeConcerne">
          <v-expansion-panel>
            <v-expansion-panel-title>
              <span class="titreChampSaisie">
                Employés concernés ({{ lesDatas.affaire.employeConcerne.length }})&nbsp;
                <v-tooltip text="ajouter un employé concerné">
                  <template v-slot:activator="{ props }">
                    <v-btn
                      v-bind="props"
                      rounded="lg"
                      @click.stop="choixEmployeConcerne('unique')"
                    >+1</v-btn>
                  </template>        
                </v-tooltip>
                &nbsp;
                <v-tooltip text="ajouter plusieurs employés concernées">
                  <template v-slot:activator="{ props }">
                    <v-btn class="text-lowercase"
                      v-bind="props"
                      rounded="lg"
                      @click.stop="choixEmployeConcerne('multiple')"
                    >+n</v-btn>
                  </template>        
                </v-tooltip>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <v-tooltip text="sauver les données employés concernés" v-if="lesDatas.controle.dataEmployeConcChange">
                  <template v-slot:activator="{ props }">
                      <v-btn
                          v-bind="props"
                          icon="mdi-database-arrow-left-outline"
                          @click.stop="demandeSauveData('employe')"
                      />
                  </template>        
                </v-tooltip>
              </span> 
            </v-expansion-panel-title>
            <v-expansion-panel-text>  
              <v-container>
                <v-row v-for="(employeConcerne, index) in lesDatas.affaire.employeConcerne" :key="index" class="d-flex align-center">
                 <v-col cols="12" md="2">
                    {{ employeConcerne.nom }}
                  </v-col>
                  <v-col cols="12" md="2">
                    <v-select
                      v-model="lesDatas.affaire.employeConcerne[index].idrole"
                      :items="rolesdisp"
                      label="rôle"
                      item-title="label"
                      :reduce="(item) => rolesdisp.value"
                      placeholder="Sélectionner un rôle"
                    ></v-select>                     
                  </v-col>
                  
                  <v-col cols="12" md="2" class="go_colsdate">
                      <div class="go_labeldate">début participation</div> 
                      <div class="go_divdate">
                        <input
                          type="date"
                          class="go_inpdate"
                          v-model="lesDatas.affaire.employeConcerne[index].datedebutparticipe"
                        ></input>
                      </div>
                  </v-col>
                  <v-col cols="12" md="2" class="go_colsdate">
                      <div class="go_labeldate">fin participation</div> 
                      <div class="go_divdate">
                        <input
                          type="date"
                          class="go_inpdate"
                          v-model="lesDatas.affaire.employeConcerne[index].datefinparticipe"
                        ></input>
                      </div>
                  </v-col>
                  <v-col cols="12" md="3">
                    <v-text-field
                      label="commentaire"
                      v-model="lesDatas.affaire.employeConcerne[index].commentaire"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="12" md="1">
                    <v-tooltip text="supprimer le lien employé">
                      <template v-slot:activator="{ props }">
                        <v-btn
                          v-bind="props"
                          icon="mdi-delete"
                          variant="text"
                          @click="supprimeLienEmploye(index)"
                        ></v-btn>
                      </template>        
                    </v-tooltip>
                  </v-col>
                </v-row>
              </v-container>
            </v-expansion-panel-text>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-col>
    </v-row>
</template>

<script setup>
import { toRefs, ref, watch } from 'vue'
import { data } from '@/stores/data.js'
import EmployeChoix from '../../../employechoix/src/components/EmployeChoix.vue'
import { demandeSauveData } from '@/sauve.js'

const lesDatas = data()
const dateini = ref([null,null])

const props = defineProps({
  rolesdisp: {
    type: Array,
    default() {
      return [
        {
          id: 1,
          label: 'Participant-e',
          value: '1'
        },
        {
          id: 2,
          label: 'Responsable',
          value: '2'
        },
        {
          id: 5,
          label: 'Gestionnaire',
          value: '5'
        },
        {
          id: 6,
          label: 'Suppléant-e',
          value: '6'
        },
        {
          id: 12,
          label: 'Concerné-e',
          value: '12'
        },
      ]
    }
  },
  roledefaut: {
    type: String,
    default() {
      return '1'
    }
  }
})
const { rolesdisp } = toRefs(props)
const { roledefaut } = toRefs(props)

watch(() => lesDatas.affaire.employeConcerne, () => {
  lesDatas.controle.dataEmployeConcChange = true
  lesDatas.controle.dataChange = true
}, { deep: true })

const modeChoixEmployeConc = ref('unique')
const panelEmployeConcerne = ref([])
const afficheChoixEmploye = ref(false)

const choixEmployeConcerne = (mode) => {
  if (!afficheChoixEmploye.value) {
    modeChoixEmployeConc.value = mode
    afficheChoixEmploye.value = true
  }
}

const quitteChoixEmployeConcerne = () => {
  afficheChoixEmploye.value = false
}

const receptionEmploye = (idemploye, jsonData) => {
  afficheChoixEmploye.value = false
  panelEmployeConcerne.value = [0]

  const oEmployeRecu = JSON.parse(jsonData)
  let aoEmployeRecu = []
  let bactif = true
  if (oEmployeRecu.bactif == 0) {
    bactif = false  
  }
  if (!Array.isArray(oEmployeRecu)) {
    aoEmployeRecu.push(oEmployeRecu)    
  } else {
    aoEmployeRecu = oEmployeRecu   
  }
  //console.log(aoEmployeRecu)
  for (let i=0; i<aoEmployeRecu.length; i++) {
    //On regarde si cet employé est déjà dans les employés concernés
    const idEmployeRecu = aoEmployeRecu[i].idemploye
    let btrouve = false
    for (let j=0; j<lesDatas.affaire.employeConcerne.length; j++) {
      if (lesDatas.affaire.employeConcerne[j].idemploye == idEmployeRecu) {
        btrouve = true
      }
    }

    if (!btrouve) {
      const oEmployeConcernePlus = {
        "idemploye": idEmployeRecu,
        "bactif": bactif,
        "nom": `${aoEmployeRecu[i].nom} ${aoEmployeRecu[i].prenom}`,
        "uniteorg": aoEmployeRecu[i].unite,
        "idrole": roledefaut.value.toString(),
        "datedebutparticipe": '',
        "datefinparticipe": '',
        "commentaire": '',
      }
      lesDatas.affaire.employeConcerne.push(oEmployeConcernePlus)
    } else {
      lesDatas.messagesErreur.messageSnackbar = `Cet employe "${aoEmployeRecu[i].nom} ${aoEmployeRecu[i].prenom}" fait déjà partie des employés concernés`
      lesDatas.messagesErreur.bSnackbar = true
    }
  }
}

const supprimeLienEmploye = (index) => {
  lesDatas.affaire.employeConcerne.splice(index, 1)
}
</script>