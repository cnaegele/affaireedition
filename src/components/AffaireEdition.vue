<template>
  <v-container>
    <AffaireIdType />
    <AffaireNom />
    <AffaireDescription />
    <AffaireActeursConcernes :rolesdisp="[
      { id: 9, label: 'Concerné.e', value: '9'},
      { id: 10, label: 'Client.e', value: '10'},
      ]" 
    />
  </v-container>     
</template>

<script setup>
import { defineProps } from 'vue'
import AffaireIdType from '@/components/AffaireIdType.vue'
import AffaireNom from '@/components/AffaireNom.vue'
import AffaireDescription from '@/components/AffaireDescription.vue'
import AffaireActeursConcernes from '@/components/AffaireActeursConcernes.vue'
import { data } from '@/stores/data.js'
import { getAffaireData } from '@/axioscalls.js'
const props = defineProps({
  affaireId: {
    type: Number
  }
})
const lesDatas = data()
const affaireId = props.affaireId
if (affaireId !== '') {
  console.log(affaireId)
  await getAffaireData(affaireId, lesDatas.affaire)
}
</script>