<style scoped>
.custom-item {
  font-size: 15px;
}
</style>

<template>
    <v-app-bar
        color="primary"
        prominent
        density="compact"
        app
    >
        <v-app-bar-nav-icon @click="navdrawer = !navdrawer"></v-app-bar-nav-icon>

        <v-toolbar-title>Edition affaire</v-toolbar-title>
    
        <v-tooltip text="sauver les données" v-if="lesDatas.bdataGenOK && (lesDatas.controle.dataGenChange || lesDatas.controle.dataChange)">
            <template v-slot:activator="{ props }">
                <v-btn
                    v-bind="props"
                    icon="mdi-database-arrow-left-outline"
                    @click="demandeSauveData('general')"
                />
            </template>        
        </v-tooltip>
    
        <v-spacer></v-spacer>
        <div style="position: absolute; right: 16px;">
            <Suspense><UserInformation groupeSecurite="AffaireManager"></UserInformation></Suspense>
        </div>
    </v-app-bar>

    <v-navigation-drawer
        v-model="navdrawer"
        temporary
        @click.stop="navdrawer = !navdrawer"
      >
        <v-list density="compact">
            <v-list-item v-for="(mElem, index) in menuElements"
                :key="index"
                :value="mElem"
                @click.stop="clickMenu(mElem)"
            >
                <v-list-item-title class="custom-item">{{ mElem.title }}</v-list-item-title>
            </v-list-item>
        </v-list>
    </v-navigation-drawer>    
</template>

<script setup>
import { ref } from 'vue'
import { demandeSauveData } from '@/sauve.js'
import { data } from '@/stores/data.js'
import UserInformation from '@/components/UserInformation.vue'

const lesDatas = data()
const navdrawer = ref(false)
const menuElements = ref([
    {
        title: 'Sauver',
        value: 'sauve',
    },
    {
        title: 'Retour à la page de consultation',
        value: 'retourconsultation',
    },
])

const clickMenu = (mElem) => {
  const code = mElem.value
  console.log(code)

  switch (code) {
    case 'sauve':
        demandeSauveData('general')
        break;
    case 'retourconsultation':
        document.location.href = `https://mygolux.lausanne.ch/goeland/affaire2/affaire_data.php?idaffaire=${lesDatas.affaire.gen.id}`
        break;
  }
  navdrawer.value = false
}
</script>