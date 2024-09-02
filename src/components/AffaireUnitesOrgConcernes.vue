<template>
    <v-row v-if="afficheChoixUniteOrg" class="border-solid border-1">
      <v-col cols="12" md="12">
        <span v-if="modeChoixUniteOrgConc == 'unique'">Choisir une unité organisationnelle</span>
        <span v-else>Choisir des unités organisationnelles</span>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <v-btn
          rounded="lg"
          @click="quitteChoixUniteOrgConcerne()"
        >QUITTER</v-btn>
        <Suspense>
            <UniteOrgChoix 
                uniteHorsVdL="non" 
                :modeChoix="modeChoixUniteOrgConc"
                @choixUniteOrg="receptionUniteOrg"
            />
        </Suspense>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12" md="12">
        <v-expansion-panels v-model="panelUniteOrgConcerne">
          <v-expansion-panel>
            <v-expansion-panel-title>
              <span class="titreChampSaisie">
                Unités organisationnelle concernés ({{ lesDatas.affaire.uniteOrgConcerne.length }})&nbsp;
                <v-tooltip text="ajouter une unité organisationnelle concernée">
                  <template v-slot:activator="{ props }">
                    <v-btn
                      v-bind="props"
                      rounded="lg"
                      @click.stop="choixUniteOrgConcerne('unique')"
                    >+1</v-btn>
                  </template>        
                </v-tooltip>
                &nbsp;
                <v-tooltip text="ajouter plusieurs unités organisationnelle concernées">
                  <template v-slot:activator="{ props }">
                    <v-btn class="text-lowercase"
                      v-bind="props"
                      rounded="lg"
                      @click.stop="choixUniteOrgConcerne('multiple')"
                    >+n</v-btn>
                  </template>        
                </v-tooltip>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <v-tooltip text="sauver les données unités organisationnelle concernés" v-if="lesDatas.controle.dataUniteOrgConcChange">
                  <template v-slot:activator="{ props }">
                      <v-btn
                          v-bind="props"
                          icon="mdi-database-arrow-left-outline"
                          @click.stop="demandeSauveData('uniteorg')"
                      />
                  </template>        
                </v-tooltip>
              </span> 
            </v-expansion-panel-title>
            <v-expansion-panel-text>  
              <v-container>
                <v-row v-for="(uniteOrgConcerne, index) in lesDatas.affaire.uniteOrgConcerne" :key="index" class="d-flex align-center">
                 <v-col cols="12" md="2">
                    {{ uniteOrgConcerne.nomuo }}
                  </v-col>
                  <v-col cols="12" md="2">
                    <v-select
                      v-model="lesDatas.affaire.uniteOrgConcerne[index].idrole"
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
                          v-model="lesDatas.affaire.uniteOrgConcerne[index].datedebutparticipe"
                        ></input>
                      </div>
                  </v-col>
                  <v-col cols="12" md="2" class="go_colsdate">
                      <div class="go_labeldate">fin participation</div> 
                      <div class="go_divdate">
                        <input
                          type="date"
                          class="go_inpdate"
                          v-model="lesDatas.affaire.uniteOrgConcerne[index].datefinparticipe"
                        ></input>
                      </div>
                  </v-col>
                  <v-col cols="12" md="3">
                    <v-text-field
                      label="commentaire"
                      v-model="lesDatas.affaire.uniteOrgConcerne[index].commentaire"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="12" md="1">
                    <v-tooltip text="supprimer le lien unité organisationelle">
                      <template v-slot:activator="{ props }">
                        <v-btn
                          v-bind="props"
                          icon="mdi-delete"
                          variant="text"
                          @click="supprimeLienUniteOrg(index)"
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
import UniteOrgChoix from '../../../uniteorgchoix/src/components/UniteOrgChoix.vue'
import { demandeSauveData } from '@/sauve.js'

const lesDatas = data()
const dateini = ref([null,null])

const props = defineProps({
  rolesdisp: {
    type: Array,
    default() {
      return [
        {
          id: 13,
          label: 'Concerné',
          value: '13'
        },
        {
          id: 2,
          label: 'Gestionnaire',
          value: '2'
        },
        {
          id: 7,
          label: 'Leader',
          value: '7'
        },
        {
          id: 1,
          label: 'Participe',
          value: '1'
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

watch(() => lesDatas.affaire.uniteOrgConcerne, () => {
  lesDatas.controle.dataUniteOrgConcChange = true
  lesDatas.controle.dataChange = true
}, { deep: true })

const modeChoixUniteOrgConc = ref('unique')
const panelUniteOrgConcerne = ref([])
const afficheChoixUniteOrg = ref(false)

const choixUniteOrgConcerne = (mode) => {
  if (!afficheChoixUniteOrg.value) {
    modeChoixUniteOrgConc.value = mode
    afficheChoixUniteOrg.value = true
  }
}

const quitteChoixUniteOrgConcerne = () => {
  afficheChoixUniteOrg.value = false
}

const receptionUniteOrg = (jsonData) => {
  console.log(`Réception unité organisationnelle \njson: ${jsonData}`)
  afficheChoixUniteOrg.value = false
  panelUniteOrgConcerne.value = [0]

  const oUniteOrgRecu = JSON.parse(jsonData)
  let aoUniteOrgRecu = []
  let bactif = true
  if (oUniteOrgRecu.bactif == 0) {
    bactif = false  
  }
  if (!Array.isArray(oUniteOrgRecu)) {
    aoUniteOrgRecu.push(oUniteOrgRecu)    
  } else {
    aoUniteOrgRecu = oUniteOrgRecu   
  }
  //console.log(aoUniteOrgRecu)
  for (let i=0; i<aoUniteOrgRecu.length; i++) {
    //On regarde si cette unité est déjà dans les unités organisationnelle concernées
    const idUniteOrgRecu = aoUniteOrgRecu[i].id
    let btrouve = false
    for (let j=0; j<lesDatas.affaire.uniteOrgConcerne.length; j++) {
      if (lesDatas.affaire.uniteOrgConcerne[j].iduniteorg == idUniteOrgRecu) {
        btrouve = true
      }
    }

    if (!btrouve) {
      const oUniteOrgConcernePlus = {
        "iduniteorg": idUniteOrgRecu,
        "bactif": bactif,
        "nomuo": aoUniteOrgRecu[i].description,
        "desctreeuo": '',
        "idrole": roledefaut.value.toString(),
        "datedebutparticipe": '',
        "datefinparticipe": '',
        "commentaire": '',
      }
      lesDatas.affaire.uniteOrgConcerne.push(oUniteOrgConcernePlus)
    } else {
      lesDatas.messagesErreur.messageSnackbar = `Cette unité organisationnelle "${aoUniteOrgRecu[i].description}" fait déjà partie des unités organisationnelle concernées`
      lesDatas.messagesErreur.bSnackbar = true
    }
  }
}

const supprimeLienUniteOrg = (index) => {
  lesDatas.affaire.uniteOrgConcerne.splice(index, 1)
}

</script>