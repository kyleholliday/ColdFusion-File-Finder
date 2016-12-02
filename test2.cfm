<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">

<cfsetting requestTimeOut="3000">

<cffunction name="SearchFiles" access="public" returntype="array" output="false" hint="Searchs files for the given values. Returns an array of file paths.">

  <!--- Define arguments. --->
  <cfargument name="Path" type="any" required="true" hint="This is either a directory path or an array of file paths which we will be searching."/>

  <cfargument name="Criteria" type="string" required="true" hint="The values for which we are searching the file contents."/>

  <cfargument name="Filter" type="string" required="false" default="cfm,cfc,css,htm,html,js,txt,xml" hint="List of file extensions that we are going to allow."/>

  <cfargument name="IsRegex" type="boolean" required="false" default="false" hint="Flags whether or not the search criteria is a regular expression."/>

  <!--- Define the local scope. --->

  <cfset var LOCAL=StructNew()/>

  <!--- Check to see if we are dealing with a directory path. If we are, we are going to want to get those paths and convert it to an array of file paths. --->
  
  <cfif IsSimpleValue( ARGUMENTS.Path )>
    <cfset pathName=#ARGUMENTS.Path#>

    <!--- Get all the files in the given directory. We are going to ensure that only files are returned in the resultant query. We don't want to deal with any directories. --->

    <cfdirectory action="LIST" directory="#ARGUMENTS.Path#" name="LOCAL.FileQuery" filter="*.*" recurse="true"/>

    <!--- Now that we have the query, we want to create an array of the file names. --->

    <cfset LOCAL.Paths=ArrayNew( 1 )/>

    <!--- Loop over the query and set up the values. --->

    <cfloop query="LOCAL.FileQuery">

      <cfset ArrayAppend( LOCAL.Paths, (LOCAL.FileQuery.directory & "\" & LOCAL.FileQuery.name) )/>

    </cfloop>

  <cfelse>

    <!--- For consistency sake, just store the path argument into our local paths value so that we can refer to this and the query-route the same way (see above). --->

    <cfset LOCAL.Paths=ARGUMENTS.Path/>

  </cfif>

  <!--- ASSERT: At this point, whether we were passed in a directory path or an array of file paths, we now have an array of file paths that we are going to search in the variable LOCAL.Paths. --->

  <!--- Create an array in which we will store the file paths that had matching criteria. --->

  <cfset LOCAL.MatchingPaths=ArrayNew( 1 )/>

  <!--- Clean up the filter to be used in a regular expression. We are going to turn the list into an OR reg ex. --->

  <cfset ARGUMENTS.Filter=ARGUMENTS.Filter.ReplaceAll( "[^\w\d,]+", "" ).ReplaceAll( ",", "|" )/>

  <!--- Loop over the file paths in our paths array. --->

  <cfloop index="LOCAL.PathIndex" from="1" to="#ArrayLen( LOCAL.Paths )#" step="1">

    <!--- Get a short hand to the current path. This is not necessary but just makes referencing the path easier. --->

    <cfset LOCAL.Path=LOCAL.Paths[ LOCAL.PathIndex ]/>

    <!--- Check to see if this file path is allowed. Either we have no file filters or we do and this file has one of them. --->

    <cfif ( (NOT Len( ARGUMENTS.Filter )) OR ( REFindNoCase( "(#ARGUMENTS.Filter#)$", LOCAL.Path ) ))>

      <!--- This is a file that we can use. Read in the contents of the file. --->

      <cffile action="READ" file="#LOCAL.Path#" variable="LOCAL.FileData"/>

      <!--- Check to see what kind of search we are doing. Is it a straight-up value search or is it a regular expression search? --->

      <cfif ( ( ARGUMENTS.IsRegex AND REFindNoCase( ARGUMENTS.Criteria, LOCAL.FileData ) ) OR ( (NOT ARGUMENTS.IsRegex) AND FindNoCase( ARGUMENTS.Criteria, LOCAL.FileData ) ) )>

        <!---This is a good file path. Add it to the list of successful file paths.--->

        <cfset ArrayAppend( LOCAL.MatchingPaths, LOCAL.Path )/>
        <cfset crit=ARGUMENTS.Criteria>
      </cfif>

    </cfif>

  </cfloop>

  <!--- Return the array of matching file paths. --->

  <cfreturn LOCAL.MatchingPaths/>

</cffunction>

<cfset arrMatchingPaths=SearchFiles( Path = ExpandPath( "../" ), Criteria = "blue" )/>
<div>

<cfif IsDefined("crit")>

      <cfoutput>
        <h3 style="padding:20px;">The criteria "<b>#crit#</b>" is located in
          <b>#ArrayLen(arrMatchingPaths)#</b>
          files in the
          <b>#pathName#</b>
          directory:</h3>
      </cfoutput>

      <table class="table table-striped table-hover table-condensed">

        <thead>
          <tr>
            <th></th>
            <th>File Name</th>
          </tr>
        </thead>

        <tbody>
          <cfloop index="name" array="#arrMatchingPaths#">
            <tr>
              <th scope="row"></th>
              <td>
                <cfoutput>
                  #name#
                </cfoutput>
              </td>
            </cfloop>
          </tr>
        </tbody>

      </table>

    <cfelse>
      <h3 style="padding:20px;">Sorry! That criteria does not exist in the specified directory</h3>

    </cfif>
</div>
