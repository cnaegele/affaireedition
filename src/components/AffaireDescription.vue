<template>
    <v-row dense>
        <v-col cols="12" md="2" class="titreChampSaisie">{{ label }}</v-col>
        <v-col cols="12" md="10">
            <v-textarea
                v-model="lesDatas.affaire.gen.description"
                rows="1"
                auto-grow
            ></v-textarea>                        
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
        default: 'Description'
    }
})

watch(() => lesDatas.affaire.gen.description, () => {
    lesDatas.controle.dataGenChange = true
    lesDatas.controle.dataChange = true
})
</script>