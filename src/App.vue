<template>
  <v-app>
    <v-snackbar
      color="#FFCDD2"
      location="center"
      v-model="lesDatas.messagesErreur.bSnackbar"
      :timeout="lesDatas.messagesErreur.timeOutSnackbar"
    >
      {{ lesDatas.messagesErreur.messageSnackbar }}
      <template v-slot:actions>
        <v-btn
          text="Fermer"
          variant="tonal"
         @click="lesDatas.messagesErreur.bSnackbar = false"
        ></v-btn>
      </template>
    </v-snackbar>

    <v-main>
      <Suspense><AffaireEdition :affaireId="prmIdAffaire" /></Suspense>
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
