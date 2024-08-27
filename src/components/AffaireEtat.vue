<style scoped>
.go-etattermine {
    color: red;
}
</style>

<template>
    <v-row dense>
        <v-col cols="12" md="2" class="titreChampInfo">{{ label }}</v-col>
        <v-col cols="12" md="10" v-if="!lesDatas.affaire.gen.bTermine">En cours</v-col>
        <v-col cols="12" md="10" class="go-etattermine" v-else>Terminée</v-col>
    </v-row>
</template>

<script setup>
    import { data } from '@/stores/data.js'
    const lesDatas = data()
    const props = defineProps({
    label: {
        type: String,
        default: 'Etat'
    }
})</script>