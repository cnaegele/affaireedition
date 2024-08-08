import { ref } from 'vue'
import axios from 'axios'
let g_devurl = ''
if (import.meta.env.DEV) {
    g_devurl = 'https://mygolux.lausanne.ch'    
}
const g_pathurl = '/goeland/affaire2/axios/'

export async function getDataUserInfo(groupeSecurite, lesDatas) {
    const urlui = `${g_devurl}/goeland/gestion_spec/g_login_f5.php`
    const params = new URLSearchParams([['groupesecurite', groupeSecurite]])
    const response = await axios.get(urlui, { params })
        .catch(function (error) {
            traiteAxiosError(error, lesData)
        })   
    const userInfo = response.data
    lesDatas.user.idEmployeUser = ref(userInfo.id_employe)
    lesDatas.user.nomEmployeUser = ref(userInfo.nom_employe)
    lesDatas.user.prenomEmployeUser = ref(userInfo.prenom_employe)
    lesDatas.user.loginEmployeUser = ref(userInfo.login_employe)
    lesDatas.user.groupeSecurite = ref(userInfo.groupesecurite)
    lesDatas.user.bInGroupe = ref(userInfo.bingroupe)
}

export async function getAffaireData(prmIdAffaire, affaireDatas) {
    const urlad = `${g_devurl}${g_pathurl}affaire_data.php`
    const params = new URLSearchParams([['idaffaire', prmIdAffaire]])
    const response = await axios.get(urlad, { params })
        .catch(function (error) {
            return traiteAxiosError(error)
        })
    const oResponse = response.data
    console.log(oResponse)
    affaireDatas.id = ref(oResponse.IdAffaire)
    affaireDatas.type = ref(oResponse.Type)
    affaireDatas.nom = ref(oResponse.Nom)
    affaireDatas.description = ref(oResponse.Description)

    //acteurs concernés
    let aoActeurConcInp = [] , aoActeurConcOut = [], oActeurConcOut
    let ac_idAcRole, ac_idActeur, ac_bactif, ac_nomActeur, ac_idRole, ac_role, ac_commentaire
    if (oResponse.hasOwnProperty('AcR')) {
        if (!Array.isArray(oResponse.AcR)) {
            aoActeurConcInp.push(oResponse.AcR)    
        } else {
            aoActeurConcInp = oResponse.AcR    
        }
        for (let i=0; i<aoActeurConcInp.length; i++) {
            ac_idAcRole = aoActeurConcInp[i].AcRId    
            ac_idActeur = aoActeurConcInp[i].AcRIdActeur
            if (aoActeurConcInp[i].AcRBActif == 1) {
                ac_bactif = true    
            } else {
                ac_bactif = false    
            }  
            ac_nomActeur = aoActeurConcInp[i].AcRNomActeur    
            ac_idRole = aoActeurConcInp[i].AcRIdRoleActeur    
            ac_role = aoActeurConcInp[i].AcRRoleActeur
            if (aoActeurConcInp[i].hasOwnProperty('AcRCommentaire')) {
                ac_commentaire = aoActeurConcInp[i].AcRCommentaire
            } else {
                ac_commentaire = ''    
            }
            oActeurConcOut = {
                idacrole: ac_idAcRole,
                idacteur: ac_idActeur,
                bactif: ac_bactif,
                nom: ac_nomActeur,
                idrole: ac_idRole,
                role: ac_role,
                commentaire: ac_commentaire, 
            }
            aoActeurConcOut.push(oActeurConcOut) 
        }
    }
    affaireDatas.acteurConcerne = ref(aoActeurConcOut)
}


function traiteAxiosError(error) {
    if (error.response) {
        return `${error.response.data}<br>${error.response.status}<br>${error.response.headers}`    
    } else if (error.request.responseText) {
        return error.request.responseText
    } else {
        return error.message
    }
}