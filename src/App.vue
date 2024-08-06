<template>
  <v-app>
    <v-main>
      <div><Suspense><UserInformation groupeSecurite="AffaireManager"></UserInformation></Suspense></div>
      <div v-if="lesDatas.user.bInGroupe == 0">
        Utilisation autoris&eacute;e uniquement aux membres du groupe {{ lesDatas.user.groupeSecurite }}
      </div>
      <div v-if="lesDatas.user.bInGroupe == 1">
        <v-container>
          <v-row>
            <v-col cols="12" md="12">
              <h2>Edition affaire</h2>
            </v-col>
          </v-row>
          <Suspense><AffaireEdition :affaireId="prmIdAffaire" /></Suspense>
        </v-container>
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
