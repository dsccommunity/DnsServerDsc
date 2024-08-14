@{
    PSDependOptions                = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild                    = 'latest'
    PSScriptAnalyzer               = 'latest'
    ConvertToSARIF                 = 'latest' # cSpell: disable-line
    Pester                         = 'latest'
    Plaster                        = 'latest'
    ModuleBuilder                  = 'latest'
    ChangelogManagement            = 'latest'
    Sampler                        = 'latest'
    'Sampler.GitHubTasks'          = 'latest'
    MarkdownLinkCheck              = 'latest'
    'DscResource.Test'             = 'latest'
    xDscResourceDesigner           = 'latest'

    # Build dependent modules
    'DscResource.Base'             = 'latest'
    'DscResource.Common'           = 'latest'

    'DscResource.AnalyzerRules'    = 'latest'
    'Indented.ScriptAnalyzerRules' = 'latest'

    # Prerequisite modules for documentation.
    'DscResource.DocGenerator'     = 'latest'
    PlatyPS                        = 'latest'
}
