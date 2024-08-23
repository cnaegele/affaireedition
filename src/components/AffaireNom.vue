<template>
    <v-row dense>
        <v-col cols="12" md="2" class="titreChampSaisie">{{ label }}</v-col>
        <v-col cols="12" md="10">
            <v-text-field
                v-model="lesDatas.affaire.nom"
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

watch(() => lesDatas.affaire.nom, () => {
    console.log(`nom : ${lesDatas.affaire.nom}`)
})
</script>