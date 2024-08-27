<template>
    <v-row dense>
        <v-col cols="12" md="2" class="titreChampSaisie">{{ label }}</v-col>
        <v-col cols="12" md="10">
            <v-text-field
                v-model="lesDatas.affaire.gen.nom"
                :rules="nomRules"
                required
            ></v-text-field>
        </v-col>
    </v-row>
</template>

<script setup>
import { watch } from 'vue'
import { data } from '@/stores/data.js'
const lesDatas = data()
const props = defineProps({
    label: {
        type: String,
        default: 'Nom'
    }
})

watch(() => lesDatas.affaire.gen.nom, () => {
    lesDatas.controle.dataGenChange = true
    lesDatas.controle.dataChange = true
})

const nomRules = [
    value => {
        if (value.trim().length >= 5) {
            lesDatas.controle.bdataGenNomOK = true
            console.log(lesDatas.bdataGenOK)
            return true
        }
        lesDatas.controle.bdataGenNomOK = false
        console.log(lesDatas.bdataGenOK)
        return 'Le nom est obligatoire et doit contenir au moins 5 caractères'
    }
]

</script>