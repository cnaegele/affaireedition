
<template>
    <v-row v-if="afficheChoixActeur" class="border-solid border-1">
      <v-col cols="12" md="12">
        <span v-if="modeChoixActeurConc == 'unique'">Choisir un acteur</span>
        <span v-else>Choisir des acteurs</span>
        &nbsp;&nbsp;&nbsp;&nbsp;
        <v-btn
          rounded="lg"
          @click="quitteChoixActeurConcerne()"
        >QUITTER</v-btn>
        <ActeurChoix 
          critereTypeInit="nom"
          nombreMaximumRetour="50"
          :modeChoix="modeChoixActeurConc"
          @choixActeur="receptionActeurConc"
        >
        </ActeurChoix>
      </v-col>
    </v-row>

    <v-row>
      <v-col cols="12" md="12">
        <v-expansion-panels v-model="panelActeurConcerne">
          <v-expansion-panel>
            <v-expansion-panel-title>
              <span class="titreChampSaisie">
                Acteurs concernés ({{ lesDatas.affaire.acteurConcerne.length }})&nbsp;
                <v-tooltip text="ajouter un acteur concerné">
                  <template v-slot:activator="{ props }">
                    <v-btn
                      v-bind="props"
                      rounded="lg"
                      @click.stop="choixActeurConcerne('unique')"
                    >+1</v-btn>
                  </template>        
                </v-tooltip>
                &nbsp;
                <v-tooltip text="ajouter plusieurs acteurs concernés">
                  <template v-slot:activator="{ props }">
                    <v-btn class="text-lowercase"
                      v-bind="props"
                      rounded="lg"
                      @click.stop="choixActeurConcerne('multiple')"
                    >+n</v-btn>
                  </template>        
                </v-tooltip>
              </span> 
            </v-expansion-panel-title>
            <v-expansion-panel-text>
              <v-container>
                <v-row v-for="(acteurConcerne, index) in lesDatas.affaire.acteurConcerne" :key="acteurConcerne.idacrole" class="d-flex align-center">
                 <v-col cols="12" md="3">
                    {{ acteurConcerne.nom }}
                  </v-col>
                  <v-col cols="12" md="3">
                    <v-select
                      v-model="lesDatas.affaire.acteurConcerne[index].idrole"
                      :items="rolesdisp"
                      label="rôle"
                      item-title="label"
                      :reduce="(item) => rolesdisp.value"
                      placeholder="Sélectionner un rôle"
                    ></v-select>                     
                  </v-col>
                  <v-col cols="12" md="4">
                    <v-text-field
                      label="commentaire"
                      v-model="lesDatas.affaire.acteurConcerne[index].commentaire"
                    ></v-text-field>
                  </v-col>
                  <v-col cols="12" md="2">
                    <v-tooltip text="information acteur">
                      <template v-slot:activator="{ props }">
                        <v-btn
                          v-bind="props"
                          icon="mdi-information"
                          variant="text"
                          @click="infoActeur(acteurConcerne.idacteur)"
                        ></v-btn>
                      </template>        
                    </v-tooltip>
                    <v-tooltip text="supprimer le lien acteur">
                      <template v-slot:activator="{ props }">
                        <v-btn
                          v-bind="props"
                          icon="mdi-delete"
                          variant="text"
                          @click="supprimeLienActeur(acteurConcerne.idacteur)"
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
import { defineProps, toRefs, ref } from 'vue'
import { data } from '@/stores/data.js'
import ActeurChoix from '../../../acteurchoix/src/components/ActeurChoix.vue'
const lesDatas = data()

const props = defineProps({
  rolesdisp: {
    type: Array,
    default() {
      return [
        {
          id: 10,
          label: 'Client',
          value: '10'
        },
        {
          id: 9,
          label: 'Concerné',
          value: '9'
        },
      ]
    }
  },
  roledefaut: {
    type: String,
    default() {
      return '9'
    }
  }
})
const { rolesdisp } = toRefs(props)
const { roledefaut } = toRefs(props)

const modeChoixActeurConc = ref('unique')
const panelActeurConcerne = ref([])
const afficheChoixActeur = ref(false)
const emit = defineEmits(['infoActeur']);
const infoActeur = (idActeur) => {
  emit('infoActeur', idActeur)
}

const choixActeurConcerne = (mode) => {
  if (!afficheChoixActeur.value) {
    modeChoixActeurConc.value = mode
    afficheChoixActeur.value = true
  }
}

const quitteChoixActeurConcerne = () => {
  afficheChoixActeur.value = false
}

const receptionActeurConc = (idacteur, jsonData) => {
  console.log(`Réception acteur(s). id: ${idacteur} \njson: ${jsonData}`)
  afficheChoixActeur.value = false
  panelActeurConcerne.value = [0]

  const oActeurRecu = JSON.parse(jsonData)
  let aoActeurRecu = []
  let bactif = true
  if (oActeurRecu.bactif == 0) {
    bactif = false  
  }
  if (!Array.isArray(oActeurRecu)) {
    aoActeurRecu.push(oActeurRecu)    
  } else {
    aoActeurRecu = oActeurRecu   
  }
  for (let i=0; i<aoActeurRecu.length; i++) {
    const oActeurConcernePlus = {
      "idacrole": 0,
      "idacteur": aoActeurRecu[i].acteurid,
      "bactif": bactif,
      "nom": aoActeurRecu[i].acteurnom,
      "idrole": roledefaut.value,
    }
    lesDatas.affaire.acteurConcerne.push(oActeurConcernePlus)
  }

}

</script>
