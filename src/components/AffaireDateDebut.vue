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
                    id="inpDateDebut"
                    class="go_input"
                    v-model="lesDatas.affaire.gen.dateDebut"
                    @keyup="inpDateDebutkeyup"
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

const inpDateDebutkeyup = () => {
    //Avec les input de type date standard du html, 
    //On peut saisir au clavier des dates invalides (31 février par exemple).
    //Mais alors la value du input est vide donc la variable v-model aussi 
    //Du coup, il faut vérifier le validity.badInput le l'objet input de type date si on veut indiquer date invalide
    //qui de toute façon ve na pas être passée plus loin mais dans ce cas, la vue à l'écran ne correspond pas à la valeur 
    //effective de la date qui est vide.
    const inpDate = document.getElementById('inpDateDebut')
    if (inpDate.validity.badInput) {
        lesDatas.controle.bdataGenDateDebutOK = false
        lesDatas.messagesErreur.dateDebut = 'la date de date de fin est invalide'
    } else if (!lesDatas.controle.bdataGenDateFinOK) {
        lesDatas.controle.bdataGenDateDebutOK = true
        lesDatas.messagesErreur.dateDebut = ''
    }
}

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