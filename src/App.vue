<template>
  <v-app>
    <v-main>
      <div><Suspense><UserInformation groupeSecurite="AffaireManager"></UserInformation></Suspense></div>
      <div v-if="lesDatas.user.bInGroupe == 0">
        Utilisation autoris&eacute;e uniquement aux membres du groupe {{ lesDatas.user.groupeSecurite }}
      </div>
      <div v-if="lesDatas.user.bInGroupe == 1">
              <h2 style="text-align: center;">Edition affaire</h2>
         <Suspense><AffaireEdition :affaireId="prmIdAffaire" /></Suspense>
        
      </div>
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
