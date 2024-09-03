import { data } from '@/stores/data.js'
import { sauveDataGen, sauveEmployeConcerne, sauveUniteOrgConcerne, sauveActeurConcerne } from '@/axioscalls.js'

export const demandeSauveData = async (provenance) => {
    const lesDatas = data()

    if (lesDatas.controle.dataGenChange && provenance == 'general') {
        if (lesDatas.bdataGenOK) {
            lesDatas.affaire.gen.nom = lesDatas.affaire.gen.nom.trim()
            lesDatas.affaire.gen.description = lesDatas.affaire.gen.description.trim()
            lesDatas.affaire.gen.commentaire = lesDatas.affaire.gen.commentaire.trim()
            await sauveDataGen(lesDatas)
            lesDatas.controle.dataGenChange = false
        } else {
            alert("Il faut corriger les données invalides avant de pouvoir sauver !")
        }
    }
    
    if (lesDatas.controle.dataEmployeConcChange && (provenance == 'general' || provenance == 'employe')) {
        await sauveEmployeConcerne(lesDatas)
        lesDatas.controle.dataEmployeConcChange = false
    }

    if (lesDatas.controle.dataUniteOrgConcChange && (provenance == 'general' || provenance == 'uniteorg')) {
        await sauveUniteOrgConcerne(lesDatas)
        lesDatas.controle.dataUniteOrgConcChange = false
    }
    
    if (lesDatas.controle.dataActeurConcChange && (provenance == 'general' || provenance == 'acteur')) {
        await sauveActeurConcerne(lesDatas)
        lesDatas.controle.dataActeurConcChange = false
    }
    
    let nbrCtrl2Change = 0
    for (const [key, value] of Object.entries(lesDatas.controle)) {
        if ( key.indexOf('Change') > 1 &&  value === true) {
            nbrCtrl2Change++    
        }
    }
    if (nbrCtrl2Change == 1) {
        //rien d'autre à sauver
        lesDatas.controle.dataChange = false
    }
}