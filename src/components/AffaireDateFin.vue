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
                    id="inpDateFin"
                    class="go_input"
                    v-model="lesDatas.affaire.gen.dateFin"
                    @keyup="inpDateFinkeyup"
                ></input>
                <span class="go-erreur">&nbsp;&nbsp;&nbsp;&nbsp;{{ lesDatas.messagesErreur.dateFin }}</span>
            </div>
        </v-col>
    </v-row>
</template>

<script setup>
import { ref, watch } from 'vue'
import { data } from '@/stores/data.js'
import {bDateValid, bDateFutur} from '../../../cnlib/cnutils.js'
const lesDatas = data()
const props = defineProps({
    label: {
        type: String,
        default: "Fin de l'affaire"
    }
})

const inpDateFinkeyup = () => {
    //Avec les input de type date standard du html, 
    //On peut saisir au clavier des dates invalides (31 février par exemple).
    //Mais alors la value du input est vide donc la variable v-model aussi 
    //Du coup, il faut vérifier le validity.badInput le l'objet input de type date si on veut indiquer date invalide
    //qui de toute façon ve na pas être passée plus loin mais dans ce cas, la vue à l'écran ne correspond pas à la valeur 
    //effective de la date qui est vide.
    const inpDate = document.getElementById('inpDateFin')
    if (inpDate.validity.badInput) {
        lesDatas.controle.bdataGenDateFinOK = false
        lesDatas.messagesErreur.dateFin = 'la date de date de fin est invalide'
    } else if (!lesDatas.controle.bdataGenDateFinOK) {
        lesDatas.controle.bdataGenDateFinOK = true
        lesDatas.messagesErreur.dateFin = ''
    }
}

watch(() => lesDatas.affaire.gen.dateFin, () => {
    //Comme on utilise pas un composant vuetify
    //if faut faire l'equivalent des rules ici
    lesDatas.controle.bdataGenDateFinOK = true
    lesDatas.messagesErreur.dateFin = ''
    if (lesDatas.affaire.gen.dateFin !== '') {
        if (!bDateValid(lesDatas.affaire.gen.dateFin)) {
            lesDatas.messagesErreur.dateFin = 'la date de fin est invalide'
            lesDatas.controle.bdataGenDateFinOK = false
        }
        if (lesDatas.affaire.gen.dateDebut === '' || lesDatas.affaire.gen.dateDebut > lesDatas.affaire.gen.dateFin) {
            lesDatas.controle.bdataGenDateFinOK = false
            lesDatas.messagesErreur.dateFin = 'la date de début doit être antérieure à la date de fin'
        }
        if (!bDateFutur(lesDatas.affaire.gen.dateFin)) {
            lesDatas.affaire.gen.bTermine = true
        } else {
            lesDatas.affaire.gen.bTermine = false    
        }
    } else {
        lesDatas.affaire.gen.bTermine = false    
    }
    lesDatas.controle.dataGenChange = true
    lesDatas.controle.dataChange = true
})
</script>