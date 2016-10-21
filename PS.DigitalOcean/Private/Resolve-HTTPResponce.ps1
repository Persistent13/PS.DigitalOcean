function Resolve-HTTPResponce
{
<#
.Synopsis
    The Resolve-HTTPResponce cmdlet will convert an HTTP responce into a string.
.DESCRIPTION
    The Resolve-HTTPResponce cmdlet will convert an HTTP responce into a string.
    The HTTP responce must be passed as a System.Net.HttpWebResponse object.

    This module is primary designed for handling REST API error data that Invoke-RestMethod
    and Invoke-WebRequest normally make difficult to access.
.EXAMPLE
    #
    try
    {
        # An un-authenticated API request
        Invoke-RestMethod -Uri 'https://api.bad-auth.com/endpoint'
    }
    catch
    {
        # Resolve the HTTP byte responce into a useable string.
        Resolve-HTTPResponce -Responce $_.Exception.Response
    }
    {"id":"unauthorized","message":"Unable to authenticate you."}

    The script block above attempts to access an RESTful endpoint while un-authenticated returning a 403 status that causes
    Invoke-RestMethod to throw an error that is handled by Resolve-HTTPResponce which returns the responce in a string.
.INPUTS
    System.Net.HttpWebResponse[]

        This cmdlet can take the System.Net.HttpWebResponse as an array.
.OUTPUTS
    System.String

        A string that holdes the HTTP responce is returned.
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
    [CmdletBinding(PositionalBinding=$true)]
    [OutputType([String])]
    Param
    (
        # The HTTP byte responce to read.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Net.HttpWebResponse[]]$Responce
    )

    Process
    {
        foreach($res in $Responce)
        {
            $reader = [IO.StreamReader]::New($res.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            [string]$resBody = $reader.ReadToEnd()
            Write-Output $resBody
        }
    }
}