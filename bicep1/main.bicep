targetScope = 'resourceGroup'

// Parameters
@description('Environnement (dev, uat, prod)')
param environment string

// Parameters
@description('Mode opératoire (Report, Set)')
param mode string

//@description('Région de déploiement')
//param location string = 'canadacentral'

@description('Préfixe pour les ressources')
param prefix string

// Import de la configuration
module config 'config.bicep' = {
  name: 'configuration'
  params: {
    environment: environment
    prefix: prefix
  }
}

// Variables pour les noms de déploiement
var deploymentNames = {
  keyVault: 'keyVaultDeployment'
  managedIdentity: 'managedIdentityDeployment'
  logicApp: 'logicAppDeployment'
  apiConnection: 'apiConnectionDeployment'
  automation: 'automationDeployment'
  scriptSrorage:'scriptStorageDeployment'
  alert:'alertDeployment'
}

// Modules
module keyVault 'modules/keyvault.bicep' = {
  name: deploymentNames.keyVault
  params: {
    //location: location
    keyVaultName: config.outputs.names.keyVault
    prefix:prefix
    //environment: environment
    //tags: config.outputs.tags
  }
}


module managedIdentity 'modules/managedIdentity.bicep' = {
  name: deploymentNames.managedIdentity
  params: {
    identityName: config.outputs.names.managedIdentity
    prefix:prefix
  }
}

module pwshScript 'modules/scriptstorage.bicep'={
  name: deploymentNames.scriptSrorage
  params: {
     storageAccountName:config.outputs.names.scriptStorageAccount
     containerName:config.outputs.names.scriptStorageAccountContainer
     blobName:config.outputs.names.scriptSotrageAccountContainerPwshFile
     prefix:prefix
  }
}

output sas string =pwshScript.outputs.sasUrl


module automation 'modules/automation.bicep' = {
name: deploymentNames.automation
params: {
  managedIdentityId:managedIdentity.outputs.identityId
  principalID:managedIdentity.outputs.principalId
  location: config.outputs.config.location
  automationAccountName: config.outputs.names.automation
  pwshURI:pwshScript.outputs.sasUrl
  sku: config.outputs.config.sku.automation
  tags: config.outputs.tags
}
}

module apiConnection 'modules/api-connection.bicep' = {
  name: deploymentNames.apiConnection
  params: {
   location:config.outputs.config.location
   keyvaultname:config.outputs.names.keyVault
   servicebusLink:config.outputs.config.serviceBuslink
  
  }
}



module logicApp 'modules/logicApp.bicep' = {
  name: deploymentNames.logicApp
  params: {
    location: config.outputs.config.location
    logicAppName: config.outputs.names.logicApp
    managedIdentityId: managedIdentity.outputs.identityId
    GINApplication:config.outputs.config.GINApplication
    GINApplicationsecretname:config.outputs.config.GINApplicationsecretname
    GINScope:config.outputs.config.GINScope
    GraphApplication:config.outputs.config.GraphApplication
    GraphApplicationsecretname:config.outputs.config.GraphApplicationsecretname
    modeOperatoire:mode
    AutomationAccount_automationName: config.outputs.names.automation
    AutomationAccount_Runnbook: automation.outputs.Runbook
    Default_Quota_group: config.outputs.names.Default_Quota_group
    Storage:config.outputs.names.scriptStorageAccount
    GINEndpoint:config.outputs.config.GinEndpoint
 

  
  }
}

module alert 'modules/alert.bicep' = {
  name: deploymentNames.alert
  params: {
    logicAppScope: logicApp.outputs.logicAppScope
    emailAddress: config.outputs.config.email

  }
}

output automationAccountPrincipalId string = automation.outputs.automationAccountPrincipalId

