<template>
    <AffaireIdType />
    <AffaireNom />
    <AffaireDescription />
</template>

<script setup>
import { defineProps } from 'vue'
import AffaireIdType from '@/components/AffaireIdType.vue'
import AffaireNom from '@/components/AffaireNom.vue'
import AffaireDescription from '@/components/AffaireDescription.vue'
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