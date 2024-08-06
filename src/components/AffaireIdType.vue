<template>
    <v-row dense>
        <v-col cols="12" md="1" class="titreChampInfo">Id / Type</v-col>
        <v-col cols="12" md="11">{{ lesDatas.affaire.id }} / {{ lesDatas.affaire.type }}</v-col>
    </v-row>
</template>

<script setup>
    import { data } from '@/stores/data.js'
    const lesDatas = data()
</script>