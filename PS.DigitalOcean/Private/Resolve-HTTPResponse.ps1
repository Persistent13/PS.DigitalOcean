function Resolve-HTTPResponse
{
<#
.Synopsis
    The Resolve-HTTPResponse cmdlet will convert an HTTP Response into a string.
.DESCRIPTION
    The Resolve-HTTPResponse cmdlet will convert an HTTP Response into a string.
    The HTTP Response must be passed as a System.Net.HttpWebResponse object.

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
        # Resolve the HTTP byte Response into a useable string.
        Resolve-HTTPResponse -Response $_.Exception.Response
    }
    {"id":"unauthorized","message":"Unable to authenticate you."}

    The script block above attempts to access an RESTful endpoint while un-authenticated returning a 403 status that causes
    Invoke-RestMethod to throw an error that is handled by Resolve-HTTPResponse which returns the Response in a string.
.INPUTS
    System.Net.HttpWebResponse[]

        This cmdlet can take the System.Net.HttpWebResponse as an array.
.OUTPUTS
    System.String

        A string that holdes the HTTP Response is returned.
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
    [CmdletBinding(PositionalBinding=$true)]
    [OutputType([String])]
    Param
    (
        # The HTTP byte Response to read.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Net.HttpWebResponse[]]$Response
    )

    Process
    {
        foreach($res in $Response)
        {
            $reader = [IO.StreamReader]::New($res.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            [string]$resBody = $reader.ReadToEnd()
            Write-Output $resBody
        }
    }
}