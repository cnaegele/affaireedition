<template>
    <v-app-bar
        color="primary"
        prominent
        density="compact"
        app
    >
    <v-app-bar-nav-icon></v-app-bar-nav-icon>

    <v-toolbar-title>Edition affaire</v-toolbar-title>

    <v-spacer></v-spacer>
    <div style="position: absolute; right: 16px;">
    <Suspense><UserInformation groupeSecurite="AffaireManager"></UserInformation></Suspense>
    </div>

    <!--
    <v-btn icon>
        <v-icon>mdi-magnify</v-icon>
    </v-btn>

    <v-btn icon>
        <v-icon>mdi-heart</v-icon>
    </v-btn>

    <v-btn icon>
        <v-icon>mdi-dots-vertical</v-icon>
    </v-btn>
    -->
    </v-app-bar>
</template>