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

export async function getAffaireDroitUtilisateur(prmIdAffaire, droitUtilisateur) {
    const urladu = `${g_devurl}${g_pathurl}affaire_droit_utilisateur.php`
    const params = new URLSearchParams([['idaffaire', prmIdAffaire]])
    const response = await axios.get(urladu, { params })
        .catch(function (error) {
            return traiteAxiosError(error)
        })
    const oResponse = response.data
    droitUtilisateur.value = oResponse.droit
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
    affaireDatas.gen.id = ref(oResponse.IdAffaire)
    affaireDatas.gen.type = ref(oResponse.Type)
    affaireDatas.gen.nom = ref(oResponse.Nom)
    if (oResponse.hasOwnProperty('Description')) {
        affaireDatas.gen.description = ref(oResponse.Description)
    } else {
        affaireDatas.gen.description = ref('')    
    }
    if (oResponse.hasOwnProperty('Commentaire')) {
        affaireDatas.gen.commentaire = ref(oResponse.Commentaire)
    } else {
        affaireDatas.gen.commentaire = ref('')    
    }
    affaireDatas.gen.dateDebut = ref(`${oResponse.DateDebut.substring(6,10)}-${oResponse.DateDebut.substring(3,5)}-${oResponse.DateDebut.substring(0,2)}`)
    if (oResponse.hasOwnProperty('DateFin')) {
        affaireDatas.gen.dateFin = ref(`${oResponse.DateFin.substring(6,10)}-${oResponse.DateFin.substring(3,5)}-${oResponse.DateFin.substring(0,2)}`)
    } else {
        affaireDatas.gen.dateFin = ref('')    
    }
    if (oResponse.BTermine === '0') {
        affaireDatas.gen.bTermine = false   
    } else {
        affaireDatas.gen.bTermine = true   
    }

    let dummydate

    //employés concernés
    let aoEmployeConcInp = [] , aoEmployeConcOut = [], oEmployeConcOut
    let empc_idEmploye, empc_bactif, empc_nom, empc_uniteOrg, empc_idRole, empc_role, empc_dateDebutParticipe, empc_dateFinParticipe, empc_commentaire
    if (oResponse.hasOwnProperty('Emp')) {
        if (!Array.isArray(oResponse.Emp)) {
            aoEmployeConcInp.push(oResponse.Emp)    
        } else {
            aoEmployeConcInp = oResponse.Emp    
        }
        for (let i=0; i<aoEmployeConcInp.length; i++) {
            empc_idEmploye = aoEmployeConcInp[i].EmpId
            if (aoEmployeConcInp[i].EmpBActif == 1) {
                empc_bactif = true    
            } else {
                empc_bactif = false    
            }
            empc_nom = aoEmployeConcInp[i].EmpNom  
            empc_uniteOrg = aoEmployeConcInp[i].EmpUniteOrg  
            empc_idRole = aoEmployeConcInp[i].EmpIdRole    
            empc_role = aoEmployeConcInp[i].EmpRole
            if (aoEmployeConcInp[i].hasOwnProperty('EmpDateDebParticipation')) {
                dummydate = aoEmployeConcInp[i].EmpDateDebParticipation
                empc_dateDebutParticipe = `${dummydate.substring(6,10)}-${dummydate.substring(3,5)}-${dummydate.substring(0,2)}`
            } else {
                empc_dateDebutParticipe = ''    
            }
            if (aoEmployeConcInp[i].hasOwnProperty('EmpDateFinParticipation')) {
                dummydate = aoEmployeConcInp[i].EmpDateFinParticipation
                empc_dateFinParticipe = `${dummydate.substring(6,10)}-${dummydate.substring(3,5)}-${dummydate.substring(0,2)}`
            } else {
                empc_dateFinParticipe = ''    
            }
            if (aoEmployeConcInp[i].hasOwnProperty('EmpCommentaire')) {
                empc_commentaire = aoEmployeConcInp[i].EmpCommentaire
            } else {
                empc_commentaire = ''    
            }
            oEmployeConcOut = {
                idemploye: empc_idEmploye,
                bactif: empc_bactif,
                nom: empc_nom,
                uniteorg: empc_uniteOrg,
                idrole: empc_idRole,
                role: empc_role,
                datedebutparticipe: empc_dateDebutParticipe,
                datefinparticipe: empc_dateFinParticipe,
                commentaire: empc_commentaire,
            }
            aoEmployeConcOut.push(oEmployeConcOut) 
        }
        affaireDatas.employeConcerne = ref(aoEmployeConcOut)        
    }
    //console.log(affaireDatas.employeConcerne)


    //unités organisationnelles concernée 
    let aoUniteOrgConcInp = [] , aoUniteOrgConcOut = [], oUniteOrgConcOut
    let uoc_idUniteOrg, uoc_bactif, uoc_nomUniteOrg, uoc_descTreeUniteOrg, uoc_idRole, uoc_role, uoc_dateDebutParticipe, uoc_dateFinParticipe, uoc_commentaire
    if (oResponse.hasOwnProperty('UO')) {
        if (!Array.isArray(oResponse.UO)) {
            aoUniteOrgConcInp.push(oResponse.UO)    
        } else {
            aoUniteOrgConcInp = oResponse.UO    
        }
        for (let i=0; i<aoUniteOrgConcInp.length; i++) {
            uoc_idUniteOrg = aoUniteOrgConcInp[i].UOId
            if (aoUniteOrgConcInp[i].UOBActif == 1) {
                uoc_bactif = true    
            } else {
                uoc_bactif = false    
            }  
            uoc_nomUniteOrg = aoUniteOrgConcInp[i].UONom    
            if (aoUniteOrgConcInp[i].hasOwnProperty('UODescTree')) {
                uoc_descTreeUniteOrg = aoUniteOrgConcInp[i].UODescTree
            } else {
                uoc_descTreeUniteOrg = ''    
            }
            uoc_idRole = aoUniteOrgConcInp[i].UOIdRole    
            uoc_role = aoUniteOrgConcInp[i].UORole
            if (aoUniteOrgConcInp[i].hasOwnProperty('UODateDebParticipation')) {
                dummydate = aoUniteOrgConcInp[i].UODateDebParticipation
                uoc_dateDebutParticipe = `${dummydate.substring(6,10)}-${dummydate.substring(3,5)}-${dummydate.substring(0,2)}`
            } else {
                uoc_dateDebutParticipe = ''    
            }
            if (aoUniteOrgConcInp[i].hasOwnProperty('UODateFinParticipation')) {
                dummydate = aoUniteOrgConcInp[i].UODateFinParticipation
                uoc_dateDebutParticipe = `${dummydate.substring(6,10)}-${dummydate.substring(3,5)}-${dummydate.substring(0,2)}`
            } else {
                uoc_dateFinParticipe = ''    
            }
            if (aoUniteOrgConcInp[i].hasOwnProperty('UOCommentaire')) {
                uoc_commentaire = aoUniteOrgConcInp[i].UOCommentaire
            } else {
                uoc_commentaire = ''    
            }
            oUniteOrgConcOut = {
                iduniteorg: uoc_idUniteOrg,
                bactif: uoc_bactif,
                nomuo: uoc_nomUniteOrg,
                desctreeuo: uoc_descTreeUniteOrg,
                idrole: uoc_idRole,
                role: uoc_role,
                datedebutparticipe: uoc_dateDebutParticipe,
                datefinparticipe: uoc_dateFinParticipe,
                commentaire: uoc_commentaire,
            }
            aoUniteOrgConcOut.push(oUniteOrgConcOut) 
        }
    }
    affaireDatas.uniteOrgConcerne = ref(aoUniteOrgConcOut)

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

export async function sauveDataGen(lesDatas) {
    const jdata = JSON.stringify(lesDatas.affaire.gen)
    console.log(jdata)
    const urlsdg = `${g_devurl}${g_pathurl}affaire_datagenerique_sauve.php`
    const response = await axios.post(urlsdg, jdata, {
        headers: {
            'Content-Type': 'application/json'
        }
    })
     .catch(function (error) {
        lesDatas.messagesErreur.serverbackend = ref(traiteAxiosError(error))
    })      
    console.log(response.data)
    //if (response.data.message.indexOf('ERREUR') == 0) {
    //    lesDatas.messagesErreur.serverbackend = ref(response.data.message)   
    //}
}
export async function sauveEmployeConcerne(lesDatas) {
    const dataAffaireEmployeConcerne = {
        idAffaire: lesDatas.affaire.gen.id,
        employesConcernes: lesDatas.affaire.employeConcerne
    }
    const jdata = JSON.stringify(dataAffaireEmployeConcerne)
    console.log(jdata)
    const urlsemc = `${g_devurl}${g_pathurl}affaire_employeconc_sauve.php`
    const response = await axios.post(urlsemc, jdata, {
        headers: {
            'Content-Type': 'application/json'
        }
    })
     .catch(function (error) {
        lesDatas.messagesErreur.serverbackend = ref(traiteAxiosError(error))
    })      
    console.log(response.data)
    //if (response.data.message.indexOf('ERREUR') == 0) {
    //    lesDatas.messagesErreur.serverbackend = ref(response.data.message)   
    //}
}

export async function sauveUniteOrgConcerne(lesDatas) {
    const dataAffaireUniteOrgConcerne = {
        idAffaire: lesDatas.affaire.gen.id,
        unitesOrgConcernes: lesDatas.affaire.uniteOrgConcerne
    }
    const jdata = JSON.stringify(dataAffaireUniteOrgConcerne)
    console.log(jdata)
    const urlsuoc = `${g_devurl}${g_pathurl}affaire_uniteorgconc_sauve.php`
    const response = await axios.post(urlsuoc, jdata, {
        headers: {
            'Content-Type': 'application/json'
        }
    })
     .catch(function (error) {
        lesDatas.messagesErreur.serverbackend = ref(traiteAxiosError(error))
    })      
    console.log(response.data)
    //if (response.data.message.indexOf('ERREUR') == 0) {
    //    lesDatas.messagesErreur.serverbackend = ref(response.data.message)   
    //}
}

export async function sauveActeurConcerne(lesDatas) {
    const dataAffaireActeurConcerne = {
        idAffaire: lesDatas.affaire.gen.id,
        acteursConcernes: lesDatas.affaire.acteurConcerne
    }
    const jdata = JSON.stringify(dataAffaireActeurConcerne)
    const urlsaac = `${g_devurl}${g_pathurl}affaire_acteurconc_sauve.php`
    const response = await axios.post(urlsaac, jdata, {
        headers: {
            'Content-Type': 'application/json'
        }
    })
     .catch(function (error) {
        lesDatas.messagesErreur.serverbackend = ref(traiteAxiosError(error))
    })      
    console.log(response.data)
    //if (response.data.message.indexOf('ERREUR') == 0) {
    //    lesDatas.messagesErreur.serverbackend = ref(response.data.message)   
    //}
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