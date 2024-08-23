<template>
  <v-app>
    <AppToper />

    <v-main>
      <div v-if="lesDatas.user.bInGroupe == 0">
        Utilisation autoris&eacute;e uniquement aux membres du groupe {{ lesDatas.user.groupeSecurite }}
      </div>
      <div v-if="lesDatas.user.bInGroupe == 1">
         <Suspense><AffaireEdition :affaireId="prmIdAffaire" /></Suspense>
      </div>
      <!--<div>{{ JSON.stringify(lesDatas) }}</div>-->
    </v-main>

    <AppFooter />
</v-app>
</template>

<script setup>
  import { ref } from 'vue'
  import { data } from '@/stores/data.js'
  import UserInformation from '@/components/UserInformation.vue'
  import AffaireEdition from '@/components/AffaireEdition.vue'
  const lesDatas = data()
  const urlParams = new URLSearchParams(window.location.search)
  const prmIdAffaire = ref(0)
  if (urlParams.has('idaffaire')) {
    prmIdAffaire.value = parseInt(urlParams.get('idaffaire'))
  }
</script>
