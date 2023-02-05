// Title: Intune Device Information
// Description: The LogicApp creates a new custom table and is responsible to import Azure AD Device data enriched with Intune information. 
// GraphScopes: "Directory.Read.All", "DeviceManagementManagedDevices.Read.All", "DeviceManagementConfiguration.Read.All"

@description('Location for all resources (Leave default to use Resource group location).')
param regionOfResources string = resourceGroup().location


@description('Define the name of the LogicApp.')
param workflowName string = 'la-ExtendedDeviceInfo'

@description('Define the name of the LogicApp Conection to LogAnalytics.')
param connectionLaName string = 'lac-azureloganalyticsdatacollector'

@description('Name of the existing LogAnalytics Workspace where the data should be saved.')
param connectionLaWorkspaceName string = 'log-prod-sentinel'

@description('Name of the resource group of the LogAnalytic Workspace where the data should be saved.')
param connectionLaWorkspaceResourcegroup string = 'rg-general'



var connection_ala_type = 'azureloganalyticsdatacollector'

// Get a reference to the existing log analytics workspace
resource logAnalyticWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: connectionLaWorkspaceName
  scope: resourceGroup(connectionLaWorkspaceResourcegroup)
}

// Deploy resources

resource connectionLaName_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connectionLaName
  location: regionOfResources
  properties: {
    displayName: connectionLaName
    parameterValues: {
      username: logAnalyticWorkspace.properties.customerId
      password: listKeys(logAnalyticWorkspace.id, logAnalyticWorkspace.apiVersion).primarySharedKey
    }
    customParameterValues: {
    }
    nonSecretParameterValues: {
      
    }
    api: {
      name: connection_ala_type
      displayName: 'Azure Log Analytics Data Collector'
      description: 'Azure Log Analytics Data Collector will send data to any Azure Log Analytics workspace.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1549/1.0.1549.2680/${connection_ala_type}/icon.png'
      brandColor: '#0072C6'
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', regionOfResources, connection_ala_type)
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
  }
}

resource workflow_resource 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowName
  location: regionOfResources
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {
          }
          type: 'Object'
        }
      }
      triggers: {
        Recurrence: {
          recurrence: {
            frequency: 'Day'
            interval: 1
          }
          evaluatedRecurrence: {
            frequency: 'Day'
            interval: 1
          }
          type: 'Recurrence'
        }
      }
      actions: {
        For_each_Device: {
          foreach: '@variables(\'DeviceList\')'
          actions: {
            ListIntuneDevice: {
              runAfter: {
                ListUsers: [
                  'Succeeded'
                ]
              }
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  type: 'ManagedServiceIdentity'
                }
                method: 'GET'
                uri: 'https://graph.microsoft.com/beta/deviceManagement/managedDevices?$filter=azureADDeviceId eq \'@{items(\'For_each_Device\')?[\'deviceId\']}\''
              }
            }
            ListMemberships: {
              runAfter: {
              }
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  type: 'ManagedServiceIdentity'
                }
                method: 'GET'
                uri: 'https://graph.microsoft.com/v1.0/devices/@{items(\'For_each_Device\')?[\'id\']}/transitiveMemberOf?$select=id,displayName'
              }
            }
            ListUsers: {
              runAfter: {
                ListMemberships: [
                  'Succeeded'
                ]
              }
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  type: 'ManagedServiceIdentity'
                }
                method: 'GET'
                uri: 'https://graph.microsoft.com/v1.0/devices/@{items(\'For_each_Device\')?[\'id\']}/registeredUsers?$select=id,displayName,mail,userPrincipalName'
              }
            }
            Parse_IntuneDevice: {
              runAfter: {
                ListIntuneDevice: [
                  'Succeeded'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'ListIntuneDevice\')'
                schema: {
                  properties: {
                    '@@odata.context': {
                      type: 'string'
                    }
                    '@@odata.count': {
                      type: 'integer'
                    }
                    value: {
                      items: {
                        properties: {
                          activationLockBypassCode: {
                          }
                          androidSecurityPatchLevel: {
                            type: 'string'
                          }
                          azureADDeviceId: {
                            type: 'string'
                          }
                          azureADRegistered: {
                            type: 'boolean'
                          }
                          complianceGracePeriodExpirationDateTime: {
                            type: 'string'
                          }
                          complianceState: {
                            type: 'string'
                          }
                          configurationManagerClientEnabledFeatures: {
                          }
                          deviceActionResults: {
                            type: 'array'
                          }
                          deviceCategoryDisplayName: {
                            type: 'string'
                          }
                          deviceEnrollmentType: {
                            type: 'string'
                          }
                          deviceHealthAttestationState: {
                          }
                          deviceName: {
                            type: 'string'
                          }
                          deviceRegistrationState: {
                            type: 'string'
                          }
                          easActivated: {
                            type: 'boolean'
                          }
                          easActivationDateTime: {
                            type: 'string'
                          }
                          easDeviceId: {
                            type: 'string'
                          }
                          emailAddress: {
                            type: 'string'
                          }
                          enrolledDateTime: {
                            type: 'string'
                          }
                          ethernetMacAddress: {
                          }
                          exchangeAccessState: {
                            type: 'string'
                          }
                          exchangeAccessStateReason: {
                            type: 'string'
                          }
                          exchangeLastSuccessfulSyncDateTime: {
                            type: 'string'
                          }
                          freeStorageSpaceInBytes: {
                            type: 'integer'
                          }
                          iccid: {
                          }
                          id: {
                            type: 'string'
                          }
                          imei: {
                            type: 'string'
                          }
                          isEncrypted: {
                            type: 'boolean'
                          }
                          isSupervised: {
                            type: 'boolean'
                          }
                          jailBroken: {
                            type: 'string'
                          }
                          lastSyncDateTime: {
                            type: 'string'
                          }
                          managedDeviceName: {
                            type: 'string'
                          }
                          managedDeviceOwnerType: {
                            type: 'string'
                          }
                          managementAgent: {
                            type: 'string'
                          }
                          managementCertificateExpirationDate: {
                            type: 'string'
                          }
                          manufacturer: {
                            type: 'string'
                          }
                          meid: {
                            type: 'string'
                          }
                          model: {
                            type: 'string'
                          }
                          notes: {
                          }
                          operatingSystem: {
                            type: 'string'
                          }
                          osVersion: {
                            type: 'string'
                          }
                          partnerReportedThreatState: {
                            type: 'string'
                          }
                          phoneNumber: {
                            type: 'string'
                          }
                          physicalMemoryInBytes: {
                            type: 'integer'
                          }
                          remoteAssistanceSessionErrorDetails: {
                          }
                          remoteAssistanceSessionUrl: {
                          }
                          requireUserEnrollmentApproval: {
                          }
                          serialNumber: {
                            type: 'string'
                          }
                          subscriberCarrier: {
                            type: 'string'
                          }
                          totalStorageSpaceInBytes: {
                            type: 'integer'
                          }
                          udid: {
                          }
                          userDisplayName: {
                            type: 'string'
                          }
                          userId: {
                            type: 'string'
                          }
                          userPrincipalName: {
                            type: 'string'
                          }
                          wiFiMacAddress: {
                            type: 'string'
                          }
                        }
                        required: [
                          'id'
                          'userId'
                          'deviceName'
                          'managedDeviceOwnerType'
                          'enrolledDateTime'
                          'lastSyncDateTime'
                          'operatingSystem'
                          'complianceState'
                          'jailBroken'
                          'managementAgent'
                          'osVersion'
                          'easActivated'
                          'easDeviceId'
                          'easActivationDateTime'
                          'azureADRegistered'
                          'deviceEnrollmentType'
                          'activationLockBypassCode'
                          'emailAddress'
                          'azureADDeviceId'
                          'deviceRegistrationState'
                          'deviceCategoryDisplayName'
                          'isSupervised'
                          'exchangeLastSuccessfulSyncDateTime'
                          'exchangeAccessState'
                          'exchangeAccessStateReason'
                          'remoteAssistanceSessionUrl'
                          'remoteAssistanceSessionErrorDetails'
                          'isEncrypted'
                          'userPrincipalName'
                          'model'
                          'manufacturer'
                          'imei'
                          'complianceGracePeriodExpirationDateTime'
                          'serialNumber'
                          'phoneNumber'
                          'androidSecurityPatchLevel'
                          'userDisplayName'
                          'configurationManagerClientEnabledFeatures'
                          'wiFiMacAddress'
                          'deviceHealthAttestationState'
                          'subscriberCarrier'
                          'meid'
                          'totalStorageSpaceInBytes'
                          'freeStorageSpaceInBytes'
                          'managedDeviceName'
                          'partnerReportedThreatState'
                          'requireUserEnrollmentApproval'
                          'managementCertificateExpirationDate'
                          'iccid'
                          'udid'
                          'notes'
                          'ethernetMacAddress'
                          'physicalMemoryInBytes'
                          'deviceActionResults'
                        ]
                        type: 'object'
                      }
                      type: 'array'
                    }
                  }
                  type: 'object'
                }
              }
            }
            Send_Data: {
              runAfter: {
                Parse_IntuneDevice: [
                  'Succeeded'
                ]
              }
              type: 'ApiConnection'
              inputs: {
                body: '{\n"id":"@{items(\'For_each_Device\')?[\'id\']}",\n"AadDeviceId":"@{items(\'For_each_Device\')?[\'deviceId\']}",\n"IntuneDeviceId":"@{first(body(\'Parse_IntuneDevice\')?[\'value\'])?[\'id\']}",\n"lastMdmSync":"@{first(body(\'Parse_IntuneDevice\')?[\'value\'])?[\'lastSyncDateTime\']}",\n"serialNumber": "@{first(body(\'Parse_IntuneDevice\')?[\'value\'])?[\'serialNumber\']}",\n"deviceOwnership":"@{items(\'For_each_Device\')?[\'deviceOwnership\']}",\n"displayName":"@{items(\'For_each_Device\')?[\'displayName\']}",\n"enrollmentType":"@{items(\'For_each_Device\')?[\'enrollmentType\']}",\n"managementType":"@{items(\'For_each_Device\')?[\'managementType\']}",\n"manufacturer":"@{items(\'For_each_Device\')?[\'manufacturer\']}",\n"model":"@{items(\'For_each_Device\')?[\'model\']}",\n"operatingSystem":"@{items(\'For_each_Device\')?[\'operatingSystem\']}",\n"operatingSystemVersion":"@{items(\'For_each_Device\')?[\'operatingSystemVersion\']}",\n"trustType":"@{items(\'For_each_Device\')?[\'trustType\']}",\n"registrationDateTime":"@{items(\'For_each_Device\')?[\'registrationDateTime\']}",\n"enrollementProfileName":"@{items(\'For_each_Device\')?[\'enrollmentProfileName\']}",\n"onPremiseSyncEnabled":"@{items(\'For_each_Device\')?[\'onPremisesSyncEnabled\']}",\n"sourceType":"@{items(\'For_each_Device\')?[\'sourceType\']}",\n"accountEnabled":"@{items(\'For_each_Device\')?[\'accountEnabled\']}",\n"isCompliant":"@{items(\'For_each_Device\')?[\'isCompliant\']}",\n"isManaged":"@{items(\'For_each_Device\')?[\'isManaged\']}",\n"GroupMemberships":@{body(\'ListMemberships\')?[\'value\']},\n"DeviceUsers":@{body(\'ListUsers\')?[\'value\']}\n}'
                headers: {
                  'Log-Type': 'ExtendedDeviceInfo'
                  'time-generated-field': '@{utcNow()}'
                }
                host: {
                  connection: {
                    name: '@parameters(\'$connections\')[\'azureloganalyticsdatacollector\'][\'connectionId\']'
                  }
                }
                method: 'post'
                path: '/api/logs'
              }
            }
          }
          runAfter: {
            Request_AadDevice_and_Handle_Paging: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        Initialize_DeviceList: {
          runAfter: {
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'DeviceList'
                type: 'array'
              }
            ]
          }
        }
        Initialize_LoopDone: {
          runAfter: {
            Initialize_DeviceList: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'LoopDone'
                type: 'boolean'
                value: '@false'
              }
            ]
          }
        }
        Initialize_NextLink: {
          runAfter: {
            Initialize_LoopDone: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'NextLink'
                type: 'string'
              }
            ]
          }
        }
        Initialize_variable_Memberships: {
          runAfter: {
            Initialize_NextLink: [
              'Succeeded'
            ]
          }
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'Memberships'
                type: 'string'
              }
            ]
          }
        }
        Request_AadDevice_and_Handle_Paging: {
          actions: {
            Initial_AadDevices_Request_Processing: {
              foreach: '@body(\'List_AadDevices\')?[\'value\']'
              actions: {
                Append_to_DeviceList: {
                  runAfter: {
                  }
                  type: 'AppendToArrayVariable'
                  inputs: {
                    name: 'DeviceList'
                    value: '@items(\'Initial_AadDevices_Request_Processing\')'
                  }
                }
              }
              runAfter: {
                List_AadDevices: [
                  'Succeeded'
                ]
              }
              type: 'Foreach'
            }
            Is_there_a_second_page: {
              actions: {
                Set_NextLink: {
                  runAfter: {
                  }
                  type: 'SetVariable'
                  inputs: {
                    name: 'NextLink'
                    value: '@{decodeUriComponent(body(\'List_AadDevices\')?[\'@odata.nextLink\'])}'
                  }
                }
                Until: {
                  actions: {
                    Is_there_another_page: {
                      actions: {
                        Set_variable: {
                          runAfter: {
                          }
                          type: 'SetVariable'
                          inputs: {
                            name: 'NextLink'
                            value: '@{decodeUriComponent(body(\'List_AadDevices_2\')?[\'@odata.nextLink\'])}'
                          }
                        }
                      }
                      runAfter: {
                        Pages_AadDevices_Request_Processing: [
                          'Succeeded'
                        ]
                      }
                      else: {
                        actions: {
                          Set_variable_2: {
                            runAfter: {
                            }
                            type: 'SetVariable'
                            inputs: {
                              name: 'LoopDone'
                              value: '@true'
                            }
                          }
                        }
                      }
                      expression: {
                        and: [
                          {
                            contains: [
                              '@string(body(\'List_AadDevices_2\'))'
                              'odata.nextLink'
                            ]
                          }
                        ]
                      }
                      type: 'If'
                    }
                    List_AadDevices_2: {
                      runAfter: {
                      }
                      type: 'Http'
                      inputs: {
                        authentication: {
                          audience: 'https://graph.microsoft.com'
                          type: 'ManagedServiceIdentity'
                        }
                        method: 'GET'
                        uri: '@variables(\'NextLink\')'
                      }
                    }
                    Pages_AadDevices_Request_Processing: {
                      foreach: '@body(\'List_AadDevices_2\')?[\'value\']'
                      actions: {
                        Append_to_DeviceList_2: {
                          runAfter: {
                          }
                          type: 'AppendToArrayVariable'
                          inputs: {
                            name: 'DeviceList'
                            value: '@items(\'Pages_AadDevices_Request_Processing\')'
                          }
                        }
                      }
                      runAfter: {
                        List_AadDevices_2: [
                          'Succeeded'
                        ]
                      }
                      type: 'Foreach'
                    }
                  }
                  runAfter: {
                    Set_NextLink: [
                      'Succeeded'
                    ]
                  }
                  expression: '@equals(variables(\'LoopDone\'), true)'
                  limit: {
                    count: 60
                    timeout: 'PT1H'
                  }
                  type: 'Until'
                }
              }
              runAfter: {
                Initial_AadDevices_Request_Processing: [
                  'Succeeded'
                ]
              }
              expression: {
                and: [
                  {
                    contains: [
                      '@string(body(\'List_AadDevices\'))'
                      'odata.nextLink'
                    ]
                  }
                ]
              }
              type: 'If'
            }
            List_AadDevices: {
              runAfter: {
              }
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com'
                  type: 'ManagedServiceIdentity'
                }
                method: 'GET'
                uri: 'https://graph.microsoft.com/v1.0/devices'
              }
            }
          }
          runAfter: {
            Initialize_variable_Memberships: [
              'Succeeded'
            ]
          }
          type: 'Scope'
        }
      }
      outputs: {
      }
    }
    parameters: {
      '$connections': {
        value: {
          azureloganalyticsdatacollector: {
            connectionId: connectionLaName_resource.id
            connectionName: connection_ala_type
            id: '${subscription().id}/providers/Microsoft.Web/locations/westeurope/managedApis/azureloganalyticsdatacollector'
          }
        }
      }
    }
  }
}
