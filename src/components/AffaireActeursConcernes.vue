
<template>
    <v-row dense>
      <v-col cols="12" md="12">
        <v-expansion-panels>
          <v-expansion-panel>
            <v-expansion-panel-title>
              <span class="titreChampSaisie">Acteurs concernés ({{ lesDatas.affaire.acteurConcerne.length }})</span>
            </v-expansion-panel-title>
            <v-expansion-panel-text>
              <v-container>
                <v-row v-for="(acteurConcerne, index) in lesDatas.affaire.acteurConcerne" :key="acteurConcerne.idacrole">
                  <v-col>{{ acteurConcerne.nom }}</v-col>
                  <v-col>
                    <v-select
                      v-model="acteurConcerne.idrole"
                      :items="rolesdisp"
                      label="rôle"
                      item-title="label"
                      :reduce="(item) => rolesdisp.value"
                      placeholder="Sélectionner un rôle"
                    ></v-select>
                     
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
  }
})
const { rolesdisp } = toRefs(props)

console.log(props.rolesdisp)
console.log(lesDatas.affaire.acteurConcerne)


</script>
