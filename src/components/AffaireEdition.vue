<template>
  <AppToper />
  <div v-if="lesDatas.user.bInGroupe == 0">
        Utilisation autoris&eacute;e uniquement aux membres du groupe {{ lesDatas.user.groupeSecurite }}
  </div>
  <div v-if="lesDatas.user.bInGroupe == 1">
    <v-container v-if="droitUtilisateur == 'CONTROLETOTAL' || droitUtilisateur == 'EDITION'">
      <AffaireIdType />
      <AffaireNom />
      <AffaireDescription />
      <AffaireCommentaire />
      <AffaireEtat />
      <AffaireDateDebut />
      <AffaireDateFin />
      <AffaireEmployesConcernes />  
      <AffaireUnitesOrgConcernes />  
      <AffaireActeursConcernes 
        @infoActeur="infoActeur"
        :rolesdisp="[
          { id: 9, label: 'Concerné.e', value: '9'},
          { id: 10, label: 'Client.e', value: '10'},
        ]"
      />
    </v-container>
  </div>
  <div class="messageErreur" v-else>
    <v-container>Vous n'avez pas le droit d'éditer cette affaire (id: {{ affaireId }})</v-container>
  </div>
  
  <v-dialog max-width="1280">
    <template v-slot:activator="{ props: activatorProps }">
      <div style="display: none;">
        <v-btn
          id="btnActiveCard"
          v-bind="activatorProps"
        ></v-btn>
      </div>
    </template>

    <template v-slot:default="isActive">
      <v-card>
        <v-card-actions>
          <span class="cardTitre">Informations détaillées</span>
          <v-spacer></v-spacer>
          <v-btn
            text="Fermer"
            variant="tonal"
            @click="closeCard"
          ></v-btn>
        </v-card-actions>
        <v-card-text>
          <div v-if="acteurConcIdInfo != '0'">
            <Suspense><ActeurData :acteurId="acteurConcIdInfo"></ActeurData></Suspense>  
          </div>
        </v-card-text>
      </v-card>
    </template>
  </v-dialog>
  
</template>

<script setup>
import { ref } from 'vue'
import AppToper from '@/components/AppToper.vue'
import AffaireIdType from '@/components/AffaireIdType.vue'
import AffaireNom from '@/components/AffaireNom.vue'
import AffaireDescription from '@/components/AffaireDescription.vue'
import AffaireCommentaire from '@/components/AffaireCommentaire.vue'
import AffaireEtat from '@/components/AffaireEtat.vue'
import AffaireDateDebut from '@/components/AffaireDateDebut.vue'
import AffaireDateFin from '@/components/AffaireDateFin.vue'
import AffaireEmployesConcernes from '@/components/AffaireEmployesConcernes.vue'
import AffairesUnitesOrgConcernes from '@/components/AffaireUnitesOrgConcernes.vue'
import AffaireActeursConcernes from '@/components/AffaireActeursConcernes.vue'
import ActeurData from '../../../acteurdata/src/components/ActeurData.vue'

import { data } from '@/stores/data.js'
import { getAffaireDroitUtilisateur } from '@/axioscalls.js'
import { getAffaireData } from '@/axioscalls.js'
const props = defineProps({
  affaireId: {
    type: Number
  }
})

const affaireId = props.affaireId
const droitUtilisateur = ref('NODROIT')
const lesDatas = data()

console.log(affaireId)

if (affaireId !== '') {
  await getAffaireDroitUtilisateur(affaireId, droitUtilisateur)
}

if (droitUtilisateur.value == 'CONTROLETOTAL' || droitUtilisateur.value == 'EDITION') {
  if (affaireId !== '') { 
    await getAffaireData(affaireId, lesDatas.affaire)
  }
}

const acteurConcIdInfo = ref('0')

const infoActeur = (acteurId) => {
  acteurConcIdInfo.value = acteurId.toString()
  document.getElementById("btnActiveCard").click() 
}
const closeCard = () => {
  acteurConcIdInfo.value = '0'
  document.getElementById("btnActiveCard").click()    
}

</script>