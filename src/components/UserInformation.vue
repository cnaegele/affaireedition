<template>
<v-row no-gutters class="d-flex align-center">
    <v-col cols="auto">
    Utilisateur : {{ lesDatas.user.prenomEmployeUser }} {{ lesDatas.user.nomEmployeUser }} / {{ lesDatas.user.loginEmployeUser }}
    </v-col>
    <v-col cols="auto">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</v-col>
    <v-col cols="auto">thème :&nbsp;</v-col>
    <v-col cols="auto">
    <v-select
        class="d-flex align-center"
        :items="['foncé', 'clair', 'goéland']"
        density="compact"
        height="20px"
        max-width="200px"
        v-model="themeAffiche"
        @update:model-value="choixTheme" 
    ></v-select>
    </v-col>
</v-row>
</template>
<script setup>
    import { ref } from 'vue'
    import { data } from '@/stores/data.js'
    import { getDataUserInfo } from '@/axioscalls.js'
    import { useTheme } from 'vuetify'
    
    const props = defineProps({
        groupeSecurite: {
            type: String,
            required: false
        }
    })
    const lesDatas = data()
    getDataUserInfo(props.groupeSecurite, lesDatas)
    let themeAffiche
    if (lesDatas.env.themeChoisi == 'dark') {
        themeAffiche = ref('foncé')    
    } else if (lesDatas.env.themeChoisi == 'light') {
        themeAffiche = ref('clair')   
    } else if (lesDatas.env.themeChoisi == 'goelandTheme') {
        themeAffiche = ref('goéland')   
    } else {
        themeAffiche = ref('foncé')   
    }
    const theme = useTheme()

    function choixTheme(value) {
        if (value == 'foncé') {
            lesDatas.env.themeChoisi = 'dark'
            theme.global.name.value = 'dark'
            localStorage.setItem('themeChoisi', 'dark')
        } else if (value == 'clair') {
            lesDatas.env.themeChoisi = 'light'    
            theme.global.name.value = 'light'
            localStorage.setItem('themeChoisi', 'light')
        } else if (value == 'goéland') {
            lesDatas.env.themeChoisi = 'goelandTheme'    
            theme.global.name.value = 'goelandTheme'
            localStorage.setItem('themeChoisi', 'goelandTheme')
        } else {
            lesDatas.env.themeChoisi = 'dark'    
            theme.global.name.value = 'dark'
            localStorage.setItem('themeChoisi', 'dark')
        }
    }    
</script>
