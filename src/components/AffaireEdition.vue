<template>
    <AffaireIdType />
</template>

<script setup>
  import AffaireIdType from '@/components/AffaireIdType.vue'
  import { data } from '@/stores/data.js'
  import { getAffaireData } from '@/axioscalls.js'
  const props = defineProps({
    affaireId: String,
  })
  const lesDatas = data()
  const urlParams = new URLSearchParams(window.location.search)
  const affaireId = props.affaireId
  if (affaireId !== '') {
    console.log(affaireId)
    await getAffaireData(affaireId, lesDatas.affaire)
  }
</script>