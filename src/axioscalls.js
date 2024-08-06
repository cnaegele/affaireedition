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