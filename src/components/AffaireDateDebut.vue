<template>
    <v-row >
        <v-col cols="12" md="2" class="titreChampSaisie">{{ label }}</v-col>
        <v-col cols="12" md="10">
            <div class="go_divdate">
                <input
                    type="date"
                    class="go_input"
                    v-model="lesDatas.affaire.dateDebut"
                ></input>
            </div>
        </v-col>
    </v-row>
</template>

<script setup>
import { ref, defineProps, watch } from 'vue'
import { data } from '@/stores/data.js'
const lesDatas = data()
const props = defineProps({
    label: {
        type: String,
        default: "Commencement de l'affaire"
    }
})

watch(() => lesDatas.affaire.dateDebut, () => {
    console.log(`dateDebut : ${lesDatas.affaire.dateDebut}`)
})
</script>