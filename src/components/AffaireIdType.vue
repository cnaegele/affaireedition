<template>
    <v-row dense>
        <v-col cols="12" md="2" class="titreChampInfo">Id / Type</v-col>
        <v-col cols="12" md="10">{{ lesDatas.affaire.gen.id }} / {{ lesDatas.affaire.gen.type }}</v-col>
    </v-row>
</template>

<script setup>
    import { data } from '@/stores/data.js'
    const lesDatas = data()
</script>