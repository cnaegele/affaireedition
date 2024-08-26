import { data } from '@/stores/data.js'
import { sauveDataGen, sauveUniteOrgConcerne, sauveActeurConcerne } from '@/axioscalls.js'

export const demandeSauveData = async (provenance) => {
    const lesDatas = data()

    if (lesDatas.controle.dataGenChange && provenance == 'general') {
        await sauveDataGen(lesDatas)
        lesDatas.controle.dataGenChange = false
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
        if (value === true) {
            nbrCtrl2Change++    
        }
    }
    if (nbrCtrl2Change == 1) {
        //rien d'autre à sauver
        lesDatas.controle.dataChange = false
    }
}