<style scoped>
.go-erreur {
    font-size: small;
    color: rgb(177, 14, 14);
    vertical-align: bottom;
}
</style>

<template>
    <v-row >
        <v-col cols="12" md="2" class="titreChampSaisie">{{ label }}</v-col>
        <v-col cols="12" md="10">
            <div class="go_divdate">
                <input
                    type="date"
                    class="go_input"
                    v-model="lesDatas.affaire.gen.dateDebut"
                ></input>
                <span class="go-erreur">&nbsp;&nbsp;&nbsp;&nbsp;{{ lesDatas.messagesErreur.dateDebut }}</span>
            </div>
        </v-col>
    </v-row>
</template>

<script setup>
import { ref, watch } from 'vue'
import { data } from '@/stores/data.js'
const lesDatas = data()
const props = defineProps({
    label: {
        type: String,
        default: "Commencement de l'affaire"
    }
})

watch(() => lesDatas.affaire.gen.dateDebut, () => {
    //Comme on utilise pas un composant vuetify
    //if faut faire l'equivalent des rules ici
    lesDatas.controle.bdataGenDateDebutOK = true
    lesDatas.messagesErreur.dateDebut = ''
    if (lesDatas.affaire.gen.dateDebut === '') {
        lesDatas.controle.bdataGenDateDebutOK = false
        lesDatas.messagesErreur.dateDebut = 'la date est obligatoire'   
    } else {
        lesDatas.controle.bdataGenDateFinOK = true
        lesDatas.messagesErreur.dateFin = ''
        if (lesDatas.affaire.gen.dateFin !== '' && lesDatas.affaire.gen.dateDebut > lesDatas.affaire.gen.dateFin) {
            lesDatas.controle.bdataGenDateFinOK = false
            lesDatas.messagesErreur.dateFin = 'la date de début doit être antérieure à la date de fin'
        }
    }
    lesDatas.controle.dataGenChange = true
    lesDatas.controle.dataChange = true
})
</script>